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
- **Assembler**: [UASM](https://github.com/Airr/UASM) (my updated fork with PIE fix)
- **Archiver / Tools**: `ar`, `strip`, `mkdir`, `install`

The resulting static library is output to `lib/libamp.a`.

### Installation

To install the library and header files to standard system paths (`/usr/local/lib` and `/usr/local/include`):

```bash
sudo make install
```

---

## API Reference by Category

### 1. Memory Management

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`ALLOC`** | `(requested_size:qword) -> rax` | Allocates memory from an arena. |
| **`CALLOC`** | `(count:qword, elem_size:qword) -> rax` | Routines and utilities for `CALLOC`. |
| **`MEM_ALLOC`** | `(memsize:QWORD) -> rax` | Allocates a block of memory from the system's heap. |
| **`MEM_COPY`** | `(dest:PTR, src:PTR, len:QWORD) -> rax` | Copies a block of memory from one location to another. |
| **`MEM_FREE`** | `(mem_ptr:PTR) -> rax` | Frees a block of memory that was previously allocated with MEMALLOC. |
| **`MEM_SET`** | `(dest:ptr - Pointer to the destination buffer to be filled with the given value. val:byte - The byte value to fill the buffer with. len:qword- The number of bytes in the buffer to set to the given value.) -> rax` | Sets a block of memory to a specific value. |

### 2. String Manipulation & Slicing

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`CONCAT$`** | `(str1:ptr, str2:ptr) -> rax` | Concatenates two null-terminated strings and allocates memory from an arena to store the result. |
| **`ENC$`** | `(srcPtr:ptr, encChar:dword) -> rax` | Encloses the given source string within a pair of characters. |
| **`EXTRACT$`** | `(mainStr:ptr, matchStr:ptr) -> rax` | Extracts a prefix from a string based on a match with another string. If no match is found, returns the entire input string. |
| **`INSERT$`** | `(src:ptr, position:qword, substring:ptr) -> rax` | Inserts a substring into another string at a specified position. |
| **`JOIN$`** | `(:qword, :vararg) -> rax` | Joins up to 5 strings into a single string with a delimiter. |
| **`LCASE$`** | `(str_buf:PTR) -> rax` | Converts all uppercase characters in a string to lowercase. |
| **`LEFT$`** | `(srcString:ptr, numBytes:qword) -> rax` | Extracts a specified number of characters from the beginning of a string. |
| **`LEN`** | `(text:ptr) -> rax` | Calculates the length of a null-terminated string. |
| **`LPAD$`** | `(srcString:ptr, fillCount:qword, fillChar:byte) -> rax` | Pads a string with a specified character to a given length from the left. |
| **`LTRIM$`** | `(srcString:ptr) -> rax` | Trims leading whitespace (spaces and tabs) from a string. |
| **`MID$`** | `(srcString:ptr, index:qword, numBytes:qword) -> rax` | Extracts a substring from a source string, starting at a given index and of a specified length. |
| **`REMAIN$`** | `(pSource:ptr, pMatch:ptr) -> rax` | Returns the substring of pSource starting from the first occurrence of pMatch. |
| **`REMOVE$`** | `(srcString:ptr, match:ptr) -> rax` | Removes all occurrences of a substring from a given string. |
| **`REPEAT$`** | `(count:qword, pattern:ptr) -> rax` | Repeats a given pattern 'count' times. |
| **`REPLACE$`** | `(src:ptr, pattern:ptr, replaceStr:ptr) -> rax` | Replaces all occurrences of a substring (pattern) within a string with another substring. |
| **`REVERSE$`** | `(src:ptr) -> rax` | Reverses the order of characters in a given string. |
| **`RIGHT$`** | `(src:ptr, count:qword) -> rax` | Extracts the specified number of characters from the right end of a string. |
| **`RPAD$`** | `(src:ptr, count:qword, fillChar:byte) -> rax` | Pads the right side of a string with a specified character until it reaches the specified length. |
| **`RTRIM$`** | `(srcString:ptr) -> rax` | Removes trailing spaces and tab characters from a given string. |
| **`SCOPY`** | `(src:ptr) -> rax` | Copies a null-terminated string into another buffer. |
| **`SPLIT$`** | `(srcString:ptr, delimiterString:ptr) -> rax` | Splits a null-terminated string into an array of substrings based on a delimiter. Tokens are allocated from the arena and stored in a pointer array. |
| **`TRIM$`** | `(srcString:ptr) -> rax` | Trims leading and trailing whitespace from a string and collapses internal spaces into a single space. |
| **`UCASE$`** | `(str_buf:PTR) -> rax` | Converts a given ASCII string into uppercase in place. |

### 3. String Search & Comparison

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`COMPARE`** | `(str1:ptr, str2:ptr) -> rax` | Compares two null-terminated strings lexicographically. |
| **`ENDSWITH`** | `(src:ptr, arg:ptr) -> rax` | Checks if the source string ends with a given substring. |
| **`INDEXOF`** | `(haystack:ptr, needle:ptr) -> rax` | Searches for the first occurrence of a substring within a string. |
| **`TALLY`** | `(srcString:ptr, matchStr:ptr) -> rax` | Counts the number of non-overlapping occurrences of a substring within a given string. |

### 4. Conversion & Formatting

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`ASC`** | `(text:PTR) -> rax` | Converts a string into the corresponding integer value. |
| **`CHR$`** | `(code:qword, args:vararg) -> rax` | Builds a string from a list of character codes (0-255) terminated by a negative value (e.g. CHR_END / -1). |
| **`HEX$`** | `(num:QWORD) -> rax` | Converts a QWORD (64-bit unsigned integer) to its hexadecimal string representation. |
| **`SPRINT`** | `(fmt:PTR, args:VARARG) -> rax` | Formats a string using printf-style formatting and stores the result in an arena-allocated buffer. |
| **`STR$`** | `(num:QWORD) -> rax` | Converts a 64-bit signed integer into its STRING representation. Handles positive and negative numbers, as well as zero. |
| **`STRL$`** | `(float:REAL8) -> rax` | Converts a 64-bit floating-point number into its ASCII representation. The result is formatted to 6 decimal places. |

### 5. Console & Terminal I/O

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`CLS`** | `() -> void` | Clears the screen, homes the cursor, and wipes the scrollback buffer using ANSI escape sequences via pure UASM system calls. |
| **`COLOR`** | `(text:ptr, colorcode:qword) -> rax` | Colorizes a given string based on the provided color code. The function allocates memory from an arena and returns a new string with the ANSI escape codes applied. |
| **`EPAUSE`** | `() -> rax` | Pauses the execution of a program until the user presses the Enter key. |
| **`INPUT$`** | `(msg:ptr) -> rax` | Reads a line of text from standard input and stores it in an allocated string. |
| **`PRINT`** | `(fmt:PTR, args:VARARG) -> rax` | Outputs formatted text to standard output. |
| **`putn`** | `(num:QWORD) -> rax` | Prints a number to standard output. |
| **`puts`** | `(text:ptr) -> rax` | Prints a string to standard output. |

### 6. File & Directory Operations

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`CHDIR`** | `(folder:ptr) -> rax` | Change the current working directory to the specified folder. |
| **`CLOSE`** | `(fileHandle:qword) -> rax` | Closes a file descriptor. |
| **`DIR$`** | `(dir_path:PTR) -> rax` | Returns a pointer to an array of strings representing the files in a directory. |
| **`EXIST`** | `(filePath:ptr) -> rax` | Checks if a file or directory exists at the given path. |
| **`KILL`** | `(filePath:ptr) -> rax` | Deletes a file or symbolic link. |
| **`LOADFILE$`** | `(filePath:ptr) -> rax` | Reads a file into memory and returns its contents as a string. |
| **`LOF`** | `(path:ptr) -> rax` | Retrieves the length of a file in bytes. |
| **`MKDIR`** | `(pathPtr:ptr, dirMode:dword) -> rax` | Creates a directory and any missing parent directories (like mkdir -p) with the specified path and mode. |
| **`OPEN`** | `(filePath:ptr, fileFlags:qword, fileMode:qword) -> rax` | Opens a file and returns a file descriptor. |
| **`READ`** | `(fileHandle:qword, buffer:ptr, numBytes:qword) -> rax` | Reads data from a file descriptor into a buffer. |
| **`RENAME`** | `(oldpath:ptr, newpath:ptr) -> rax` | Rename a file or directory from oldpath to newpath. |
| **`SAVEFILE`** | `(filePath:ptr, srcString:ptr) -> rax` | Saves the contents of a string to a specified file. |
| **`SEEK`** | `(fileHandle:qword, fileOffset:qword, seekFlags:qword) -> rax` | Sets the file offset of a file descriptor. |
| **`WRITE$`** | `(fileHandle:qword, buffer:ptr, numBytes:qword) -> rax` | Writes data from a buffer to a file descriptor. |

### 7. Date & Time

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`DATE$`** | `() -> rax` | Retrieves the current date in "MM-DD-YYYY" format and returns it as a string. |
| **`ISODATE$`** | `() -> rax` | Retrieves the current date in "YYYY-MM-DD" ISO format and returns it as a string. |
| **`NOW$`** | `() -> rax` | Retrieves the current date and time in a formatted string. |
| **`TIME$`** | `(None.) -> rax` | Returns the current local time as a string formatted in "HH:MM:SS AM/PM". |

### 8. System, Process & Environment

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`APPNAME$`** | `() -> rax` | Retrieves the name of the current application (usually argv[0]). |
| **`APPPATH$`** | `() -> rax` | Retrieves the path to the current executable. For example, "/usr/bin/ls" -> "/usr/bin". |
| **`CMDCOUNT`** | `() -> rax` | Retrieves the number of command-line arguments provided to the program, excluding the executable itself. |
| **`COMMAND$`** | `(argnum:qword) -> rax` | Retrieves a command-line argument from the program's arguments. |
| **`CURDIR$`** | `() -> rax` | Retrieves the current working directory path and allocates memory from an arena to store it. |
| **`ENV$`** | `(namePtr:ptr) -> rax` | Retrieves the value of an environment variable by name. |
| **`EXEPATH$`** | `() -> rax` | Constructs the full path of the executable from the application name and path. |
| **`EXIT`** | `(code:qword) -> rax` | Exits the program with a given exit code. |
| **`SHELL`** | `(cmd_str:ptr) -> rax` | Executes a command in a new process using the system call sys_execve. |
| **`WHERE$`** | `(argv:ptr) -> rax` | Searches for an executable in the system's PATH. |

### 9. Dynamic Library Loading (Shared Objects)

*Note: Dynamic library routines require linking against `libdl` / libc (`-lc`).*

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`FREELIB`** | `(handle:qword) -> rax` | Closes a previously loaded shared library using dlclose(). |
| **`LOADFUNC`** | `(libHandle:qword, funcname:ptr) -> rax` | Retrieves a function pointer from a previously loaded shared library using dlsym(). |
| **`LOADLIB`** | `(filename:ptr) -> rax` | Loads a shared library using dlopen(). |

### 10. Algorithms & Data Structures

| Function / Procedure | Signature / Registers | Description |
| :--- | :--- | :--- |
| **`SORT`** | `(arrPtr:ptr) -> rax` | Sorts an array of qwords in ascending order using a simple bubble sort algorithm. |

---

## License

See [LICENSE](LICENSE) for terms and details.
