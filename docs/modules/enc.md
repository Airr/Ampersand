### `ENC$`

```
  Encloses the given source string within a pair of characters
```
#### Parameters:
```
  srcPtr:ptr - Pointer to the source string to be enclosed.
  encChar:dword - The character used for enclosing (both opening and closing).
```
#### Returns:
```
  rax = Pointer to the newly allocated string containing the enclosed content 
  of srcPtr, or null if allocation fails.
```
