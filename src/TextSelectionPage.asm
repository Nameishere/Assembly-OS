DisplayTextSelection:
    call Clear_Screen

    ;Display Page Title: 
    mov rcx, .PageTitle
    call print_String
    call next_line

    mov rcx, .Headers
    call print_String
    call next_line

    mov rbx, .ColorArray
    mov r11, 0
    .loop:
    cmp r11, .ColorArraySize
    je .endloop
    push rbx
    push r11
    add rbx, r11
    mov rcx, [rbx]
    call print_String

    mov rdx, SelectedTextColor
    mov r10, [rdx]

    pop r11
    mov rax, r11
    push r11

    mov rdx, 0
    mov rcx, 8
    div rcx
    cmp rax, r10
    jne .TextnotSelected

    mov rcx, .SelectArrow
    call print_String 

    .TextnotSelected:

    mov rcx, 1
    call jmptoColumn

    pop r11
    pop rbx
    push rbx
    push r11

    cmp r11, numBackground*8
    jge .DoneBackground

    add rbx, r11
    mov rcx, [rbx]
    call print_String

    mov rdx, SelectedBackgroundColor
    mov r10, [rdx]

    pop r11
    mov rax, r11
    push r11

    mov rdx, 0
    mov rcx, 8
    div rcx
    cmp rax, r10
    jne .BackgroundnotSelected

    mov rcx, .SelectArrow
    call print_String 

    .BackgroundnotSelected:

    mov rcx, 2
    call jmptoColumn

    pop r11
    pop rbx
    push rbx
    push r11

    add rbx, r11
    mov rcx, [rbx]
    call print_String

    mov rdx, SelectedHighlightColor
    mov r10, [rdx]

    pop r11
    mov rax, r11
    push r11

    mov rdx, 0
    mov rcx, 8
    div rcx
    cmp rax, r10
    jne .HighlightnotSelected

    mov rcx, .SelectArrow
    call print_String 

    .HighlightnotSelected:


    .DoneBackground:

    call next_line
    pop r11
    add r11, 8
    pop rbx
    jmp .loop

    .endloop:

    call HighlightSelectionText
    
    call DisplayEsc
    call DisplayTime

    

    jmp TextSelectionCheckKey

    .PageTitle: db "                     Select Attribute", 0
    .Headers: db "Text Color:          BackgroundColor:     HighlightColor:", 0
    .SelectArrow: db " <-", 0
    .ColorArray: dq .BlackText, .BlueText, .GREENText, .CYANText, .REDText, .MAGENTAText, .BROWNText, .LIGHTGRAYText, .DARKGRAYText, .LIGHTBLUEText, .LIGHTGREENText, .LIGHTCYANText, .LIGHTREDText, .LIGHTMAGENTAText, .YELLOWText, .WHITEText
    .ColorArraySize: equ ($-.ColorArray)

    .BlackText: db "Black", 0
    .BlueText: db "BLUE", 0
    .GREENText: db "GREEN", 0
    .CYANText: db "CYAN", 0
    .REDText: db "RED", 0
    .MAGENTAText: db "MAGENTA", 0
    .BROWNText: db "BROWN", 0
    .LIGHTGRAYText: db "LIGHTGRAY", 0
    .DARKGRAYText: db "DARKGRAY", 0
    .LIGHTBLUEText: db "LIGHTBLUE", 0
    .LIGHTGREENText: db "LIGHTGREEN", 0
    .LIGHTCYANText: db "LIGHTCYAN", 0
    .LIGHTREDText: db "LIGHTRED", 0
    .LIGHTMAGENTAText: db "LIGHTMAGENTA", 0
    .YELLOWText: db "YELLOW", 0
    .WHITEText: db "WHITE", 0

unHighlightSelectionText:
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
    mov rbx, SelectedRow
    mov rdx, [rbx]
    push rdx
    add rdx, 2
    call SetCursorPosition

    mov rdx, SelectedColumn
    mov rcx, [rdx]
    call jmptoColumn


    pop rdx
    mov rcx, DisplayTextSelection.ColorArray
    mov rax, 8
    mul rdx 
    mov rdx, rax
    add rcx, rdx
    mov rcx, [rcx]
    call print_String

    call SelectedAttribute

    mov rdx, SelectedColumn
    mov rcx, [rdx]

    inc rcx 

    call FillColumn

    pop rcx
    pop rdx
    call SetCursorPosition

    ret

HighlightSelectionText:
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
    mov rbx, SelectedRow
    mov rdx, [rbx]
    push rdx
    add rdx, 2
    call SetCursorPosition

    mov rdx, SelectedColumn
    mov rcx, [rdx]
    call jmptoColumn

    call SetHighlight

    pop rdx
    mov rcx, DisplayTextSelection.ColorArray
    mov rax, 8
    mul rdx 
    mov rdx, rax
    add rcx, rdx
    mov rcx, [rcx]
    call print_String

    call SelectedAttribute

    mov rdx, SelectedColumn
    mov rcx, [rdx]

    inc rcx 

    call FillColumn

    call SetColors

    pop rcx
    pop rdx
    call SetCursorPosition

    ret


