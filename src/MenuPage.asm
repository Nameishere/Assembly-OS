
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

    ;Highlight the Selection
    ; call HighlightSelection

    ; Display time and how to esc
    call DisplayEsc
    call DisplayTime

    ;Wait for Key to be pressed
    jmp MenucheckKey

    .PrintList:
    .PageTitle: db "        Menu", 0
    .FirmwareInfo: db   "Info Page          ", 0
    .TextSelection: db  "Text Selection     ", 0
    .ModeSelection: db  "Mode Selection     ", 0

HighlightSelection:
    


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

    cmp rcx, 0x17
    je ResetSystem

    cmp rcx, 0x03
    ; je increaseSelection

    cmp rcx, 0x02
    ; je decreaseSelection

    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.unicodeChar
    mov cx, [rdx]
    

    cmp rcx, 0x0D
    je ChangePage

    jmp .Start


ChangePage:
    mov rcx, SelectedPage 
    mov rdx, [rcx]
    cmp rdx, 0 
    je DisplayFirmwareInfo

    jmp MenucheckKey

section .data



SelectedPage: dq 1

PageCount equ 2