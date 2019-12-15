

extern printf
extern scanf
global assign6

segment .data
welcome db "This machine is running an Intel(R) Core(TM) i7-7700HQ CPU @ 2.80GHz",10,0
prompt db "Please enter the number of terms to be included in the harmonic sum:  ",10,0
one_float_format db "%lf",0
start db "The clock is now %ld tics and the computation will begin immediately.",10,0
sum db "Final sum is %7.10lf",10,0
stop db "The clock is now %ld and the computation is complete.",10,0
elapsed1 db "The elapsed time was %ld tics. ",0
elapsed2 db "At 2.8GHz that is %7.10lf seconds.",10,0
finish db "This assembly program will now return the harmonic sum to the driver program.",10,0
integerformat db "%ld", 0
printsum1 db "With %ld", 0
printsum2 db " terms the sum is %7.10lf",10,0
showmod db "show mod/r11: %ld ***********", 10,0
showr db "show r: %ld ***********", 10,0

segment .bss  ;Reserved for uninitialized data

segment .text ;Reserved for executing instructions.

assign6:


push rbp
mov  rbp,rsp
push rdi                                                    ;Backup rdi
push rsi                                                    ;Backup rsi
push rdx                                                    ;Backup rdx
push rcx                                                    ;Backup rcx
push r8                                                     ;Backup r8
push r9                                                     ;Backup r9
push r10                                                    ;Backup r10
push r11                                                    ;Backup r11
push r12                                                    ;Backup r12
push r13                                                    ;Backup r13
push r14                                                    ;Backup r14
push r15                                                    ;Backup r15
push rbx                                                    ;Backup rbx
pushf                                                       ;Backup rflags

;Registers rax, rip, and rsp are usually not backed up.
push qword 0

;welcome message to the viewer.
mov rax, 0
mov rdi, welcome
call printf


;Display a prompt message asking for input
mov rax, 0
mov rdi, prompt
call printf

;get number
mov       rax, 0
mov       rdi, integerformat
push      qword 0
mov       rsi, rsp
call      scanf
pop       r15

;get time
mov qword  rax, 0                                           ;Make sure rax is zeroed out.  This may be un-necessary.
mov qword  rdx, 0
cpuid
rdtsc                                                       ;Write the number of tics in edx:eax
shl        rdx, 32                                          ;Shift the lower half of rdx to the upper half of rdx
or         rdx, rax                                         ;Join the two half into a single register, namely: rdx
mov        r14, rdx                                         ;Save the clock in a safe register: in this case r14.

;show start time
mov qword rax, 0
mov rdi, start
mov rsi, r14
call printf



;sum arithmetic           ********************* TODO**********************
mov r12, 1                              ;counter at 1
mov rbx, 0x0000000000000000             ;sum holder xmm13 at 0
push rbx
movsd xmm13, [rsp]
pop rax

mov rax, r15
mov rbx, 10
div rbx
mov r13, rax                            ;get mod
inc r15
cdqe
cmp r15, 11                             ;if less than 10 then dont print out terms
jl onlycalc
jmp pass2                               ;else pass2 to regular loop
onlycalc:
loopless:
mov rbx, 0x3FF0000000000000
push rbx
movsd xmm14, [rsp]
pop rax
cvtsi2sd xmm12,r12
divsd xmm14, xmm12
addsd xmm13, xmm14

inc r12

cdqe
cmp r12, r15
jge end2
jmp loopless
pass2:


jmp pass                              ;pass through first print
;print sum of iteration
psum:
mov r9, r12
dec r9
mov qword rax, 0
mov rdi, printsum1
mov rsi, r9
call printf
push qword 99
mov rax, 1
mov rdi, printsum2
movsd xmm0, xmm13
call printf
pop rax
pass:
loop:
mov rbx, 0x3FF0000000000000
push rbx
movsd xmm14, [rsp]
pop rax
cvtsi2sd xmm12,r12
divsd xmm14, xmm12
addsd xmm13, xmm14

inc r12

cdqe
cmp r12, r15
jge end                   ;if counter reaches input num then end
mov r9, 0
mov rax, r12
mov rbx, r13
cqo
idiv rbx
mov r9, rdx
cdqe
cmp r9, 1                 ;if mod is equal to 1 then print term
je psum
jmp loop

end:

dec r15
mov qword rax, 0
mov rdi, printsum1        ;call print for last term, b/c counter starts at 1
mov rsi, r15
call printf
push qword 99
mov rax, 1
mov rdi, printsum2
movsd xmm0, xmm13
call printf
pop rax

end2:                     ;pass the last print, not needed for harmonic sum less than 10

push qword 99
mov rax, 1
mov rdi, sum
movsd xmm0, xmm13
call printf
pop rax

;Read the time on the cpu clock again
mov qword  rax, 0                    ;Make sure rax is zeroed out.  This may be un-necessary.
mov qword  rdx, 0
cpuid
rdtsc                                ;Write the number of tics in edx:eax
shl        rdx, 32                   ;Shift the lower half of rdx to the upper half of rdx
or         rdx, rax                     ;Join the two half into a single register, namely: rdx
mov r13, rdx

;show stop time
mov qword rax, 0
mov rdi, stop
mov rsi, r13
call printf

;Compute the elapsed time
sub        r13, r14               ;The elapsed time measured in tics is in rdx.
mov        r14, r13              ;Copy elapsed time to r14 for safe keeping, which is safer than rdx


;show elapsed time
mov qword rax, 0
mov rdi, elapsed1
mov rsi, r14
call printf

;show seconds
cvtsi2sd xmm15, r14
mov rbx, 0x41E4DC9380000000       ;find X.XGHz = XX eight zeroes
push rbx
divsd xmm15, [rsp]
pop rax

push qword 99
mov rax, 1
mov rdi, elapsed2
movsd xmm0, xmm15
call printf
pop rax




pop rax
movsd xmm0,xmm13
;===== Restore original values to integer registers ===============================================================================
popf                                                        ;Restore rflags
pop rbx                                                     ;Restore rbx
pop r15                                                     ;Restore r15
pop r14                                                     ;Restore r14
pop r13                                                     ;Restore r13
pop r12                                                     ;Restore r12
pop r11                                                     ;Restore r11
pop r10                                                     ;Restore r10
pop r9                                                      ;Restore r9
pop r8                                                      ;Restore r8
pop rcx                                                     ;Restore rcx
pop rdx                                                     ;Restore rdx
pop rsi                                                     ;Restore rsi
pop rdi                                                     ;Restore rdi
pop rbp                                                     ;Restore rbp

ret

;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3**
