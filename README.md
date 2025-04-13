# FLOW OS

This is an operating system project targeting the x86 architecture, designed to run in the QEMU emulator.

This personal project represents both my development work and learning journey in OS internals. I'm building it from scratch to gain deep understanding of low-level system operations.

## Current Development Focus

**FAT12 Filesystem Implementation** - Learning and implementing disk operations for this simple filesystem format, which serves as a foundation for storage management.

For now, FAT12 in c has been working, here is how to test fat.c 

From the root folder of project,
1. Build the program by running: 

```
make
```


2. Run test for fat.c by runing:
```
./build/tools/fat ./build/main_floppy.img "TEST    TXT"
```



Current state of FLOW OS via qemu emulator:

![Hello OS Screenshot](pics/helloOS.png)

## Contributions

This project can serve as an educational resource for others learning OS development.

Thanks to NANOBYTE for providing the inspiration and tutorials that made this project possible.