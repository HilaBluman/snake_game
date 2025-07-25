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
	explantion1 db "It is simple! You control the direction of the snake's head with the$"
	explantion2 db "arrow keys (up, down, left, or right) and the snake's body follows.$"
	explantion3 db "The 'snake' can move any direction except, it cannot turn backwards $"
	explantion4 db "into itself. if you want to exit the game press ESC.$"
	msgToLevels db "Press ENTER to selcet level$"
	;General variables
   reet dw ?
	x dw 0
	y dw 0
	color db 9
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
	n dw 00 
	;apple
	numApple dw 00
	appleX dw 100, 40, 60, 260, 100, 50, 75, 214, 240, 175
	appleY dw 40, 80, 30, 20, 45, 130, 85, 90, 170, 90, 50  ;problam number 5, dont know
	addSnake dw 0
	placeApple dw 00
	score db 00
	divisorTable db 10,01,0
	;Game Over screen
	TitleE db "GAME OVER$"
	Again db "Press R to return to home screen$"
	End_Game db "and ENTER to end the game$"

CODESEG

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
	pop [reet]
	pop bx
	push [reet]
	mov cx,4
delete1:
	call PrintDot
	inc [byte ptr bx]
loop delete1
ret
endp delete


proc deleteUp
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset x
	call delete     
	dec [deleteY + si] ;deleteY + si

ret
endp deleteUp

proc deleteDown 
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset x
	call delete     
	inc [deleteY + si] ;deleteY + si

ret
endp deleteDown

proc deleteLeft
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset y
	call delete     
	dec [deleteX + si] ;deleteY + si

ret
endp deleteLeft

proc deleteRight
	push [deleteX + si]    ;change to delX + si
	push [deleteY + si]    ;change to delY + si
	pop [y]
	pop [x]
	push offset y
	call delete     
	inc [deleteX + si] ;deleteX + si

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
	mov cx ,10
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
	mov cx ,10
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
	mov [x], 309     ;max X = 319
	call PrintWall
	mov [y], 190    ;max y = 200
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
   mov cx, 4
widthS:
	call PrintDot
	inc [y]
loop widthS
;delay
	inc [currentX]
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
   mov cx, 4
widthS1:
	call PrintDot
	inc [y]
loop widthS1
;delay
	dec [currentX]
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
   mov cx, 4
widthS2:
	call PrintDot
	inc [x]
loop widthS2
;delay
	dec [currentY] 
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
   mov cx, 4
widthS3:
	call PrintDot
	inc [x]
