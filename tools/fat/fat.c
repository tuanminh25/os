/*
* This file would "read" valuable information from image disk 
* to construct a file system accordingly to FAT12
*/ 

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef uint8_t bool;
#define true 1
#define false 0

/*
Fat 12 definition

BootSector

The boot sector is the first sector of a disk or partition. It's crucial because:

1. It's loaded first when the system boots
2. It contains critical metadata about the filesystem structure
3. Its layout is fixed - the exact order and size of fields is defined by the FAT specification

*/
typedef struct 
{
    uint8_t BootJumpInstruction[3];     // First 3 bytes containing jump code to the boot code
    uint8_t OemIdentifier[8];           // 8-byte string identifying the formatting system
    uint16_t BytesPerSector;            // Number of bytes in each sector (typically 512)
    uint8_t SectorsPerCluster;          // Number of sectors in a cluster (allocation unit)
    uint16_t ReservedSectors;           // Number of reserved sectors before FAT begins
    uint8_t FatCount;                   // Number of FAT copies (typically 2 for redundancy)
    uint16_t DirEntryCount;             // Maximum number of root directory entries
    uint16_t TotalSectors;              // Total sectors in the volume (if < 65535)
    uint8_t MediaDescriptorType;        // Type of media (e.g., fixed or removable)
    uint16_t SectorsPerFat;             // Number of sectors each FAT occupies
    uint16_t SectorsPerTrack;           // Number of sectors per track (for CHS addressing)
    uint16_t Heads;                     // Number of heads/sides (for CHS addressing)
    uint32_t HiddenSectors;             // Number of hidden sectors before partition
    uint32_t LargeSectorCount;          // Total sectors if TotalSectors is 0 (large volumes)

    // extended boot record
    uint8_t DriveNumber;                // BIOS drive number (0x00 for floppy, 0x80 for hard disk)
    uint8_t _Reserved;                  // Reserved byte, unused
    uint8_t Signature;                  // Extended boot signature (should be 0x29)
    uint32_t VolumeId;                  // Volume serial number, value doesn't matter
    uint8_t VolumeLabel[11];            // 11 bytes volume name, padded with spaces
    uint8_t SystemId[8];                // 8 bytes filesystem type, e.g. "FAT12   "

} __attribute__((packed)) BootSector;


/*
Directory Entry
This represents a single directory entry (file or subdirectory) in the FAT filesystem,
not the beginning of the directory itself

The directory is actually a contiguous collection of these 32-byte directory entries

Technically, directory entries are just metadata structures that point to actual data

In FAT12: 
1. A directory entry is a 32 - byte record containing metadata about file or subdirectory
2. The key part is FirstClusterLow filed, which points to the first cluster where the actual
data begin
3. The actual file data is stored in clusters in data region of the disk
4. To read a complete file, folow the cluster chain through File Allocation Table (FAT)

*/
typedef struct 
{
    uint8_t Name[11];                   // 8.3 filename format (8 chars name + 3 chars extension)
    uint8_t Attributes;                 // File attributes (read-only, hidden, system, etc.)
    uint8_t _Reserved;                  // Reserved byte, unused
    uint8_t CreatedTimeTenths;          // Tenths of seconds for file creation time (0-199)
    uint16_t CreatedTime;               // Time file was created (encoded time format)
    uint16_t CreatedDate;               // Date file was created (encoded date format)
    uint16_t AccessedDate;              // Date file was last accessed
    uint16_t FirstClusterHigh;          // High 16 bits of first cluster (FAT32 only, 0 for FAT12/16)
    uint16_t ModifiedTime;              // Time file was last modified
    uint16_t ModifiedDate;              // Date file was last modified
    uint16_t FirstClusterLow;           // Low 16 bits of first cluster number
    uint32_t Size;                      // File size in bytes
} __attribute__((packed)) DirectoryEntry;


BootSector g_BootSector;
uint8_t* g_Fat = NULL;
DirectoryEntry* g_RootDirectory = NULL;
uint32_t g_RootDirectoryEnd;

/*
* Reads the boot sector from the beginning of the disk into the global g_BootSector structure.
* Returns true if at least one item was read, false if the read failed.
*/
bool readBootSector(FILE* disk)
{
    return fread(&g_BootSector, sizeof(g_BootSector), 1, disk) > 0;
}

/*
* Reads a specified number of sectors from a given location on the disk.
* Parameters:
*   disk - File pointer to the disk image
*   lba - Logical Block Address (starting sector number)
*   count - Number of sectors to read
*   bufferOut - Memory buffer where the read data will be stored
* Returns true only if both seek and read operations succeed completely.
*/
bool readSectors(FILE* disk, uint32_t lba, uint32_t count, void* bufferOut)
{
    bool ok = true;
    ok = ok && (fseek(disk, lba * g_BootSector.BytesPerSector, SEEK_SET) == 0);
    ok = ok && (fread(bufferOut, g_BootSector.BytesPerSector, count, disk) == count);
    return ok;
}

