### `READ`

```
  Reads data from a file descriptor into a buffer.
```
#### Parameters:
```
  fileHandle:qword - The file descriptor to read from.
  buffer:ptr - Pointer to the buffer where the data will be stored.
  numBytes:qword - Number of bytes to read.
```
#### Returns:
```
  rax = Number of bytes actually read on success,
        a negative error code on failure.
```
