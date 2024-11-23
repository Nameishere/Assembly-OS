section .text
memset: ;registers used: rax, rbx, rcx, rdx 
    ;rax is a pointer to the start of the sting 
    ;rbx is the length of the string to be set to rax 
    ;rcx is the character to set the values to 
    ;only inside: rdx 
    push rax
    push rbx
    push rcx
    push rdx

    mov rdx, 0
    .loop1_start:
        cmp rbx, rdx 
        je .loop1_end
        mov [rax], cl
        inc rdx
        inc rax
        
        
        jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret 

memcopy:; registers used: rax, rbx, rcx, rdx
    ;rax is the string to be set 
    ;rbx is pointer to value to copy
    ;rcx is the length of the string 
    ;only inside: rdx
    push rax
    push rbx
    push rdx
    mov rdx, 0

    .loop1_start:

    cmp rdx, rcx
    je .loop1_end

    ; call print_test
    push rcx
    mov rcx, 0
    mov cl, [rbx]
    mov [rax], cl
    pop rcx

    inc rax 
    inc rbx 
    inc rdx
    jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rbx
    pop rax

    ret 


zeroarray: ;registers used: rax, rbx, rcx 
    ;rax is the string 
    ;rbx is the length 
    ;only inside: rcx
   push rax
   push rbx
   push rcx
    mov rcx, 0
    .loop1_start:
        cmp rbx, rcx 
        je .loop1_end
        mov byte [rax], 0
        inc rcx
        
        jmp .loop1_start
    .loop1_end:

    pop rcx
    pop rbx
    pop rax
    ret 

memcmp:
    ;rax is the input of the first memory pointer , and the true or false output
    ;rbx is the input of the second memory
    ;rcx is the length of the comparison 
    ;internal registers: rdx, r10
    push rdx
    push rbx
    push rcx
    push r10
    mov rdx, 0 
    .loop:
    ; call print_test

    mov r10b, [rbx]
    cmp [rax], r10b
    jne .fail
    inc rax
    inc rbx
    inc rdx

    cmp rdx, rcx
    jl .loop

    mov rax, 1
    jmp .end

    .fail:
    mov rax, 0

    .end:

    pop r10
    pop rcx
    pop rbx
    pop rdx
    ret

mmap:
    ;rax is the starting address address and the pointer to the region
    ;rbx is the length of the mapping 
    ;rcx is the prot memory protection 
    ;rdx is the flags  
    ;r10 is the file pointer 
    ;r9 is the offset 
    push rbx
    push rcx
    push rdx 
    push r10
    push r9

    mov r9, r9
    mov r8, r10
    mov r10, rdx 
    mov rdx, rcx 
    mov rsi, rbx 
    mov rdi, rax 
    mov rax, LINUX_SYSCALL.mmap
    syscall

    call check_Error

    pop r9
    pop r10
    pop rdx 
    pop rcx
    pop rbx

    ret 




munmap:
    ;rax is the address to the mapping 
    ;rbx is the length of the mapping 
    push rbx
    mov rsi, rbx 
    mov rdi, rax 
    mov rax, LINUX_SYSCALL.munmap
    syscall

    call check_Error

    pop rbx 
    ret 


fwrite:
    ;rax is a pointer to the file 
    ;rbx is a pointer to the input 
    ;rcx is the size to input 

    push rax
    push rdx
    push rsi
    push rdi
    mov rdx, rcx       ;message length
    mov rsi, rbx        ;message to write
    mov rdi, rax        ;file descriptor
    mov rax, LINUX_SYSCALL.write  
    syscall            ;call kernel    
    pop rdi
    pop rsi
    pop rdx
    pop rax

    ret

fread:
    ;rax is the file pointer and number of bytes read 
    ;rbx is the location the output read from file 
    ;rcx is the count of bytes taken from the file 
    push rdx
    push rdi 
    push rsi
    mov rdi, rax
    mov rsi, rbx
    mov rdx, rcx     
    mov rax, LINUX_SYSCALL.read_SYSCALL
    syscall


    call check_Error
    pop rsi
    pop rdi
    pop rdx
    ret

fseek:
    ;uses lseek linux function
    ;rax is file
    ;rbx is destination in file 
    ;rcx is type of Search  

    push rdx
    push rdi 
    push rsi


    mov rdi, rax
    mov rsi, rbx
    mov rdx, rcx     
    mov rax, LINUX_SYSCALL.lseek
    syscall

    call check_Error

    pop rsi
    pop rdi
    pop rdx
    ret