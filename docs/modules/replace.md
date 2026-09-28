### `REPLACE$`

```
  Replaces all occurrences of a substring (pattern) within a string with another 
  substring.
```
#### Parameters:
```
  src (ptr): The source string in which to replace occurrences of the pattern.
  pattern (ptr): The substring to be replaced.
  replaceStr (ptr): The substring to insert as a replacement for each occurrence
                    of the pattern.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the source string with all 
       occurrences of the pattern replaced by replaceStr. If an error occurs or no 
       replacements are made, returns NULL.
```
