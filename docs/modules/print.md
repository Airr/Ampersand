### `PRINT`

```
  Outputs formatted text to standard output.
```
#### Parameters:
```
  fmt (pointer): A null-terminated format string specifying the output format.
  ...: Variable arguments corresponding to the placeholders in the format string.
```
#### Returns:
```
  None
```
#### Supports:
```
  %c   character
  %%   literal %
  %s   string
  %d   decimal
  %u   unsigned decimal
  %x   hexadecimal
```

---

### `PRINT`

```
  Outputs formatted text to standard output.
```
#### Parameters:
```
  fmt (pointer): A null-terminated format string specifying the output format.
  ...: Variable arguments corresponding to the placeholders in the format string.
```
#### Returns:
```
  None
```
#### Notes:
```
  The function uses a buffer (print_buf) to store formatted text before writing it
  to standard output. It supports various format specifiers including %d for integers,
  %u for unsigned integers, %x for hexadecimal values, %s for strings, and %% for the literal "%".

  For unsupported format specifiers or errors during formatting, the function simply ignores them.
  The buffer is flushed to standard output at the end of the formatted text.
```
