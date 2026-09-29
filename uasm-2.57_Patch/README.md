# UASM 2.57 ELF64 Relocation Patch

This directory contains a bugfix patch specifically for the **`v2.57` branch** of the **[UASM](https://github.com/Terraspace/UASM)** assembler.

---

## Background & Problem

When building Position Independent Executables (**PIE**) or shared libraries on 64-bit Linux (`x86_64`), modern linkers (`ld`, `gold`, `lld`) require external PC-relative relocations to use `R_X86_64_PLT32` instead of `R_X86_64_PC32`. 

Using `R_X86_64_PC32` against external symbols causes link-time failures such as:
```text
relocation R_X86_64_PC32 against symbol `some_external_function' can not be used when making a PIE object; recompile with -fPIE
```

In stock UASM 2.57, only external `CALL` instructions (`OPTJ_CALL`) generated `R_X86_64_PLT32` relocations. Other external PC-relative fixups defaulted to `R_X86_64_PC32`.

### The Fix

The patch updates `write_relocs64()` in `elf.c` so that **all** external 32-bit relative fixups (`FIX_RELOFF32`) targeting symbols marked `SYM_EXTERNAL` properly emit `R_X86_64_PLT32` relocations.

---

## Contents

| File | Description |
| :--- | :--- |
| [`elf.c.diff`](elf.c.diff) | Unified diff patch that can be applied to the UASM 2.57 source tree using `patch` or `git apply`. |
| [`elf.c.patched`](elf.c.patched) | Complete, pre-patched replacement for `elf.c`. |

---

## How to Apply & Build

### Step 1: Clone UASM (My forked 2.57 Branch with PIE fix)

```bash
git clone https://github.com/Airr/UASM.git
cd UASM
git checkout v2.57  # or switch to the 2.57 release branch / tag
```

### Step 2: Apply the Patch

You can apply the diff using either method:

**Option A — Using `git apply` or `patch`:**
```bash
git apply /path/to/Ampersand/uasm-2.57_Patch/elf.c.diff
# or
patch -p1 < /path/to/Ampersand/uasm-2.57_Patch/elf.c.diff
```

**Option B — Direct Replacement:**
```bash
cp /path/to/Ampersand/uasm-2.57_Patch/elf.c.patched ./elf.c
```

### Step 3: Compile UASM on Linux (x86_64)

Compile UASM using its GCC Linux 64-bit makefile:

```bash
make -f Makefile-Linux-GCC-64.mak
```

### Step 4: Install the Binary

Copy the resulting `uasm` binary to a directory in your `$PATH` (such as `/usr/local/bin`):

```bash
sudo cp GccUnixR/uasm /usr/local/bin/
sudo chmod +x /usr/local/bin/uasm
```

### Step 5: Verify

Verify the installed version:

```bash
uasm -?
```
