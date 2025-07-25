IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	;home screen
	TitleS db "Snake$"
	Instructions db "Instructions:$"
	explantion1 db "It is simple! You control the direction of the snakes head with the$"
	explantion2 db "arrow keys (up, down, left, or right) and the snakes body follows.$"
	explantion3 db "The snake can move in any direction except it cannot turn backwards.$"
	explantion4 db "The goal of the game is to eat as mach apples as you can without$"
	explantion5 db "hiting a wall or the snakes body.$"
	msgToStart db "Press ENTER to start$"
	;General variables
    reet dw ?
	x dw 0
	y dw 0
	color db 9
	speed db 02
	;Progression variables
	snakeDir db 'R'
	currentY dw ?
	currentX dw ?
	delayTime dw 00
	;These variables are only used to delete the back of the snake 
	deleteX dw 300 dup (-1)
	deleteY dw 300 dup (-1)
	turns dw 300 dup ('N')
	delCounter dw 300 dup (-1)
	click dw 02
	currentDelete dw 00 
	;apple
	numApple dw 00
	appleX dw 100, 40, 60, 260, 100, 50, 75, 214, 240, 175, 80, 240, 36, 90, 70, 150, 110, 40, 125, 70 ; there are 20 options
	appleY dw 40, 80, 30, 20, 45, 130, 85, 90, 170, 90, 50, 140, 60, 36, 120, 40, 100, 70, 80, 175, 70 ; there are 20 options
	addSnake dw 0
	placeApple dw 00
	score db 00
	divisorTable db 10,01,0
	yourScore db "Your score is:$"
	Clock equ es:6ch
	;Game Over screen
	TitleE db "GAME OVER$"
	Again db "Press R to restart the game $"
	End_Game db "and ENTER to end the game$"

CODESEG

proc Random_place
	mov ax, 40h
	mov es, ax 
	;generate random number
	mov ax, [clock] ;read timer counter
	mov ah, [byte cs:bx] ;read one byte from memory
	xor al,ah 
	and al, 00011111b ;leave result 0 - 31
	cmp al, 00010100b
	jl con_random
	sub al, 12
con_random:
	mov [byte ptr placeApple], al
	shl [placeApple], 01
ret
endp Random_place


proc Print_Apple

	push [appleX + bx]
	push [appleY +bx]
	pop [y]
	pop [x]
	call PrintDot
	inc [x]
	call PrintDot

	pop [reet]
	pop ax
	mov [color], al
	push [reet]
	push bx
	push cx

	sub [x], 02
	mov ax, 03
nextRow:
	inc [y]
	dec ax
	mov cx, 4
AppleRow:
	call PrintDot
	inc [x]
loop AppleRow
	push [appleX + bx]
	pop [x]
	dec [x]
	cmp ax, 0
jne nextRow
	pop cx
	pop bx

ret
endp Print_Apple

proc delete
	push bp
	mov bp, sp
	mov bx, [bp + 04]
	mov cx,4
delete1:
	call PrintDot
	inc [byte ptr bx]
loop delete1
	mov sp,bp
	pop bp
ret 02
endp delete


proc deleteUp
push dx 
	xor dx,dx
	mov dl, [speed]
fast_delUp:
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset x
	call delete     
	dec [deleteY + si] ;deleteY + si
	dec dx
	cmp dx, 0
	jne fast_delUp
pop dx
ret
endp deleteUp

proc deleteDown
push dx 
	xor dx,dx
	mov dl, [speed]
fast_delDown:
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset x
	call delete     
	inc [deleteY + si] ;deleteY + si
	dec dx
	cmp dx, 0
	jne fast_delDown
pop dx
ret
endp deleteDown

proc deleteLeft
push dx 
	xor dx,dx
	mov dl, [speed]
fast_delLeft:
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset y
	call delete     
	dec [deleteX + si] ;deleteY + si
	dec dx
	cmp dx, 0
	jne fast_delLeft
pop dx
ret
endp deleteLeft

proc deleteRight
push dx 
	xor dx,dx
	mov dl, [speed]
fast_delRight:
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset y
	call delete     
	inc [deleteX + si] ;deleteX + si
	dec dx
	cmp dx, 0
	jne fast_delRight
