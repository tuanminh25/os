The BSS section is a special memory section in programs that holds uninitialized or zero-initialized global and static variables. Its name comes from “Block Started by Symbol”, a historical term from early UNIX linkers.

Here’s what you need to know, step by step:

1. What goes in BSS

Any global or static variable that is declared but not explicitly initialized goes into BSS. For example:

int counter;       // goes into .bss
static int flag;   // goes into .bss


Variables that are explicitly initialized to zero also go in BSS:

int buffer[1024] = {0}; // goes into .bss


But variables initialized to non-zero values go into the .data section.