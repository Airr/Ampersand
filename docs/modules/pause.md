### `EPAUSE`

```
  Pauses the execution of a program until the user presses the Enter key.
```
#### Parameters:
```
  None
```
#### Returns:
```
  None
```
#### Notes:
```
  This procedure temporarily modifies the terminal settings to enable raw mode,
  allowing character-by-character input without echoing. It then reads characters
  from standard input until it encounters an Enter key press ('\n' or '\r'), at which
  point it restores the original terminal settings and prints a clean trailing newline.

  The procedure does not return any value as it is intended to be used for pausing
  the program temporarily without affecting its execution flow.
```
