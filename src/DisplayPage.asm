DisplayFirmwareInfo: 
    call Clear_Screen

    ;Display Page Title: 
    mov rax, .PageTitle
    call print_String
    call next_line
    call next_line

    ;Firmware Section Title
    mov rax, .FirmwareInfo
    call print_String
    call next_line

    ;Display Firmware Vendor
    mov rax, .FirmwareVendor
    call print_String
    mov rdx, EFI_SYSTEM_TABLE.FirmwareVendor
    mov rax, [rdx]
    call print_unicode 
    call next_line

    ;Display Firmware Revision
    mov rax, .FirmwareRevision
    call print_String
    mov rbx, EFI_SYSTEM_TABLE.FirmwareRevision
    call DisplayFirmwareRevision
    call next_line

    call next_line

    ;Table Section Title
    mov rax, .TableInfo
    call print_String
    call next_line

    ;Display System Table Revision
    mov rax, .SystemTableRevision
    call print_String
    mov rbx, EFI_SYSTEM_TABLE.Revision ;pointer to number 
    call DisplayRevision
    call next_line

    ;Display Boot Services Table Revision
    mov rax, .BootServicesRevision
    call print_String
    mov rbx, EFI_BOOT_SERVICES.Revision
    call DisplayRevision
    call next_line

    ;Display RunTime Services Table Revision
    mov rax, .RunTimeServicesRevision
    call print_String
    mov rbx, EFI_RUNTIME_SERVICES.Revision
    call DisplayRevision
    call next_line


    call DisplayTime

    call DisplayEsc

    ret

    .PageTitle: db "        General Info Page", 0
    .FirmwareInfo: db "Firmware Info:", 0
    .TableInfo: db "Table Revisions:", 0
    .FirmwareVendor: db "System Firmware Vendor: ",0
    .FirmwareRevision: db "System Firmware Revision: ", 0
    .SystemTableRevision: db "System Table Revision: ", 0
    .BootServicesRevision: db "Boot Services Table Revision: ", 0
    .RunTimeServicesRevision: db "RunTime Services Table Revision: ", 0


DisplayRevision:
    ;rbx is number input
    mov rax, 0
    mov eax, [rbx]
    mov r12, rax 
    shr rax, 16
    mov rcx, 0
    call print_Number

    call print_dot

    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 10
    div rcx 
    mov r12, rdx
    mov rcx, 0 
    call print_Number

    call print_dot

    mov rax, r12
    mov rcx, 0 
    call print_Number

    ret

DisplayFirmwareRevision:
    mov rax, [rbx]
    mov r12, rax 
    shr rax, 16
    mov rcx, 0
    call print_Number

    call print_dot

    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 0 
    call print_Number

    ret