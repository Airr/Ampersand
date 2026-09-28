### `REPEAT$`

```
  Repeats a given pattern 'count' times.
```
#### Parameters:
```
  count (qword): The number of times to repeat the pattern.
  pattern (ptr): The substring to be repeated.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the repeated pattern.
        If an error occurs or 'count' is less than or equal to 0, returns NULL.
```
