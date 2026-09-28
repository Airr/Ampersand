### `MKDIR`

```
  Creates a directory and any missing parent directories (like mkdir -p)
  with the specified path and mode.
```
#### Parameters:
```
  pathPtr:ptr - Pointer to a null-terminated string representing the path of the new directory.
  dirMode:dword - The mode (permissions) for the new directory, as per the mkdir system call.
```
#### Returns:
```
  rax = 0 on success,
        or an error code if an error occurs during the directory creation process.
```