pop dx
ret
endp deleteRight

proc PrintDot
   push ax
	push cx
	push dx
	push bx
   mov bh,0h
	mov cx,[x]
	mov dx,[y]
	mov al,[color]
	mov ah,0ch
	int 10h
	pop bx 
	pop dx
	pop cx
	pop ax
ret
endp PrintDot

proc PrintWall
	push cx
	mov cx ,20
Wall:
   push cx
   mov [y], 0
	mov cx ,200
col:
	call PrintDot
	inc [y]
loop col
   inc [x]
	pop cx
loop wall
   pop cx
ret
endp PrintWall

proc PrintCol
	push cx
	mov cx ,20
Wall2:
   push cx
   mov [x], 0
	mov cx ,314
row:
	call PrintDot
	inc [x]
loop row
   inc [y]
	pop cx
loop wall2
   pop cx
ret
endp PrintCol

proc Walls
	mov [x], 0
   call PrintWall
	mov [y],0
	call PrintCol
	mov [x], 300     ;max X = 320
	call PrintWall
	mov [y], 180    ;max y = 200
	call PrintCol
ret
endp Walls

proc moveR
   pop [reet]
   pop [x]
   pop [y]
   push [reet]
   push cx
   mov [color], 15
   mov bl, [speed]
again_right:
   mov cx, 4
widthS:
	call PrintDot
	inc [y]
loop widthS	
	push [currentY]
	pop [y]
	inc [x]
	dec bl
	cmp bl, 0
jne again_right
;delay
   xor bx,bx
   mov bl, [speed]
   add [currentX], bx
   mov ah, 86h
   mov cx, [delayTime] ; it is a delay
	mov dx, 9680h
	int 15h
	pop cx
ret
endp moveR

proc moveL
   pop [reet]
   pop [x]
   pop [y]
   push [reet]
   push cx
   mov [color], 15
   mov bl, [speed]
again_Left:
   mov cx, 4
widthS1:
	call PrintDot
	inc [y]
loop widthS1
    push [currentY]
	pop [y]
	dec [x]
	dec bl
	cmp bl, 0
jne again_Left
;delay
	xor bx,bx
	mov bl, [speed]
	sub [currentX], bx
   mov ah, 86h
   mov cx, [delayTime] ; it is a delay 
	mov dx, 9680h
	int 15h
	pop cx
ret
endp moveL

proc moveU
   pop [reet]
   pop [x]
   pop [y]
   push [reet]
   push cx
   mov [color], 15
   mov bl, [speed]
again_Up:
mov cx, 4
widthS2:
	call PrintDot
	inc [x]
loop widthS2
	push [currentX]
	pop [x]
	dec [y]
	dec bl
	cmp bl, 0
jne again_Up
;delay
	xor bx,bx
	mov bl, [speed]
	sub [currentY], bx 
   mov ah, 86h
   mov cx, [delayTime] ; it is a delay 
	mov dx, 9680h
	int 15h
	pop cx
ret
endp moveU

proc moveD
   pop [reet]
   pop [x]
   pop [y]
   push [reet]
   push cx
   mov [color], 15
   mov bl, [speed]
again_Down:
	mov cx, 4
widthS3:
	call PrintDot
	inc [x]
loop widthS3
	push [currentX]
	pop [x]
	inc [y]
	dec bl
	cmp bl, 0
jne again_Down
;delay
	xor bx,bx
	mov bl, [speed]
	add [currentY], bx
   mov ah, 86h
   mov cx, [delayTime] ; it is a delay
	mov dx, 9680h
	int 15h
	pop cx
ret
endp moveD

proc printNumber
    push ax
    push bx
    push dx
    mov bx,offset divisorTable
nextDigit:
    xor ah,ah
    div [byte ptr bx] 
    add al,'0'
    call printCharacter 
    mov al,ah 
    add bx,1 
    cmp [byte ptr bx],0 
    jne nextDigit
    pop dx
    pop bx
    pop ax
ret
endp printNumber
 
proc printCharacter
   push ax
   push dx
   mov ah,2
   mov dl, al
   int 21h
   pop dx
   pop ax
