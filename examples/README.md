# Ampersand Examples & Test Suite

This directory contains standalone example and test programs demonstrating the usage of each module and function in the **Ampersand** standard library on 64-bit Linux with **UASM**.

---

## Directory Structure

- **[`src/`](src/)**: Assembly source files (`.asm`) for each individual function test/demo.
- **[`bin/`](bin/)**: Output directory for compiled executable binaries.
- **[`obj/`](obj/)**: Intermediate object files (`.o`).
- **[`Makefile`](Makefile)**: Batch build configuration to assemble and link all examples into `bin/`.
- **[`build`](build)**: Shell script helper to quickly assemble, link, and run a single test file.

---

## Prerequisites

- **[UASM](https://www.terraspace.co.uk/uasm.html)** in system `PATH`
- **GNU Binutils (`ld`)** or **GCC**
- **Ampersand Library**: Built and installed (default search path `/usr/local/lib/libamp.a` and `/usr/local/include`)

---

## Building the Examples

### 1. Batch Build All Examples with Make

To assemble and link all test programs in `src/` using `ld` into `bin/`:

```bash
make
```

To build and link using GCC (with `libdl`):

```bash
make USE_GCC=1
```

To clean all generated object files and binaries:

```bash
make clean
```

### 2. Build and Run a Single Example with the Build Script

You can assemble, link, and immediately run an individual example using the `build` script:

```bash
# Build & run with ld (default)
./build test_print

# Build & run with gcc
./build test_print gcc
```

### 3. Build with the `amp` Tool

If you have built and installed the `amp` driver:

```bash
amp src/test_print
```

---

## Example Programs Catalog

### String Operations

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_left.asm`** | `LEFT$` | Extracts characters from the left of a string. |
| **`test_right.asm`** | `RIGHT$` | Extracts characters from the right of a string. |
| **`test_mid.asm`** | `MID$` | Extracts arbitrary substrings by index and length. |
| **`test_trim.asm`** | `TRIM$` | Trims leading/trailing spaces and collapses internal spaces. |
| **`test_ltrim.asm`** | `LTRIM$` | Removes leading whitespace and tabs. |
| **`test_rtrim.asm`** | `RTRIM$` | Removes trailing whitespace and tabs. |
| **`test_lpad.asm`** | `LPAD$` | Left-pads strings to target width with a specific character. |
| **`test_rpad.asm`** | `RPAD$` | Right-pads strings to target width with a specific character. |
| **`test_insert.asm`** | `INSERT$` | Inserts a substring at a given position. |
| **`test_extract.asm`** | `EXTRACT$` | Extracts prefix before a delimiter match. |
| **`test_remove.asm`** | `REMOVE$` | Removes all matching occurrences of a substring. |
| **`test_repeat.asm`** | `REPEAT$` | Generates repeated pattern strings. |
| **`test_replace.asm`** | `REPLACE$` | Substring search and replace. |
| **`test_reverse.asm`** | `REVERSE$` | Reverses character order in strings. |
| **`test_split.asm`** | `SPLIT$` | Tokenizes a string by delimiter into a string pointer array. |
| **`test_indexof.asm`** | `INDEXOF` | 1-based substring search index. |
| **`test_tally.asm`** | `TALLY` | Counts non-overlapping occurrences of a substring. |

### Formatting & Type Conversion

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_print.asm`** | `PRINT`, `ENV$`, `CMDCOUNT` | Formatted output with specifiers (`%s`, `%d`, `%x`, `%c`). |
| **`test_str.asm`** | `STR$` | Converts 64-bit integers to string representations. |
| **`test_hex.asm`** | `HEX$` | Converts numbers to hexadecimal strings. |
| **`test_chr.asm`** | `CHR` | Converts decimal numeric strings to integer values. |

### Terminal & Console I/O

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_cls.asm`** | `CLS` | Clears terminal screen and scrollback buffer. |
| **`test_color.asm`** | `COLOR` | Formats and outputs ANSI colorized terminal text. |
| **`test_input.asm`** | `INPUT$`, `EPAUSE` | Prompted line input from stdin and single-key pause. |

### Filesystem & I/O

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_fileops.asm`** | `OPEN`, `WRITE$`, `READ`, `SEEK`, `CLOSE`, `KILL` | Low-level file creation, seeking, reading, writing, and deletion. |
| **`test_loadfile.asm`** | `LOADFILE$` | Reads entire file into an allocated string. |
| **`test_savefile.asm`** | `SAVEFILE` | Writes string contents directly to disk. |
| **`test_exist.asm`** | `EXIST` | Tests whether a file or directory exists. |
| **`test_lof.asm`** | `LOF` | Queries file size in bytes via `stat`. |
| **`test_dir.asm`** | `DIR$` | Traverses directory entries with wildcard filter patterns. |

### Date & Time

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_date.asm`** | `DATE$` | Formats current calendar date (`MM-DD-YYYY`). |
| **`test_time.asm`** | `TIME$` | Formats current local time (`HH:MM:SS AM/PM`). |
| **`test_now.asm`** | `NOW$` | Formats current combined timestamp (`MM/DD/YY HH:MM:SS AM`). |

### System & Environment

| Example File | Key Functions Demonstrated | Description |
| :--- | :--- | :--- |
| **`test_appname.asm`** | `APPNAME$` | Retrieves the current application / binary name. |
| **`test_apppath.asm`** | `APPPATH$` | Resolves directory path of current running binary. |
| **`test_cwd.asm`** | `CURDIR$` | Retrieves current working directory. |
| **`test_env.asm`** | `ENV$` | Queries environment variables. |
| **`test_command.asm`** | `COMMAND$`, `CMDCOUNT` | Accesses command-line arguments by index. |
| **`test_where.asm`** | `WHERE$` | Searches `PATH` directories for an executable binary. |
| **`test_shell.asm`** | `SHELL` | Spawns a child process and executes a shell command. |

---

## Running the Examples

Once built with `make`, all test binaries reside in `bin/`:

```bash
./bin/test_print
./bin/test_split
./bin/test_dir
./bin/test_date
```
