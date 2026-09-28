### `WHERE$`

```
  Searches for an executable in the system's PATH.
```
#### Parameters:
```
  argv (ptr): A pointer to the ASCII string representing the filename to search for.
```
#### Returns:
```
  rax: Pointer to an arena-allocated string containing the full path of the executable,
       or NULL if no such file is found in the PATH directories.
```
