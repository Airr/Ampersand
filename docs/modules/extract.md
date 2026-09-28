### `EXTRACT$`

```
  Extracts a prefix from a string based on a match with another string.
  If no match is found, returns the entire input string.
```
#### Parameters:
```
  mainStr:ptr - Pointer to the source string from which to extract.
  matchStr:ptr - Pointer to the substring that indicates where to stop extraction.
```
#### Returns:
```
  rax = Pointer to a new string containing the extracted prefix,
        or a copy of the entire input string if no match is found.
```
