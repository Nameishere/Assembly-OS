
section .text
localtime:
    ;divide to get the number of minutes since epoch in rax and currenty seconds in rdx 
    push rcx
    push rax 
    push rdx 
    push rbx
    push r10

    mov rdx, 0
    mov rcx, 60 
    div rcx

    ; rdx is the current seconds time  
    mov [tm.sec], dl

    ;divide to get the number of hours since epoch in rax and current minutes in rdx 
    mov rdx, 0
    mov rcx, 60 
    div rcx

    ; rdx is the current minutes 
    mov [tm.min], dl

    ; convert to time zone and daylight savings
    add rax, nz_time
    add rax, day_light_savings

    ;divide by 24 to get the number of days since epoch in rax and current hours in rdx
    mov rdx, 0
    mov rcx, 24 
    div rcx

    ; rdx is the current hours 
    mov [tm.hour], dl

    ;At this point rax is the number of days 
    ;need: number of years, day of year, months, day of month and day of week


    ;Calculate the day of the week 
    push rax 
    add rax, 3 ;account for not starting on monday 
    mov rdx, 0
    mov rcx, 7
    div rcx
    mov [tm.wday], dl
    pop rax


    ;calculate year 
    add rax, 365*2 + 1  ;account for leap year timings 
    
    mov rdx, 0
    mov rcx, 4
    mul rcx
    mov rdx, 0
    mov rcx, 1461 ;365*4 + 1
    div rcx
    sub rax, 2


    ;Year 
    push rax 
    push rdx 
    mov rcx, 70
    add rax, rcx
    mov [tm.year], eax
    pop rdx
    pop rax 

    ;caluculate day of year 
    push rax 
    mov rax, rdx
    
    mov rdx, 0
    mov rcx, 4
    div rcx

    mov [tm.yday], ax

    mov rdx, rax
    pop rax



    push rdx
    mov rdx,0 
    mov rcx, 4
    div rcx
    mov rax, rdx
    sub rax, 2
    pop rdx
    
    ;at this point rdx is the day of the year and rax is remainder of year /4 (0 when leap)
    ;need day of month and month
    mov rcx, 0 ; month
    mov r10, .month_lengths
    .startloop1:
    cmp rax, 0
    jne .ifend1 
    
    cmp rcx, 1
    je .ifend2
    
    .ifend1:
    cmp dx, [r10]
    jl .endloop1
    sub dx, [r10]
    jmp .else1
    .ifend2:
    
    cmp dx, 29
    jl .endloop1
    sub dx, 29
    .else1:


    
    inc r10
    inc r10
    inc rcx
    jmp .startloop1 
    .endloop1:


    mov [tm.mon], cl

    mov [tm.mday], dl

    mov byte [tm.isdst], day_light_savings

    pop r10
    pop rbx
    pop rdx
    pop rax
    pop rcx

    ret 
    .month_lengths: dw 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


print_localtime:
    ;Run the Local time function then call this function to print all Tm Values 
    mov rbx, 5
    mov rax, 0
    mov al, [tm.sec]
    call print_number
    call print_newline
    mov rax, 0 
    mov al, [tm.min] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.hour] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.mday] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.mon] 
    call print_number
    call print_newline
    mov rax, 0
    mov eax, [tm.year] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.wday] 
    call print_number
    call print_newline
    mov rax, 0
    mov ax, [tm.yday] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.isdst] 
    call print_number
    call print_newline
    ret

timef:
    ;rax is a pointer to the output if not null 

    push rdx
    push rsi
    push rdi
    mov rdx, 0       ;message length
    mov rsi, 0        ;message to write
    mov rdi, rax        ;file descriptor
    mov rax, LINUX_SYSCALL.time  
    syscall            ;call kernel   

    call check_Error
    pop rdi
    pop rsi
    pop rdx
    

    ret