
section .data

mov_data:
    ;rdx is source
    ;rbx is the destination  
    ;rcx is the source
    push rdx 
    mov r8, 0
    .loop1_start:
    cmp r8, rcx
    jg .loop1_end

    mov r10b, [rdx]
    mov [rbx], r10b 
    
    inc r8 
    inc rdx
    inc rbx 
    jmp .loop1_start
    .loop1_end:

    pop rdx 
    ret 

print_unicode:
    ;rcx is pointer to string 

    push rcx
    call test_string
    pop rcx

    mov rdx, rcx
    mov r12, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [r12]
    mov r12, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r12] 
    call rbx 
    ret 


test_string:
    ;rcx is pointer to string 

    mov rdx, rcx
    mov rdx, rbx
    mov r12, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.TestString
    mov rbx, [r12]
    mov r12, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r12] 
    call rbx 
    ret



print_String: 
    ;This function prints a asci string as a unicode string (format of firmwae input)
    ;rcx is input string  

    mov r11, 1 ;loop Count initiliased 
    .loop1_start:
        mov r8, [rcx]
        cmp r8, 0
        je .loop1_end

        inc rcx 
        inc r11
        jmp .loop1_start
    .loop1_end:

    mov r8, r11 
    mov r9, 0 
    .loop2_start:
        cmp r11, 0
        je .loop2_end

        dec rsp 
        mov r9b, 0 
        mov [rsp], r9b

        dec rsp 
        mov r9b, [rcx]
        mov [rsp], r9b

        dec r11 
        dec rcx 
        jmp .loop2_start
    .loop2_end:

    ;Print 
    mov rcx, rsp
    push r8
    call print_unicode

    pop r8
    mov rax, 2
    mul r8
    add rsp, rax

    ret


print_Number: 
    ;This function prints a asci string as a unicode string (format of firmwae input)

    ;rcx - the Number
    ;rdx - num digits (optional set to 0 if not used ) 

    sub rsp, 2 ; gives space for 0 at end of string 

    mov r8, 0 ;put zero on stack
    mov [rsp], r8w


    mov r11, 0 ;loop Count initiliased 
    .loop2_start:
        cmp rdx, 0 ;check if rdx is zero to determing if fixed digits 
        je .if1_end
        
        cmp rdx, r11 ;check if digit count matches loop count (for digits)
        jle .if2_end

        jmp .if3_end 
        .if1_end:

        cmp rcx, 0 ;check if number is zero (everything has been printed)
        jne .if3_end
        
        
        cmp r11, 0 ;check if something has been printed by loop count being over 0
        jne .if2_end

        inc r11 ; add zero to stack to be printed 
        sub rsp, 2
        mov r8, 0x0030 
        mov [rsp], r8w

        .if2_end:

        jmp .loop2_end 
        .if3_end:

        dec rsp ;add zero to convert to unicode
        mov bl, 0 
        mov [rsp], bl

        push rdx 
        mov rax, rcx
        mov rcx, 10
        mov rdx, 0
        div rcx
        mov rcx, rax
        mov r8, rdx
        pop rdx 

        dec rsp 
        add r8, 0x30
        mov [rsp], r8b

        inc r11 
        jmp .loop2_start
    .loop2_end:
    ;Print 
    mov rcx, rsp
    push r11 ;save count to fix stack
    call print_unicode

    pop r11
    mov rax, 2 ;Correct the stack pointer 
    mul r11
    add rsp, rax
    add rsp, 2

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
    mov r11, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [r11]
    mov r11, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r11] 
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
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetMode
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    call rbx 
    ret

QueryMode:
    ;rcx - mode number  
    ;rdx - Column Output pointer 
    ;r8 - Row Output pointer 

    mov r9, r8
    mov r8, rdx
    mov rdx, rcx
    
    mov r11, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.QueryMode
    mov rbx, [r11]
    mov r11, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r11]
    call rbx 
    ; call exception
    ret 

next_line:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rdx, [rcx]
    add rdx, 16
    mov r8, 0
    mov r8d, [rdx]
    add r8, 1
    mov rdx, r8

    mov rcx, 0 
    call SetCursorPosition

    ret 

SetCursorPosition:
    ;rcx is the column
    ;rdx is the Row 

    mov r8, rdx
    mov rdx, rcx

    mov r11, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetCursorPosition
    mov rbx, [r11]
    mov r11, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r11]
    call rbx 
    ret

Clear_Screen:
    mov r11, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
    mov rbx, [r11]
    mov r11, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [r11] 
    call rbx 
    ret

SetTextColor:
    ;rdx is the color
    push rdx
    mov rdx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetAttribute
    mov rbx, [rdx]
    mov rdx, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rdx]
    pop rdx
    call rbx 
    ret

EnableCursor:
    mov r8, 0
    mov r9, 0
    mov rdx, rax
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.EnableCursor
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    ; call exception
    call rbx 
    ret

GetTime:
    ; No inputs output time is returned in EFI_Time and capablities are in EFI_TIME_CAPABILITIES 
    mov r11, EFI_RUNTIME_SERVICES.GetTime
    mov rbx, [r11]
    mov rcx, EFI_TIME
    mov rdx, EFI_TIME_CAPABILITIES
    call rbx 

    ret

SetTimer:
    ;rcx is the Event
    ;rdx is the Type 
    ; r8 is the Trigger time 

    mov rax, EFI_BOOT_SERVICES.SetTimer
    mov rbx, [rax]
    call rbx 
    ret


WaitForEvent:
    ;rcx is the number of Events 
    ;rdx is the event 
    mov r8, EFI_BOOT_SERVICES.WaitForEvent
    mov rbx, [r8]
    mov r8, index
    call rbx 
    ret


ReadKeyStroke:
    mov rdx, EFI_SYSTEM_TABLE.ConIn
    mov rcx, [rdx]
    mov rdx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke
    mov rbx, [rdx]
    mov rdx, EFI_INPUT_KEY
    call rbx 
    ret

ResetSystem:
    mov r8, EFI_RUNTIME_SERVICES.ResetSystem
    mov rbx, [r8]
    mov rcx, 2
    mov rdx, EFI_SUCCESS
    mov r8, 0
    call rbx 
    ret

CreateEvent:
    ;rcx - Type
    ;rdx - NotifyTpl
    ;r8 - NotifyFunction
    ;r9 - NotifyContext
    ;after sub rsp 32
    ;[rsp - 0x10] - Event
    
    sub rsp, 0x28
    mov r11, EFI_BOOT_SERVICES.CreateEvent
    mov rbx, [r11]
    call rbx
    add rsp, 0x28

    ret