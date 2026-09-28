### `MEM_ALLOC`

```
  Allocates a block of memory from the system's heap.
```
#### Parameters:
```
  memsize:qword - The size, in bytes, of the memory block to allocate.
```
#### Returns:
```
  rax = Pointer to the newly allocated block of memory,
        or null if an error occurs during allocation.
```
