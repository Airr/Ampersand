# Ampersand

A high-performance runtime and standard utility library for **UASM** targeting **64-bit Linux (`x86_64`)**.

Ampersand provides a comprehensive suite of assembly routines—bringing high-level language ergonomics and BASIC-style string/system utilities to native assembly development while maintaining low overhead, zero external dependencies for core routines, and direct Linux 64-bit system calls.

---

## Key Features

- **Libc-Independent Core**: Core system calls (I/O, process, memory, filesystem, time) are implemented via direct 64-bit Linux syscalls (`syscall`).
- **High-Speed Arena Memory Management**: O(1) bump allocation backed by chained `mmap` chunks, supporting fast reset and zero-fill clearing.
- **Rich String Library**: Full suite of string operations (`LEFT$`, `RIGHT$`, `MID$`, `SPLIT$`, `JOIN$`, `REPLACE$`, `TRIM$`, etc.) returning arena-managed or modified strings.
- **Console & Terminal I/O**: Line-buffered formatted printing (`PRINT`, `SPRINT`), raw terminal pausing (`EPAUSE`), ANSI styling (`COLOR`), screen clearing (`CLS`), and user input (`INPUT$`).
- **Filesystem & Path Utilities**: High-level file loaders/savers (`LOADFILE$`, `SAVEFILE`), directory traversal with wildcard matching (`DIR$`), recursive directory creation (`MKDIR`), and path resolution (`WHERE$`, `EXEPATH$`, `CURDIR$`).
- **System & Process Control**: Process execution (`SHELL`), command-line argument querying (`CMDCOUNT`, `COMMAND$`), environment variables (`ENV$`), and clean termination (`EXIT`).
- **Dynamic Linking Support**: Optional dynamic module loading (`LOADLIB`, `LOADFUNC`, `FREELIB`) for shared libraries (`.so`).

---

## ABI and Calling Conventions

