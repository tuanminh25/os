# FLOW OS
An x86 operating system project designed for QEMU emulation (for now). This personal project represents my development journey in OS internals, built from scratch to understand low-level system operations.

Project Goals:

- Create a functioning bootable system

- Achieve easy installation process

- Maintain lightweight performance

- Ensure high compatibility with hardware

- Develop robust driver support

- Distribute as open-source software

- "FLOW" - optimize for fast, smooth experience 

## Current Development Focus

**FAT12 Filesystem Implementation** - Learning and implementing disk operations for this simple filesystem format, which serves as a foundation for storage management.

For now, FAT12 in c has been working, the following step is how to test fat.c 

## Installation
1. Git clone
```
git clone git@github.com:tuanminh25/os.git
```


2. Build the program by running : 

```
make
```

from the root folder of project.

3. Run test for fat.c by runing:

```
./build/tools/fat ./build/main_floppy.img "TEST    TXT"
```

## Extra tools development

- I plan to implement a memory allocation simulator once we reach to the point of managing memory.  

## Current state of FLOW OS via qemu emulator:

![Hello OS Screenshot](pics/helloOS.png)

## Contributions

This project can serve as an educational resource for others learning OS development.

Thanks to NANOBYTE for providing the inspiration and tutorials that made this project possible.
