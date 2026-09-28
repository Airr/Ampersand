### `SEEK`

```
  Sets the file offset of a file descriptor.
```
#### Parameters:
```
  fileHandle:qword - The file descriptor to seek on.
  fileOffset:qword - The new position in bytes from the origin.
  seekFlags:qword - Indicates where the offset is relative to (e.g., start, current position).
```
#### Returns:
```
  rax = New file offset on success,
        a negative error code on failure.
```
