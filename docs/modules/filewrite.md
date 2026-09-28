### `WRITE$`

```
  Writes data from a buffer to a file descriptor.
```
#### Parameters:
```
  fileHandle:qword - The file descriptor to write to.
  buffer:ptr - Pointer to the buffer containing the data to write.
  numBytes:qword - Number of bytes to write.
```
#### Returns:
```
  rax = Number of bytes actually written on success,
        a negative error code on failure.
```
