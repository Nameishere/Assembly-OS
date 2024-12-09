
DisplayMenu:
    call Clear_Screen

    ;Display Page Title: 
    mov rax, .PageTitle
    call print_String
    call next_line
    call next_line


    mov rax, SelectedPage
    mov rbx, [rax]
    cmp rbx, 0
    jne .Swith1

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rax]
    add rbx, 8 

    mov rax, [rbx]

    push rax 
    add rax, 0x20

    call SetTextColor

    ;Firmware Section Title
    mov rax, .FirmwareInfo
    call print_String
    call next_line

    pop rax

    call SetTextColor   

    .Swith1:

    ;Text Color Selection
    mov rax, .TextSelection
    call print_String
    call next_line

    call DisplayEsc
    call DisplayTime

    call DisplayTime

    call MenucheckKey



    ret 
    .PageTitle: db "        Menu", 0
    .FirmwareInfo: db "Info Page", 0
    .TextSelection: db "Text Selection", 0
    .ModeSelection: db "Mode Selection", 0


MenucheckKey:

    .Start:
    mov rcx, 1
    mov rdx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.WaitForKey

    call WaitForEvent
    cmp rax, EFI_SUCCESS
    jne exception
    
    call ReadKeyStroke
    mov rdx, EFI_INPUT_KEY.ScanCode
    mov rcx, [rdx]
    
    cmp rcx, 0x17
    je ResetSystem

    jmp .Start

    ret


section .data

SelectedPage: dq 0