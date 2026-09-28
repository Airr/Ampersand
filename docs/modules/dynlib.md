### `LOADLIB`

```
  Loads a shared library using dlopen().
```
#### Parameters:
```
  filename (ptr): A pointer to the ASCII string representing the path to the 
                   shared library.
```
#### Returns:
```
  rax: Pointer to the handle of the loaded library, 
       or NULL if the library could not be opened.
```
#### Notes:
```
  - This function requires linking against libc with the option "-lc".
```

---

### `FREELIB`

```
  Closes a previously loaded shared library using dlclose().
```
#### Parameters:
```
  handle (qword): The handle of the shared library to close.
```
#### Returns:
```
  rax: 0 on success, non-zero value on failure.
```
#### Notes:
```
  - This function requires linking against libc with the option "-lc".
```

---

### `LOADFUNC`

```
  Retrieves a function pointer from a previously loaded shared library 
  using dlsym().
```
#### Parameters:
```
  libHandle (qword): The handle of the shared library.
  funcname (ptr): A pointer to the ASCII string representing the name of the function.
```
#### Returns:
```
  rax: Pointer to the function, or NULL if the function could not be found in the library.
```
#### Notes:
```
  - This function requires linking against libc with the option "-lc".
```
