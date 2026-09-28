### `COMPARE`

```
  Compares two null-terminated strings lexicographically.
```
#### Parameters:
```
  str1:ptr - Pointer to the first string.
  str2:ptr - Pointer to the second string.
```
#### Returns:
```
  rax = Result of the comparison:
        0 if the strings are equal
        Positive value if str1 is lexicographically greater than str2
        Negative value if str1 is lexicographically less than str2
```