ret
endp printCharacter


proc Direction
   push ax
   push bx
   mov di, [click] ; click represent the place in the array where the value we get from the keys will be restored.
	cmp [turns + di -02], 'U' 
	je RL
	cmp [turns + di - 02], 'D'
	je RL
	jmp UD
RL:
   ;Check if arrow keys left or right were pressed
   cmp al, 0CDh      ;Arrow right
   je move_right
   cmp al, 0CBh		;Arrow left
   jne long_jmp
   jmp move_left

long_jmp:
	jmp outp

move_right:
	mov [turns + di], 'R'
	mov [snakeDir], 'R'

	cmp [turns + di -02], 'D'
	je DR
	add [currentY], 01   
	add [currentX], 04

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	sub [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]

	push [deleteY + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteY + di - 02]
	sub [delCounter + di -02], ax
	add [delCounter + di -02], 03

	jmp change
DR:
	add [currentX], 04
	sub [currentY], 04 

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	sub [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]

	push [deleteY + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteY + di - 02]
	sub [delCounter + di -02], ax

	jmp change

move_left:
	mov [turns + di], 'L'
	mov [snakeDir], 'L'

	cmp [turns + di -02], 'U'  ;Check which direction the snake is currently moving
	jne DL1					
	sub [currentX], 01  			;;Calculate the new position of currentX & currentY
	add [currentY], 01

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	add [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]
	add [deleteY + di], 03

	;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	push [deleteY + di]			
	pop [delCounter + di -02]
	mov ax, [deleteY + di - 02]
	sub [delCounter + di -02], ax
	sub [deleteY + di], 03

	jmp change
DL1:
	sub [currentX], 01 			;Calculate the new position of currentX & currentY
	sub [currentY], 04

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	add [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]

	;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	push [deleteY + di]			
	pop [delCounter + di -02]
	mov ax, [deleteY + di - 02]
	sub [delCounter + di -02], ax

	jmp change

UD:
   ;Check if arrow keys up or down were pressed
   cmp al, 0C8h      ;Arrow up
   je move_up
   cmp al, 0D0h      ;Arrow Down
   je down
   jmp outp

down:
	jmp move_down

move_Up:
	mov [turns + di], 'U'
	mov [snakeDir], 'U'

	cmp [turns + di -02], 'R'
	jne LU
	sub [currentX], 04
	sub [currentY], 01

	push [currentX]
	pop [deleteX + di]		;Calculate the position and save it to deleteX[click]
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]
	add [deleteY + di], 04 

	cmp [turns + di -02], 'U'	     
	jne UpUp_fix
	sub [deleteY + di-02], 03

UpUp_fix:
	push [deleteX + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteX + di - 02]
	sub [delCounter + di -02], ax

	jmp change
LU:
	add [currentX], 01
	sub [currentY], 01

	push [currentX]
	pop [deleteX + di]		;Calculate the position and save it to deleteX[click]
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]
	add [deleteY + di], 04

	push [deleteX + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteX + di - 02]
	sub [delCounter + di -02], ax
	add [delCounter + di -02], 03

	jmp change

move_down:
	mov [turns + di], 'D'
	mov [snakeDir], 'D'

   cmp [turns + di -02], 'R'
	jne LD1            ;LD is a reserved word
	sub [currentX], 04
	add [currentY], 04

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]  
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]

	;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	push [deleteX + di]	
	pop [delCounter + di -02]
	mov ax, [deleteX + di - 02]
	sub [delCounter + di -02], ax
	sub [deleteY + di], 04  

	jmp change
LD1:
	add [currentY], 04
	add [currentX], 01

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]  
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]
	sub [deleteY + di], 04

	push [deleteX + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteX + di - 02]
	sub [delCounter + di -02], ax
	
	add [delCounter + di -02], 03 ;change 03

   jmp change
	
change:
	cmp [delCounter + di -02], 0
	jge add_click
	neg [delCounter + di -02]
add_click:
	add [click], 02
outp:
	pop bx
	pop ax
ret	
endp Direction

proc Move
    push [currentY]
	push [currentX]
	cmp [snakeDir], 'R' ;Checking which way does the snake need to progress to
	je MR
	cmp [snakeDir], 'U'
	je MU
	cmp [snakeDir], 'D'
	je MD
