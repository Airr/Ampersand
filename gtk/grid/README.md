# GTK Grid Demo

This example demonstrates how to build a graphical user interface using **GTK+ 3** and **UASM** on Linux x86-64, combining **Ampersand**'s standard runtime routines with GTK layout containers and signal callbacks.

---

## Overview

[`demo.asm`](demo.asm) creates a GTK+ 3 desktop window utilizing a **`GtkGrid`** container for responsive multi-column/multi-row layout. It includes a text entry box and three action buttons with event handlers that dynamically update the text box content when clicked.

---

## Key Features & Concepts Demonstrated

### 1. Grid Layout (`GtkGrid`)
- **Container Creation**: Uses `NEW_GRID()` (`gtk_grid_new`) and adds it to the window via `CONTAINER_ADD(win, grid)`.
- **Spacing & Alignment**: Configures `row-spacing`, `column-spacing`, `halign`, and `valign` using `SET_PROP` (`g_object_set`).
- **Widget Placement**: Uses `GRID_ATTACH(grid, widget, column, row, width_span, height_span)`:
  - Text Entry placed at Column 0, Row 0 (with `hexpand` enabled to fill available width).
  - Buttons 1, 2, and 3 stacked vertically in Column 1 at Rows 0, 1, and 2.

### 2. Signal Handling & Callbacks
- **Window Close**: Connects the window `"destroy"` signal to `gtk_main_quit` via `SET_CALLBACK`.
- **Button Clicks**: Connects the `"clicked"` signal of each button to `on_button_clicked`, passing the button ID (`1`, `2`, or `3`) as user data.
- **Register Preservation**: Uses `USES r12 r13 rbx rsi rdi` in the callback procedure to preserve registers across GTK calls according to the System V AMD64 ABI.

### 3. Ampersand Runtime Integration
- **String Formatting**: Formats dynamic feedback strings using Ampersand's `SPRINT("Button %d Clicked", data)`.
- **Widget Property Updates**: Sets the text in the entry widget dynamically via `SET_PROP(entry1, "text", formatted_string)`.

---

## Code Breakdown

```assembly
; Callback executed when any of the buttons are clicked
on_button_clicked PROC USES r12 r13 rbx rsi rdi widget:QWORD, data:QWORD
    mov rax, data
    mov rbx, SPRINT("Button %d Clicked", rax)
    SET_PROP(entry1, "text", rbx)

    xor eax, eax ; Return 0/FALSE to indicate event handled
    ret
on_button_clicked endp
```

---

## Requirements

- **UASM** (v2.57 or newer recommended)
- **GTK+ 3 Development Libraries**: `libgtk-3-dev` (Ubuntu/Debian) or `gtk3-devel` (Fedora/RHEL/Arch)
- **Ampersand Library**: Installed to `/usr/local/lib/libamp.a` and `/usr/local/include/amp.inc`

---

## Building and Running

Compile and link using the provided [`Makefile`](Makefile):

```bash
make
```

### Manual Build Commands

```bash
# 1. Assemble using UASM
uasm -elf64 -q -pie -zcw -I/usr/local/include -Fo demo.o demo.asm

# 2. Link using GCC with GTK+ 3 and libamp
gcc -o demo demo.o /usr/local/lib/libamp.a -pie -s -Wl,--as-needed -ldl $(pkg-config --libs gtk+-3.0) -nostartfiles -Wl,-e,_start

# 3. Run the executable
./demo
```

### Cleaning Build Artifacts

```bash
make clean
```