loop widthS3
;delay
	inc [currentY]
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
nextDigit :
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

	cmp [turns + di -02], 'U'
	jne DL1				;DL is reserved word
	sub [currentX], 01  
	add [currentY], 01

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	add [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]
	add [deleteY + di], 03

	push [deleteY + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
	pop [delCounter + di -02]
	mov ax, [deleteY + di - 02]
	sub [delCounter + di -02], ax
	sub [deleteY + di], 03

	jmp change
DL1:
	sub [currentX], 01
	sub [currentY], 04

	push [currentX]
	pop [deleteX + di] 		;Calculate the position and save it to deleteX[click]
	add [deleteX + di], 04
	push [currentY]
	pop [deleteY + di]		;Calculate the position and save it to deleteY[click]

	push [deleteY + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
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

	push [deleteX + di]			;Calculate the number we need to delete before we change direction and save it to delcounter[click-01]
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
	
	add [delCounter + di -02], 03

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




start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
Home_Screen:
   mov ah,0h 										 ; clean screen
   mov al,03h
   int 10h

	mov ah,02h 										 ; place cursor
	mov dh,3 
	mov dl,35 
	mov bh,0
	int 10h
	mov ah,09 									  	 ; print string until $ is found.
	mov dx, offset TitleS
	int 21h

	mov ah,02h
	mov dh,6
	mov dl,19
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
	mov dh,22
	mov dl,28
	mov bh,0
	int 10h
	mov ah,09
	mov dx, offset msgToLevels
	int 21h

WaitEnter: 											; wait until you press the enter key.
	mov ah,00h
	int 16h
	cmp al, 0dh  									; 0dh = enter
jne WaitEnter
   

	;Graphic mode + clear screen
	mov ax, 13h
	int 10h


	mov [color], 9
	
	call Walls
   ;snake
   mov [color], 15   ;later add an option to change color
   mov [currentX], 155
   mov [currentY], 98
   mov [x], 155
   mov cx, 10
StartSnake:
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
   mov cx, 05h ; it is a delay of 1 sec
	mov dx, 9680h
	int 15h
	;print score
	xor ax,ax
   mov al,[score]
   call printNumber
   mov dl, 13
   mov ah, 02
   int 21h

	mov [turns + 00], 'R'
   mov [deleteY + 00], 98
   mov [deleteX + 00], 155

Moving:
	
	call Direction

Move:
   push [currentY]
	push [currentX]
	cmp [snakeDir], 'R'
	je MR
	cmp [snakeDir], 'U'
	je MU
	cmp [snakeDir], 'D'
	je MD
;ML
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

ate_apple:
;Check if the snake eats an apple, does this by chacking the color of the pixel
	mov bh, 0				;check one side of the front of the snake
	mov cx, [currentX]
	mov dx, [currentY]
	mov ah, 0dh
	int 10h
	cmp al, 12 
	je apple1
	cmp al, 10 
	je apple1

	mov bh, 0				;check the other side of the front of the snake
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

apple1:
	mov [numApple], 0		; the snake ate the apple
	mov [addSnake] , 08
	inc [score]
	;print score
	;xor ax,ax
   ;mov al,[score]
   ;call printNumber
   mov dl, 13
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
Random_Num:
   mov ah, 00h	; interrupts to get system time     
   int 1Ah   ; cx:dx now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 10    
   div  cx       ; here dx contains the remainder of the division - from 0 to 9
   xor dh,dh
   cmp [placeApple], dx
   je Random_Num
   mov [placeApple], dx
   xor ax,ax
   mov al,dl
   call printNumber

grow_snake:            ;does not work yet 
	cmp [addSnake],0
	je Deleting
	dec [addSnake]
	jmp self          ;skipps the deleting part so the snake will be longer


Deleting:
	mov si, [n]
	mov [color], 0
;incN
	cmp [delCounter + si], 0
	jne con
	add [n], 02
	add si, 02
con:
	cmp si, 0    ;check if this is the first dircetion
	jne turn
	call deleteRight
	jmp dec_or_not
turn:
	cmp [turns + si], 'R'
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
	cmp [delCounter + si], -1   ;Check if we need to count down a turn
	je self
	dec [delCounter + si]

self:				;Check if the snake hit it self, does this by chacking the color of the pixel
	mov bh, 0				
	mov cx, [currentX]
	mov dx, [currentY]
	mov ah, 0dh
	int 10h
	cmp al, 15
	je goTo_gameOver

	mov bh, 0				;check the other side of the front of the snake
	mov cx, [currentX]
	mov dx, [currentY]
	cmp [snakeDir], 'D'
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

check_needApple:
	cmp [numApple], 0
	je Apple
	jmp input

Apple:
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


input: ;need to check all the walls are good

	;Check if it hit a wall 
   cmp [currentX], 309 ; right wall
   je Game_over
   cmp [currentY], 190 ; down wall
   je Game_over
   cmp [currentX], 9 ; left wall
   je Game_over
   cmp [currentY], 9 ; up wall
   je Game_over
   ;Get the input from keybord
   in al, 64h
   cmp al, 10b
   in al, 60h


  jmp Moving

Game_over:
	mov ah,02h 										 ; place cursor
	mov dh,05 
	mov dl,15 
	mov bh,0
	int 10h
	mov ah,09 									  	 ; print string until $ is found.
	mov dx, offset TitleE
	int 21h

	mov ah,02h
	mov dh,15
	mov dl,04
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


Enter1: 
	mov ah,00h
	int 16h
	cmp al, 72h    ;space = 20h, r = 72h on my counputer
	je Restart
   cmp al, 0dh
jne Enter1
jmp yess

Restart:
	mov [snakeDir], 'R'
	mov [color], 9
	mov [click], 02
	mov [n], 00
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
	jmp start

yess:
	;Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
exit:
	mov ax, 4c00h
	int 21h
END start


