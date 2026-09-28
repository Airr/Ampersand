### `ENV$`

```
  Retrieves the value of an environment variable by name.
```
#### Parameters:
```
  namePtr:ptr - Pointer to a string representing the name 
  of the environment variable to retrieve.
```
#### Returns:
```
  rax = Pointer to a string containing the value of the environment variable,
        or null if the environment variable is not found.
```
