# amp — Ampersand Build Driver CLI

`amp` is a lightweight command-line build driver written in x86_64 assembly using the Ampersand standard library. It streamlines the assembly and linking workflow for applications written with **UASM** and **Ampersand** on 64-bit Linux.

---

## Overview

Instead of manually invoking `uasm` and configuring linker arguments for `ld` or `gcc`, `amp` automates the entire process:

1. **Source Resolution**: Accepts source filenames with or without the `.asm` extension.
2. **Toolchain Discovery**: Dynamically resolves paths to `uasm`, `ld`, and `gcc` via system `PATH`.
3. **Assembly**: Assembles 64-bit ELF object files using UASM with the default include path `/usr/local/include`.
4. **Linking**: Links the generated object file with `/usr/local/lib/libamp.a` using either `ld` (standalone) or `gcc` (with `libdl` and custom linker flags).
5. **Cleanup**: Automatically removes temporary `.o` object files upon successful executable generation.

---

## Prerequisites

Before using or building `amp`, ensure the following are installed:
- **[UASM](https://www.terraspace.co.uk/uasm.html)** in your system `PATH`
- **Linker / Toolchain**: `ld` (GNU binutils) and/or `gcc`
- **Ampersand Library**: Installed to `/usr/local/lib/libamp.a` and headers in `/usr/local/include`

---

## Building `amp`

Build the `amp` binary using `make`:

```bash
cd amp
make
```

To clean build artifacts:
```bash
make clean
```

---

## Usage

```bash
amp <filename> [gcc] [gcc_options]
```

### Examples

#### 1. Default Build (`ld`)
Assembles `<filename>.asm` and links using `ld` against `libamp.a`:
```bash
amp myapp
```
*(Assembles `myapp.asm` into `myapp.o`, links into executable `myapp`, and deletes `myapp.o`)*

#### 2. Build with GCC & Dynamic Linking
Assembles `<filename>.asm` and links using `gcc` (linking with `-ldl`):
```bash
amp myapp gcc
```

#### 3. Build with GCC and Custom Linker Options
Pass extra options or additional libraries through GCC:
```bash
amp myapp gcc "-lm -lpthread"
```

---

## Build Pipeline Details

- **Assembler Command**:
  ```bash
  uasm -elf64 -q -zcw -I/usr/local/include -Fo <name>.o <name>.asm
  ```

- **Linker Command (`ld` Mode)**:
  ```bash
  ld <name>.o /usr/local/lib/libamp.a -o <name> -s -no-pie -e _start
  ```

- **Linker Command (`gcc` Mode)**:
  ```bash
  gcc <name>.o -o <name> /usr/local/lib/libamp.a -ldl <options> -no-pie -s -Wl,--as-needed -nostartfiles -Wl,-e,_start
  ```

---

## Source Structure

- **[`amp.asm`](amp.asm)**: Main program driver demonstrating the use of Ampersand library functions (`CMDCOUNT`, `COMMAND$`, `COMPARE`, `EXTRACT$`, `CONCAT$`, `WHERE$`, `PRINT`, `SPRINT`, `SHELL`, `EXIST`, `KILL`, `EXIT`).
- **[`Makefile`](Makefile)**: Makefile to assemble and link `amp` into an executable.
