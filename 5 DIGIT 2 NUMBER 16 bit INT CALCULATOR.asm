;   5 DIGIT 2 NUMBER 16 bit INT CALCULATOR 
;   Features:
;   upto 5 digit support
;   '-' input support
;   asks for input again while entering number if wrong input is pressed
;   press esc at menu to exit or press esc while entring number to exit at menu
;   handles div by 0

; CODE STARTS FROM HERE

; pm -> print message
; prints given message
pm macro p1
    mov ah,9
    mov dx,offset p1
    int 21h
endm


.model small
.stack 100h
.data

; VARS

msg1 db 13,10,13,10,'Press any from 1 to 4 to perform specified calculation OR press esc to exit...'

db 13,10,13,10,'1. Addition'
db 13,10,'2. Subtraction'
db 13,10,'3. Multiplication'
db 13,10,'4. Division'
db 13,10,13,10,'Your choice: $'

msg2 db 13,10,'Enter 1st Number: $'
msg3 db 13,10,'Enter 2nd Number: $'
msg4 db 13,10,13,10,'Result: $'

msg5 db 13,10,13,10,'Infinity Divide error - denominator is 0 $'

; neg flag 1 and 2 initally at 0
; will be set for flag 1 for first and 2 for second when user enter's '-'
neg_flag_1 db 0
neg_flag_2 db 0

; digit counter
counter dw 0
; first the second number and finally the result is stored in sum
sum dw 0
; the first complete input is stored in fsum
fsum dw 0
; multiplies previous value with 10
mulBy10 dw 10
; mod to value to print and divide digit at end 
; initially at 10k for 5 digits
mod dw 10000 

; stores operator val any from 1 to 4 based on user's input
op db '$'

.code

proc main
 
  mov ax,@data
  mov ds,ax
 
start: 
  ; prints menu
  pm msg1
    
  mov ah,1
  int 21h  
    
    ; starts comparision from here
    ; 27 for ESC key - if pressed then exit
   cmp al,27
   je end
   ; operator checking
   cmp al,'1'
   je plus
   
   cmp al,'2'
   je minus
   
   cmp al,'3'
   je multiply
   
   cmp al,'4'
   je divide
    ; if something else start again
   jmp start 
    
   ; moves input value by checking for which accordingly to op
   plus:
   mov op,1 
   jmp start_2 
    
   minus:
    mov op,2 
   jmp start_2
  
   multiply:
    mov op,3 
   jmp start_2
   
   divide:
    mov op,4
   
    
  ; the numbers inputs start from here
  start_2:
    
  mov cx,2     
        
inp:

    ; if its cx = 2 means its turn for first number 
    ; print first number prompt 
    cmp cx,2
    je  printmsg1
    
    ; else for second number
    pm msg3
    jmp input
    
  printmsg1:
    pm msg2
    
        
        
  input:
  
    mov ah,1
    int 21h
    
    ; takes input one digit a time and 
    ; compares
    
    ; here if pressed enter
    ; then jump to further operation
    cmp al,13
    je resume_2
    
    ; if esc - go to menu
    cmp al,27
    je retry
    
    ; if neg input then sets flag
    ; of whichever number's turn it is
     cmp al,'-'
     jne check_further
     
    ; '-' sign should be input at first digit only
     cmp counter,0
     jne again_input
        
     cmp cx,2
     je set_neg_flag_1
     
     mov neg_flag_2,1  
    
     jmp input
     set_neg_flag_1:
     
     mov neg_flag_1,1
     
     jmp input
     
     
     
     
     
    check_further: 
        
        ; checking if digit is in range 0-9
    cmp al,48
    jb again_input
    
    cmp al,57
    jg again_input
    
    
    
     jmp resume
    
    ; if user inputs wrong then
    ; print's backspace and again 
    ; ask's for input at same location on screen
    again_input:
    mov dl,8
    mov ah,2
    int 21h
    jmp input
    
     
    resume:
          
    mov ah,0
    sub al,48
    
    ; moves input to bx
    ; to free ax
    mov bx,ax
   
   ; compare if previous val is 10
   ; then no need to mul by 10 to raise place
    cmp sum,0
    je resume_1
    mov ax,sum
    mul mulBy10
    mov sum,ax 
