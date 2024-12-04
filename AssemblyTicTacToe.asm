section .data ; May not work on NetRun, worked on different NASM compilers
    board db '123456789', 0
    currentPlayer db 'X'
    prompt db 'Player ', 0
    inputMsg db ', enter your move (1-9): ', 0
    invalidMsg db 'Invalid move. Try again. ', 10, 0
    winMsg db 'Player ', 0
    winMsg2 db ' wins!', 10, 0
    tieMsg db 'It is a tie!', 10, 0
    newline db 10, 0

section .bss
    move resb 1
    winCondition resb 1

section .text
    global _start

_start:
    mov byte [winCondition], 0

gameLoop:
    call printBoard
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 8
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, currentPlayer
    mov edx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, inputMsg
    mov edx, 25
    int 0x80

    call readInput
    call validateMove
    test eax, eax
    jz invalidInput
    call updateBoard
    call checkWin
    cmp byte [winCondition], 1
    je gameEnd
    call checkTie
    cmp eax, 2
    je tieDetected
    call switchPlayer
    jmp gameLoop

invalidInput:
    mov eax, 4
    mov ebx, 1
    mov ecx, invalidMsg
    mov edx, 25
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp gameLoop


gameEnd:
    call printBoard
    mov eax, 4
    mov ebx, 1
    mov ecx, winMsg
    mov edx, 8
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, currentPlayer
    mov edx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, winMsg2
    mov edx, 7
    int 0x80
    jmp _exit

tieDetected:
    call printBoard
    mov eax, 4
    mov ebx, 1
    mov ecx, tieMsg
    mov edx, 11
    int 0x80
    jmp _exit

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

printBoard:
    mov eax, 4
    mov ebx, 1
    mov ecx, board
    mov edx, 3
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    lea ecx, [board + 3]
    mov edx, 3
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    lea ecx, [board + 6]
    mov edx, 3
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

readInput:
    mov eax, 3
    mov ebx, 0
    mov ecx, move
    mov edx, 2
    int 0x80
    mov al, byte [move]
    cmp al, 10
    je readInput
    sub al, '1'
    movzx eax, al
    ret

validateMove:
    mov al, byte [move]
    sub al, '1'
    cmp al, 0
    jl invalid
    cmp al, 8
    jg invalid
    movzx eax, al
    mov bl, byte [board + eax]
    cmp bl, 'X'
    je invalid
    cmp bl, 'O'
    je invalid
    mov eax, 1
    ret

invalid:
    xor eax, eax
    ret

updateBoard:
    mov al, byte [move]
    sub al, '1'
    movzx eax, al
    mov dl, byte [currentPlayer]
    mov byte [board + eax], dl
    ret

checkWin:
    mov ecx, 0
checkWinLoop:
    call checkLine
    cmp eax, 1
    je winDetected
    inc ecx
    cmp ecx, 8
    je noWinner
    jmp checkWinLoop
winDetected:
    mov byte [winCondition], 1
    ret
noWinner:
    ret

checkLine: ; There's probably a more efficient way to do this w/o repeat code
    mov esi, board
    cmp ecx, 0
    je checkRow1
    cmp ecx, 1
    je checkRow2
    cmp ecx, 2
    je checkRow3
    cmp ecx, 3
    je checkCol1
    cmp ecx, 4
    je checkCol2
    cmp ecx, 5
    je checkCol3
    cmp ecx, 6
    je checkDiag1
    cmp ecx, 7
    je checkDiag2

checkRow1:
    mov al, byte [esi]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 1]
    jne notMatch
    cmp al, byte [esi + 2]
    jne notMatch
    mov eax, 1
    ret
checkRow2:
    mov al, byte [esi + 3]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 4]
    jne notMatch
    cmp al, byte [esi + 5]
    jne notMatch
    mov eax, 1
    ret
checkRow3:
    mov al, byte [esi + 6]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 7]
    jne notMatch
    cmp al, byte [esi + 8]
    jne notMatch
    mov eax, 1
    ret
checkCol1:
    mov al, byte [esi]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 3]
    jne notMatch
    cmp al, byte [esi + 6]
    jne notMatch
    mov eax, 1
    ret
checkCol2:
    mov al, byte [esi + 1]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 4]
    jne notMatch
    cmp al, byte [esi + 7]
    jne notMatch
    mov eax, 1
    ret
checkCol3:
    mov al, byte [esi + 2]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 5]
    jne notMatch
    cmp al, byte [esi + 8]
    jne notMatch
    mov eax, 1
    ret
checkDiag1:
    mov al, byte [esi]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 4]
    jne notMatch
    cmp al, byte [esi + 8]
    jne notMatch
    mov eax, 1
    ret
checkDiag2:
    mov al, byte [esi + 2]
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 4]
    jne notMatch
    cmp al, byte [esi + 6]
    jne notMatch
    mov eax, 1
    ret
notMatch:
    xor eax, eax
    ret

checkTie: ; If all board spaces are filled w/o win condition for either player, then tie
    mov ecx, 0
checkTieLoop:
    cmp byte [board + ecx], 'X'
    je checkNext
    cmp byte [board + ecx], 'O'
    je checkNext
    xor eax, eax
    ret

checkNext:
    inc ecx
    cmp ecx, 9
    jne checkTieLoop
    mov eax, 2
    ret

switchPlayer:
    mov al, byte [currentPlayer]
    cmp al, 'X'
    jne switchToX
    mov byte [currentPlayer], 'O'
    ret
switchToX:
    mov byte [currentPlayer], 'X'
    ret