;ML 						;Calling the right procedure according to cmp above
	call moveL
	jmp ate_apple
MD:
	call moveD
	jmp ate_apple
MU:
	call moveU
	jmp ate_apple
MR:
	call moveR

ret
endp Move

proc Deleting
	push cx
	mov si, [currentDelete]       ;move to si the place in the arrays to delete by
	mov [color], 00
;incN
	cmp [delCounter + si], 0 		;Checks if we need to move on to delete the next dircetion 
	jne con
	add [currentDelete], 02
	add si, 02
con:
	cmp si, 0    ;check if this is the first dircetion
	jne turn
	call deleteRight
	jmp dec_or_not
	xor cx,cx
	mov cl, [speed]
turn:
	cmp [turns + si], 'R'         ;Checks in which dircetion we need to delete 
	je BR
	cmp [turns + si], 'U'
	je BU
	cmp [turns + si], 'D'
	je BD
 
;BL
	call deleteLeft
	jmp dec_or_not
BD:
	call deleteDown
	jmp dec_or_not
BU:
	call deleteUp
	jmp dec_or_not
BR:
	call deleteRight


dec_or_not:
	cmp [delCounter + si], -1   ;Check if we need decrease the counter for the current turn
	je out_of_Deleting
	sub [delCounter + si], 02
out_of_Deleting:
	pop cx
ret
endp Deleting

start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
Home_Screen:

   mov ah,0h 										 ;Clean screen and set video mode
   mov al,03h
   int 10h

	mov ah,02h 										 ;Prints title and explantions
	mov dh,3 
	mov dl,35 
	mov bh,0
	int 10h
	mov ah,09 				 
	mov dx, offset TitleS
	int 21h

	mov ah,02h 																				
	mov dh,6
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset Instructions
	int 21h

	mov ah,02h
	mov dh,8
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset explantion1
	int 21h

	mov ah,02h
	mov dh,9
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset explantion2
	int 21h

	mov ah,02h
	mov dh,10
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset explantion3
	int 21h

	mov ah,02h
	mov dh,11
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset explantion4
	int 21h

	mov ah,02h
	mov dh,12
	mov dl,8
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset explantion5
	int 21h

	mov ah,02h
	mov dh,22
	mov dl,30
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset msgToStart
	int 21h

WaitEnter: 											; wait until you press the enter key to continue.
	mov ah,00h
	int 16h
	cmp al, 0dh  									; 0dh = enter
jne WaitEnter
   

	;Graphic mode + clear screen
	mov ax, 13h
	int 10h

	mov [color], 3
	
	call Walls
   ;snake
   mov [color], 15  
   mov [currentX], 154
   mov [currentY], 98
   mov [x], 154
   mov cx, 16
StartSnake:											;Print the snake before the game loop starts
	push [currentY]
	push [currentX]
	pop [x]
   pop [y]
   push cx
   mov cx, 4
widthStart:
	call PrintDot
	inc [y]
loop widthStart
	inc [currentX]
	pop cx
loop StartSnake
	
   ;delay
   mov ah, 86h
   mov cx, 05h 
	mov dx, 9680h
	int 15h

	;print inital score
	mov ah,02h
	mov dh,0
	mov dl, 0
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset yourScore
	int 21h
	mov dl, 10
	mov ah, 02h
	int 21h
   mov al, 00
   call printNumber
   mov dl, 13
   mov ah, 02
   int 21h

	mov [turns + 00], 'R'     					;Initial data before the snake starts moving
   mov [deleteY + 00], 98
   mov [deleteX + 00], 154


;Main game loop
Moving:
	
	call Direction

	call Move

ate_apple:				;Check if the snake eats an apple, does this by chacking the color of the pixel

	mov bh, 0			 ;Checking if one side of the front of the snake ate an apple
	mov cx, [currentX]
	mov dx, [currentY]
	mov ah, 0dh
	int 10h
	cmp al, 12 
	je apple1
	cmp al, 10 
	je apple1

	mov bh, 0				;Checking if other side of the front of the snake ate an apple
	mov cx, [currentX]
	mov dx, [currentY]
	cmp [snakeDir], 'D'
	je apple_UD
	cmp [snakeDir], 'U'
	je apple_UD
	add dx, 03
	jmp apple_RL
