### `RPAD$`

```
  Pads the right side of a string with a specified character until it reaches 
  the specified length.
```
#### Parameters:
```
  src (ptr): The source string to be padded.
  count (qword): The total length of the resulting string after padding.
  fillChar (byte): The character used for padding.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the original string 
       padded with 'fillChar' on the right side. If an error occurs or 
       'count' is zero, returns NULL.
```
