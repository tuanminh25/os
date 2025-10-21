Different environment to compile and run code in Window

| Environment    | Compiler    | C Runtime     | Target        | Recommended for         |
| -------------- | ----------- | ------------- | ------------- | ----------------------- |
| **MSYS**       | POSIX shell | MSYS          | Tools only    | Running `pacman`, setup |
| **MINGW64**    | GCC         | MSVCRT (old)  | Win7+         | Compatibility builds    |
| **UCRT64**     | GCC         | UCRT (modern) | Win8.1+ / 10+ | Modern native builds    |
| **CLANG64**    | LLVM Clang  | UCRT          | Win10+        | MSVC-compatible builds  |
| **CLANGARM64** | LLVM Clang  | UCRT          | ARM64 Win10+  | ARM64 builds            |

Decision: choose MSYS2 UCRT64 because it is most stable, modern, compatible with Win 10/11 with lastest C runtime (UCRT) 

which is great for compiling and running tools like QEMU 