### `SCOPY`

```
  Copies a null-terminated string into another buffer.
```
#### Parameters:
```
  src (ptr): The source string to be copied.
```
#### Returns:
```
  rax: Pointer to a newly allocated buffer containing the copy of the source 
       string. If an error occurs or 'src' is NULL, returns NULL.
```