apple_UD:
	add cx, 03
apple_RL:
	mov ah, 0dh
	int 10h
	cmp al, 12 
	je apple1
	cmp al, 10 
	je apple1
	jmp grow_snake

apple1:						;Changes after thesnake ate the apple
	mov [numApple], 0		
	mov [addSnake] , 05
	add [score], 01

	mov dl, 13 				;Deleting the apple that was eaten
   mov ah, 02
   int 21h
	;delete apple
	push bx
   push ax
   mov bx, [placeApple]
	mov [color], 0
	push 0
	call Print_Apple
	pop bx
	pop ax
	call Random_place
	
	;print yourScore		  ;Prirting the updated score
	xor ax,ax
   mov ax,[word ptr score]
   call printNumber


grow_snake:               ;Checking if the snake need to grow
	cmp [addSnake],0
	je Not_grow
	dec [addSnake]
	jmp self          ;skipps the deleting part so the snake will be longer

Not_grow:
	call Deleting

self:								;Check if the snake hit itself, does this by chacking the color of the pixel
	mov bh, 0				
	mov cx, [currentX]		;Checking if one side of the front of the snake hit itself
	mov dx, [currentY]
	mov ah, 0dh
	int 10h
	cmp al, 15
	je goTo_gameOver

	mov bh, 0					;Checking if other side of the front of the snake hit itself
	mov cx, [currentX]
	mov dx, [currentY]
	cmp [snakeDir], 'D'		;Checking which dircetion the snake is going so it can calculate the other sode of the front of the snake
	je otherSide_UD
	cmp [snakeDir], 'U'
	je otherSide_UD
	add dx, 03
	jmp otherSide_RL
otherSide_UD:
	add cx, 03
otherSide_RL:
	mov ah, 0dh
	int 10h
	cmp al, 15 
	jne check_needApple
goTo_gameOver:
	jmp Game_over

check_needApple:				;Check if it need to print a new apple(the program only prints one apple at a time)
	cmp [numApple], 0
	je Apple
	jmp input

Apple:							;Print an apple if needed
	inc [numApple]
	;print apple
	push bx
	push ax
	mov bx, [placeApple]
	mov [color], 10
	push 12
	call Print_Apple
	pop ax
	pop bx


input: 

   ;Check if it hit a wall 
   cmp [currentX], 300 ; right wall
   je Game_over
   cmp [currentY], 180 ; down wall
   je Game_over
   cmp [currentX], 19 ; left wall
   je Game_over
   cmp [currentY], 19 ; up wall
   je Game_over

   ;Get the input from keybord
   in al, 64h
   cmp al, 10b
   in al, 60h


  jmp Moving						;jmp to the start of the game loop

Game_over: 							;Prints on the screen game over and give instructions going forward
	mov ah,02h 										
	mov dh,10 
	mov dl,15 
	mov bh,0
	int 10h
	mov ah,09 									  	 
	mov dx, offset TitleE
	int 21h

	mov ah,02h
	mov dh,15
	mov dl,08
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset Again
	int 21h

	mov ah,02h
	mov dh,17
	mov dl,08
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset End_Game
	int 21h


Enter1: 									;waits for input and checks if it need to restart the game or exit the program
	mov ah,00h
	int 16h
	cmp al, 72h    ;r = 72h
	je Restart
   cmp al, 0dh
jne Enter1
jmp yess

Restart:									;Reset all the necessay variables to restart the game
	mov [snakeDir], 'R'
	mov [color], 15
	mov [click], 02
	mov [currentDelete], 00
	mov si, 0
	mov cx, 300
restart_delete:
	mov [deleteX + si], -1
	mov [deleteY + si], -1
	mov [delCounter + si], -1
	mov [turns + si], 'N'
	add si, 02
loop restart_delete
	mov [numApple], 0
	mov [score], 00
	jmp start 							;jamps to the start of the code

yess:
	;Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
exit:
	mov ax, 4c00h
	int 21h
END start


