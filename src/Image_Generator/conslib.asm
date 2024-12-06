section .text

LINUX_SYSCALL:
    .read_SYSCALL:  equ 0 
    .write: equ 1
        write_console   equ 1
    .open:  equ 2;int open(const char *pathname, int flags, /* mode_t mode */ );
        O_RDONLY        equ 0000o ;Read only 
        O_WRONLY        equ 0001o ;write only 
        O_RDWR          equ 0002o ;read and write
        O_CREAT         equ 0100o ;if file doesn't exist create it 

        ;modes for O_CREAT
        S_IRWXU         equ 00700o ; user (file owner) has read, write, and execute permission
        S_IRUSR         equ 00400o ; user has read permission
        S_IWUSR         equ 00200o ; user has write permission
        S_IXUSR         equ 00100o ; user has execute permission
        S_IRWXG         equ 00070o ; group has read, write, and execute permission
        S_IRGRP         equ 00040o ; group has read permission
        S_IWGRP         equ 00020o ; group has write permission
        S_IXGRP         equ 00010o ; group has execute permission
        S_IRWXO         equ 00007o ; others have read, write, and execute permission
        S_IROTH         equ 00004o ; others have read permission
        S_IWOTH         equ 00002o ; others have write permission
        S_IXOTH         equ 00001o ; others have execute permission

        S_ISUID         equ 00040o ;00 set-user-ID bit
        S_ISGID         equ 00020o ;00 set-group-ID bit (see inode(7)).
        S_ISVTX         equ 00010o ;00 sticky bit (see inode(7)).
    .close_SYSCALL: equ 3
    .stat_SYSCALL:  equ 4
    .fstat_SYSCALL: equ 5
    .lstat_SYSCALL: equ 6
    .poll:          equ 7
    .lseek:         equ 8
        SEEK_SET        equ 0
        SEEK_CUR        equ 1
        SEEK_END        equ 2
    .mmap:          equ 9
        PROT_READ	    equ 0x1		; page can be read */
        PROT_WRITE	    equ 0x2		; page can be written */
        PROT_EXEC	    equ 0x4	    ; page can be executed */
        PROT_NONE	    equ 0x0	

        MAP_SHARED	    equ 0x01		; Share changes */
        MAP_PRIVATE	    equ 0x02		; Changes are private */
        MAP_SHARED_VALIDATE equ  0x03	; share + validate extension flags */
        MAP_FIXED	    equ 0x10		; Interpret addr exactly */
        MAP_ANONYMOUS	equ 0x20        ; don't use a file */
        MAP_FIXED_NOREPLACE	equ 0x200000; MAP_FIXED which doesn't unmap underlying mapping */
        MAP_GROWSDOWN	equ 0x01000		; stack-like segment */
        MAP_HUGETLB 	equ 0x100000	; create a huge page mapping */
        MAP_LOCKED	    equ 0x08000		; lock the mapping */
        MAP_NONBLOCK    equ 0x40000		; do not block on IO */
        MAP_NORESERVE	equ 0x10000		; don't check for reservations */
        MAP_POPULATE    equ 0x20000		; populate (prefault) pagetables */
        MAP_STACK	    equ 0x80000		; give out an address that is best suited for process/thread stacks */
        MAP_UNINITIALIZED equ  0x4000000	; For anonymous mmap, memory could be uninitialized */
        MAP_SYNC		equ 0x080000 ; perform synchronous page faults for the mapping */
        MAP_32BIT	    equ 0x40	
        MAP_HUGE_2MB    equ 21 << MAP_HUGE_SHIFT
        MAP_HUGE_1GB    equ 30 << MAP_HUGE_SHIFT


    .mporotect:     equ 10
    .munmap:        equ 11
    .time:          equ 201



MAP_HUGE_SHIFT equ 26	