resume_1:    
    
   ; after mul by 10 means
   ; if user inputs 123 previously 
   ; and now he enters 4 - so mul 123 by 10
   ; to make in 1230 then add 4 in it
   ; so then it becomes 1234  
   add sum,bx
    

    
     inc counter
     
     ; see if counter is 5 means 5 igits dare entered
     ;if not then keep asking for input
     cmp counter,5
     jne input
   
   resume_2:
     
     cmp cx,2
     je store_first_number
       
      jmp resume_3 
    store_first_number:
    
  
     mov bx,sum
     mov fsum,bx
     mov sum,0
    mov counter,0
   
    resume_3:
     
     ;loops for second number
     loop inp
     
     ; moves first complete number to bx
     mov bx,fsum 
      
        ; check if div the jmp to div
         cmp op,4
         je division
    
    
     
            ; here it checks for
            ;if user pressed - for
            ;number then take 2's complement
         

           cmp neg_flag_1,1
     jne check_further_2
     
     
     ; if first is neg then
     ; take 2's complement
     do_neg_1:
     neg bx
     
     
     check_further_2:
     
     cmp neg_flag_2,1
     jne resume_4
     
     
     ; if second is neg then
     ; take 2's complement
      neg sum
        
     
     ; check for which calc to perform
     resume_4:
     
     cmp op,1
     je addition
     
     cmp op,2
     je subtraction
     
     cmp op,3
     je multiplication
     
     jmp division
     
    
     addition:
     
     add bx,sum
     mov sum,bx
     jmp resume_5
     
     subtraction:
     sub bx,sum
     mov sum,bx
     jmp resume_5
     
     
     multiplication:
     mov ax,bx
     
     imul sum
     
     mov sum,ax
     
       
     
     jmp resume_5
     
     
     
     division:
     ; check if denom is zero - print error - goes back to start
     cmp sum,0
     jne resume_div 
       
      pm msg5
      jmp start
     ; else resume div
     resume_div:
     mov dx,0
     mov ax,bx
                
     mov bx,sum
     
     idiv bx
     
     mov sum,ax
     
     ; checking for div is 
     ; seperate fro other 3
     ; due to resons having difficult
     ; calculating mod and printing values
     ; with same code as other 3
     
     ; prints result msg
     pm msg4
    
    ; check for signs

         cmp neg_flag_1,1
     je neg_div_check
     
     
    cmp neg_flag_2,1
     je print_neg_div
     
         jmp calc_mod_for_div
       
       
     neg_div_check:
     
     cmp neg_flag_2,1
     jne print_neg_div
      
          jmp calc_mod_for_div
         
      print_neg_div:
      mov dl,'-'
      mov ah,2
      int 21h
     
    
     calc_mod_for_div:     
     resume_5:    
        
        cmp op,4
        je resume_6
        
        pm msg4
        
        ; here calc mod value by checking 
        ; result's range
      resume_6:  
      cmp sum,10
      jb make_mod_1
      
      cmp sum,100
      jb make_mod_10
      
      cmp sum,1000
      jb make_mod_100
      
      cmp sum,10000
      jb make_mod_1000
      
      cmp sum,10000
      jge make_mod_10000
      
      ; seperate for neg values
      cmp sum,-10
      jg make_mod_1_minus
      
      cmp sum,-100
      jg make_mod_10_minus
      
      cmp sum,-1000
      jg make_mod_100_minus
      
      cmp sum,-10000
      jg make_mod_1000_minus
      
       cmp sum,-10000
      jbe make_mod_10000_minus
      
      
      make_mod_1:
      mov mod,1
      mov counter,1
      jmp check_negative
      
      make_mod_10:
      mov mod,10
       mov counter,2
      jmp check_negative
      
      make_mod_100:
       mov mod,100
       mov counter,3
      jmp check_negative
      
      make_mod_1000:
       mov mod,1000
        mov counter,4 
      jmp check_negative
       
       make_mod_10000:
       mov mod,10000
        mov counter,5 
       cmp op,3
      jmp check_negative
       


      make_mod_1_minus:
      mov mod,1
      mov counter,1
      jmp  check_negative
      
      make_mod_10_minus:
      mov mod,10
       mov counter,2
      jmp  check_negative
     
      
      make_mod_100_minus:
       mov mod,100
       mov counter,3
      jmp  check_negative
     
      make_mod_1000_minus:
       mov mod,1000
        mov counter,4 
      
      make_mod_10000_minus:
       mov mod,10000
        mov counter,5 
      
      
        
        ; checks for neg
        ; if signs is to be print or not
 check_negative:
           
           ; if val is 32768 as 16 bit max int is 32767 if take neg
           ; then it becomes negative so checking then reversing
           ; and positive upto is 65,535
         
          cmp op,3
          jne check_2
          
         cmp op,2
         je minus_adjust
  
  cmp neg_flag_1,1
  je check_flag_2
  
  cmp neg_flag_2,1
  je  check_pos_mul
  
  jmp print
 
  check_flag_2:
   cmp neg_flag_2,1
   je print
   
   check_pos_mul:
   neg sum
   cmp sum,-1
   jbe print_neg
   
   
          
          
          check_2:
          cmp sum,32768
          jb check_further_neg 
  
          cmp neg_flag_1,1
          je do_neg_sum
          
          cmp neg_flag_2,1
          jne check_further_neg
          
          do_neg_sum:
          neg sum
          
          jmp print_neg
          
       
        check_further_neg:
        
        cmp op,1
        je print
           
        cmp op,4
        je print
        
 check_neg: 
 cmp sum,-1
 js minus_adjust
 jmp print
 minus_adjust:

 
 neg sum
  
 
 print_neg:
 mov dl,'-'
 mov ah,2
 int 21h       
       
    ; this prints finally result on screen
    ; it takes complete input
    ; e.g 1234 - the mod is calculated and for this case it would be initially at 1000
    ; divides it by mod it gives ax = 1 and dx = 234 - store dx back to sum
    ; takes ax - mov to dx - add 48 - finally print
    ; does this same until counter reaches 0 - as it dec's counter at each print
    print:
    
      mov ax,sum
      mov dx,0
      
      mov bx,mod
      div bx
      
      mov sum,dx
      
      mov dx,ax
      add dx,48
      mov ah,2
      int 21h
      
      mov dx,0
      mov ax,mod
      
      mov bx,10
      
      div bx
      
      mov mod,ax
      
     
       dec counter
       
       cmp counter,0
       jne print
       
       ; mov 0 at each register and var just to be safe
       retry:
       mov ax,0
       mov cx,0
       mov bx,0
       mov dx,0
       mov sum,0
       mov fsum,0
       mov counter,0
       mov neg_flag_1,0
       mov neg_flag_2,0
       jmp start
       
  
end:
         
mov ah,4ch
int 21h


endp main
end main