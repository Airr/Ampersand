;******************************************************************************
; JWASM Syscall Macro - Linux x86-64 Only
;******************************************************************************

;----------------------------------------
; Standard File Descriptors
;----------------------------------------

STDIN                 EQU 0 ; Standard input
STDOUT                EQU 1 ; Standard output
STDERR                EQU 2 ; Standard error

;----------------------------------------
; System Call Numbers (x86-64)
;----------------------------------------
SYS_READ              EQU 0 ; Read from a file descriptor
SYS_WRITE             EQU 1 ; Write to a file descriptor
SYS_OPEN              EQU 2 ; Open and optionally create a file
SYS_CLOSE             EQU 3 ; Close a file descriptor
SYS_STAT              EQU 4 ; Get file status (by filename)
SYS_FSTAT             EQU 5 ; Get file status (by file descriptor)
SYS_LSTAT             EQU 6 ; Get file status (symbolic link aware)
SYS_POLL              EQU 7 ; Wait for some event on a file descriptor
SYS_LSEEK             EQU 8 ; Reposition read/write file offset
SYS_MMAP              EQU 9 ; Map files or devices into memory
SYS_MPROTECT          EQU 10 ; Set protection on a region of memory
SYS_MUNMAP            EQU 11 ; Unmap pages of memory
SYS_BRK               EQU 12 ; Change data segment size (heap allocation)
SYS_RT_SIGACTION      EQU 13 ; Examine and change a signal action
SYS_RT_SIGPROCMASK    EQU 14 ; Examine and change blocked signals
SYS_RT_SIGRETURN      EQU 15 ; Return from signal handler
SYS_IOCTL             EQU 16 ; Control device parameters
SYS_PREAD64           EQU 17 ; Read from a file descriptor at a given offset
SYS_PWRITE64          EQU 18 ; Write to a file descriptor at a given offset
SYS_READV             EQU 19 ; Read data into multiple buffers
SYS_WRITEV            EQU 20 ; Write data from multiple buffers
SYS_ACCESS            EQU 21 ; Check user's permissions for a file
SYS_PIPE              EQU 22 ; Create pipe
SYS_SELECT            EQU 23 ; Synchronous I/O multiplexing
SYS_SCHED_YIELD       EQU 24 ; Yield the processor
SYS_MREMAP            EQU 25 ; Remap a virtual memory address
SYS_MSYNC             EQU 26 ; Synchronize a file with a memory map
SYS_MINCORE           EQU 27 ; Determine whether pages are resident in memory
SYS_MADVISE           EQU 28 ; Give advice about use of memory
SYS_SHMGET            EQU 29 ; Allocate shared memory segment
SYS_SHMAT             EQU 30 ; Attach shared memory segment
SYS_SHMCTL            EQU 31 ; Shared memory control
SYS_DUP               EQU 32 ; Duplicate a file descriptor
SYS_DUP2              EQU 33 ; Duplicate a file descriptor (to specific target)
SYS_PAUSE             EQU 34 ; Wait for signal
SYS_NANOSLEEP         EQU 35 ; High-resolution sleep
SYS_GETITIMER         EQU 36 ; Get value of an interval timer
SYS_ALARM             EQU 37 ; Set an alarm clock for delivery of a signal
SYS_SETITIMER         EQU 38 ; Set value of an interval timer
SYS_GETPID            EQU 39 ; Get process ID
SYS_SENDFILE          EQU 40 ; Transfer data between file descriptors
SYS_SOCKET            EQU 41 ; Create an endpoint for communication
SYS_CONNECT           EQU 42 ; Initiate a connection on a socket
SYS_ACCEPT            EQU 43 ; Accept a connection on a socket
SYS_SENDTO            EQU 44 ; Send a message on a socket
SYS_RECVFROM          EQU 45 ; Receive a message from a socket
SYS_SENDMSG           EQU 46 ; Send a message on a socket via msghdr
SYS_RECVMSG           EQU 47 ; Receive a message from a socket via msghdr
SYS_SHUTDOWN          EQU 48 ; Shut down part of a full-duplex connection
SYS_BIND              EQU 49 ; Bind a name to a socket
SYS_LISTEN            EQU 50 ; Listen for connections on a socket
SYS_GETSOCKNAME       EQU 51 ; Get socket name
SYS_GETPEERNAME       EQU 52 ; Get name of connected socket peer
SYS_SOCKETPAIR        EQU 53 ; Create a pair of connected sockets
SYS_SETSOCKOPT        EQU 54 ; Set options on sockets
SYS_GETSOCKOPT        EQU 55 ; Get options on sockets
SYS_CLONE             EQU 56 ; Create a child process (thread/fork)
SYS_FORK              EQU 57 ; Create a child process
SYS_VFORK             EQU 58 ; Create a child process and block parent
SYS_EXECVE            EQU 59 ; Execute program
SYS_EXIT              EQU 60 ; Terminate the calling process
SYS_WAIT4             EQU 61 ; Wait for process termination
SYS_KILL              EQU 62 ; Send signal to a process
SYS_UNAME             EQU 63 ; Get name and information about current kernel
SYS_SEMGET            EQU 64 ; Get semaphore set identifier
SYS_SEMOP             EQU 65 ; Semaphore operations
SYS_SEMCTL            EQU 66 ; Semaphore control operations
SYS_SHMDT             EQU 67 ; Detach shared memory segment
SYS_MSGGET            EQU 68 ; Get message queue identifier
SYS_MSGSND            EQU 69 ; Send message to message queue
SYS_MSGRCV            EQU 70 ; Receive message from message queue
SYS_MSGCTL            EQU 71 ; Message queue control operations
SYS_FCNTL             EQU 72 ; Manipulate file descriptor
SYS_FLOCK             EQU 73 ; Apply or remove an advisory lock on an open file
SYS_FSYNC             EQU 74 ; Synchronize a file's in-core state with storage device
SYS_FDATASYNC         EQU 75 ; Synchronize data of a file with storage device
SYS_TRUNCATE          EQU 76 ; Truncate a file to a specified length
SYS_FTRUNCATE         EQU 77 ; Truncate a file to a specified length by descriptor
SYS_GETDENTS          EQU 78 ; Get directory entries
SYS_GETCWD            EQU 79 ; Get current working directory
SYS_CHDIR             EQU 80 ; Change working directory
SYS_FCHDIR            EQU 81 ; Change working directory by file descriptor
SYS_RENAME            EQU 82 ; Change the name or location of a file
SYS_MKDIR             EQU 83 ; Create a directory
SYS_RMDIR             EQU 84 ; Delete a directory
SYS_CREAT             EQU 85 ; Create a file
SYS_LINK              EQU 86 ; Make a new name for a file
SYS_UNLINK            EQU 87 ; Delete a name and possibly the file it refers to
SYS_SYMLINK           EQU 88 ; Make a symbolic link to a file
SYS_READLINK          EQU 89 ; Read value of a symbolic link
SYS_CHMOD             EQU 90 ; Change file permissions
SYS_FCHMOD            EQU 91 ; Change file permissions by file descriptor
SYS_CHOWN             EQU 92 ; Change file ownership
SYS_FCHOWN            EQU 93 ; Change file ownership by file descriptor
SYS_LCHOWN            EQU 94 ; Change ownership of symbolic link
SYS_UMASK             EQU 95 ; Set file mode creation mask
SYS_GETTIMEOFDAY      EQU 96 ; Get time
SYS_GETRLIMIT         EQU 97 ; Get resource limits
SYS_GETRUSAGE         EQU 98 ; Get resource usage
SYS_SYSINFO           EQU 100 ; Get overall system statistics
SYS_TIMES             EQU 100 ; Get process times
SYS_PTRACE            EQU 101 ; Process trace
SYS_GETUID            EQU 102 ; Get real user ID
SYS_SYSLOG            EQU 103 ; Read and/or clear kernel message ring buffer
SYS_GETGID            EQU 104 ; Get real group ID
SYS_SETUID            EQU 105 ; Set user ID
SYS_SETGID            EQU 106 ; Set group ID
SYS_GETEUID           EQU 107 ; Get effective user ID
SYS_GETEGID           EQU 108 ; Get effective group ID
SYS_SETPGID           EQU 109 ; Set process group ID for job control
SYS_GETPPID           EQU 110 ; Get parent process ID
SYS_GETPGRP           EQU 111 ; Get process group ID of the calling process
SYS_SETSID            EQU 112 ; Create session and set process group ID
SYS_SETREUID          EQU 113 ; Set real and/or effective user ID
SYS_SETREGID          EQU 114 ; Set real and/or effective group ID
SYS_GETGROUPS         EQU 115 ; Get list of supplementary group IDs
SYS_SETGROUPS         EQU 116 ; Set list of supplementary group IDs
SYS_SETRESUID         EQU 117 ; Set real, effective, and saved user ID
SYS_GETRESUID         EQU 118 ; Get real, effective, and saved user ID
SYS_SETRESGID         EQU 119 ; Set real, effective, and saved group ID
SYS_GETRESGID         EQU 120 ; Get real, effective, and saved group ID
SYS_GETPGID           EQU 121 ; Get process group ID
SYS_SETFSUID          EQU 122 ; Set user identity for filesystem checks
SYS_SETFSGID          EQU 123 ; Set group identity for filesystem checks
SYS_GETSID            EQU 124 ; Get session ID
SYS_CAPGET            EQU 125 ; Get capability of thread(s)
SYS_CAPSET            EQU 126 ; Set capability of thread(s)
SYS_RT_SIGPENDING     EQU 127 ; Examine pending signals
SYS_RT_SIGTIMEDWAIT   EQU 128 ; Wait for queued signals (with timeout)
SYS_RT_SIGQUEUEINFO   EQU 129 ; Queue a signal and data
SYS_RT_SIGSUSPEND     EQU 130 ; Wait for signal
SYS_SIGALTSTACK       EQU 131 ; Set and/or get signal stack context
SYS_UTIME             EQU 132 ; Change file last access and modification times
SYS_MKNOD             EQU 133 ; Create a special or ordinary file
SYS_USELIB            EQU 134 ; Load shared library (obsolete)
SYS_PERSONALITY       EQU 135 ; Set the process execution domain
SYS_USTAT             EQU 136 ; Get filesystem statistics (obsolete)
SYS_STATFS            EQU 137 ; Get filesystem statistics
SYS_FSTATFS           EQU 138 ; Get filesystem statistics by file descriptor
SYS_SYSFS             EQU 139 ; Get filesystem type information
SYS_GETPRIORITY       EQU 140 ; Get program scheduling priority
SYS_SETPRIORITY       EQU 141 ; Set program scheduling priority
SYS_SCHED_SETPARAM    EQU 142 ; Set scheduling parameters
SYS_SCHED_GETPARAM    EQU 143 ; Get scheduling parameters
SYS_SCHED_SETSCHEDULER EQU 144 ; Set scheduling policy and parameters
SYS_SCHED_GETSCHEDULER EQU 145 ; Get scheduling policy
SYS_SCHED_GET_PRIORITY_MAX EQU 146 ; Get maximum priority value
SYS_SCHED_GET_PRIORITY_MIN EQU 147 ; Get minimum priority value
SYS_SCHED_RR_GET_INTERVAL EQU 148 ; Get SCHED_RR interval for the process
SYS_MLOCK             EQU 149 ; Lock memory
SYS_MUNLOCK           EQU 150 ; Unlock memory
SYS_MLOCKALL          EQU 151 ; Lock all calling process's memory
SYS_MUNLOCKALL        EQU 152 ; Unlock all calling process's memory
SYS_VHANGUP           EQU 153 ; Hang up the current terminal
SYS_MODIFY_LDT        EQU 154 ; Read or write local descriptor table
SYS_PIVOT_ROOT        EQU 155 ; Change the root filesystem
SYS__SYSCTL           EQU 156 ; Read/write system parameters (deprecated)
SYS_PRCTL             EQU 157 ; Operations on a process or thread
SYS_ARCH_PRCTL        EQU 158 ; Set architecture-specific thread state
SYS_ADJTIMEX          EQU 159 ; Tune kernel clock
SYS_SETRLIMIT         EQU 160 ; Set resource limits
SYS_CHROOT            EQU 161 ; Change root directory
SYS_SYNC              EQU 162 ; Commit buffer cache to disk
SYS_ACCT              EQU 163 ; Switch process accounting on or off
SYS_SETTIMEOFDAY      EQU 164 ; Set time
SYS_MOUNT             EQU 165 ; Mount filesystem
SYS_UMOUNT2           EQU 166 ; Unmount filesystem
SYS_SWAPON            EQU 167 ; Start swapping to file/device
SYS_SWAPOFF           EQU 168 ; Stop swapping to file/device
SYS_REBOOT            EQU 169 ; Reboot or enable/disable Ctrl-Alt-Del
SYS_SETHOSTNAME       EQU 170 ; Set hostname
SYS_SETDOMAINNAME     EQU 171 ; Set NIS domain name
SYS_IOPL              EQU 172 ; Change I/O privilege level
SYS_IOPERM            EQU 173 ; Set port input/output permissions
SYS_INIT_MODULE       EQU 175 ; Load a kernel module
SYS_DELETE_MODULE     EQU 176 ; Unload a kernel module
SYS_QUOTACTL          EQU 179 ; Manipulate disk quotas
SYS_GETPMSG           EQU 181 ; Stream messages (STREAMS)
SYS_PUTPMSG           EQU 182 ; Stream messages (STREAMS)
SYS_AFS_SYSCALL       EQU 183 ; Andrew File System syscall
SYS_TUXCALL           EQU 184 ; Tux (in-kernel HTTP server) syscall
SYS_SECURITY          EQU 185 ; Security module syscall
SYS_GETTID            EQU 186 ; Get thread ID
SYS_READAHEAD         EQU 187 ; Initiate file read ahead into page cache
SYS_SETXATTR          EQU 188 ; Set extended attribute value
SYS_LSETXATTR         EQU 189 ; Set extended attribute value (symbolic link aware)
SYS_FSETXATTR         EQU 190 ; Set extended attribute value by file descriptor
SYS_GETXATTR          EQU 191 ; Get extended attribute value
SYS_LGETXATTR         EQU 192 ; Get extended attribute value (symbolic link aware)
SYS_FGETXATTR         EQU 193 ; Get extended attribute value by file descriptor
SYS_LISTXATTR         EQU 194 ; List extended attribute names
SYS_LLISTXATTR        EQU 195 ; List extended attribute names (symbolic link aware)
SYS_FLISTXATTR        EQU 196 ; List extended attribute names by file descriptor
SYS_REMOVEXATTR       EQU 197 ; Remove extended attribute
SYS_LREMOVEXATTR      EQU 198 ; Remove extended attribute (symbolic link aware)
SYS_FREMOVEXATTR      EQU 199 ; Remove extended attribute by file descriptor
SYS_TKILL             EQU 200 ; Send signal to a specific thread
SYS_TIME              EQU 201 ; Get time in seconds
SYS_FUTEX             EQU 202 ; Fast user-space mutex
SYS_SCHED_SETAFFINITY EQU 203 ; Set thread's CPU affinity mask
SYS_SCHED_GETAFFINITY EQU 204 ; Get thread's CPU affinity mask
SYS_SET_THREAD_AREA   EQU 205 ; Set a thread local storage (TLS) area
SYS_IO_SETUP          EQU 206 ; Create asynchronous I/O context
SYS_IO_DESTROY        EQU 207 ; Destroy asynchronous I/O context
SYS_IO_GETEVENTS      EQU 208 ; Read asynchronous I/O events from completion queue
SYS_IO_SUBMIT         EQU 209 ; Submit asynchronous I/O blocks for processing
SYS_IO_CANCEL         EQU 210 ; Cancel pending asynchronous I/O request
SYS_GET_THREAD_AREA   EQU 211 ; Get a thread local storage (TLS) area
SYS_LOOKUP_DCOOKIE    EQU 212 ; Return path of directory entry from cookie
SYS_EPOLL_CREATE      EQU 213 ; Open an epoll file descriptor
SYS_EPOLL_CTL_OLD     EQU 214 ; Control interface for epoll (old)
SYS_EPOLL_WAIT_OLD    EQU 215 ; Wait for an event on epoll file descriptor (old)
SYS_REMAP_FILE_PAGES  EQU 216 ; Remap file pages in memory
SYS_GETDENTS64        EQU 217 ; Get 64-bit directory entries
SYS_SET_TID_ADDRESS   EQU 218 ; Set thread ID address
SYS_RESTART_SYSCALL   EQU 219 ; Restart a system call after interruption by signal
SYS_SEMTIMEDOP        EQU 220 ; Semaphore operations with timeout
SYS_FADVISE64         EQU 221 ; Pre-declare an access pattern for file data
SYS_TIMER_CREATE      EQU 222 ; Create a per-process timer
SYS_TIMER_SETTIME     EQU 223 ; Arm/disarm and arm per-process timer
SYS_TIMER_GETTIME     EQU 224 ; Fetch time remaining for per-process timer
SYS_TIMER_GETOVERRUN  EQU 225 ; Get overrun count for per-process timer
SYS_TIMER_DELETE      EQU 226 ; Delete a per-process timer
SYS_CLOCK_SETTIME     EQU 227 ; Set specified clock time
SYS_CLOCK_GETTIME     EQU 228 ; Get specified clock time
SYS_CLOCK_GETRES      EQU 229 ; Get resolution of specified clock
SYS_CLOCK_NANOSLEEP   EQU 230 ; High-resolution sleep with specific clock
SYS_EXIT_GROUP        EQU 231 ; Exit all threads in a process
SYS_EPOLL_WAIT        EQU 232 ; Wait for an event on an epoll file descriptor
SYS_EPOLL_CTL         EQU 233 ; Control interface for an epoll descriptor
SYS_TGKILL            EQU 234 ; Send signal to a thread group member
SYS_UTIMES            EQU 235 ; Change file access and modification times
SYS_VSERVER           EQU 236 ; VServer-related system call
SYS_MBIND             EQU 237 ; Set memory policy for a memory range
SYS_SET_MEMPOLICY     EQU 238 ; Set default NUMA memory policy for thread
SYS_GET_MEMPOLICY     EQU 239 ; Get NUMA memory policy for thread
SYS_MQ_OPEN           EQU 240 ; Open a POSIX message queue
SYS_MQ_UNLINK         EQU 241 ; Remove a POSIX message queue
SYS_MQ_TIMEDSEND      EQU 242 ; Send a message to a queue (with timeout)
SYS_MQ_TIMEDRECEIVE   EQU 243 ; Receive a message from a queue (with timeout)
SYS_MQ_NOTIFY         EQU 244 ; Register for notification when message is available
SYS_MQ_GETSETATTR     EQU 245 ; Get/set message queue attributes
SYS_KEXEC_LOAD        EQU 246 ; Load a new kernel for later execution
SYS_WAITID            EQU 247 ; Wait for process state changes generically
SYS_ADD_KEY           EQU 248 ; Add a key to the kernel's key management facility
SYS_REQUEST_KEY       EQU 249 ; Request a key from kernel key management facility
SYS_KEYCTL            EQU 250 ; Manipulate keys in kernel key management facility
SYS_IOPRIO_SET        EQU 251 ; Set I/O scheduling class and priority
SYS_IOPRIO_GET        EQU 252 ; Get I/O scheduling class and priority
SYS_INOTIFY_INIT      EQU 253 ; Initialize inotify instance
SYS_INOTIFY_ADD_WATCH EQU 254 ; Add watch to an inotify instance
SYS_INOTIFY_RM_WATCH  EQU 255 ; Remove existing watch from an inotify instance
SYS_MIGRATE_PAGES     EQU 256 ; Move all pages in process to another node
SYS_OPENAT            EQU 257 ; Open file relative to directory file descriptor
SYS_MKDIRAT           EQU 258 ; Create directory relative to directory file descriptor
SYS_MKNODAT           EQU 259 ; Create special/ordinary file relative to directory descriptor
SYS_FCHOWNAT          EQU 260 ; Change file ownership relative to directory descriptor
SYS_FUTIMESAT         EQU 261 ; Change file timestamps relative to directory descriptor
SYS_NEWFSTATAT        EQU 262 ; Get file status relative to directory descriptor
SYS_UNLINKAT          EQU 263 ; Remove directory entry relative to directory descriptor
SYS_RENAMEAT          EQU 264 ; Rename file relative to directory descriptors
SYS_LINKAT            EQU 265 ; Create hard link relative to directory descriptors
SYS_SYMLINKAT         EQU 266 ; Create symbolic link relative to directory descriptor
SYS_READLINKAT        EQU 267 ; Read symbolic link relative to directory descriptor
SYS_FCHMODAT          EQU 268 ; Change file mode relative to directory descriptor
SYS_FACCESSAT         EQU 269 ; Check user's permissions for a file relative to directory descriptor
SYS_PSELECT6          EQU 270 ; Synchronous I/O multiplexing with signal mask
SYS_PPOLL             EQU 271 ; Wait for event on file descriptor with signal mask
SYS_UNSHARE           EQU 272 ; Disallow sharing of execution context with parent
SYS_SET_ROBUST_LIST   EQU 273 ; Set list of robust futexes
SYS_GET_ROBUST_LIST   EQU 274 ; Get list of robust futexes
SYS_SPLICE            EQU 275 ; Splice data to/from pipe
SYS_TEE               EQU 276 ; Duplicate pipe content
SYS_SYNC_FILE_RANGE   EQU 277 ; Sync a portion of a file with disk
SYS_VMSPLICE          EQU 278 ; Splice user pages into a pipe
SYS_MOVE_PAGES        EQU 279 ; Move individual pages of a process to another node
SYS_UTIMENSAT         EQU 280 ; Change file timestamps with nanosecond precision
SYS_EPOLL_PWAIT       EQU 281 ; Wait for event on epoll file descriptor with signal mask
SYS_SIGNALFD          EQU 282 ; Create a file descriptor for accepting signals
SYS_TIMERFD_CREATE    EQU 283 ; Create timer that notifies via file descriptor
SYS_EVENTFD           EQU 284 ; Create event file descriptor for inter-process notification
SYS_FALLOCATE         EQU 285 ; Manipulate file space (allocate/deallocate)
SYS_TIMERFD_SETTIME   EQU 286 ; Arm/disarm timer associated with file descriptor
SYS_TIMERFD_GETTIME   EQU 287 ; Get time remaining on timer file descriptor
SYS_ACCEPT4           EQU 288 ; Accept connection on socket (with flags)
SYS_SIGNALFD4         EQU 289 ; Create a file descriptor for signals (with flags)
SYS_EVENTFD2          EQU 290 ; Create event file descriptor (with flags)
SYS_EPOLL_CREATE1     EQU 291 ; Open an epoll file descriptor (with flags)
SYS_DUP3              EQU 292 ; Duplicate a file descriptor (with flags)
SYS_PIPE2             EQU 293 ; Create pipe (with flags)
SYS_INOTIFY_INIT1     EQU 294 ; Initialize inotify instance (with flags)
SYS_PREADV            EQU 295 ; Read from file descriptor into multiple buffers at offset
SYS_PWRITEV           EQU 296 ; Write to file descriptor from multiple buffers at offset
SYS_RT_TGSIGQUEUEINFO EQU 297 ; Queue a signal to a specific thread
SYS_PERF_EVENT_OPEN   EQU 298 ; Set up performance monitoring counter
SYS_RECVMMSG          EQU 299 ; Receive multiple messages on a socket

