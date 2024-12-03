
link to UEFI Documentation:
file:///home/george-pierce/Desktop/OS/Reference/UEFI_Spec_2_10_A_Aug8.pdf


Key: 
Do something with all Functions/values:

EFI_TABLE_HEADER
    Signature               Not Being Printed 
    Revision                Being Printed for each table that uses the Header 
    HeaderSize              Not Being Printed 
    CRC32                   Not Being Printed 
    Reserved                Not Being Printed


EFI_SYSTEM_TABLE 
    Hdr                     Revision Printed to Screen
    *FirmwareVendor         Printed to Screen 
    FirmwareRevision        Printed to Screen 
    ConsoleInHandle         Not Used
    *ConIn                  Not Used
    ConsoleOutHandle        Not Used
    *ConOut                 Not Used
    StandardErrorHandle     Not Used
    *StdErr                 Not Used
    *RuntimeServices        Not Used
    *BootServices           Not Used
    NumberOfTableEntries    Not Used
    *ConfigurationTable     Not Used

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL:
    Reset                   Used  
    OutputString            Used 
    TestString              Used 
    QueryMode               Used 
    SetMode                 Used 
    SetAttribute            Used
    ClearScreen             Used 
    SetCursorPosition       Used 
    EnableCursor            Used 
    Mode                    Accessed Cursor Row Position   


EFI_SIMPLE_TEXT_INPUT_PROTOCOL:
    Reset                   Used
    ReadKeyStroke           Used   
    WaitForKey              Not Used 


EFI_BOOT_SERVICES:
    Hdr                                 Revision Printed to Screen
    RaiseTPL                            Not Used
    RestoreTPL                          Not Used
    AllocatePages                       Not Used
    FreePages                           Not Used
    GetMemoryMap                        Not Used
    AllocatePool                        Not Used
    FreePool                            Not Used
    CreateEvent                         Not Used
    SetTimer                            Not Used
    WaitForEvent                        Not Used
    SignalEvent                         Not Used
    CloseEvent                          Not Used
    CheckEvent                          Not Used
    InstallProtocolInterface            Not Used
    ReinstallProtocolInterface          Not Used
    UninstallProtocolInterface          Not Used
    HandleProtocol                      Not Used
    Reserved2                           Not Used
    RegisterProtocolNotify              Not Used
    LocateHandle                        Not Used
    LocateDevicePath                    Not Used
    InstallConfigurationTable           Not Used
    LoadImage                           Not Used
    StartImage                          Not Used
    Exit                                Not Used
    UnloadImage                         Not Used
    ExitBootServices                    Not Used
    GetNextMonotonicCount               Not Used
    Stall                               Not Used
    SetWatchdogTimer                    Not Used
    ConnectController                   Not Used
    DisconnectController                Not Used
    OpenProtocol                        Not Used
    CloseProtocol                       Not Used
    OpenProtocolInformation             Not Used
    ProtocolsPerHandle                  Not Used
    LocateHandleBuffer                  Not Used
    LocateProtocol                      Not Used
    InstallMultipleProtocolInterfaces   Not Used
    UninstallMultipleProtocolInterfaces Not Used
    CalculateCrc32                      Not Used
    CopyMem                             Not Used
    SetMem                              Not Used
    CreateEventEx                       Not Used


EFI_RUNTIME_SERVICES:
    Hdr                         Not Used
    GetTime                     Not Used
    SetTime                     Not Used
    GetWakeupTime               Not Used
    SetWakeupTime               Not Used
    SetVirtualAddressMap        Not Used
    ConvertPointer              Not Used
    GetVariable                 Not Used
    GetNextVariableName         Not Used
    SetVariable                 Not Used
    GetNextHighMonotonicCount   Not Used
    ResetSystem                 Used
    UpdateCapsule               Not Used
    QueryCapsuleCapabilities    Not Used
    QueryVariableInfo           Not Used