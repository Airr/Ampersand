#!/usr/bin/env python3
"""
generateReadme.py - Generates or updates the root README.md for the Ampersand repository.
Extracts function signatures and descriptions from source files in 'src/' and 'include/amp.inc'.
"""

import os
import re
from pathlib import Path

# Category classifications for all Ampersand functions and procedures
CATEGORIES = {
    "1. Memory Management": [
        "ALLOC", "CALLOC", "MEM_ALLOC", "MEM_COPY",
        "MEM_FREE", "MEM_SET", "arena_alloc", "arena_reset",
        "arena_secure_reset", "memset"
    ],
    "2. String Manipulation & Slicing": [
        "CONCAT$", "ENC$", "EXTRACT$", "INSERT$",
        "JOIN$", "LCASE$", "LEFT$", "LEN",
        "LPAD$", "LTRIM$", "MID$", "REMAIN$",
        "REMOVE$", "REPEAT$", "REPLACE$", "REVERSE$",
        "RIGHT$", "RPAD$", "RTRIM$", "SCOPY",
        "SPLIT$", "TRIM$", "UCASE$"
    ],
    "3. String Search & Comparison": [
        "COMPARE", "ENDSWITH", "INDEXOF", "TALLY",
        "strstr"
    ],
    "4. Conversion & Formatting": [
        "ASC", "HEX$", "SPRINT", "STR$",
        "STRL$"
    ],
    "5. Console & Terminal I/O": [
        "CLS", "COLOR", "EPAUSE", "INPUT$",
        "PRINT", "putn", "puts"
    ],
    "6. File & Directory Operations": [
        "CHDIR", "CLOSE", "DIR$", "EXIST",
        "KILL", "LOADFILE$", "LOF", "MKDIR",
        "OPEN", "READ", "RENAME", "SAVEFILE",
        "SEEK", "WRITE$"
    ],
    "7. Date & Time": [
        "DATE$", "ISODATE$", "NOW$", "TIME$"
    ],
    "8. System, Process & Environment": [
        "APPNAME$", "APPPATH$", "CMDCOUNT", "COMMAND$",
        "CURDIR$", "ENV$", "EXEPATH$", "EXIT",
        "SHELL", "WHERE$"
    ],
    "9. Dynamic Library Loading (Shared Objects)": [
        "FREELIB", "LOADFUNC", "LOADLIB"
    ],
    "10. Algorithms & Data Structures": [
        "SORT"
    ]
}

# Custom notes or details for specific categories
CATEGORY_NOTES = {
    "9. Dynamic Library Loading (Shared Objects)": "*Note: Dynamic library routines require linking against `libdl` / libc (`-lc`).*"
}