;----------------------------------------
; File Open Modes (for SYS_OPEN)
;----------------------------------------
O_RDONLY              EQU 0       ; Open for reading only
O_WRONLY              EQU 1       ; Open for writing only
O_RDWR                EQU 2       ; Open for reading and writing
O_CREAT               EQU 64      ; Create file if it does not exist
O_EXCL                EQU 128     ; Ensure that this call creates the file (with O_CREAT)
O_NOCTTY              EQU 256     ; Do not make the opened file the controlling terminal
O_TRUNC               EQU 512     ; Truncate file to zero length if it already exists
O_APPEND              EQU 1024    ; Append to file on each write operation
O_NONBLOCK            EQU 2048    ; Non-blocking mode
O_DSYNC               EQU 4096    ; Synchronized I/O data integrity completion
O_DIRECT              EQU 16384   ; Minimize cache effects of I/O operations
O_LARGEFILE           EQU 32768   ; Allow files larger than 2GB
O_DIRECTORY           EQU 65536   ; Error if path is not a directory
O_NOFOLLOW            EQU 131072  ; Do not follow symbolic links
O_NOATIME             EQU 262144  ; Do not update file last access time
O_CLOEXEC             EQU 524288  ; Set close-on-exec flag
O_SYNC                EQU 1052672 ; Synchronized I/O file integrity completion

