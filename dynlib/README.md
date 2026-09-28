# Dynamic Library Loading (`dynlib`)

This folder contains an example and reference implementation demonstrating **runtime dynamic library loading** in 64-bit Linux x86_64 assembly for **UASM**, using the **Ampersand** standard library.

---

## Overview

Ampersand provides high-level assembly wrappers around the Linux dynamic linking interface (`libdl`):

- **`LOADLIB(filename:ptr)`**: Dynamically loads a shared library (`.so`) at runtime using `dlopen` (`RTLD_LAZY`).
- **`LOADFUNC(libHandle:qword, funcName:ptr)`**: Resolves and returns the memory address of an exported function symbol using `dlsym`.
- **`FREELIB(libHandle:qword)`**: Unloads the shared library and releases resources using `dlclose`.

---

## Example Walkthrough (`dynlib.asm`)

The included example demonstrates loading the Linux standard C math library (`libm.so.6`), resolving its `cos` function, invoking it dynamically with floating-point parameters, and printing the result:

```assembly
AMP_MAIN = 1
include amp.inc

.code
main proc argc:qword, argv:ptr
    local lib:qword, cosine:qword

    ; 1. Load the shared math library
    mov     lib, LOADLIB("libm.so.6")

    .if lib
        ; 2. Resolve the function pointer for 'cos'
        mov     cosine, LOADFUNC(lib, "cos")

        ; 3. Prepare arguments and call the dynamically resolved function
        LOADSD  xmm0, 1.0           ; Load double 1.0 into xmm0
        call    cosine              ; Invoke cos(1.0) -> result in xmm0

        ; 4. Format and print the result
        PRINT("cos(1.0) = '%s'\n", STRL$(xmm0))

        ; 5. Unload the library
        FREELIB(lib)
    .endif

    EXIT(0)
main endp
end
```

---

## Prerequisites & Linking Requirements

Because dynamic library loading relies on `dlopen` and `dlsym`, programs using `dynlib` must be linked against `libdl` via GCC / CC rather than standalone `ld`.

- **Assembler**: [UASM](https://www.terraspace.co.uk/uasm.html)
- **C Compiler / Linker**: `gcc` / `cc` with `-ldl`
- **Ampersand Library**: Installed to `/usr/local/lib/libamp.a` and `/usr/local/include`

---

## Building

### 1. Using Make
Build the `dynlib_test` executable:

```bash
cd dynlib
make
```

To clean build artifacts:
```bash
make clean
```

### 2. Using the `amp` Tool
Compile and link directly using the `amp` build driver with GCC:

```bash
amp dynlib gcc
```

---

## Running

Run the compiled executable:

```bash
./dynlib_test
```

### Expected Output:
```text
cos(1.0) = '0.540302'
```

---

## Source Files

- **[`dynlib.asm`](dynlib.asm)**: Example assembly application demonstrating `LOADLIB`, `LOADFUNC`, and `FREELIB`.
- **[`Makefile`](Makefile)**: Build configuration linking the binary with `gcc` and `-ldl`.
