DisplayMenu:
    call Clear_Screen

    ;Display Page Title: 
    mov rcx, .PageTitle
    call print_String
    call next_line
    call next_line

    ;Firmware Section Title
    mov rcx, .FirmwareInfo
    call print_String
    call next_line

    ;Text Color Selection
    mov rcx, .TextSelection
    call print_String
    call next_line

    ;Mode Selection
    mov rcx, .ModeSelection
    call print_String
    call next_line

    ;Highlight the Selection
    call HighlightSelection

    ; Display time and how to esc
    call DisplayEsc
    call DisplayTime

    ;Wait for Key to be pressed
    jmp MenucheckKey

    .PageTitle: db "        Menu", 0
    .FirmwareInfo: db   "Info Page", 0
    .TextSelection: db  "Text Selection", 0
    .ModeSelection: db  "Mode Selection", 0
    .titles: dq .FirmwareInfo, .TextSelection, .ModeSelection

HighlightSelection:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rcx]

    add rbx, 12
    mov rdx, 0
    mov edx, [rbx]
    push rdx
    add rbx, 4
    mov rcx, 0
    mov ecx, [rbx]
    push rcx 

    mov rcx, 0
    mov rbx, SelectedPage
    mov rdx, [rbx]
    push rdx
    add rdx, 2
    call SetCursorPosition

    call SetHighlight

    pop rdx
    mov rcx, DisplayMenu.titles
    mov rax, 8
    mul rdx 
    mov rdx, rax
    add rcx, rdx
    mov rcx, [rcx]
    call print_String

    Call SetColors

    pop rcx
    pop rdx
    call SetCursorPosition

    ret

unHighlightSelection:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rcx]

    add rbx, 12
    mov rdx, 0
    mov edx, [rbx]
    push rdx
    add rbx, 4
    mov rcx, 0
    mov ecx, [rbx]
    push rcx 

    mov rcx, 0
    mov rbx, SelectedPage
    mov rdx, [rbx]
    push rdx
    add rdx, 2
    call SetCursorPosition

    pop rdx
    mov rcx, DisplayMenu.titles
    mov rax, 8
    mul rdx 
    mov rdx, rax
    add rcx, rdx
    mov rcx, [rcx]
    call print_String

    pop rcx
    pop rdx
    call SetCursorPosition

    ret

increaseSelection:
    mov rbx, SelectedPage
    mov rcx, [rbx]

    cmp rcx, PageCount - 1 
    je MenucheckKey
    push rbx
    push rcx
    call unHighlightSelection
    pop rcx
    pop rbx

    inc rcx
    mov [rbx], rcx

    call HighlightSelection

    jmp MenucheckKey

decreaseSelection:
    mov rbx, SelectedPage
    mov rcx, [rbx]

    cmp rcx, 0
    je MenucheckKey

    push rbx
    push rcx
    call unHighlightSelection
    pop rcx
    pop rbx

    dec rcx
    mov [rbx], rcx

    call HighlightSelection

    jmp MenucheckKey

MenucheckKey:

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

    cmp cx, 0x02 ;down arrow 
     je increaseSelection

    cmp cx, 0x01 ;up arrow 
    je decreaseSelection

    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.unicodeChar
    mov cx, [rdx]
    
    cmp rcx, 0x0D ;Enter Key
    je ChangePage

    jmp .Start


ChangePage:
    mov rcx, SelectedPage 
    mov rdx, [rcx]
    cmp rdx, 0 
    je DisplayFirmwareInfo

    mov rcx, SelectedPage 
    mov rdx, [rcx]
    cmp rdx, 1 
    je DisplayTextSelection

    mov rcx, SelectedPage 
    mov rdx, [rcx]
    cmp rdx, 2
    je DisplayModeSelection

    jmp MenucheckKey

section .data



SelectedPage: dq 1

PageCount equ 3