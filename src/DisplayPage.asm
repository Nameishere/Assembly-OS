DisplayFirmwareInfo: 
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

    ;Display Firmware Vendor
    mov rcx, .FirmwareVendor
    call print_String
    mov rdx, EFI_SYSTEM_TABLE.FirmwareVendor
    mov rcx, [rdx]
    call print_unicode 
    call next_line

    ;Display Firmware Revision
    mov rcx, .FirmwareRevision
    call print_String
    mov rcx, EFI_SYSTEM_TABLE.FirmwareRevision
    call DisplayFirmwareRevision
    call next_line

    call next_line

    ;Table Section Title
    mov rcx, .TableInfo
    call print_String
    call next_line

    ;Display System Table Revision
    mov rcx, .SystemTableRevision
    call print_String
    mov rcx, EFI_SYSTEM_TABLE.Revision ;pointer to number 
    call DisplayRevision
    call next_line

    ;Display Boot Services Table Revision
    mov rcx, .BootServicesRevision
    call print_String
    mov rcx, EFI_BOOT_SERVICES.Revision
    call DisplayRevision
    call next_line

    ;Display RunTime Services Table Revision
    mov rcx, .RunTimeServicesRevision
    call print_String
    mov rcx, EFI_RUNTIME_SERVICES.Revision
    call DisplayRevision
    call next_line

    call DisplayEsc

    call DisplayTime

    jmp DisplaycheckKey

    .loop:
    jmp .loop 

    ret

    .PageTitle: db "        General Info Page", 0
    .FirmwareInfo: db "Firmware Info:", 0
    .TableInfo: db "Table Revisions:", 0
    .FirmwareVendor: db "System Firmware Vendor: ",0
    .FirmwareRevision: db "System Firmware Revision: ", 0
    .SystemTableRevision: db "System Table Revision: ", 0
    .BootServicesRevision: db "Boot Services Table Revision: ", 0
    .RunTimeServicesRevision: db "RunTime Services Table Revision: ", 0

DisplaycheckKey:

    .Start:
    mov rcx, 1
    mov rdx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.WaitForKey

    call WaitForEvent
    
    call ReadKeyStroke
    mov rcx, 0
    mov rdx, EFI_INPUT_KEY.ScanCode
    mov cx, [rdx]
    
    cmp rcx, 0x17 ;Escape key 
    je ResetSystem

    cmp rcx, 0x05 ;Home Key 
    je DisplayMenu 

    jmp .Start


DisplayRevision:
    ;rcx is pointer to number input
    mov r8, 0
    mov r8d, [rcx]
    mov r12, r8 
    shr r8, 16

    mov rcx, r8
    mov rdx, 0
    push r12
    call print_Number

    call print_dot

    pop r12
    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 10
    div rcx 
    mov rcx, rax
    mov r12, rdx
    mov rdx, 0 
    push r12
    call print_Number

    call print_dot

    pop r12
    mov rcx, r12
    mov rdx, 0 
    call print_Number

    ret

DisplayFirmwareRevision:
    mov r11, [rcx]
    mov rcx, r11 
    shr rcx, 16
    mov rdx, 0
    push r11
    call print_Number
    
    call print_dot

    pop r11
    mov rcx, r11
    and rcx, 0x0000000000FFFF
    mov rdx, 0 
    call print_Number

    ret