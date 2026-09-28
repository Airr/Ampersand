# VS Code Extension: UAsm Assembly Syntax

This directory contains the **UAsm Assembly Syntax** (`uasm-syntax`) extension for Visual Studio Code (and VSCodium), providing syntax highlighting and language support for **UASM** x86_64 assembly (`.asm` and `.inc` files).

---

## Features

- **Syntax Highlighting**: Comprehensive TextMate grammar (`uasm.tmLanguage.json`) supporting:
  - UASM directives, pseudo-ops, and memory segment definitions.
  - x86-64 instructions and registers.
  - High-level control-flow macros (`.IF`, `.ELSE`, `.WHILE`, `.ENDIF`, `PROC`, `INVOKE`).
  - Ampersand function naming conventions (`$` suffix) and constants.
  - Strings, hexadecimal / binary / decimal literals, and escape sequences.
- **Language Configuration**:
  - Line comments (`lineComment`: `;`) for single-key comment toggling (`Ctrl+/` or `Cmd+/`).
  - Auto-closing pairs for brackets, braces, parentheses, and quotes (`()`, `[]`, `{}`, `""`, `''`).

---

## Extension Structure

- **[`uasm-syntax/package.json`](uasm-syntax/package.json)**: Extension manifest declaring language ID `uasm`, associated file extensions (`.asm`, `.inc`), and grammar bindings.
- **[`uasm-syntax/language-configuration.json`](uasm-syntax/language-configuration.json)**: Editor bracket matching and comment behavior.
- **[`uasm-syntax/syntaxes/uasm.tmLanguage.json`](uasm-syntax/syntaxes/uasm.tmLanguage.json)**: TextMate grammar definitions for UASM assembly.

---

## Manual Installation Instructions

You can install the extension manually using either of the two methods below:

### Method 1: Direct Copy or Symlink (Fastest)

VS Code automatically loads extensions placed in its user extensions directory.

#### On Linux:
```bash
# Option A: Create a symbolic link (recommended for live editing)
ln -s "$(pwd)/vscode/uasm-syntax" ~/.vscode/extensions/uasm-syntax

# Option B: Copy directory directly
cp -r vscode/uasm-syntax ~/.vscode/extensions/
```

*(If using **VSCodium**, use `~/.vscode-oss/extensions/` instead of `~/.vscode/extensions/`)*

#### On macOS:
```bash
# Copy into user extensions directory
cp -r vscode/uasm-syntax ~/.vscode/extensions/
```

#### On Windows (PowerShell):
```powershell
Copy-Item -Recurse -Path "vscode\uasm-syntax" -Destination "$HOME\.vscode\extensions\uasm-syntax"
```

---

### Method 2: Package as VSIX and Install

If you prefer installing via a standard `.vsix` extension package:

1. **Package the extension** using `vsce` (Node.js required):
   ```bash
   cd vscode/uasm-syntax
   npx @vscode/vsce package
   ```
   *(This generates `uasm-syntax-0.0.1.vsix` in the directory)*

2. **Install via Command Line**:
   ```bash
   code --install-extension uasm-syntax-0.0.1.vsix
   ```

3. **Or Install via the VS Code GUI**:
   - Open VS Code.
   - Open the **Extensions** view (`Ctrl+Shift+X` or `Cmd+Shift+X`).
   - Click the **`...` (Views and More Actions)** menu in the top-right of the Extensions panel.
   - Select **Install from VSIX...**
   - Browse and select the generated `.vsix` file.

---

## Activating and Verifying

1. **Reload VS Code**:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open the Command Palette.
   - Run `Developer: Reload Window`.
2. **Open an Assembly File**:
   - Open any `.asm` or `.inc` file.
   - Look at the bottom right of the status bar; the language mode should display **UAsm**.
   - If not automatically selected, click the language mode or press `Ctrl+K M`, type `UAsm`, and press `Enter`.
