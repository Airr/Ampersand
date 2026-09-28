### `RENAME`

```
  Rename a file or directory from oldpath to newpath.
```
#### Parameters:
```
  oldpath (ptr): A pointer to a null-terminated ASCII string representing 
                 the current path of the file or directory.
  newpath (ptr): A pointer to a null-terminated ASCII string representing 
                 the new path for the file or directory.
```
#### Returns:
```
  rax: 1 if successful, 0 if an error occurred.
```
#### Notes:
```
  - This function will fail if attempting to rename a directory and
    the newpath already exists and contains files.
```