;----------------------------------------
; File Permissions (for SYS_OPEN with O_CREAT)
;----------------------------------------
S_IRUSR               EQU 00400Q  ; Read by owner
S_IWUSR               EQU 00200Q  ; Write by owner
S_IXUSR               EQU 00100Q  ; Execute/search by owner
S_IRGRP               EQU 00040Q  ; Read by group
S_IWGRP               EQU 00020Q  ; Write by group
S_IXGRP               EQU 00010Q  ; Execute/search by group
S_IROTH               EQU 00004Q  ; Read by others
S_IWOTH               EQU 00002Q  ; Write by others
S_IXOTH               EQU 00001Q  ; Execute/search by others
S_IRWXU               EQU 00700Q  ; Read, write, and execute by owner
S_IRWXG               EQU 00070Q  ; Read, write, and execute by group
S_IRWXO               EQU 00007Q  ; Read, write, and execute by others

;----------------------------------------
; File Seek Options (for SYS_LSEEK)
;----------------------------------------
SEEK_SET              EQU 0       ; Set offset to absolute value
SEEK_CUR              EQU 1       ; Set offset to current location plus value
SEEK_END              EQU 2       ; Set offset to file size plus value

;----------------------------------------
; Protection Flags (for SYS_MMAP)
;----------------------------------------
PROT_READ             EQU 1       ; Pages may be read
PROT_WRITE            EQU 2       ; Pages may be written
PROT_EXEC             EQU 4       ; Pages may be executed
PROT_NONE             EQU 0       ; Pages may not be accessed

