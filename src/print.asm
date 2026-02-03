%include "constants.inc"

section .text
    global print_number

print_number:
    ; print a 64-bit unsigned int to stdout
    ; input: rax = number to print
    ; clobbers: rax, rdi, rsi, rdx, rcx, r8, r9, r10

    push rbp
    mov rbp, rsp
    sub rsp, 32         ; allocate buffer (max 20 digits + newline)

    mov r8, rax         ; r8 = number to print
    lea rcx, [rsp + 31] ; rcx = end of buffer
    mov byte [rcx], 0x0A; newline at end
    mov r10, rcx        ; r10 = end position (after newline)
    dec rcx             ; move back for digits
    mov r9, 10          ; divisor

    ; handle zero case
    test r8, r8
    jnz .convert_loop
    mov byte [rcx], '0'
    dec rcx
    jmp .write_out

.convert_loop:
    mov rax, r8         ; number to divide
    xor rdx, rdx        ; clear rdx for division
    div r9              ; rax = quotient, rdx = remainder
    add dl, '0'         ; convert remainder to ASCII
    mov [rcx], dl       ; store digit
    dec rcx             ; move buffer pointer backwards
    mov r8, rax         ; quotient becomes new number
    test rax, rax
    jnz .convert_loop

.write_out:
    ; rcx points one before first digit
    inc rcx             ; rcx = start of number string
    mov rsi, rcx        ; rsi = buffer start

    ; calculate length (including newline)
    mov rdx, r10
    sub rdx, rcx
    inc rdx             ; +1 for newline

    ; write to stdout
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall

    mov rsp, rbp
    pop rbp
    ret