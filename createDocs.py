#!/usr/bin/env python3
import argparse
import glob
import os
import sys
from pathlib import Path


def format_block_as_markdown(block_lines):
    """
    Takes the raw extracted lines from a delimited comment block and formats them 
    into Markdown, extracting all sections (Description, Parameters, Returns, Notes, 
    Supports, etc.) and trimming excess padding lines.
    """
    if not block_lines:
        return "", ""

    # Strip empty lines from the beginning of the block
    lines = list(block_lines)
    while lines and not lines[0].strip():
        lines.pop(0)

    if not lines:
        return "", ""

    # The first non-empty line is the function/symbol name
    func_name = lines[0].strip()

    sections = {}
    current_section = "Description"
    sections[current_section] = []

    for line in lines[1:]:
        raw_line = line.rstrip("\r\n")
        stripped = raw_line.strip()

        # Check if line is a top-level section header (e.g., "Parameters:", "Returns:", "Notes:", "Supports:")
        # Header lines are not heavily indented and end with a colon.
        is_header = False
        if not line.startswith(("  ", "\t")) and stripped.endswith(":"):
            # Exclude register/instruction labels or URLs
            if not stripped.startswith(("rax", "rbx", "rcx", "rdx", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "http://", "https://")):
                is_header = True

        if is_header:
            current_section = stripped[:-1].strip()
            if current_section not in sections:
                sections[current_section] = []
            continue

        sections[current_section].append(raw_line)

    # Helper function to strip leading/trailing empty lines from a list of lines
    def clean_section_lines(sec_lines):
        cleaned = list(sec_lines)
        while cleaned and not cleaned[0].strip():
            cleaned.pop(0)
        while cleaned and not cleaned[-1].strip():
            cleaned.pop()
        return cleaned

    # Clean empty lines for each section
    for sec_name in list(sections.keys()):
        sections[sec_name] = clean_section_lines(sections[sec_name])

    # Construct the Markdown output
    markdown_output = []
    markdown_output.append(f"### `{func_name}`")
    markdown_output.append("")

    # Output Description section if present
    desc_lines = sections.get("Description", [])
    if desc_lines:
        markdown_output.append("```")
        markdown_output.extend(desc_lines)
        markdown_output.append("```")

    # Output all other extracted sections in order
    for sec_name, sec_lines in sections.items():
        if sec_name == "Description":
            continue

        markdown_output.append(f"#### {sec_name}:")
        if sec_lines:
            markdown_output.append("```")
            markdown_output.extend(sec_lines)
            markdown_output.append("```")

    return func_name, "\n".join(markdown_output)


def extract_and_format_blocks(filepath, delimiter=";=============================================================================="):
    """
    Opens a file, scans for all blocks between delimiter lines, cleans them,
    and returns a list of tuples: (function_name, formatted_markdown).
    """
    formatted_blocks = []
    current_block = []
    recording = False

    try:
        with open(filepath, "r", encoding="utf-8") as file:
            for line in file:
                stripped_line = line.rstrip("\r\n")

                if stripped_line == delimiter:
                    if recording:
                        if current_block:
                            func_name, markdown = format_block_as_markdown(current_block)
                            if markdown:
                                formatted_blocks.append((func_name, markdown))
                        current_block = []
                        recording = False
                    else:
                        recording = True
                        current_block = []
                    continue

                if recording:
                    if line.startswith(";"):
                        cleaned_line = line[1:]
                        if cleaned_line.startswith(" "):
                            cleaned_line = cleaned_line[1:]
                        current_block.append(cleaned_line)
                    else:
                        current_block.append(line)

    except FileNotFoundError:
        print(f"Error: The file '{filepath}' was not found.")
    except Exception as e:
        print(f"An error occurred while reading '{filepath}': {e}")

    return formatted_blocks


def process_directory(directory_path, pattern="*.asm", delimiter=";=============================================================================="):
    """
    Loops through a directory of ASM files, extracting and formatting
    all delimiter-bounded documentation sections from each file.
    
    Returns a dict mapping file_path -> list of (func_name, markdown_block) tuples.
    """
    results = {}
    path = Path(directory_path)

    if not path.is_dir():
        print(f"Error: Directory '{directory_path}' does not exist.")
        return results

    files = sorted(path.glob(pattern))

    for file_path in files:
        blocks = extract_and_format_blocks(str(file_path), delimiter=delimiter)
        if blocks:
            results[str(file_path)] = blocks

    return results


def build_master_index(results, docs_dir_name="docs", title="Ampersand Documentation"):
    """
    Builds the master Markdown file content containing links to each generated doc file.
    """
    lines = []
    lines.append(f"# {title}")
    lines.append("")
    lines.append("## Index of Modules")
    lines.append("")
    lines.append("| Module / File | Routines |")
    lines.append("| :--- | :--- |")

    for file_path, blocks in sorted(results.items()):
        stem = Path(file_path).stem
        doc_filename = f"{stem}.md"
        routines = ", ".join([f"`{fn}`" for fn, _ in blocks if fn])
        lines.append(f"| [{doc_filename}]({doc_filename}) | {routines} |")

    lines.append("")
    return "\n".join(lines)


def generate_docs(source_dir="src", docs_dir="docs", delimiter=";=============================================================================="):
    """
    1. Checks if the docs folder exists; creates it if not.
    2. Processes all ASM files in source_dir.
    3. Generates an individual markdown file in docs_dir for each ASM file (without the filename in the header).
    4. Generates a master README.md file in docs_dir with links to all generated doc files.
    """
    docs_path = Path(docs_dir + "/modules")

    # Check if doc folder exists, and if not create it
    if not docs_path.exists():
        print(f"Directory '{docs_dir}' does not exist. Creating it...")
        docs_path.mkdir(parents=True, exist_ok=True)
    else:
        print(f"Using existing directory '{docs_dir}'.")

    # Extract documentation from source files
    results = process_directory(source_dir, delimiter=delimiter)

    if not results:
        print(f"No documentation blocks found in '{source_dir}'.")
        return

    # 1. Generate individual markdown files for each ASM file
    files_created = 0
    for file_path, blocks in results.items():
        stem = Path(file_path).stem
        target_md_path = docs_path / f"{stem}.md"

        # Combine all blocks for this file (without filename header)
        content_blocks = [md for _, md in blocks]
        file_content = "\n\n---\n\n".join(content_blocks) + "\n"

        with open(target_md_path, "w", encoding="utf-8") as f:
            f.write(file_content)
        files_created += 1

    # 2. Generate master index file with links to each generated file
    master_index_content = build_master_index(results, docs_dir_name=docs_dir)
    master_file_path = docs_path / "README.md"
    with open(master_file_path, "w", encoding="utf-8") as f:
        f.write(master_index_content)

    total_blocks = sum(len(b) for b in results.values())
    print(f"\nSuccessfully generated:")
    print(f"  - {files_created} individual documentation files in '{docs_dir}/modules'")
    print(f"  - 1 master index file: '{master_file_path}'")
    print(f"  - {total_blocks} total documentation blocks processed.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract documentation from ASM files into individual Markdown files and a master index.")
    parser.add_argument("-s", "--source", default="src", help="Source directory containing ASM files (default: 'src')")
    parser.add_argument("-d", "--docs-dir", default="docs", help="Target documentation directory (default: 'docs')")

    args = parser.parse_args()

    generate_docs(source_dir=args.source, docs_dir=args.docs_dir)