### `SPLIT$`

```
  Splits a null-terminated string into an array of substrings based on a delimiter.
  Tokens are allocated from the arena and stored in a pointer array.
```
#### Parameters:
```
  srcString (ptr): A null-terminated string to be split.
  delimiterString (ptr): A null-terminated string that serves as the delimiter.
```
#### Returns:
```
  rax: Pointer to an array of pointers, where each element is a token from srcString,
       and the last element is NULL. If an error occurs, returns NULL.
```
