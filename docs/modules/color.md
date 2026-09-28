### `COLOR`

```
  Colorizes a given string based on the provided color code.
  The function allocates memory from an arena and returns a new string with 
  the ANSI escape codes applied.
```
#### Parameters:
```
  text:ptr - Pointer to the input text string.
  colorcode:qword - The foreground color code (0-7) for the text.
```
#### Returns:
```
  rax = Pointer to the newly allocated string containing the colored text, 
  or null if allocation fails.
```
