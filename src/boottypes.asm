EFI_BLACK equ  0x00
EFI_BLUE equ   0x01
EFI_GREEN equ  0x02
EFI_CYAN equ   0x03
EFI_RED equ    0x04
EFI_YELLOW equ 0x0E
EFI_WHITE equ  0x0F


uint64 equ 8
pointer equ 8
uint32 equ 4

EFI_SUCCESS equ 0
EFI_LOAD_ERROR equ 1 ; The image failed to load.
EFI_INVALID_PARAMETER equ 2 ; A parameter was incorrect.
EFI_UNSUPPORTED equ 3 ; The operation is not supported.
EFI_BAD_BUFFER_SIZE equ 4 ; The buffer was not the proper size for the request.
EFI_BUFFER_TOO_SMALL equ 5 ; The buffer is not large enough to hold the requested data. The required buffer size is returned in the appropriate parameter when this error occurs.
EFI_NOT_READY equ 6 ; There is no data pending upon return.
EFI_DEVICE_ERROR equ 7 ; The physical device reported an error while attempting the operation.
EFI_WRITE_PROTECTED equ 8 ; The device cannot be written to.
EFI_OUT_OF_RESOURCES equ 9 ; A resource has run out.
EFI_VOLUME_CORRUPTED equ 10 ;An inconstancy was detected on the file system causing the operating to fail.
EFI_VOLUME_FULL equ 11 ;There is no more space on the file system.
EFI_NO_MEDIA equ 12 ;The device does not contain any medium to perform the operation.
EFI_MEDIA_CHANGED equ 13 ;The medium in the device has changed since the last access.
EFI_NOT_FOUND equ 14 ;The item was not found.
EFI_ACCESS_DENIED equ 15 ;Access was denied.
EFI_NO_RESPONSE equ 16 ;The server was not found or did not respond to the request.
EFI_NO_MAPPING equ 17 ;A mapping to a device does not exist.
EFI_TIMEOUT equ 18 ;The timeout time expired.
EFI_NOT_STARTED equ 19 ;The protocol has not been started.
EFI_ALREADY_STARTED equ 20 ;The protocol has already been started.
EFI_ABORTED equ 21 ;The operation was aborted.
EFI_ICMP_ERROR equ 22 ;An ICMP error occurred during the network operation.
EFI_TFTP_ERROR equ 23 ;A TFTP error occurred during the network operation.
EFI_PROTOCOL_ERROR equ 24 ;A protocol error occurred during the network operation.
EFI_INCOMPATIBLE_VERSION equ 25 ;The function encountered an internal version that was incompatible with a version requested by the caller.
EFI_SECURITY_VIOLATION equ 26 ;The function was not performed due to a security violation.
EFI_CRC_ERROR equ 27 ;A CRC error was detected.
EFI_END_OF_MEDIA equ 28 ;Beginning or end of media was reached
EFI_END_OF_FILE equ 31 ;The end of the file was reached.
EFI_INVALID_LANGUAGE equ 32 ;The language specified was invalid.
EFI_COMPROMISED_DATA equ 33 ;The security status of the data is unknown or compromised and the data must be updated or replaced to restore a valid security status.
EFI_IP_ADDRESS_CONFLICT equ 34 ;There is an address conflict address allocation
EFI_HTTP_ERROR equ 35 ;A HTTP error occurred during the network operation.



section .bss

EFI_RESET_TYPE:
    .EfiResetCold: equ 0
    .EfiResetWarm: equ 1
    .EfiResetShutdown: equ 2
    .EfiResetPlatformSpecific: equ 3


EFI_SYSTEM_TABLE:
    ;EFI Table Header 
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;End of EFI Table Header
    .FirmwareVendor: resb 8 
    .FirmwareRevision: resb 8  
    .ConsoleInHandle: resb 8   
    .ConIn: resb 8  
    .ConsoleOutHandle: resb 8     
    .ConOut: resb 8  
    .StandardErrorHandle: resb 8  
    .StdErr: resb 8  
    .RuntimeServices: resb 8  
    .BootServices: resb 8  
    .NumberOfTableEntries: resb 8  
    .ConfigurationTable: resb 8   
    .size: equ $ - EFI_SYSTEM_TABLE

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL:
    .Reset: resb pointer
    .OutputString: resb pointer ;
    .TestString: resb pointer ;
    .QueryMode: resb pointer ;
    .SetMode: resb pointer ;
    .SetAttribute: resb pointer ;
    .ClearScreen: resb pointer ;
    .SetCursorPosition: resb pointer ;
    .EnableCursor: resb pointer ;
    .Mode: resb pointer
    .size: equ $ - EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL 


EFI_SIMPLE_TEXT_INPUT_PROTOCOL:
    .Reset: resb pointer 
    .ReadKeyStroke: resb pointer   
    .WaitForKey: resb pointer 
    .size: equ $ - EFI_SIMPLE_TEXT_INPUT_PROTOCOL


