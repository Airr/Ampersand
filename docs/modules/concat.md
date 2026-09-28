### `CONCAT$`

```
  Concatenates two null-terminated strings and allocates memory from an arena 
  to store the result.
```
#### Parameters:
```
  str1:ptr - Pointer to the first string.
  str2:ptr - Pointer to the second string.
```
#### Returns:
```
  rax = Pointer to the newly allocated string containing the concatenated content
   of str1 and str2, or null if allocation fails.
```
