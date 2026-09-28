### `RTRIM$`

```
  Removes trailing spaces and tab characters from a given string.
```
#### Parameters:
```
  srcString (ptr): The source string from which trailing spaces and tabs 
                   will be removed.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the trimmed version 
       of the source string. 

       If an error occurs or the source is empty, returns NULL.
```
