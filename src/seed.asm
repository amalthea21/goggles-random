%include "constants.inc"

section .data
    global current_seed
    current_seed dq 0xDEADBEEFCAFEBABE  ; initial static seed

section .text
    global init_seed
    global get_seed
    global update_seed
    global mix_seed

init_seed:
    ; initialize seed with system time and other entropy sources
    push rbp
    mov rbp, rsp

    ; get systime
    mov rax, SYS_CLOCK_GETTIME
    mov rdi, CLOCK_REALTIME
    sub rsp, 16
    mov rsi, rsp
    syscall

    ; mix seconds and nanoseconds
    mov rax, [rsp]          ; seconds
    mov rdx, [rsp + 8]      ; nanoseconds
    xor rax, rdx            ; mix by XOR
    add rsp, 16

    ; mix with current PID
    mov rdi, 0              ; getpid syscall
    mov rax, SYS_GETPID
    syscall

    xor rax, [current_seed] ; mix with current seed

    ; mix with stack pointer
    xor rax, rsp

    ; store as new seed
    mov [current_seed], rax

    pop rbp
    ret

get_seed:
    ; get curent seed value
    mov rax, [current_seed]
    ret

update_seed:
    ; update seed with new entropy
    ; input: rdi = entropy value to mix in

    mov rax, [current_seed]

    ; XOR with new entropy
    xor rax, rdi

    ; mix
    rol rax, 13
    xor rax, 0x9E3779B97F4A7C15 ; golden ratio constant

    mov [current_seed], rax
    ret

mix_seed:
    ; mix current seed with provided value
    ; input: rdi = value to mix in
    ; output: rax = mixed result

    mov rax, [current_seed]

    ; xor rotate mix
    xor rax, rdi
    rol rax, 17
    xor rax, 0xBF58476D1CE4E5B9 ; mixing constant
    rol rax, 31

    ; update seed
    mov [current_seed], rax
    ret

section .text
    ; add syscall for getpid
        %ifndef SYS_GETPID
        %define SYS_GETPID 39
        %endif