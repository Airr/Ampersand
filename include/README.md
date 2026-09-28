# Ampersand Header / Include Files

This directory contains the assembly include definition files (`.inc`) for building applications with the **Ampersand** runtime and standard library using **UASM** on **Linux x86-64**.

---

## Files Overview

| File | Description |
| :--- | :--- |
| [`amp.inc`](amp.inc) | Main Ampersand library header. Contains UASM configuration, helper macros, function prototypes, and the optional program entry point (`_start` &rarr; `main`). |
| [`syscall.inc`](syscall.inc) | Comprehensive Linux x86-64 system call definitions, standard file descriptors, open/mmap flags, seek modes, and POSIX signal numbers. |

---

## 1. `amp.inc`

The primary interface definition file for the Ampersand static library (`libamp.a`).

### Key Components

- **UASM Directives & Stack Hardening**:
  - Sets `OPTION LITERALS:ON`, `option casemap:none`, and `option frame:auto`.
  - Configures `.note.GNU-stack` to ensure non-executable stack markings for compatibility with modern Linux linkers.

- **Utility Macros**:
  - `assign dest, func, args...`: Calls an Ampersand function and stores `rax` into `dest`.
  - `FCALL target, targs...`: Aligns the stack by 8 bytes before invoking `call`, restoring stack alignment afterwards.
  - `LIBCALL func, args...`: Wrapper around `invoke`.

- **Function Prototypes**:
  - Full prototypes for all Ampersand standard library routines including Arena memory management (`ALLOC`, `MEM_ALLOC`), string processing (`LEFT$`, `MID$`, `CONCAT$`, `SPLIT$`, etc.), file I/O (`LOADFILE$`, `SAVEFILE`, `OPEN`, `READ`, `WRITE$`), formatting/console (`PRINT`, `SPRINT`, `INPUT$`), and system operations (`SHELL`, `ENV$`, `COMMAND$`).

- **Entry Point & Runtime Initialization (`AMP_MAIN`)**:
  When defining `AMP_MAIN` before including `amp.inc`, the file generates the standard Linux `_start` entry point:
  - Captures command-line arguments and environment: `g_argc` (`rdi`), `g_argv` (`rsi`), and `g_envp` (`rdx`).
  - Aligns the stack to a 16-byte boundary.
  - Automatically transfers execution to your `main` procedure using System V AMD64 ABI conventions.
  - If `AMP_MAIN` is not defined, global variables (`arena`, `g_argc`, `g_argv`, `g_envp`, `NULL`) are declared as `EXTERNDEF`.

---

## 2. `syscall.inc`

A standalone definitions file for direct Linux 64-bit kernel system calls (`syscall`).

### Constants Provided

- **Standard I/O Descriptors**: `STDIN` (0), `STDOUT` (1), `STDERR` (2)
- **Syscall Numbers**: Complete mapping for x86-64 Linux syscalls (`SYS_READ`, `SYS_WRITE`, `SYS_OPEN`, `SYS_CLOSE`, `SYS_MMAP`, `SYS_MUNMAP`, `SYS_FORK`, `SYS_EXECVE`, `SYS_EXIT`, etc.)
- **File Access & Open Flags**: `O_RDONLY`, `O_WRONLY`, `O_RDWR`, `O_CREAT`, `O_TRUNC`, `O_APPEND`, file permissions (`S_IRUSR`, `S_IWUSR`, etc.)
- **Memory Protection & Mapping Flags**: `PROT_READ`, `PROT_WRITE`, `PROT_EXEC`, `MAP_SHARED`, `MAP_PRIVATE`, `MAP_ANONYMOUS`
- **Seek Modes**: `SEEK_SET`, `SEEK_CUR`, `SEEK_END`
- **Signal Constants**: Standard Linux signals (`SIGINT`, `SIGKILL`, `SIGSEGV`, `SIGTERM`, etc.)

---

## Usage Example

### 1. Minimal Application (`hello.asm`)

```assembly
AMP_MAIN equ 1
include amp.inc

.code
main proc
    PRINT "Hello, %s!\n", "Ampersand"
    xor     rax, rax
    ret
main endp
end
```

### 2. Building with UASM and Linker

```bash
# Assemble with include path pointing to where headers are located
uasm -elf64 -q -zcw -I/usr/local/include -Fo hello.o hello.asm

# Link against libamp.a
ld hello.o /usr/local/lib/libamp.a -o hello -s -no-pie -e _start
```

---

## Installation

When running `sudo make install` from the repository root:
- `amp.inc` and `syscall.inc` are copied to `/usr/local/include/` (or `$(PREFIX)/include`).
- `libamp.a` is copied to `/usr/local/lib/` (or `$(PREFIX)/lib`).
