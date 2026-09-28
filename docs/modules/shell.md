### `SHELL`

```
  Executes a command in a new process using the system call sys_execve.
```
#### Parameters:
```
  cmd_str (ptr): A null-terminated string representing the command to execute.
```
#### Returns:
```
  rax: The exit status of the child process if successful. If an error occurs, 
       returns -22 for invalid argument or -1 for other errors.
```
