; hello_world64.asm 64-bit
;
; Author: Steve M <livewirez@github.com>
; Date: 16/05/2024
;
; Assembled using Nasm (Netwide Assembler)
; Linked with The GCC (GNU Compiler Collection) or MSVC Linker
; Using Windows Console Api for Stdout https://learn.microsoft.com/en-us/windows/console/getstdhandle and https://learn.microsoft.com/en-us/windows/console/writeconsole


extern GetStdHandle
extern WriteConsoleA
extern GetLastError
extern MessageBoxA
extern ExitProcess

section .bss
    written resd 1  ; Reserve space for one 32-bit integer

section .data
    hello db "Hello, World", 0
    hello_length equ $-hello ; Length of hello string

    STD_OUTPUT_HANDLE equ -11  ; -11 is the value for STD_OUTPUT_HANDLE

    dialog_box_title db "Hello World 64 Console", 0

    GetStdHandleErrorErrorMessage db "GetStdHandleError::Error getting the standard input handle", 0
    WriteConsoleAErrorMessage db "WriteConsoleAError::Could not print to console", 0

section .text
    global main

main:
    sub rsp, 28h  ; Allocate shadow space for Windows x64 calling convention

    ; Call GetStdHandle(STD_OUTPUT_HANDLE)
    mov ecx, STD_OUTPUT_HANDLE   ; nStdHandle
    call GetStdHandle
    cmp rax, 0                   ; Check if GetStdHandle failed
    je GetStdHandleError                 ; Jump to error handling if it failed

    ; Preparing the values for WriteConsoleA
    mov rcx, rax           ; hConsoleOutput (returned by GetStdHandle)
    lea rdx, [rel hello]   ; lpBuffer
    mov r8d, hello_length  ; nNumberOfCharsToWrite
    lea r9, [rel written]  ; lpNumberOfCharsWritten (address of written)
    mov qword [rsp], 0     ; lpReserved (NULL)
    call WriteConsoleA

    ;mov rax, 0             ; Force WriteConsoleA to return 0 instead of non zero
    test rax, rax           ; Check if WriteConsoleA failed
    jz WriteConsoleError            ; Jump to error handling if it failed

    ; Exit the process
    xor ecx, ecx  ; exit code 0
    call ExitProcess

    add rsp, 28h  ; Clean up shadow space



GetStdHandleError:
    ; Display error message using MessageBoxA

    ;----------------------------------------------------
    ;  64-bit Version
    ;----------------------------------------------------

    mov rcx, 0   ; hWnd
    ;mov rdx, 0   ; lpText
    lea rdx, [rel GetStdHandleErrorErrorMessage] ; lpText
    lea r8, [rel dialog_box_title] ; lpCaption
    mov r9d, 0   ; uType
    call MessageBoxA

    ; Exit the process with error code from GetLastError
    xor ecx, ecx  ; exit code 0
    call GetLastError
    call ExitProcess

WriteConsoleError:
    ; Display error message using MessageBoxA

    ;----------------------------------------------------
    ;  64-bit Version
    ;----------------------------------------------------

    mov rcx, 0   ; hWnd
    ;mov rdx, 0   ; lpText
    lea rdx, [rel WriteConsoleAErrorMessage] ; lpText
    lea r8, [rel dialog_box_title] ; lpCaption
    mov r9d, 0   ; uType
    call MessageBoxA

    ; Exit the process with error code from GetLastError
    xor ecx, ecx  ; exit code 0
    call GetLastError
    call ExitProcess
