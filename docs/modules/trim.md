### `TRIM$`

```
  Trims leading and trailing whitespace from a string and collapses internal
  spaces into a single space.
```
#### Parameters:
```
  srcString (ptr): A pointer to the source string to be trimmed.
```
#### Returns:
```
  rax: Pointer to an arena-allocated string with all leading/trailing 
       whitespace removed and consecutive internal spaces collapsed. 

       If allocation fails, returns NULL.
```
