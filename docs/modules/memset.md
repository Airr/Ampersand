### `MEM_SET`

```
  Sets a block of memory to a specific value.
```
#### Parameters:
```
  dest:ptr - Pointer to the destination buffer to be filled with the given value.
  val:byte - The byte value to fill the buffer with.
  len:qword- The number of bytes in the buffer to set to the given value.
```
#### Returns:
```
  rax = Pointer to the destination buffer (same as the input dest parameter),
        indicating the completion of the setting operation.
```
