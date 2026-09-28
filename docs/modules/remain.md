### `REMAIN$`

```
  Returns the substring of pSource starting from the first occurrence of pMatch.
```
#### Parameters:
```
  pSource (ptr): The source string from which to start the substring.
  pMatch (ptr): The substring at which to begin the returned substring.
```
#### Returns:
```
  rax: Pointer to a null-terminated string containing the portion of pSource
       starting from the first occurrence of pMatch.

       If an error occurs or no match is found, returns NULL.
```
