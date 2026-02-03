%include "constants.inc"

section .text
    global get_args     ; make function available to other files
    global parse_range  ; make function available to other files

get_args:
    ; initial stack layout is:
    ; [rsp]     = argc (number of arguments)
    ; [rsp+8]   = argv[0] (pointer to program name)
    ; [rsp+16]  = argv[1] (pointer to first argument)
    ; ...

    ; get original stack pointer from start
    mov rax, [saved_rsp]
    mov rdi, [rax]          ; rdi = argc
    lea rsi, [rax + 8]      ; rsi = pointer to argv[0]

    ; return values:
    ; rdi = argc
    ; rsi = pointer to argv (array of string pointers)
    ret

parse_range:
    ; Parse min and max from command line arguments
    ; Returns: rdi = min, rsi = max
    ; If invalid or missing args, returns default: rdi = 0, rsi = 255

    call get_args
    ; rdi = argc, rsi = pointer to argv array

    ; save values before we modify rdi
    mov r14, rsi            ; r14 = argv pointer
    mov r15, rdi            ; r15 = argc

    ; check if we have at least 3 arguments (program name + 2 args)
    cmp r15, 3
    jl .use_defaults

    ; parse argv[1] (min)
    ; argv[0] is at [r14], argv[1] is at [r14+8]
    mov rdi, [r14 + 8]      ; get pointer to argv[1] string
    call atoi
    mov r12, rax            ; save min in r12

    ; parse argv[2] (max)
    ; argv[2] is at [r14+16]
    mov rdi, [r14 + 16]     ; get pointer to argv[2] string
    call atoi
    mov r13, rax            ; save max in r13

    ; validate: min <= max
    cmp r12, r13
    jg .use_defaults

    ; return valid values
    mov rdi, r12
    mov rsi, r13
    ret

.use_defaults:
    xor rdi, rdi            ; min = 0
    mov rsi, 255            ; max = 255
    ret

atoi:
    ; convert ASCII string to integer
    ; input: rdi = pointer to string
    ; output: rax = integer value
    xor rax, rax            ; result = 0
    xor rcx, rcx            ; temp for current char

.loop:
    movzx rcx, byte [rdi]   ; load next character
    cmp rcx, '0'
    jl .done                ; if < '0', done
    cmp rcx, '9'
    jg .done                ; if > '9', done

    sub rcx, '0'            ; convert ASCII to digit
    imul rax, 10            ; result *= 10
    add rax, rcx            ; result += digit
    inc rdi                 ; next character
    jmp .loop

.done:
    ret

section .data
    global saved_rsp        ; make variable available to other files
    saved_rsp dq 0          ; storage for original stack pointer