;----------------------------------------
; Mapping Flags (for SYS_MMAP)
;----------------------------------------
MAP_SHARED            EQU 1       ; Share changes with other processes
MAP_PRIVATE           EQU 2       ; Create a private copy-on-write mapping
MAP_FIXED             EQU 16      ; Interpret start address strictly
MAP_ANONYMOUS         EQU 32      ; Don't use a backing file (anonymous memory)
MAP_ANON              EQU MAP_ANONYMOUS ; Alias for MAP_ANONYMOUS

;----------------------------------------
; Wait Options (for SYS_WAIT4)
;----------------------------------------
WNOHANG               EQU 1       ; Return immediately if no child has exited
WUNTRACED             EQU 2       ; Return if a child has stopped
WCONTINUED            EQU 8       ; Return if a stopped child has been resumed

;----------------------------------------
; Signal Numbers
;----------------------------------------
SIGHUP                EQU 1       ; Hangup detected on controlling terminal
SIGINT                EQU 2       ; Interrupt from keyboard (Ctrl+C)
SIGQUIT               EQU 3       ; Quit from keyboard (Ctrl+\)
SIGILL                EQU 4       ; Illegal instruction
SIGTRAP               EQU 5       ; Trace/breakpoint trap
SIGABRT               EQU 6       ; Abort signal from abort()
SIGBUS                EQU 7       ; Bus error (bad memory access)
SIGFPE                EQU 8       ; Floating-point exception
SIGKILL               EQU 9       ; Kill signal (cannot be caught or ignored)
SIGUSR1               EQU 10      ; User-defined signal 1
SIGSEGV               EQU 11      ; Segmentation fault (invalid memory reference)
SIGUSR2               EQU 12      ; User-defined signal 2
SIGPIPE               EQU 13      ; Broken pipe: write to pipe with no readers
SIGALRM               EQU 14      ; Timer signal from alarm()
SIGTERM               EQU 15      ; Termination signal
SIGSTKFLT             EQU 16      ; Stack fault on coprocessor
SIGCHLD               EQU 17      ; Child stopped or terminated
SIGCONT               EQU 18      ; Continue if stopped
SIGSTOP               EQU 19      ; Stop process (cannot be caught or ignored)
SIGTSTP               EQU 20      ; Stop typed at terminal (Ctrl+Z)
SIGTTIN               EQU 21      ; Terminal input for background process
SIGTTOU               EQU 22      ; Terminal output for background process
SIGURG                EQU 23      ; Urgent condition on socket
SIGXCPU               EQU 24      ; CPU time limit exceeded
SIGXFSZ               EQU 25      ; File size limit exceeded
SIGVTALRM             EQU 26      ; Virtual timer expired
SIGPROF               EQU 27      ; Profiling timer expired
SIGWINCH              EQU 28      ; Window resize signal
SIGIO                 EQU 29      ; I/O now possible
SIGPWR                EQU 30      ; Power failure
SIGSYS                EQU 31      ; Bad system call

