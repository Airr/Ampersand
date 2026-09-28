### `LPAD$`

```
  Pads a string with a specified character to a given length from the left.
```
#### Parameters:
```
  srcString:ptr - Pointer to the null-terminated string to be padded.
  fillCount:qword - Number of characters by which the string should be padded.
  fillChar:byte - Character used for padding.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the left-padded string,
        or null if an error occurs during allocation.
```
