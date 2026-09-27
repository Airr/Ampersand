#!/usr/bin/env python3

def format_block_as_markdown(block_lines):
    """
    Takes the raw extracted lines and formats them into Markdown 
    matching the requested style, trimming excess padding lines.
    """
    if not block_lines:
        return ""

    # The first line is the function name
    func_name = block_lines[0].strip()
    
    description_lines = []
    param_lines = []
    return_lines = []
    
    current_section = "description"
    
    for line in block_lines[1:]:
        stripped = line.strip()
        
        if stripped.startswith("Parameters:"):
            current_section = "parameters"
            continue
        elif stripped.startswith("Returns:"):
            current_section = "returns"
            continue
            
        if current_section == "description":
            description_lines.append(line.rstrip('\r\n'))
        elif current_section == "parameters":
            param_lines.append(line.rstrip('\r\n'))
        elif current_section == "returns":
            return_lines.append(line.rstrip('\r\n'))

    # Helper function to strip leading/trailing empty lines from a list of lines
    def clean_section_lines(lines):
        while lines and not lines[0].strip():
            lines.pop(0)
        while lines and not lines[-1].strip():
            lines.pop()
        return lines

    description_lines = clean_section_lines(description_lines)
    param_lines = clean_section_lines(param_lines)
    return_lines = clean_section_lines(return_lines)

    # Construct the Markdown output
    markdown_output = []
    markdown_output.append(f"### `{func_name}`")
    markdown_output.append("")
    
    if description_lines:
        markdown_output.append("```")
        markdown_output.extend(description_lines)
        markdown_output.append("```")
        
    markdown_output.append("#### Parameters:")
    if param_lines:
        markdown_output.append("```")
        markdown_output.extend(param_lines)
        markdown_output.append("```")
        
    markdown_output.append("#### Returns:")
    if return_lines:
        markdown_output.append("```")
        markdown_output.extend(return_lines)
        markdown_output.append("```")

    return "\n".join(markdown_output)

def extract_and_format_blocks(filepath):
    """
    Opens a file, scans for blocks between the delimiter, cleans them, 
    and returns them formatted as Markdown.
    """
    delimiter = ";=============================================================================="
    formatted_blocks = []
    current_block = []
    recording = False

    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            for line in file:
                stripped_line = line.rstrip('\r\n')

                if stripped_line == delimiter:
                    if recording:
                        markdown = format_block_as_markdown(current_block)
                        formatted_blocks.append(markdown)
                        current_block = []
                        recording = False
                    else:
                        recording = True
                    continue

                if recording:
                    if line.startswith(';'):
                        cleaned_line = line[1:]
                        if cleaned_line.startswith(' '):
                            cleaned_line = cleaned_line[1:]
                        current_block.append(cleaned_line)
                    else:
                        current_block.append(line)

    except FileNotFoundError:
        print(f"Error: The file '{filepath}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

    return formatted_blocks

# --- Example Usage ---
if __name__ == "__main__":
    file_path = "src/env.asm"  # Replace with your actual file path
    markdown_blocks = extract_and_format_blocks(file_path)

    for i, md in enumerate(markdown_blocks, 1):
        print(f"\n--- Output Block {i} ---")
        print(md)