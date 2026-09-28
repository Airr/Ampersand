### `LTRIM$`

```
  Trims leading whitespace (spaces and tabs) from a string.
```
#### Parameters:
```
  srcString:ptr - Pointer to the null-terminated string from which leading 
                   whitespace will be removed.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the trimmed string,
        or null if an error occurs during allocation.
```
