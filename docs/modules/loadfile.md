### `LOADFILE$`

```
  Reads a file into memory and returns its contents as a string.
```
#### Parameters:
```
  filePath:ptr - Pointer to the null-terminated string representing 
  the path of the file to be loaded.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the contents of the file,
        or null if an error occurs during file opening, reading, or allocation.
```
