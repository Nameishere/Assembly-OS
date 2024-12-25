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
    
    call DisplayEsc
    call DisplayTime

    .stay:
    jmp .stay

    .maxmodes: db "Max Mode = ", 0
    .PageTitle: db "                     Select Mode", 0
    .Headers: db "Mode Number:         Column Number:       Row Number:", 0
    .SelectArrow: db " <-", 0
    
.displayModes:

    mov rdx, 0 ;line

    mov r10, 0
    mov rcx, [r10] 
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


    pop rcx 
    pop rdx
    push rdx
    push rcx

    mov r10, 1 ; last row

    cmp rdx, r10 
    je .loop_End

    pop rcx
    push rcx 
    mov rdx, Column
    mov r8, Row
    call QueryMode

    cmp rax, 0
    jne .no_mode

    pop rcx
    pop rdx
    inc rdx
    push rdx
    push rcx

    call .DisplayMode

    .no_mode:
    pop rcx
    pop rdx
    inc rcx

    jmp .loop_Start
    .loop_End:

    pop rcx
    pop rdx

    ret

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
    call next_line
    ret



section .data

SelectedMode: dq 0
