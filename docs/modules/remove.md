### `REMOVE$`

```
  Removes all occurrences of a substring from a given string.
```
#### Parameters:
```
  srcString (ptr): The source string from which to remove matches.
  match (ptr): The substring to be removed from the source string.
```
#### Returns:
```
  rax: Pointer to the modified string with all occurrences of match removed.
        If an error occurs or no matches are found, returns NULL.
```
