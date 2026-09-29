### `CHR$`

```
  Builds a string from a list of character codes (0-255) terminated by a
  negative value (e.g. CHR_END / -1).
```
#### Parameters:
```
  codes (vararg): Character codes (0-255) terminated by a negative value.
```
#### Returns:
```
  rax: Pointer to the newly allocated null-terminated string, or NULL on error.
```