EFI_BOOT_SERVICES:
    ;EFI Table Header 
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;End of EFI Table Header
    ;
    ; Task Priority Services
    ;
    .RaiseTPL: resq 1; EFI 1.0+
    .RestoreTPL: resq 1; EFI 1.0+
    ;
    ; Memory Services
    ;
    .AllocatePages: resq 1; EFI 1.0+
    .FreePages: resq 1; EFI 1.0+
    .GetMemoryMap: resq 1; EFI 1.0+
    .AllocatePool: resq 1; EFI 1.0+
    .FreePool: resq 1; EFI 1.0+
    ;
    ; Event & Timer Services
    ;
    .CreateEvent: resq 1; EFI 1.0+
    .SetTimer: resq 1; EFI 1.0+
    .WaitForEvent: resq 1; EFI 1.0+
    .SignalEvent: resq 1; EFI 1.0+
    .CloseEvent: resq 1; EFI 1.0+
    .CheckEvent: resq 1; EFI 1.0+
    ;
    ; Protocol Handler Services
    ;
    .InstallProtocolInterface: resq 1; EFI 1.0+
    .ReinstallProtocolInterface: resq 1; EFI 1.0+
    .UninstallProtocolInterface: resq 1; EFI 1.0+
    .HandleProtocol: resq 1; EFI 1.0+
    .Reserved2: resq 1; EFI 1.0+
    .RegisterProtocolNotify: resq 1; EFI 1.0+
    .LocateHandle: resq 1; EFI 1.0+
    .LocateDevicePath: resq 1; EFI 1.0+
    .InstallConfigurationTable: resq 1; EFI 1.0+
    ;
    ; Image Services
    ;
    .LoadImage: resq 1; EFI 1.0+
    .StartImage: resq 1; EFI 1.0+
    .Exit: resq 1; EFI 1.0+
    .UnloadImage: resq 1; EFI 1.0+
    .ExitBootServices: resq 1; EFI 1.0+
    ;
    ; Miscellaneous Services
    ;
    .GetNextMonotonicCount: resq 1; EFI 1.0+
    .Stall: resq 1; EFI 1.0+
    .SetWatchdogTimer: resq 1; EFI 1.0+
    ;
    ; DriverSupport Services
    ;
    .ConnectController: resq 1; EFI 1.1
    .DisconnectController: resq 1; EFI 1.1+
    ;
    ; Open and Close Protocol Services
    ;
    .OpenProtocol: resq 1; EFI 1.1+
    .CloseProtocol: resq 1; EFI 1.1+
    .OpenProtocolInformation: resq 1; EFI 1.1+
    ;
    ; Library Services
    ;
    .ProtocolsPerHandle: resq 1; EFI 1.1+
    .LocateHandleBuffer: resq 1; EFI 1.1+
    .LocateProtocol: resq 1; EFI 1.1+
    .InstallMultipleProtocolInterfaces: resq 1; ;EFI 1.1+
    .UninstallMultipleProtocolInterfaces: resq 1; EFI 1.1+*
    ;
    ; 32-bit CRC Services
    ;
    .CalculateCrc32: resq 1; ; EFI 1.1+
    ;
    ; Miscellaneous Services
    ;
    .CopyMem: resq 1; EFI 1.1+
    .SetMem: resq 1; EFI 1.1+
    .CreateEventEx: resq 1; UEFI 2.0+
    .size: equ $ - EFI_BOOT_SERVICES


EFI_RUNTIME_SERVICES:
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;
    ; Time Services
    ;
    .GetTime: resq 1
    .SetTime: resq 1
    .GetWakeupTime: resq 1
    .SetWakeupTime: resq 1
    ;
    ; Virtual Memory Services
    ;
    .SetVirtualAddressMap: resq 1
    .ConvertPointer: resq 1
    ;
    ; Variable Services
    ;
    .GetVariable: resq 1
    .GetNextVariableName: resq 1
    .SetVariable: resq 1
    ;
    ; Miscellaneous Services
    ;
    .GetNextHighMonotonicCount: resq 1
    .ResetSystem: resq 1
    ;
    ; UEFI 2.0 Capsule Services
    ;
    .UpdateCapsule: resq 1
    .QueryCapsuleCapabilities: resq 1
    ;
    ; Miscellaneous UEFI 2.0 Service
    ;
    .QueryVariableInfo: resq 1
    .size: equ $ - EFI_RUNTIME_SERVICES

EFI_TIME:;
    .Year: resw 1; // 1900 - 9999
    .Month: resb 1; // 1 - 12
    .Day: resb 1; // 1 - 31
    .Hour: resb 1; // 0 - 23
    .Minute: resb 1; // 0 - 59
    .Second: resb 1; // 0 - 59
    .Pad1: resb 1;
    .Nanosecond: resd 1 ; // 0 - 999,999,999
    .TimeZone: resw 1 ; // —1440 to 1440 or 2047
    .Daylight: resb 1;
    .Pad2: resb 1;

EFI_EVENT_NOTIFY:
    .Event: resq 1
    .Context: resq 1 



EFI_EVENT: resq 1 
 
EVT_TIMER equ  0x80000000
EVT_RUNTIME equ  0x40000000
EVT_NOTIFY_WAIT equ  0x00000100
EVT_NOTIFY_SIGNAL equ  0x00000200
EVT_SIGNAL_EXIT_BOOT_SERVICES equ  0x00000201
EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE equ  0x60000202


EFI_TIME_CAPABILITIES:
    .Resolution: resd 1
    .Accuracy: resd 1
    .SetsToZero: resb 1


TPL_APPLICATION equ  4
TPL_CALLBACK equ  8
TPL_NOTIFY equ  16
TPL_HIGH_LEVEL equ  31

TimerCancel equ 0
TimerPeriodic equ 1
TimerRelative equ 2
 

 EFI_INPUT_KEY:
    .ScanCode: resw 1
    .unicodeChar: resw 1
 

index: resq 1