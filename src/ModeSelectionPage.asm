DisplayModeSelection:
    call Clear_Screen

    ;Display Page Title: 
    mov rcx, .PageTitle
    call print_String
    call next_line

    mov rcx, .maxmodes
    call print_String

    mov rdx, SIMPLE_TEXT_OUTPUT_MODE.MaxMode
    mov rcx, 0
    mov ecx, [rdx]
    mov rdx, 0
    call print_Number
    call next_line 

    mov rcx, .Headers
    call print_String
    call next_line
    
    call .displayModes

    call .HighlightSelection

    call DisplayEsc
    call DisplayTime

    jmp .checkKey

    .maxmodes: db "Max Mode = ", 0
    .PageTitle: db "                     Select Mode", 0
    .Headers: db "Mode Number:         Column Number:       Row Number:", 0
    .SelectArrow: db " <-", 0

    .checkKey:
    mov rcx, 1
    mov rdx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.WaitForKey

    call WaitForEvent
    
    call ReadKeyStroke
    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.ScanCode
    mov cx, [rdx]
    
    cmp cx, 0x17 ;Escape key 
    je ResetSystem

    cmp cx, 0x05 ;Home Key 
    je DisplayMenu 

    cmp cx, 0x02 ;down arrow 
    je .increaseSelection

    cmp cx, 0x01 ;up arrow 
    je .decreaseSelection

    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.unicodeChar
    mov cx, [rdx]
    
    cmp rcx, 0x0D ;Enter Key
    je .ChangeSelection

    jmp .checkKey

.HighlightSelection:

    call GetCursorRow
    push rdx

    call GetCursorColumn
    mov rdx, rcx
    push rcx
    
    mov rcx, HighlightedMode
    mov r8, [rcx]
    push r8

    mov rdx, r8
    mov rcx, 0
    add rdx, 3
    call SetCursorPosition

    call SetHighlight

    pop r8
    mov rcx, StartRow
    mov rdx, [rcx]
    add rdx, r8
    mov rcx, rdx
    push rcx
    mov rdx, Column
    mov r8, Row
    call QueryMode

    pop rcx
    cmp rax, 0
    jne .noMode

    call .DisplayMode

    jmp .skipNoMode2
    .noMode:
    call .DisplayNoMode

    .skipNoMode2:

    call SetColors

    pop rcx
    pop rdx
    call SetCursorPosition
    ret


.unHighlightSelection:

    call GetCursorRow
    push rdx

    call GetCursorColumn
    mov rdx, rcx
    push rcx
    
    mov rcx, HighlightedMode
    mov r8, [rcx]
    push r8

    mov rdx, r8
    mov rcx, 0
    add rdx, 3
    call SetCursorPosition

    call SetColors

    pop r8
    mov rcx, StartRow
    mov rdx, [rcx]
    add rdx, r8
    mov rcx, rdx
    push rcx
    mov rdx, Column
    mov r8, Row
    call QueryMode

    pop rcx
    cmp rax, 0
    jne .noMode3

    call .DisplayMode

    jmp .skipNoMode3
    .noMode3:
    call .DisplayNoMode

    .skipNoMode3:

    call SetColors

    pop rcx
    pop rdx
    call SetCursorPosition
    ret

.increaseSelection:

    mov rcx, StartRow
    mov r8, [rcx]

    mov rdx, HighlightedMode
    mov rcx, [rdx]
    push rcx
    add r8, rcx

    mov rcx, SIMPLE_TEXT_OUTPUT_MODE.MaxMode
    mov rdx, 0
    mov edx, [rcx]

    pop rcx
    cmp rdx, r8
    je .checkKey

    push rcx
    mov rcx, SelectedMode
    mov rdx, [rcx]

    mov rcx, rdx
    mov rdx, Column
    mov r8, Row
    call QueryMode

    mov rcx, Row
    mov r10, [rcx]
    dec r10 
    pop rcx

    mov rdx, rcx

    cmp rdx, r10
    jge .check

    jmp .check2
    .check:
    mov rcx, StartRow
    mov rdx, [rcx]
    inc rdx
    mov [rcx], rdx

    call .displayModes
    call .HighlightSelection

    jmp .checkKey
    .check2:

    call .unHighlightSelection

    mov rcx, HighlightedMode
    mov rdx, [rcx]
    inc rdx
    mov [rcx], rdx 

    call .HighlightSelection

    jmp .checkKey

