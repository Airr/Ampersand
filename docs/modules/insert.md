### `INSERT$`

```
  Inserts a substring into another string at a specified position.
```
#### Parameters:
```
  src:ptr - Pointer to the source string where the substring will be inserted.
  position:qword - The 1-based index at which the substring should be inserted.
  substring:ptr - Pointer to the substring that will be inserted.
```
#### Returns:
```
  rax = Pointer to a newly allocated string with the substring inserted,
        or null if an error occurs during allocation.
```
