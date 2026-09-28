### `RIGHT$`

```
  Extracts the specified number of characters from the right end of a string.
```
#### Parameters:
```
  src (ptr): The source string from which to extract the substring.
  count (qword): The number of characters to extract from the right side.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the extracted substring. 
       If an error occurs or 'count' is zero, returns NULL.
```
