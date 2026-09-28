### `COMMAND$`

```
  Retrieves a command-line argument from the program's arguments.
```
#### Parameters:
```
  argnum:qword - The zero-based index of the desired command-line argument.
```
#### Returns:
```
  rax = Pointer to the string containing the specified command-line argument,
        or null if the specified index is out of bounds or an error occurs.
```
