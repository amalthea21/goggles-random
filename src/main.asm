section .data
    msg db "Hello, World!", 10      ; Message with newline
    msg_len equ $ - msg             ; Calculate message length

section .text
    global _start

_start:
    ; write to stdout
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; message address
    mov rdx, msg_len    ; message length
    syscall

    ; exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit code 0
    syscall