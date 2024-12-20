DisplayModeSelection:
    call Clear_Screen

    ;Display Page Title: 
    mov rcx, .PageTitle
    call print_String
    call next_line

    mov rcx, .maxmodes
    call print_String

    mov rcx, SIMPLE_TEXT_OUTPUT_MODE.MaxMode
    mov rdx, 0
    mov edx, [rcx]
    mov rcx, rdx
    mov rdx, 0
    call print_Number
    call next_line 


    mov rcx, .Headers
    call print_String
    call next_line

    ; call .HighlighSelection

    call display_modes
    
    call DisplayEsc
    call DisplayTime

    jmp .CheckKey

    .maxmodes: db "Max Mode = ", 0
    .PageTitle: db "                     Select Mode", 0
    .Headers: db "Mode Number:         Column Number:       Row Number:", 0
    .SelectArrow: db " <-", 0

    .HighlightSelection:
         
         




    ret

    .CheckKey:
        .Start:
        mov rcx, 1
        mov rdx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.WaitForKey

        call WaitForEvent
        
        call ReadKeyStroke
        mov rcx, 0
        mov rdx, EFI_INPUT_KEY.ScanCode
        mov cx, [rdx]

        mov rbx, .Start

        cmp rcx, 0x17 ;Esc 
        je ResetSystem

        cmp rcx, 0x05 ;Home Key 
        je DisplayMenu 

        ; cmp cx, 0x02 ;down arrow 
        ;  je increaseSelection

        ; cmp cx, 0x01 ;up arrow 
        ; je decreaseSelection

        mov rcx, 0
        mov rdx, EFI_INPUT_KEY.unicodeChar
        mov cx, [rdx]
        
        ; cmp rcx, 0x0D ;Enter Key
        ; je ChangePage

        jmp .Start

display_modes:

    mov rcx, 0
    .loop_Start:
    push rcx
    mov rcx, SIMPLE_TEXT_OUTPUT_MODE.MaxMode
    mov rdx, 0
    mov edx, [rcx]

    pop rcx
    push rcx
    cmp rdx, rcx
    jl .loop_End


    pop rcx
    push rcx 
    mov rdx, Column
    mov r8, Row
    call QueryMode

    cmp rax, 0
    jne .no_mode

    pop rcx
    push rcx
    mov rdx, 0
    call print_Number


    mov rcx, 1
    call jmptoColumn

    mov rdx, Column
    mov rcx, [rdx]
    mov rdx, 0
    call print_Number

    mov rcx, 2
    call jmptoColumn

    mov rdx, Row
    mov rcx, [rdx]
    mov rdx, 0
    call print_Number

    call next_line

    .no_mode:
    pop rcx
    inc rcx

    jmp .loop_Start
    .loop_End:

    pop rcx

    ret

section .data

SelectedMode: dq 0
HighlightedMode: dq 0
