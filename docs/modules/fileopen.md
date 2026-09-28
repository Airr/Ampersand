### `OPEN`

```
  Opens a file and returns a file descriptor.
```
#### Parameters:
```
  filePath:ptr - Pointer to a string containing the path of the file to open.
  fileFlags:qword - Flags indicating the mode in which to open the file (e.g., read, write).
  fileMode:qword - Permissions to set if creating the file (if applicable).
```
#### Returns:
```
  rax = File descriptor on success,
        a negative error code on failure.
```
