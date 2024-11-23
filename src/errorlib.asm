section .text
; %include "src/strlib.asm"

check_Error: ;Code is Done
    cmp rax, 0
    jl .Error
    ret 

    .Error:
    mov rcx, -1
    mul rcx

    mov rbx, LINUX_ERRORS.EBADF
    cmp rax, EBADF
    je .print

    mov rbx, LINUX_ERRORS.ENOENT
    cmp rax, ENOENT
    je .print

    mov rbx, LINUX_ERRORS.EACCES
    cmp rax, EACCES
    je .print

    mov rbx, LINUX_ERRORS.EAGAIN
    cmp rax, EAGAIN
    je .print

    mov rbx, LINUX_ERRORS.EEXIST
    cmp rax, EEXIST
    je .print
    
    mov rbx, LINUX_ERRORS.EINVAL
    cmp rax, EINVAL
    je .print

    mov rbx, LINUX_ERRORS.ENFILE
    cmp rax, ENFILE
    je .print

    mov rbx, LINUX_ERRORS.ENODEV
    cmp rax, ENODEV
    je .print

    mov rbx, LINUX_ERRORS.ENOMEM
    cmp rax, ENOMEM
    je .print

    mov rbx, LINUX_ERRORS.EOVERFLOW
    cmp rax, EOVERFLOW
    je .print

    mov rbx, LINUX_ERRORS.EPERM
    cmp rax, EPERM
    je .print

    mov rbx, LINUX_ERRORS.ETXTBSY
    cmp rax, ETXTBSY
    je .print

    mov rbx, .unknown
    .print:

    mov rax, .Error_Message
    call print_string

    mov rax, rbx
    call print_string
    
    .end_program:
    mov eax, 60
    xor rdi, rdi
    syscall

    .unknown: db "Unknown Error", 0 
    .Error_Message: db "Error: " , 0

