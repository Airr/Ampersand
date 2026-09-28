### `LEFT$`

```
  Extracts a specified number of characters from the beginning of a string.
```
#### Parameters:
```
  srcString:ptr - Pointer to the source string from which characters will be extracted.
  numBytes:qword - Number of characters to extract from the beginning of the string.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the extracted characters,
        or null if an error occurs during allocation.
```
