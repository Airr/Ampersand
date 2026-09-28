### `LEN`

```
  Calculates the length of a null-terminated string.
```
#### Parameters:
```
  text:ptr - Pointer to the null-terminated string whose length will be calculated.
```
#### Returns:
```
  rax = Number of characters in the string (excluding the null terminator),
        or 0 if the input pointer is null.
```