LINUX_ERRORS:
    EPERM equ           1  ;Operation not permitted
    ENOENT equ          2  ;No such file or directory
    ESRCH equ           3  ;No such process
    EINTR equ           4  ;Interrupted system call
    EIO equ             5  ;I/O error
    ENXIO equ           6  ;No such device or address
    E2BIG equ           7  ;Argument list too long
    ENOEXEC equ         8  ;Exec format error
    EBADF equ           9  ;Bad file number
    ECHILD equ          10 ;No child processes
    EAGAIN equ          11 ;Try again
    ENOMEM equ          12 ;Out of memory
    EACCES equ          13 ;Permission denied
    EFAULT equ          14 ;Bad address
    ENOTBLK equ         15 ;Block device required
    EBUSY equ           16 ;Device or resource busy
    EEXIST equ          17 ;File exists
    EXDEV equ           18 ;Cross-device link
    ENODEV equ          19 ;No such device
    ENOTDIR equ         20 ;Not a directory
    EISDIR equ          21 ;Is a directory
    EINVAL equ          22 ;Invalid argument
    ENFILE equ          23 ;File table overflow
    EMFILE equ          24 ;Too many open files
    ENOTTY equ          25 ;Not a typewriter
    ETXTBSY equ         26 ;Text file busy
    EFBIG equ           27 ;File too large
    ENOSPC equ          28 ;No space left on device
    ESPIPE equ          29 ;Illegal seek
    EROFS equ           30 ;Read-only file system
    EMLINK equ          31 ;Too many links
    EPIPE equ           32 ;Broken pipe
    EDOM equ            33 ;Math argument out of domain of func
    ERANGE equ          34 ;Math result not representable
    EDEADLK equ         35 ;Resource deadlock would occur
    ENAMETOOLONG equ    36 ;File name too long
    ENOLCK equ          37 ;No record locks available
    ENOSYS equ          38 ;Function not implemented
    ENOTEMPTY equ       39 ;Directory not empty
    ELOOP equ           40 ;Too many symbolic links encountered
    ENOMSG equ          42 ;No message of desired type
    EIDRM equ           43 ;Identifier removed
    ECHRNG equ          44 ;Channel number out of range
    EL2NSYNC equ        45 ;Level 2 not synchronized
    EL3HLT equ          46 ;Level 3 halted
    EL3RST equ          47 ;Level 3 reset
    ELNRNG equ          48 ;Link number out of range
    EUNATCH equ         49 ;Protocol driver not attached
    ENOCSI equ          50 ;No CSI structure available
    EL2HLT equ          51 ;Level 2 halted
    EBADE equ           52 ;Invalid exchange
    EBADR equ           53 ;Invalid request descriptor
    EXFULL equ          54 ;Exchange full
    ENOANO equ          55 ;No anode
    EBADRQC equ         56 ;Invalid request code
    EBADSLT equ         57 ;Invalid slot
    EBFONT equ          59 ;Bad font file format
    ENOSTR equ          60 ;Device not a stream
    ENODATA equ         61 ;No data available
    ETIME equ           62 ;Timer expired
    ENOSR equ           63 ;Out of streams resources
    ENONET equ          64 ;Machine is not on the network
    ENOPKG equ          65 ;Package not installed
    EREMOTE equ         66 ;Object is remote
    ENOLINK equ         67 ;Link has been severed
    EADV equ            68 ;Advertise error
    ESRMNT equ          69 ;Srmount error
    ECOMM equ           70 ;Communication error on send
    EPROTO equ          71 ;Protocol error
    EMULTIHOP equ       72 ;Multihop attempted
    EDOTDOT equ         73 ;RFS specific error
    EBADMSG equ         74 ;Not a data message
    EOVERFLOW equ       75 ;Value too large for defined data type
    ENOTUNIQ equ        76 ;Name not unique on network
    EBADFD equ          77 ;File descriptor in bad state
    EREMCHG equ         78 ;Remote address changed
    ELIBACC equ         79 ;Can not access a needed shared library
    ELIBBAD equ         80 ;Accessing a corrupted shared library
    ELIBSCN equ         81 ;.lib section in a.out corrupted
    ELIBMAX equ         82 ;Attempting to link in too many shared libraries
    ELIBEXEC equ        83 ;Cannot exec a shared library directly
    EILSEQ equ          84 ;Illegal byte sequence
    ERESTART equ        85 ;Interrupted system call should be restarted
    ESTRPIPE equ        86 ;Streams pipe error
    EUSERS equ          87 ;Too many users
    ENOTSOCK equ        88 ;Socket operation on non-socket
    EDESTADDRREQ equ    89 ;Destination address required
    EMSGSIZE equ        90 ;Message too long
    EPROTOTYPE equ      91 ;Protocol wrong type for socket
    ENOPROTOOPT equ     92 ;Protocol not available
    EPROTONOSUPPORT equ 93 ;Protocol not supported
    ESOCKTNOSUPPORT equ 94 ;Socket type not supported
    EOPNOTSUPP equ      95 ;Operation not supported on transport endpoint
    EPFNOSUPPORT equ    96 ;Protocol family not supported
    EAFNOSUPPORT equ    97 ;Address family not supported by protocol
    EADDRINUSE equ      98 ;Address already in use
    EADDRNOTAVAIL equ   99 ;Cannot assign requested address
    ENETDOWN equ        100;Network is down
    ENETUNREACH equ     101;Network is unreachable
    ENETRESET equ       102;Network dropped connection because of reset
    ECONNABORTED equ    103;Software caused connection abort
    ECONNRESET equ      104;Connection reset by peer
    ENOBUFS equ         105;No buffer space available
    EISCONN equ         106;Transport endpoint is already connected
    ENOTCONN equ        107;Transport endpoint is not connected
    ESHUTDOWN equ       108;Cannot send after transport endpoint shutdown
    ETOOMANYREFS equ    109;Too many references: cannot splice
    ETIMEDOUT equ       110;Connection timed out
    ECONNREFUSED equ    111;Connection refused
    EHOSTDOWN equ       112;Host is down
    EHOSTUNREACH equ    113;No route to host
    EALREADY equ        114;Operation already in progress
    EINPROGRESS equ     115;Operation now in progress
    ESTALE equ          116;Stale NFS file handle
    EUCLEAN equ         117;Structure needs cleaning
    ENOTNAM equ         118;Not a XENIX named type file
    ENAVAIL equ         119;No XENIX semaphores available
    EISNAM equ          120;Is a named type file
    EREMOTEIO equ       121;Remote I/O error
    EDQUOT equ          122;Quota exceeded
    ENOMEDIUM equ       123;No medium found
    EMEDIUMTYPE equ     124;Wrong medium type
    ECANCELED equ       125;Operation Canceled
    ENOKEY equ          126;Required key not available
    EKEYEXPIRED equ     127;Key has expired
    EKEYREVOKED equ     128;Key has been revoked
    EKEYREJECTED equ    129;Key was rejected by service
    EOWNERDEAD equ      130;Owner died
    ENOTRECOVERABLE equ 131;State not recoverable
    .EPERM:           db "Operation not permitted   ", 0x0A ,0
    .ENOENT:          db "No such file or directory ", 0x0A ,0
    .ESRCH:           db "No such process           ", 0x0A ,0
    .EINTR:           db "Interrupted system call   ", 0x0A ,0
    .EIO:             db "I/O error                 ", 0x0A ,0
    .ENXIO:           db "No such device or address ", 0x0A ,0
    .E2BIG:           db "Argument list too long    ", 0x0A ,0
    .ENOEXEC:         db "Exec format error         ", 0x0A ,0
    .EBADF:           db "Bad file number           ", 0x0A ,0
    .ECHILD:          db "No child processes        ", 0x0A ,0
    .EAGAIN:          db "Try again                 ", 0x0A ,0
    .ENOMEM:          db "Out of memory             ", 0x0A ,0
    .EACCES:          db "Permission denied         ", 0x0A ,0
    .EFAULT:          db "Bad address               ", 0x0A ,0
    .ENOTBLK:         db "Block device required", 0x0A ,0
    .EBUSY:           db "Device or resource busy   ", 0x0A ,0
    .EEXIST:          db "File exists       ", 0x0A ,0
    .EXDEV:           db "Cross-device link     ", 0x0A ,0
    .ENODEV:          db "No such device        ", 0x0A ,0
    .ENOTDIR:         db "Not a directory       ", 0x0A ,0
    .EISDIR:          db "Is a directory        ", 0x0A ,0
    .EINVAL:          db "Invalid argument      ", 0x0A ,0
    .ENFILE:          db "File table overflow", 0x0A ,0
    .EMFILE:          db "Too many open files", 0x0A ,0
    .ENOTTY:          db "Not a typewriter", 0x0A ,0
    .ETXTBSY:         db "Text file busy", 0x0A ,0
    .EFBIG:           db "File too large", 0x0A ,0
    .ENOSPC:          db "No space left on device", 0x0A ,0
    .ESPIPE:          db "Illegal seek", 0x0A ,0
    .EROFS:           db "Read-only file system", 0x0A ,0
    .EMLINK:          db "Too many links", 0x0A ,0
    .EPIPE:           db "Broken pipe", 0x0A ,0
    .EDOM:            db "Math argument out of domain of func", 0x0A ,0
    .ERANGE:          db "Math result not representable", 0x0A ,0
    .EDEADLK:         db "Resource deadlock would occur", 0x0A ,0
    .ENAMETOOLONG:    db "File name too long", 0x0A ,0
    .ENOLCK:          db "No record locks available", 0x0A ,0
    .ENOSYS:          db "Function not implemented", 0x0A ,0
    .ENOTEMPTY:       db "Directory not empty", 0x0A ,0
    .ELOOP:           db "Too many symbolic links encountered", 0x0A ,0
    .ENOMSG:          db "No message of desired type", 0x0A ,0
    .EIDRM:           db "Identifier removed", 0x0A ,0
    .ECHRNG:          db "Channel number out of range", 0x0A ,0
    .EL2NSYNC:        db "Level 2 not synchronized", 0x0A ,0
    .EL3HLT:          db "Level 3 halted", 0x0A ,0
    .EL3RST:          db "Level 3 reset", 0x0A ,0
    .ELNRNG:          db "Link number out of range", 0x0A ,0
    .EUNATCH:         db "Protocol driver not attached", 0x0A ,0
    .ENOCSI:          db "No CSI structure available", 0x0A ,0
    .EL2HLT:          db "Level 2 halted", 0x0A ,0
    .EBADE:           db "Invalid exchange", 0x0A ,0
    .EBADR:           db "Invalid request descriptor", 0x0A ,0
    .EXFULL:          db "Exchange full", 0x0A ,0
    .ENOANO:          db "No anode", 0x0A ,0
    .EBADRQC:         db "Invalid request code", 0x0A ,0
    .EBADSLT:         db "Invalid slot", 0x0A ,0
    .EBFONT:          db "Bad font file format", 0x0A ,0
    .ENOSTR:          db "Device not a stream", 0x0A ,0
    .ENODATA:         db "No data available", 0x0A ,0
    .ETIME:           db "Timer expired", 0x0A ,0
    .ENOSR:           db "Out of streams resources", 0x0A ,0
    .ENONET:          db "Machine is not on the network", 0x0A ,0
    .ENOPKG:          db "Package not installed", 0x0A ,0
    .EREMOTE:         db "Object is remote", 0x0A ,0
    .ENOLINK:         db "Link has been severed", 0x0A ,0
    .EADV:            db "Advertise error", 0x0A ,0
    .ESRMNT:          db "Srmount error", 0x0A ,0
    .ECOMM:           db "Communication error on send", 0x0A ,0
    .EPROTO:          db "Protocol error", 0x0A ,0
    .EMULTIHOP:       db "Multihop attempted", 0x0A ,0
    .EDOTDOT:         db "RFS specific error", 0x0A ,0
    .EBADMSG:         db "Not a data message", 0x0A ,0
    .EOVERFLOW:       db "Value too large for defined data type", 0x0A ,0
    .ENOTUNIQ:        db "Name not unique on network", 0x0A ,0
    .EBADFD:          db "File descriptor in bad state", 0x0A ,0
    .EREMCHG:         db "Remote address changed", 0x0A ,0
    .ELIBACC:         db "Can not access a needed shared library", 0x0A ,0
    .ELIBBAD:         db "Accessing a corrupted shared library", 0x0A ,0
    .ELIBSCN:         db ".lib section in a.out corrupted", 0x0A ,0
    .ELIBMAX:         db "Attempting to link in too many shared libraries", 0x0A ,0
    .ELIBEXEC:        db "Cannot exec a shared library directly", 0x0A ,0
    .EILSEQ:          db "Illegal byte sequence", 0x0A ,0
    .ERESTART:        db "Interrupted system call should be restarted", 0x0A ,0
    .ESTRPIPE:        db "Streams pipe error", 0x0A ,0
    .EUSERS:          db "Too many users", 0x0A ,0
    .ENOTSOCK:        db "Socket operation on non-socket", 0x0A ,0
    .EDESTADDRREQ:    db "Destination address required", 0x0A ,0
    .EMSGSIZE:        db "Message too long", 0x0A ,0
    .EPROTOTYPE:      db "Protocol wrong type for socket", 0x0A ,0
    .ENOPROTOOPT:     db "Protocol not available", 0x0A ,0
    .EPROTONOSUPPORT: db "Protocol not supported", 0x0A ,0
    .ESOCKTNOSUPPORT: db "Socket type not supported", 0x0A ,0
    .EOPNOTSUPP:      db "Operation not supported on transport endpoint", 0x0A ,0
    .EPFNOSUPPORT:    db "Protocol family not supported", 0x0A ,0
    .EAFNOSUPPORT:    db "Address family not supported by protocol", 0x0A ,0
    .EADDRINUSE:      db "Address already in use", 0x0A ,0
    .EADDRNOTAVAIL:   db "Cannot assign requested address", 0x0A ,0
    .ENETDOWN:        db "Network is down", 0x0A ,0
    .ENETUNREACH:     db "Network is unreachable", 0x0A ,0
    .ENETRESET:       db "Network dropped connection because of reset", 0x0A ,0
    .ECONNABORTED:    db "Software caused connection abort", 0x0A ,0
    .ECONNRESET:      db "Connection reset by peer", 0x0A ,0
    .ENOBUFS:         db "No buffer space available", 0x0A ,0
    .EISCONN:         db "Transport endpoint is already connected", 0x0A ,0
    .ENOTCONN:        db "Transport endpoint is not connected", 0x0A ,0
    .ESHUTDOWN:       db "Cannot send after transport endpoint shutdown", 0x0A ,0
    .ETOOMANYREFS:    db "Too many references: cannot splice", 0x0A ,0
    .ETIMEDOUT:       db "Connection timed out", 0x0A ,0
    .ECONNREFUSED:    db "Connection refused", 0x0A ,0
    .EHOSTDOWN:       db "Host is down", 0x0A ,0
    .EHOSTUNREACH:    db "No route to host", 0x0A ,0
    .EALREADY:        db "Operation already in progress", 0x0A ,0
    .EINPROGRESS:     db "Operation now in progress", 0x0A ,0
    .ESTALE:          db "Stale NFS file handle", 0x0A ,0
    .EUCLEAN:         db "Structure needs cleaning", 0x0A ,0
    .ENOTNAM:         db "Not a XENIX named type file", 0x0A ,0
    .ENAVAIL:         db "No XENIX semaphores available", 0x0A ,0
    .EISNAM:          db "Is a named type file", 0x0A ,0
    .EREMOTEIO:       db "Remote I/O error", 0x0A ,0
    .EDQUOT:          db "Quota exceeded", 0x0A ,0
    .ENOMEDIUM:       db "No medium found", 0x0A ,0
    .EMEDIUMTYPE:     db "Wrong medium type", 0x0A ,0
    .ECANCELED:       db "Operation Canceled", 0x0A ,0
    .ENOKEY:          db "Required key not available", 0x0A ,0
    .EKEYEXPIRED:     db "Key has expired", 0x0A ,0
    .EKEYREVOKED:     db "Key has been revoked", 0x0A ,0
    .EKEYREJECTED:    db "Key was rejected by service", 0x0A ,0
    .EOWNERDEAD:      db "Owner died", 0x0A ,0
    .ENOTRECOVERABLE: db "State not recoverable", 0x0A ,0