Ampersand adheres to the standard **System V AMD64 ABI**:
- **Arguments**: Passed in order via `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.
- **Return Values**: Returned in `rax` (and `rdx` when returning 128-bit values / secondary data). Floating-point results use `xmm0`.
- **Preserved Registers**: Callee-saved registers (`rbx`, `rsp`, `rbp`, `r12`, `r13`, `r14`, `r15`) are preserved across procedure calls.
- **GNU Stack**: Object files include `.note.GNU-stack` segment markings for modern non-executable stack compatibility.

---

## Building the Library

Assemble the source files into a static archive (`libamp.a`) using `uasm` and `ar`:

```bash
make
```

### Build Requirements
- **Assembler**: [UASM](https://www.terraspace.co.uk/uasm.html) (configured for `-elf64 -q -pie`)
- **Archiver / Tools**: `ar`, `strip`, `mkdir`

The resulting static library is output to `lib/libamp.a`.

---

## API Reference by Category

### 1. Memory Management

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`ALLOC` / `arena_alloc`** | `(requestedBytes:qword, arenaDescriptor:ptr) -> rax` | Allocates memory from an arena descriptor using O(1) bump allocation, expanding via `mmap` as needed. |
| **`arena_reset`** | `(arenaDescriptor:ptr) -> void` | Fast reset: resets arena offset pointers back to 0 without unmapping memory chunks for fast reuse. |
| **`arena_secure_reset`**| `(arenaDescriptor:ptr) -> void` | Zeroes all payload memory across allocated chunks before resetting offsets. |
| **`MEM_ALLOC`** | `(size:qword) -> rax` | Allocates a raw heap memory block via anonymous private `mmap`. |
| **`MEM_FREE`** | `(memPtr:ptr) -> void` | Releases an allocated heap memory block back to the system via `munmap`. |
| **`MEM_COPY`** | `(dest:ptr, src:ptr, len:qword) -> rax (dest)` | Copies `len` bytes from `src` to `dest`. |
| **`MEM_SET`** | `(dest:ptr, val:byte, len:qword) -> rax (dest)` | Fills `len` bytes of buffer `dest` with byte `val`. |

---

### 2. String Manipulation & Slicing

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`LEN`** | `(text:ptr) -> rax` | Returns the length in bytes of a null-terminated string. |
| **`LEFT$`** | `(src:ptr, numBytes:qword) -> rax` | Extracts `numBytes` characters from the left end of the string into an arena-allocated buffer. |
| **`RIGHT$`** | `(src:ptr, count:qword) -> rax` | Extracts `count` characters from the right end of the string. |
| **`MID$`** | `(src:ptr, index:qword, numBytes:qword) -> rax` | Extracts a substring starting at 1-based `index` with length `numBytes`. |
| **`TRIM$`** | `(src:ptr) -> rax` | Trims leading/trailing whitespace (spaces, tabs) and collapses consecutive internal whitespace. |
| **`LTRIM$`** | `(src:ptr) -> rax` | Removes leading whitespace and tabs from the string. |
| **`RTRIM$`** | `(src:ptr) -> rax` | Removes trailing whitespace and tabs from the string. |
| **`LPAD$`** | `(src:ptr, totalLen:qword, fillChar:byte) -> rax` | Pads the left side of a string with `fillChar` to reach `totalLen`. |
| **`RPAD$`** | `(src:ptr, totalLen:qword, fillChar:byte) -> rax` | Pads the right side of a string with `fillChar` to reach `totalLen`. |
| **`CONCAT$`** | `(str1:ptr, str2:ptr) -> rax` | Concatenates two null-terminated strings into a new arena-allocated string. |
| **`JOIN$`** | `(count:qword, s1:ptr, s2:ptr, s3:ptr, s4:ptr, s5:ptr) -> rax` | Joins up to 5 strings into a single string. |
| **`SPLIT$`** | `(src:ptr, delimiter:ptr) -> rax` | Splits a string by delimiter into a null-terminated array of string pointers. |
| **`INSERT$`** | `(src:ptr, position:qword, substring:ptr) -> rax` | Inserts a substring at a 1-based position within `src`. |
| **`EXTRACT$`** | `(mainStr:ptr, matchStr:ptr) -> rax` | Extracts prefix of `mainStr` before the first occurrence of `matchStr`. |
| **`REMAIN$`** | `(pSource:ptr, pMatch:ptr) -> rax` | Returns substring starting from first occurrence of `pMatch`. |
| **`REMOVE$`** | `(src:ptr, match:ptr) -> rax` | Removes all occurrences of `match` from `src`. |
| **`REPEAT$`** | `(count:qword, pattern:ptr) -> rax` | Repeats `pattern` string `count` times. |
| **`REPLACE$`** | `(src:ptr, pattern:ptr, replaceStr:ptr) -> rax` | Replaces all occurrences of `pattern` with `replaceStr`. |
| **`REVERSE$`** | `(src:ptr) -> rax` | Returns a newly allocated reversed copy of `src`. |
| **`UCASE$`** | `(str_buf:ptr) -> rax` | Converts string in place to uppercase. |
| **`LCASE$`** | `(str_buf:ptr) -> rax` | Converts string in place to lowercase. |
| **`ENC$`** | `(srcPtr:ptr, encChar:dword) -> rax` | Encloses `srcPtr` inside opening and closing boundary character `encChar`. |
| **`SCOPY`** | `(src:ptr) -> rax` | Duplicates a null-terminated string into newly allocated buffer. |

---

### 3. String Search & Comparison

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`COMPARE`** | `(s1:ptr, s2:ptr) -> rax` | Lexicographically compares two strings (returns `< 0`, `0`, or `> 0`). |
| **`INDEXOF`** | `(haystack:ptr, needle:ptr) -> rax` | Finds 1-based index of first occurrence of `needle` in `haystack` (-1 if not found). |
| **`ENDSWITH`** | `(src:ptr, suffix:ptr) -> rax` | Returns `1` if `src` ends with `suffix`, `0` otherwise. |
| **`TALLY`** | `(src:ptr, matchStr:ptr) -> rax` | Returns count of non-overlapping occurrences of `matchStr` in `src`. |

---

### 4. Conversion & Formatting

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`STR$`** | `(num:qword) -> rax` | Converts a signed 64-bit integer to an ASCII decimal string. |
| **`STRL$`** | `(floatVal:real8) -> rax` | Converts a 64-bit floating-point value to an ASCII string (6 decimal places). |
| **`HEX$`** | `(num:qword) -> rax` | Converts a 64-bit unsigned integer to a hexadecimal string. |
| **`CHR`** | `(strPtr:ptr) -> rax` | Parses an ASCII decimal integer string into its 64-bit integer numeric value. |
| **`SPRINT`** | `(fmt:ptr, ...VARARG) -> rax` | Formats data according to `fmt` specifiers (`%s`, `%d`, `%u`, `%x`, `%c`, `%%`) into an arena-allocated string. |

---

### 5. Console & Terminal I/O

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`PRINT`** | `(fmt:ptr, ...VARARG) -> void` | Formatted printing to standard output with internal write buffering (`%s`, `%d`, `%u`, `%x`, `%c`, `%%`). |
| **`puts`** | `(text:ptr) -> void` | Writes a null-terminated string to stdout. |
| **`putn`** | `(num:qword) -> void` | Prints a signed 64-bit integer followed by output. |
| **`INPUT$`** | `(prompt:ptr) -> rax` | Displays `prompt`, reads a line from stdin, and returns an allocated string. |
| **`EPAUSE`** | `() -> void` | Enables raw terminal mode, pauses until Enter is pressed, and restores terminal mode. |
| **`CLS`** | `() -> void` | Clears terminal screen, resets cursor to top-left, and wipes scrollback buffer via ANSI escape codes. |
| **`COLOR`** | `(text:ptr, colorCode:qword) -> rax` | Encloses text with ANSI color codes for terminal display. |

---

### 6. File & Directory Operations

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`OPEN`** | `(filePath:ptr, flags:qword, mode:qword) -> rax` | Opens file via `sys_open` and returns file descriptor (or negative error). |
| **`READ`** | `(fd:qword, buffer:ptr, numBytes:qword) -> rax` | Reads up to `numBytes` into `buffer` via `sys_read`. |
| **`WRITE$`** | `(fd:qword, buffer:ptr, numBytes:qword) -> rax` | Writes `numBytes` from `buffer` to descriptor via `sys_write`. |
| **`SEEK`** | `(fd:qword, offset:qword, whence:qword) -> rax` | Repositions file offset via `sys_lseek`. |
| **`CLOSE`** | `(fd:qword) -> rax` | Closes open file descriptor via `sys_close`. |
| **`EXIST`** | `(filePath:ptr) -> rax` | Checks if a file or directory exists via `sys_stat` (returns `1` or `0`). |
| **`LOF`** | `(filePath:ptr) -> rax` | Returns file length in bytes via `sys_stat` (or `-1` on error). |
| **`KILL`** | `(filePath:ptr) -> rax` | Deletes a file or symbolic link via `sys_unlink`. |
| **`MKDIR`** | `(pathPtr:ptr, dirMode:dword) -> rax` | Creates directory and any missing parent directories (`mkdir -p` behavior). |
| **`LOADFILE$`** | `(filePath:ptr) -> rax` | Reads entire contents of a file into a newly allocated null-terminated string. |
| **`SAVEFILE`** | `(filePath:ptr, contentStr:ptr) -> rax` | Writes string contents to a file (returns `1` on success, `0` on failure). |
| **`DIR$`** | `(dirPath:ptr) -> rax` | Reads directory contents (supports wildcards/patterns) and returns a null-terminated array of filename strings. |

---

### 7. Date & Time

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`DATE$`** | `() -> rax` | Returns current date formatted as `"MM-DD-YYYY"`. |
| **`TIME$`** | `() -> rax` | Returns current local time formatted as `"HH:MM:SS AM/PM"`. |
| **`NOW$`** | `() -> rax` | Returns current date and time formatted as `"MM/DD/YY HH:MM:SS AM"`. |

---

### 8. System, Process & Environment

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`APPNAME$`** | `() -> rax` | Retrieves executable name from `/proc/self/cmdline` or `argv[0]`. |
| **`APPPATH$`** | `() -> rax` | Retrieves directory path containing the running executable. |
| **`EXEPATH$`** | `() -> rax` | Resolves full executable path (combining path and name). |
| **`CURDIR$`** | `() -> rax` | Returns the current working directory path via `sys_getcwd`. |
| **`WHERE$`** | `(executableName:ptr) -> rax` | Searches system `PATH` environment directories to find executable location. |
| **`ENV$`** | `(varName:ptr) -> rax` | Retrieves environment variable value from process environment. |
| **`CMDCOUNT`** | `() -> rax` | Returns number of command-line arguments. |
| **`COMMAND$`** | `(argIndex:qword) -> rax` | Retrieves specific command-line argument by 0-based index. |
| **`SHELL`** | `(cmdStr:ptr) -> rax` | Forks and executes command string via `sys_execve` / `/bin/sh -c` and returns exit status. |
| **`EXIT`** | `(exitCode:qword) -> void` | Exits process immediately via `sys_exit_group`. |

---

### 9. Dynamic Library Loading (Shared Objects)

*Note: Linking shared libraries requires linking against `libdl` / libc (`-lc`).*

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`LOADLIB`** | `(libPath:ptr) -> rax` | Loads a shared library (`.so`) using `dlopen`. |
| **`LOADFUNC`** | `(handle:ptr, funcName:ptr) -> rax` | Resolves symbol address from loaded library handle using `dlsym`. |
| **`FREELIB`** | `(handle:ptr) -> rax` | Closes loaded library handle using `dlclose`. |

---

### 10. Algorithms & Data Structures

| Function | Signature / Parameters | Description |
| :--- | :--- | :--- |
| **`SORT`** | `(arrPtr:ptr) -> void` | Sorts a null-terminated / length-bounded array of 64-bit QWORD values in place (ascending order). |

---

## License

See [LICENSE](LICENSE) for terms and details.
