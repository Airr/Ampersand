### `STRL$`

```
  Converts a 64-bit floating-point number into its ASCII representation.
  The result is formatted to 6 decimal places.
```
#### Parameters:
```
  float (real8): The double-precision floating-point number to be converted.
```
#### Returns:
```
  rax: Pointer to the arena-allocated string representing the number,
       or NULL if allocation fails.
```