SelectedAttribute:

    mov rcx, SelectedColumn
    mov rdx, [rcx]
    cmp rdx, 0
    jne .check2 
    mov rcx, SelectedTextColor
    mov r8, [rcx]
    mov rcx, SelectedRow
    mov rdx, [rcx]
    cmp r8, rdx
    je .Selected
    jmp .done
    
    .check2:
    mov rcx, SelectedColumn
    mov rdx, [rcx]
    cmp rdx, 1
    jne .check3
    mov rcx, SelectedBackgroundColor
    mov r8, [rcx]
    mov rcx, SelectedRow
    mov rdx, [rcx]
    cmp r8, rdx
    je .Selected
    jmp .done

    .check3:
    mov rcx, SelectedHighlightColor
    mov r8, [rcx]
    mov rcx, SelectedRow
    mov rdx, [rcx]
    cmp r8, rdx
    je .Selected
    jmp .done

    .Selected:
    mov rcx, .SelectArrow
    call print_String

    .done:
    
    ret
    .SelectArrow: db " <-", 0 

    
TextSelectionCheckKey:

    .Start:
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
     je increaseSelectionText

    cmp cx, 0x01 ;up arrow 
    je decreaseSelectionText


    cmp cx, 0x03 ;Right arrow 
    je RightSelectionText

    
    cmp cx, 0x04 ;Left arrow 
    je lefSelectionText

    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.unicodeChar
    mov cx, [rdx]
    
    cmp rcx, 0x0D ;Enter Key
    je ChangeSelection

    jmp .Start

increaseSelectionText:
    mov rbx, SelectedRow
    mov rcx, [rbx]
    
    push rcx
    
    mov rcx, SelectedColumn
    mov r11, [rcx]
    
    mov rax, 8
    mul r11
    mov rdx, ColumnHeights
    add rdx, rax
    pop rcx

    mov r11, [rdx]
    cmp rcx, r11
    je TextSelectionCheckKey
    push rbx
    push rcx
    call unHighlightSelectionText
    pop rcx
    pop rbx

    inc rcx
    mov [rbx], rcx

    call HighlightSelectionText

    jmp TextSelectionCheckKey

decreaseSelectionText:
    mov rbx, SelectedRow
    mov rcx, [rbx]

    cmp rcx, 0
    je TextSelectionCheckKey

    push rbx
    push rcx
    call unHighlightSelectionText
    pop rcx
    pop rbx

    dec rcx
    mov [rbx], rcx

    call HighlightSelectionText

    jmp TextSelectionCheckKey

RightSelectionText:
    mov rbx, SelectedColumn
    mov rcx, [rbx]

    cmp rcx, 2
    je TextSelectionCheckKey

    push rbx
    push rcx
    call unHighlightSelectionText
    pop rcx
    pop rbx

    inc rcx
    mov [rbx], rcx

    mov rax, 8
    mul rcx
    mov rdx, ColumnHeights
    add rdx, rax
    mov rcx, [rdx]
    mov rdx, SelectedRow
    mov r11, [rdx]

    cmp rcx, r11
    jg .Fine

    mov [rdx], rcx
    .Fine:

    call HighlightSelectionText

    jmp TextSelectionCheckKey

lefSelectionText:
    mov rbx, SelectedColumn
    mov rcx, [rbx]

    cmp rcx, 0
    je TextSelectionCheckKey

    push rbx
    push rcx
    call unHighlightSelectionText
    pop rcx
    pop rbx

    dec rcx
    mov [rbx], rcx

    call HighlightSelectionText

    jmp TextSelectionCheckKey


ChangeSelection:
    mov rcx, SelectedColumn 
    mov rdx, [rcx]
    cmp rdx, 0 
    je .changeTextColor

    cmp rdx, 1
    je .changeBackgroundColor

    cmp rdx, 2
    je .changeHighlightColor

    jmp DisplayTextSelection
    .changeTextColor:

    mov rdx, SelectedRow
    mov rcx, [rdx]
    mov rdx, SelectedTextColor
    mov [rdx], rcx

    call SetColors

    jmp DisplayTextSelection
    .changeBackgroundColor:

    mov rdx, SelectedRow
    mov rcx, [rdx]
    mov rdx, SelectedBackgroundColor
    mov [rdx], rcx

    call SetColors


    jmp DisplayTextSelection
    .changeHighlightColor:


    mov rdx, SelectedRow
    mov rcx, [rdx]
    mov rdx, SelectedHighlightColor
    mov [rdx], rcx

    call SetColors

    jmp DisplayTextSelection

SetColors:

    mov rcx, Highlighted
    mov rdx, 0
    mov [rcx], rdx

    mov rcx, SelectedBackgroundColor
    mov rdx, [rcx]

    shl rdx, 4

    mov rcx, SelectedTextColor
    mov r11, [rcx]
    add rdx, r11 

    mov rcx, rdx
    call SetTextColor
    ret

Highlighted: dq 0


SetHighlight:

    mov rcx, Highlighted
    mov rdx, 1
    mov [rcx], rdx

    mov rcx, SelectedHighlightColor
    mov rdx, [rcx]

    shl rdx, 4

    mov rcx, SelectedTextColor
    mov r11, [rcx]
    add rdx, r11 

    mov rcx, rdx
    call SetTextColor
    ret

section .data

SelectedColumn: dq 1
SelectedRow: dq 0

SelectedTextColor dq 2
colPos equ 21
numBackground equ 8
numText equ 14
SelectedBackgroundColor dq 0
SelectedHighlightColor dq 1

ColumnHeights:
    .Column1: dq 15
    .Column2: dq 7
    .Column3: dq 7
