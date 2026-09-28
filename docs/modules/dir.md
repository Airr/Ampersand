### `DIR$`

```
  Returns a pointer to an array of strings representing the files in a directory 
```
#### Parameters:
```
  dir_path:ptr - Pointer to the directory path string.
```
#### Returns:
```
  rax = Pointer to the array of strings containing the matching filenames,
        or null if allocation fails or no files match.
```
#### Notes:
```
  The returned array includes a NULL terminator at the end.
```
