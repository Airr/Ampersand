### `SPRINT`

```
  Formats a string using printf-style formatting and stores the result in an 
  arena-allocated buffer.
```
#### Parameters:
```
  fmt (ptr): A null-terminated format string. Supported specifiers are:
    %c - character
    %% - literal '%'
    %s - string
    %d - signed decimal integer
    %u - unsigned decimal integer
    %x - hexadecimal integer (lowercase)

  ...: Variable arguments corresponding to placeholders in fmt.
```
#### Returns:
```
  rax: Pointer to the formatted string stored in the arena, or NULL if allocation fails.
```
