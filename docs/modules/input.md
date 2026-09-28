### `INPUT$`

```
  Reads a line of text from standard input and stores it in an allocated string.
```
#### Parameters:
```
  msg:ptr - Pointer to a prompt message to be displayed before reading input.
```
#### Returns:
```
  rax = Pointer to a newly allocated string containing the user's input,
        or null if an error occurs during allocation or input failure.
```