def parse_doc_blocks(source_dir="src", delimiter=";=============================================================================="):
    """
    Parses doc comment blocks from all ASM files in source_dir.
    Returns a dict: { routine_name: {'description': str, 'params': str, 'returns': str} }
    """
    routines = {}
    src_path = Path(source_dir)

    for asm_file in sorted(src_path.glob("*.asm")):
        with open(asm_file, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()

        in_block = False
        block_lines = []
        for line in lines:
            stripped = line.strip()
            if stripped == delimiter:
                if in_block:
                    in_block = False
                    parsed = parse_single_block(block_lines)
                    if parsed and parsed.get("name"):
                        routines[parsed["name"]] = parsed
                    block_lines = []
                else:
                    in_block = True
                    block_lines = []
                continue

            if in_block:
                clean_line = line.strip()
                if clean_line.startswith(";"):
                    clean_line = clean_line[1:].strip()
                block_lines.append(clean_line)

    return routines


def parse_single_block(lines):
    """Parses a single doc comment block into name, description, parameters, and returns."""
    while lines and not lines[0].strip():
        lines.pop(0)
    if not lines:
        return {}

    first_line = lines[0].strip()
    match = re.match(r"^([A-Za-z0-9_\$\@]+)(?:\s*-\s*(.*))?", first_line)
    if not match:
        return {}

    func_name = match.group(1).strip()
    inline_desc = match.group(2).strip() if match.group(2) else ""

    sections = {}
    current_sec = "Description"
    sections[current_sec] = []
    if inline_desc:
        sections[current_sec].append(inline_desc)

    for line in lines[1:]:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.endswith(":") and not any(stripped.startswith(r) for r in ["rax", "rbx", "rcx", "rdx", "rsi", "rdi", "r8", "r9"]):
            current_sec = stripped[:-1].strip()
            if current_sec not in sections:
                sections[current_sec] = []
            continue
        sections[current_sec].append(stripped)

    # Format description into a single concise line
    desc_lines = sections.get("Description", [])
    description = " ".join(desc_lines).strip()

    # Format parameters
    param_lines = sections.get("Parameters", [])
    params = " ".join(param_lines).strip()

    # Format returns
    ret_lines = sections.get("Returns", [])
    returns = " ".join(ret_lines).strip()

    return {
        "name": func_name,
        "description": description,
        "params": params,
        "returns": returns
    }


def parse_prototypes(inc_file="include/amp.inc"):
    """
    Parses prototypes from include/amp.inc to get canonical parameter types and names.
    Returns dict: { routine_name: proto_args_string }
    """
    protos = {}
    inc_path = Path(inc_file)
    if not inc_path.exists():
        return protos

    proto_regex = re.compile(r"^\s*([A-Za-z0-9_\$\@]+)\s+PROTO\s*(.*)$", re.IGNORECASE)
    with open(inc_path, "r", encoding="utf-8") as f:
        for line in f:
            match = proto_regex.match(line)
            if match:
                name = match.group(1)
                args = match.group(2).strip()
                protos[name] = args
    return protos


def get_signature_and_desc(func_name, doc_info, protos):
    """Constructs a clean signature string and description for Markdown table row."""
    proto_args = protos.get(func_name, "")
    ret_text = ""

    if doc_info and doc_info.get("returns"):
        ret_val = doc_info["returns"]
        # Shorten return value to rax / void
        if "rax" in ret_val.lower() or "returns" in ret_val.lower() or "pointer" in ret_val.lower() or "1 " in ret_val:
            ret_text = " -> rax"
        elif "nothing" in ret_val.lower() or "void" in ret_val.lower():
            ret_text = " -> void"
        else:
            ret_text = " -> rax"
    else:
        ret_text = " -> rax"

    if proto_args:
        # Clean up prototype arguments
        cleaned_args = re.sub(r"\s+", " ", proto_args)
        signature = f"({cleaned_args}){ret_text}"
    elif doc_info and doc_info.get("params") and doc_info["params"].lower() != "none":
        signature = f"({doc_info['params']}){ret_text}"
    else:
        signature = f"(){ret_text}"

    # Clean description
    desc = doc_info.get("description", "") if doc_info else ""
    if not desc:
        desc = f"Routines and utilities for `{func_name}`."
    # Ensure ends with period
    if desc and not desc.endswith("."):
        desc += "."

    return signature, desc


def generate_root_readme(source_dir="src", inc_file="include/amp.inc", output_file="README.md"):
    """Generates the full root README.md file."""
    doc_blocks = parse_doc_blocks(source_dir=source_dir)
    protos = parse_prototypes(inc_file=inc_file)

    content = []
    content.append("# Ampersand")
    content.append("")
    content.append("A high-performance runtime and standard utility library for **UASM** targeting **64-bit Linux (`x86_64`)**.")
    content.append("")
    content.append("Ampersand provides a comprehensive suite of assembly routines—bringing high-level language ergonomics and BASIC-style string/system utilities to native assembly development while maintaining low overhead, zero external dependencies for core routines, and direct Linux 64-bit system calls.")
    content.append("")
    content.append("---")
    content.append("")
    content.append("## Key Features")
    content.append("")
    content.append("- **Libc-Independent Core**: Core system calls (I/O, process, memory, filesystem, time) are implemented via direct 64-bit Linux syscalls (`syscall`).")
    content.append("- **High-Speed Arena Memory Management**: O(1) bump allocation backed by chained `mmap` chunks, supporting fast reset and zero-fill clearing.")
    content.append("- **Rich String Library**: Full suite of string operations (`LEFT$`, `RIGHT$`, `MID$`, `SPLIT$`, `JOIN$`, `REPLACE$`, `TRIM$`, etc.) returning arena-managed or modified strings.")
    content.append("- **Console & Terminal I/O**: Line-buffered formatted printing (`PRINT`, `SPRINT`), raw terminal pausing (`EPAUSE`), ANSI styling (`COLOR`), screen clearing (`CLS`), and user input (`INPUT$`).")
    content.append("- **Filesystem & Path Utilities**: High-level file loaders/savers (`LOADFILE$`, `SAVEFILE`), directory traversal with wildcard matching (`DIR$`), recursive directory creation (`MKDIR`), and path resolution (`WHERE$`, `EXEPATH$`, `CURDIR$`).")
    content.append("- **System & Process Control**: Process execution (`SHELL`), command-line argument querying (`CMDCOUNT`, `COMMAND$`), environment variables (`ENV$`), and clean termination (`EXIT`).")
    content.append("- **Dynamic Linking Support**: Optional dynamic module loading (`LOADLIB`, `LOADFUNC`, `FREELIB`) for shared libraries (`.so`).")
    content.append("")
    content.append("---")
    content.append("")
    content.append("## ABI and Calling Conventions")
    content.append("")
    content.append("Ampersand adheres to the standard **System V AMD64 ABI**:")
    content.append("- **Arguments**: Passed in order via `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.")
    content.append("- **Return Values**: Returned in `rax` (and `rdx` when returning 128-bit values / secondary data). Floating-point results use `xmm0`.")
    content.append("- **Preserved Registers**: Callee-saved registers (`rbx`, `rsp`, `rbp`, `r12`, `r13`, `r14`, `r15`) are preserved across procedure calls.")
    content.append("- **GNU Stack**: Object files include `.note.GNU-stack` segment markings for modern non-executable stack compatibility.")
    content.append("")
    content.append("---")
    content.append("")
    content.append("## Building the Library")
    content.append("")
    content.append("Assemble the source files into a static archive (`libamp.a`) using `uasm` and `ar`:")
    content.append("")
    content.append("```bash")
    content.append("make")
    content.append("```")
    content.append("")
    content.append("### Build Requirements")
    content.append("- **Assembler**: [UASM](https://www.terraspace.co.uk/uasm.html) (configured for `-elf64 -q -pie`)")
    content.append("  with patch file in the 'uasm-2.57_Patch' folder applied, or replacing the 'elf.c' file with the renamed 'elf.c.patched' file.")
    content.append("- **Archiver / Tools**: `ar`, `strip`, `mkdir`, `install`")
    content.append("")
    content.append("The resulting static library is output to `lib/libamp.a`.")
    content.append("")
    content.append("### Installation")
    content.append("")
    content.append("To install the library and header files to standard system paths (`/usr/local/lib` and `/usr/local/include`):")
    content.append("")
    content.append("```bash")
    content.append("sudo make install")
    content.append("```")
    content.append("")
    content.append("---")
    content.append("")
    content.append("## API Reference by Category")

    for cat_name, routines in CATEGORIES.items():
        content.append("")
        content.append(f"### {cat_name}")
        content.append("")
        if cat_name in CATEGORY_NOTES:
            content.append(CATEGORY_NOTES[cat_name])
            content.append("")

        content.append("| Function / Procedure | Signature / Registers | Description |")
        content.append("| :--- | :--- | :--- |")

        for r_name in routines:
            doc_info = doc_blocks.get(r_name, {})
            sig, desc = get_signature_and_desc(r_name, doc_info, protos)
            # Escape pipes if any
            desc = desc.replace("|", "\\|")
            sig = sig.replace("|", "\\|")
            content.append(f"| **`{r_name}`** | `{sig}` | {desc} |")

    content.append("")
    content.append("---")
    content.append("")
    content.append("## License")
    content.append("")
    content.append("See [LICENSE](LICENSE) for terms and details.")
    content.append("")

    readme_text = "\n".join(content)
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(readme_text)

    print(f"Successfully generated '{output_file}' with {len(CATEGORIES)} categories.")


if __name__ == "__main__":
    generate_root_readme()