.decreaseSelection:
    mov rcx, StartRow
    mov r8, [rcx]

    mov rdx, HighlightedMode
    mov rcx, [rdx]
    add r8, rcx

    mov rdx, 0
    cmp rdx, r8
    je .checkKey

    mov rdx, rcx

    cmp rdx, 0
    je .check3

    jmp .check4
    .check3:
    mov rcx, StartRow
    mov rdx, [rcx]
    dec rdx
    mov [rcx], rdx

    call .displayModes
    call .HighlightSelection

    jmp .checkKey
    .check4:

    call .unHighlightSelection

    mov rcx, HighlightedMode
    mov rdx, [rcx]
    dec rdx
    mov [rcx], rdx 

    call .HighlightSelection

    jmp .checkKey


.ChangeSelection:
    mov rcx, StartRow
    mov r8, [rcx]

    mov rdx, HighlightedMode
    mov rcx, [rdx]
    add r8, rcx

    mov rcx, r8
    push rcx
    mov rdx, Column
    mov r8, Row
    call QueryMode

    pop rcx
    cmp rax, 0 
    jne .checkKey

    mov rdx, SelectedMode
    mov [rdx], rcx

    call Change_Mode

    jmp DisplayModeSelection

.displayModes:

    mov rcx, 0
    mov rdx, 3
    call SetCursorPosition

    mov rdx, 0 ;line
    mov rcx, StartRow
    mov r10, [rcx]
    mov rcx, r10 
    .loop_Start:
    push rdx
    push rcx
    mov rcx, SIMPLE_TEXT_OUTPUT_MODE.MaxMode
    mov rdx, 0
    mov edx, [rcx]

    pop rcx
    push rcx
    cmp rdx, rcx
    jl .loop_End

    mov rcx, SelectedMode
    mov rdx, [rcx]

    mov rcx, rdx
    mov rdx, Column
    mov r8, Row
    call QueryMode

    mov rcx, Row
    mov r10, [rcx]

    pop rcx 
    pop rdx
    push rdx
    push rcx

    dec r10 ; last row

    cmp rdx, r10 
    je .loop_End

    pop rcx
    push rcx 
    mov rdx, Column
    mov r8, Row
    call QueryMode
    
    pop rcx
    pop rdx
    inc rdx
    push rdx
    push rcx

    cmp rax, 0
    jne .no_mode

    call .DisplayMode

    jmp .skipNoMode
    .no_mode:
    call .DisplayNoMode

    .skipNoMode:
    pop rcx
    pop rdx
    inc rcx

    jmp .loop_Start
    .loop_End:

    pop rcx
    pop rdx

    ret

.DisplayNoMode:
    ;rcx - mode to display
    ; Column contains mode columns 
    ; row contains mode rows 
    mov rdx, 0
    call print_Number

    mov rcx, 1
    call FillColumn

    mov rcx, .HashTag
    call print_String

    mov rcx, 2
    call FillColumn

    mov rcx, .HashTag
    call print_String

    mov rcx, 3
    call FillColumn
    
    call next_line
    ret
    .HashTag: db "#", 0

.DisplayMode:
    ;rcx - mode to display
    ; Column contains mode columns 
    ; row contains mode rows 
    push rcx
    mov rdx, 0
    call print_Number

    mov rcx, 1
    call FillColumn

    mov rdx, Column
    mov rcx, [rdx]
    mov rdx, 0
    call print_Number

    mov rcx, 2
    call FillColumn

    mov rdx, Row
    mov rcx, [rdx]
    mov rdx, 0
    call print_Number

    pop rcx
    mov rdx, SelectedMode
    mov r10, [rdx] 
    cmp rcx, r10
    jne .end

    mov rcx, .SelectArrow
    call print_String
        
    .end:

    mov rcx, 3
    call FillColumn
    call next_line
    ret

section .data

SelectedMode: dq 0
HighlightedMode: dq 0 
StartRow: dq 0

