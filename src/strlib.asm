section .text
print_number: 
    ;rax is input number 
    ;rbx is digits printed 
    ;internal registers: rcx, rdx, rdi, rsi, r10
    push rax
    push rbx
    push rcx
    push rdx
    push rdi 
    push rsi 
    push r10

    mov r10, 0 ;loop Count initiliased 
    push 0x0A ; add new line to stack

    .loop:
    mov rdx, 0 ;zero rdx
    mov rcx, 10 ;base ten 

    div rcx ; rax = rax / rcx, rdx = remainder 

    add rdx, 0x30 ;convert to ASCI

    push rdx ; add to stack 

    ; call print_test
    inc r10
    
    cmp r10, rbx ;check if loop is done 
     
    jl .loop

    mov rax, 8
    mul rbx ; rax = rbx * rax
    mov rdx, rax
    mov rax, LINUX_SYSCALL.write  
    mov rdi, write_console
    mov rsi, rsp ;print stack
    syscall

    inc r10 
    mov rax, 8
    mul r10
    add rsp, rax 


    pop r10
    pop rsi 
    pop rdi 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


print_string: ;rax is pointer to string

    push rax
    push rcx
    push rax
    push rdx
    push rdi
    push rsi

    mov rsi, rax
    call strlen
    mov rdx, rax
    mov rax, LINUX_SYSCALL.write
    mov rdi, write_console
    syscall

    
    pop rsi
    pop rdi
    pop rdx
    pop rax
    pop rcx
    pop rax
    ret


strncpy:; registers used: rax, rbx, rcx, rdx
    ;rax is the string to be set 
    ;rbx is pointer to value to copy
    ;rcx is the length of the string 
    ;only inside: rdx
    push rax
    push rbx
    push rcx
    push rdx
    mov rdx, 0 
    .loop1_start:
    cmp rdx, rcx
    je .loop1_end

    cmp byte [rbx], 0
    je .loop1_end
    push rcx
    mov rcx, [rbx]
    mov [rax], rcx
    pop rcx
    inc rax 
    inc rbx 
    jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret 


strlen:; registers used: rax
    ;rax is the string to be set and the number returned
    push rbx
    mov rbx, 0
    .loop1_start:

    cmp byte [rax], 0
    je .loop1_end

    inc rbx
    inc rax 
    ; push rax
    ; mov rax, rbx
    ; call print_number
    ; pop rax
    jmp .loop1_start
    .loop1_end:
    mov rax, rbx
    pop rbx

    ret 

strchr:
    ;rax is pointer to start of string is kept the same 
    ;r9 is character to compare and will be position if true (r9l)
    
    push rax 

    .loop1_start:
        cmp [rax], r9b
        je .loop1_end2
        inc rax


        cmp byte [rax], 0
        je .loop1_end1
        
        jmp .loop1_start
    .loop1_end1:
    mov rax, 0 
    .loop1_end2:
    mov r9, rax 
    pop rax 
    ret


String_to_Upper:
    ;rax is the pointer to the string for input and output
    ;rbx is the length of the string for input and output
    push rax
    push rbx 
    
    mov r10, rbx 
    mov r9, 0
    .loop_start:
        cmp byte [rax], 122
        jg .else

        cmp byte [rax], 97
        jl  .else

    .if:
        mov rbx, [rax]
        mov rcx, 32
        Sub rbx, rcx
        mov [rax], rbx

    .else:
        inc rax 
        inc r9
        cmp r9, r10

        jl .loop_start


    pop rbx
    pop rax 
    ret

print_test: 

    push rax
    push rdi
    push rsi 
    push rdx
    push rcx 

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 5
    syscall

    pop rcx
    pop rdx
    pop rsi 
    pop rdi
    pop rax
    ret 

    .message: db "Test" , 0x0A


done: ;Code is Done

    mov rax , .message
    call print_string

    mov eax, 60
    xor rdi, rdi
    syscall

    .message: 
        dd "Code is done", 0x0A, 0