# libcurl Integration & Example for Ampersand

This folder provides **libcurl** bindings and an example HTTP/HTTPS client written in 64-bit x86_64 assembly for **UASM**, leveraging the Ampersand standard library.

---

## Overview

The `curl` module demonstrates how to interface native assembly applications with `libcurl` for high-performance network requests, complete with:
- Prototype declarations and constants for libcurl C APIs in UASM.
- A helper wrapper (`curl_init`) for streamlined global and handle initialization.
- A streaming data callback (`write_callback`) that outputs HTTP responses directly to stdout using Ampersand's `WRITE$` system call.
- Support for following HTTP redirects (`CURLOPT_FOLLOWLOCATION`).

---

## Prerequisites

- **[UASM](https://www.terraspace.co.uk/uasm.html)** (x86_64 assembler)
- **libcurl development library**:
  ```bash
  # Debian / Ubuntu:
  sudo apt-get install libcurl4-openssl-dev
  ```
- **Ampersand Library**: Installed to `/usr/local/lib/` and `/usr/local/include`
- **GCC**: For linking against shared libraries (`-lcurl`, `-ldl`)

---

## Files

- **[`curl.inc`](curl.inc)**: UASM include file containing:
  - External C prototypes for `libcurl` functions (`curl_global_init`, `curl_easy_init`, `curl_easy_setopt`, `curl_easy_perform`, `curl_easy_cleanup`, `curl_global_cleanup`).
  - Common curl option constants (`CURLOPT_URL`, `CURLOPT_WRITEFUNCTION`, `CURLOPT_FOLLOWLOCATION`, `CURL_GLOBAL_DEFAULT`).
  - Helper procedure `curl_init(hndPtr:ptr qword)` that initializes global state and creates an easy handle.
- **[`curl.asm`](curl.asm)**: Example command-line application that fetches content from a given URL and streams the response to standard output.
- **[`Makefile`](Makefile)**: Makefile to assemble and link `curl.asm` into the `curl_test` executable.

---

## Building

To assemble and link the example executable (`curl_test`):

```bash
cd curl
make
```

### Alternatively, using `amp`:
You can also compile and link using the `amp` build tool with GCC and the curl library flag:

```bash
amp curl gcc "-lcurl"
```

To clean build artifacts:
```bash
make clean
```

---

## Usage

Run the compiled executable passing the target URL as an argument:

```bash
./curl_test https://icanhazip.com
```

Or fetching an API or web page:
```bash
./curl_test https://httpbin.org/get
```

---

## Example Callback Architecture

The assembly callback implementation demonstrates how `libcurl` passes chunked payload buffers to native assembly code:

```assembly
write_callback proc USES rbx rbp
    mov     rbx, rdi            ; rbx = buffer pointer
    imul    rsi, rdx            ; rsi = size * nmemb
    mov     rbp, rsi            ; rbp = total chunk byte count
    WRITE$(1, rbx, rbp)         ; output chunk to stdout via Ampersand WRITE$
    mov     rax, rbp            ; return bytes handled to curl
    ret
write_callback endp
```
