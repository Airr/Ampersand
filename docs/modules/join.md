### `JOIN$`

```
  Joins up to 5 strings into a single string with a delimiter.
```
#### Parameters:
```
  count:qword - Number of strings to join (up to 5).
  arg1:ptr, arg2:ptr, arg3:ptr, arg4:ptr, arg5:ptr - Pointers to the strings to be joined.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the concatenated result,
        or null if an error occurs during allocation.
```