/*
* Allocates memory for and reads the File Allocation Table (FAT) from the disk.
* The FAT starts after the reserved sectors and contains the cluster chain information.
* Returns true if the FAT was successfully read.
*/
bool readFat(FILE* disk)
{
    g_Fat = (uint8_t*) malloc(g_BootSector.SectorsPerFat * g_BootSector.BytesPerSector);
    return readSectors(disk, g_BootSector.ReservedSectors, g_BootSector.SectorsPerFat, g_Fat);
}

/*
* Read root directory entries from the disk
*/
bool readRootDirectory(FILE* disk)
{
    uint32_t lba = g_BootSector.ReservedSectors + g_BootSector.SectorsPerFat * g_BootSector.FatCount;
    uint32_t size = sizeof(DirectoryEntry) * g_BootSector.DirEntryCount;
    uint32_t sectors = (size / g_BootSector.BytesPerSector);
    if (size % g_BootSector.BytesPerSector > 0)
        sectors++;

    g_RootDirectoryEnd = lba + sectors;
    g_RootDirectory = (DirectoryEntry*) malloc(sectors * g_BootSector.BytesPerSector);
    return readSectors(disk, lba, sectors, g_RootDirectory);
}

/*
 * Searches for a file in the root directory by name.
 * Parameters:
 *   name - 11-byte file name in 8.3 format (padded with spaces if needed)
 * Returns:
 *   Pointer to the directory entry if found, NULL otherwise
 */
DirectoryEntry* findFile(const char* name)
{
    for (uint32_t i = 0; i < g_BootSector.DirEntryCount; i++)
    {
        if (memcmp(name, g_RootDirectory[i].Name, 11) == 0)
            return &g_RootDirectory[i];
    }

    return NULL;
}

/*
 * Reads the contents of a file from disk following the FAT cluster chain.
 * Parameters:
 *   fileEntry - Pointer to the directory entry of the file to read
 *   disk - File pointer to the disk image
 *   outputBuffer - Buffer where file contents will be stored
 * Returns:
 *   true if the file was read successfully, false otherwise
 */
bool readFile(DirectoryEntry* fileEntry, FILE* disk, uint8_t* outputBuffer)
{
    bool ok = true;
    uint16_t currentCluster = fileEntry->FirstClusterLow;

    do {
        uint32_t lba = g_RootDirectoryEnd + (currentCluster - 2) * g_BootSector.SectorsPerCluster;
        ok = ok && readSectors(disk, lba, g_BootSector.SectorsPerCluster, outputBuffer);
        outputBuffer += g_BootSector.SectorsPerCluster * g_BootSector.BytesPerSector;

        uint32_t fatIndex = currentCluster * 3 / 2;
        if (currentCluster % 2 == 0)
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) & 0x0FFF;
        else
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) >> 4;

    } while (ok && currentCluster < 0x0FF8);

    return ok;
}

int main(int argc, char** argv)
{
    if (argc < 3) {
        printf("Syntax: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb");
    if (!disk) {
        fprintf(stderr, "Cannot open disk image %s!\n", argv[1]);
        return -1;
    }

    if (!readBootSector(disk)) {
        fprintf(stderr, "Could not read boot sector!\n");
        return -2;
    }

    if (!readFat(disk)) {
        fprintf(stderr, "Could not read FAT!\n");
        free(g_Fat);
        return -3;
    }

    if (!readRootDirectory(disk)) {
        fprintf(stderr, "Could not read FAT!\n");
        free(g_Fat);
        free(g_RootDirectory);
        return -4;
    }

    DirectoryEntry* fileEntry = findFile(argv[2]);
    if (!fileEntry) {
        fprintf(stderr, "Could not find file %s!\n", argv[2]);
        free(g_Fat);
        free(g_RootDirectory);
        return -5;
    }

    uint8_t* buffer = (uint8_t*) malloc(fileEntry->Size + g_BootSector.BytesPerSector);
    if (!readFile(fileEntry, disk, buffer)) {
        fprintf(stderr, "Could not read file %s!\n", argv[2]);
        free(g_Fat);
        free(g_RootDirectory);
        free(buffer);
        return -5;
    }

    for (size_t i = 0; i < fileEntry->Size; i++)
    {
        if (isprint(buffer[i])) fputc(buffer[i], stdout);
        else printf("<%02x>", buffer[i]);
    }
    printf("\n");

    free(buffer);
    free(g_Fat);
    free(g_RootDirectory);
    return 0;
}