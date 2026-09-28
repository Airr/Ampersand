### `MID$`

```
  Extracts a substring from a source string, starting at a given index and of 
  a specified length.
```
#### Parameters:
```
  srcString:ptr - Pointer to the null-terminated source string 
                  from which to extract.
  index:qword   - The starting index of the substring in the source string.
  numBytes:qword- The number of bytes (characters) to include in 
                  the extracted substring.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the extracted substring,
        or null if an error occurs during allocation or if the input parameters 
        are invalid.
```
