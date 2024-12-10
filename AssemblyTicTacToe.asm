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
    ; increment db 0

section .bss
    move resb 1 ; Buffer for player move input
    winCondition resb 1 ; Flag to set condition byte for if Player X or Player O has won

section .text
    global _start

_start:
    mov byte [winCondition], 0

gameLoop: ; This is the Main function of the code for each player turn and updates as it goes on.
    call printBoard
    mov eax, 4 ; eax is for storing function results like from validateMove and readInput.
    mov ebx, 1 ; ebx is for determining whether input or output.
    mov ecx, prompt ; ecx is pointer to current message.
    mov edx, 8 ; edx is for message length in prompt, inputMsg, invalidMsg, winMsg, winMsg2, tieMsg, and invalidMsg.
    int 0x80 ; This is system call specific to the NASM compiler I used, based on Linux.
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
    jz invalidInput ; The program jumps to this function if player's move is invalid (space taken or not 1-9).
    call updateBoard
    call checkWin
    cmp byte [winCondition], 1
    je gameEnd ; The program jumps to the end of the game if a player has won.
    call checkTie
    cmp eax, 2
    je tieDetected ; The program jumps to a specific end of the game if all spaces are filled but neither player has won.
    call switchPlayer
    jmp gameLoop ; Repeat the loop with the opposite player.

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
    jmp gameLoop ; This repeats the game loop with the same (not opposite) player if the player move is invalid (determined by validateMove).


gameEnd:
    call printBoard ; Print the final game board, with no numbers and only X or O.
    mov eax, 4
    mov ebx, 1
    mov ecx, winMsg
    mov edx, 8
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, currentPlayer ; Acknowledge which player has won, X or O.
    mov edx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, winMsg2 ; This is the part of winMsg used after currentPlayer is listd.
    mov edx, 7
    int 0x80
    jmp _exit ; Finally end the program after displaying winMsg and winMsg2.

tieDetected:
    call printBoard
    mov eax, 4
    mov ebx, 1
    mov ecx, tieMsg
    mov edx, 11
    int 0x80
    jmp _exit ; Finally end the program after displaying tieMsg.

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

printBoard:
    mov eax, 4
    mov ebx, 1
    mov ecx, board ; This points to the first row (123).
    mov edx, 3
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline ; This points to a newline character so the board displays as 3x3.
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    lea ecx, [board + 3] ; This points to the second row (456).
    mov edx, 3
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    lea ecx, [board + 6] ; This points to the third row (789).
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
    mov al, byte [move] ; This reads the byte from the move buffer.
    cmp al, 10
    je readInput
    sub al, '1' ; This converts 1-9 input to 0-8 indexes.
    movzx eax, al
    ret

validateMove:
    mov al, byte [move]
    sub al, '1'
    cmp al, 0
    jl invalid ; This jumps to invalid if the index is less than 0 (1 on the board).
    cmp al, 8
    jg invalid ; This jumps to invalid if the index is greater than 8 (9 on the board).
    movzx eax, al
    mov bl, byte [board + eax]
    cmp bl, 'X'
    je invalid ; This jumps to invalid in the index is already filled with 'X' when it needs to be empty.
    cmp bl, 'O'
    je invalid ; This jumps to invalid if the index is already filled with 'O' when it needs to be empty.
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
    mov byte [board + eax], dl ; This follows user input, finding the corresponding index for 1-9, then replacing it with the currentPlayer mark (X or O).
    ret

checkWin:
    mov ecx, 0 ; Initialize loop incrementer for each possible win condition.
checkWinLoop:
    call checkLine
    cmp eax, 1
    je winDetected
    inc ecx
    cmp ecx, 8 ; Compare the incrementer with all possible win conditions (3 horizontal, 3 vertical, 2 diagonal).
    je noWinner
    jmp checkWinLoop
winDetected:
    mov byte [winCondition], 1
    ret
noWinner:
    ret

checkLine:
    mov esi, board ; Point to the board, then check for every possible win condition within it (horizontal, vertical, or diagonal).
    cmp ecx, 0
    je checkRow
    cmp ecx, 1
    je checkRow
    cmp ecx, 2
    je checkRow
    cmp ecx, 3
    je checkCol
    cmp ecx, 4
    je checkCol
    cmp ecx, 5
    je checkCol
    cmp ecx, 6
    je checkDiag
    cmp ecx, 7
    je checkDiag

checkRow:
    mov edx, ecx
    imul edx, 3 ; Multiply ecx by 3 to reach respective row (row 2 = index 6, row 3 = index 9).

    mov al, byte [esi + edx] ; Check the first element of the row, then second and third with +1 and +2.
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + edx + 1]
    jne notMatch
    cmp al, byte [esi + edx + 2]
    jne notMatch
    mov eax, 1
    ret

checkCol:
    mov edx, ecx
    sub edx, 3
    imul edx, 1

    mov al, byte [esi + edx] ; Check the first element of the column, then second and third with +3 and +6.
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + edx + 3]
    jne notMatch
    cmp al, byte [esi + edx + 6]
    jne notMatch
    mov eax, 1
    ret

checkDiag:
    cmp ecx, 6
    je checkDiag1
    cmp ecx, 7
    je checkDiag2

checkDiag1:
    mov al, byte [esi] ; Check the first element of the diagonal, then second and third with +4 and +8, for index 5 and index 9.
    cmp al, byte [currentPlayer]
    jne notMatch
    cmp al, byte [esi + 4] 
    jne notMatch
    cmp al, byte [esi + 8]
    jne notMatch
    mov eax, 1
    ret

checkDiag2:
    mov al, byte [esi + 2] ; Check the first element of the diagonal, then second and third with +4 and +6, for index 5 and index 7.
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


checkTie: ; If all board spaces are filled w/o win condition for either player, then tie.
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
