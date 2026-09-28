### `MEM_COPY`

```
  Copies a block of memory from one location to another.
```
#### Parameters:
```
  dest:ptr - Pointer to the destination buffer where data will be copied.
  src:ptr  - Pointer to the source buffer from which data is copied.
  len:qword- The number of bytes to copy.
```
#### Returns:
```
  rax = Pointer to the destination buffer (same as the input dest parameter),
        indicating the completion of the copying operation.
```
