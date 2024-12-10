# assembly-tic-tac-toe
For CS F301 at the University of Alaska Fairbanks. Due December 13, 2024. By Ian Rodriguez.
This program is a recreation of a game of Tic-Tac-Toe, written in Assembly Language. The game alternates between turns for two players, Player X and Player O, on a 3x3 in-game board, numbered 1-9 to represent a grid. The goal for each player is to successfully mark three spaces in a row, horizontally, vertically, or diagonally, so that they win the game and the other player loses. Almost the entire program is based on a single gameLoop function that calls numerous other functions to handle user input, update the game board for every valid input, check to see if a player has won or if the game has tied, and decides whether or not to loop again based on these conditions.

gameLoop works as follows:
1. The loop continues unless a win is detected (match 3 in a row, column, or diagonal) or if all spaces are filled without a win condition (this means a tie).
2. The game board is printed, numbered 1-9, in a 3x3 format. Any player marks ('X' or 'O') replace the given number with each update.
3. The player is prompted to enter a number 1-9. If they don't enter a number 1-9, or that space is already marked on the board, invalidInput is called, outputting that their input is invalid and that the turn repeats with the same player. If the player input is valid, then updateBoard is called to replace that number with the mark of currentPlayer, 'X' or 'O'.
4. The program calls checkWin and checkTie. If the conditions of these functions are met, the game ends with a message stating who (currentPlayer) won or that the game tied. If neither condition is met, switchPlayer is called, switching from Player X to Player O or vice-versa, and gameLoop continues.

The program should be run on an NASM Assembly compiler; I used this: https://www.jdoodle.com/compile-assembler-nasm-online
