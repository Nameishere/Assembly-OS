
section .data

mov_data:
    ;rdx is source
    ;rbx is the destination  
    ;rcx is the source
    push rdx 
    mov rax, 0
    .loop1_start:
    cmp rax, rcx
    jg .loop1_end

    mov r10b, [rdx]
    mov [rbx], r10b 
    
    inc rax 
    inc rdx
    inc rbx 
    jmp .loop1_start
    .loop1_end:

    pop rdx 
    ret 

print_unicode:
    ;rax is pointer to string 

    call test_string

    mov rdx, rax
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 
    ret 


test_string:
    ;rax is pointer to string 
    push rax

    mov rdx, rax
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.TestString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 


    pop rax 
    ret



print_String: 
    ;This function prints a asci string as a unicode string (format of firmwae input)
    ;rax is input string  
    push rax
    push rbx
    push rcx
    push rdx

    mov r10, 1 ;loop Count initiliased 
    .loop1_start:
        mov bl, [rax]
        cmp bl, 0
        je .loop1_end

        inc rax 
        inc r10
        jmp .loop1_start
    .loop1_end:

    mov r12, r10 
    mov rbx, 0 
    .loop2_start:
        cmp r10, 0
        je .loop2_end

        dec rsp 
        mov bl, 0 
        mov [rsp], bl

        dec rsp 
        mov bl, [rax]
        mov [rsp], bl

        dec r10 
        dec rax 
        jmp .loop2_start
    .loop2_end:

    ;Print 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, rsp
    call rbx 

    mov rax, 2
    mul r12
    mov r12, rax 
    add rsp, r12


    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


print_Number: 
    ;This function prints a asci string as a unicode string (format of firmwae input)
    ;rax is input number
    ;rcx is optional digits input ie if 0 doesn't use 


    ; call exception ;FEA6808
    push rbx 
    push r12

    dec rsp
    dec rsp 

    mov rdx, 0 
    mov [rsp], dx

    ; mov rcx, 10
    mov r12, 0 ;loop Count initiliased 
    .loop2_start:
        cmp rcx, 0 
        je .if1_end
        
        cmp rcx, r12
        jl .if2_end

        jmp .if3_end
        .if1_end:

        cmp rax, 0
        jne .if3_end
        
        
        cmp r12, 0 
        jne .if2_end
        ; call exception

        inc r12
        dec rsp
        dec rsp 

        mov rdx, 0x0030 
        mov [rsp], dx

        ; call print_dot
        .if2_end:

        jmp .loop2_end
        .if3_end:


        dec rsp 
        mov bl, 0 
        mov [rsp], bl

        

        ; call print_test

        push rcx 
        mov rdx, 0 
        mov rcx, 10
        div rcx
        pop rcx 

        dec rsp 
        add rdx, 0x30
        mov bl, dl
        mov [rsp], bl




        inc r12 
        jmp .loop2_start
    .loop2_end:

    ;Print 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, rsp
    call rbx 

    mov rax, 2
    mul r12
    mov r12, rax 
    add rsp, r12
    add rsp, 2

    pop r12
    pop rbx 
    ; call exception
    ret ;FEA686E ;FEA6800 ;FEA67F8


print_dot:
    push rax 
    push rbx 
    push rcx 
    push rdx 
    push r10 
    push r8
    push r9
    push r11
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, .dot
    call rbx 

    pop r11
    pop r9
    pop r8
    pop r10 
    pop rdx 
    pop rcx 
    pop rbx 
    pop rax 
    ret 
    .dot: dw ".",0

Change_Mode: 
    ;rax is the mode to change to 

    mov rdx, rax 
    push rdx 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.QueryMode
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    call rbx 
    pop rdx

    ; call exception
    cmp rax, EFI_SUCCESS
    jne .if1

    mov rdx ,rax 

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetMode
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    call rbx 

    jmp .if1_end
    .if1:
    call next_line


    mov rax, .Message
    call print_String

    call next_line

    .if1_end:


    ret 



    .Message: db "Mode Does not Exist", 0



next_line:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rdx, [rcx]
    add rdx, 16
    mov r8d, [rdx]
    add r8, 1
    ; call exception
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetCursorPosition
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    mov rdx, 0
    call rbx 
    ret 