; ============================================================================
; FILE: Logic.asm
; PURPOSE: All game procedures (functions) in x86 Assembly
;
; WHAT IS THIS FILE?
; Contains all the game logic: checking guesses, calculating scores,
; determining win/loss conditions. This is the "brain" of the game.
;
; WHAT ARE PROCEDURES?
; Procedures are like functions in C++. They do one specific task.
; Each procedure receives input (in registers), does work, returns output.
; ============================================================================

; Include Irvine32 library header file
; This gives us access to basic Assembly functions
.INCLUDE Irvine32.inc

; Declare that we're using 32-bit code
.386
.MODEL flat, stdcall
.STACK 4096

; Import the data from Data.asm
; EXTERN means "this variable is defined in another file"
EXTERN secretWord:BYTE          ; The word to guess
EXTERN wordLength:DWORD         ; How many letters in the word
EXTERN selectedCategory:BYTE    ; Category chosen by Player 1
EXTERN letterMask:BYTE          ; Which letters are revealed
EXTERN wrongCount:DWORD         ; Current wrong guesses
EXTERN maxWrong:DWORD           ; Maximum wrong guesses allowed
EXTERN guessedLetters:BYTE      ; Which letters A-Z have been tried
EXTERN score:DWORD              ; Points earned
EXTERN gameState:BYTE           ; Current game state (0-4)
EXTERN hintUsed:BYTE            ; Has hint been used?
EXTERN currentDifficulty:BYTE   ; Difficulty level (1-3)
EXTERN timeLimit:DWORD          ; Time allowed (seconds)
EXTERN timeElapsed:DWORD        ; Time so far (seconds)
EXTERN totalScore:DWORD         ; Total points this session
EXTERN isDailyChallenge:BYTE    ; Daily challenge mode?
EXTERN dailyChallengeWord:BYTE  ; Daily challenge word
EXTERN dailyChallengeCategory:BYTE ; Daily challenge category

.CODE

; ============================================================================
; PROCEDURE 1: SetSecretWord
;
; PURPOSE: Initialize game with Player 1's word and difficulty
;
; INPUT (parameters):
;   ESI = pointer to the word text (memory address of first character)
;   ECX = length of the word (number of characters)
;
; OUTPUT:
;   Variables in memory are updated
;
; EXPLANATION:
; This procedure is called when Player 1 clicks CONFIRM.
; It copies the word into Assembly memory, calculates difficulty, and resets game state.
;
; ============================================================================

PUBLIC SetSecretWord

SetSecretWord PROC
    ; Save registers we'll modify (for safety)
    push eax
    push ebx
    push edi
    
    ; Store the word length
    ; wordLength = ECX (the parameter we received)
    mov eax, ecx                ; Move ECX to EAX
    mov wordLength, eax         ; Store in wordLength variable
    
    ; Copy the word byte by byte from ESI to secretWord
    ; We use ESI as source pointer, EDI as destination pointer
    lea edi, secretWord         ; Load address of secretWord array
    
    ; Loop from 0 to wordLength-1
    xor eax, eax                ; EAX = 0 (loop counter)
    
CopyWordLoop:
    cmp eax, ecx                ; Compare counter with word length
    jge CopyWordDone            ; If counter >= length, jump to done
    
    ; Copy one byte from source to destination
    mov bl, [esi + eax]         ; BL = byte at [ESI + counter]
    mov [edi + eax], bl         ; [EDI + counter] = BL
    
    ; Increment counter
    add eax, 1                  ; EAX++
    
    ; Continue loop
    jmp CopyWordLoop
    
CopyWordDone:
    ; Add null terminator (0) at end of word
    mov byte ptr [edi + ecx], 0 ; [secretWord + length] = 0
    
    ; ====================================================================
    ; DETERMINE DIFFICULTY BASED ON WORD LENGTH
    ; ====================================================================
    
    ; Check word length and set currentDifficulty and maxWrong
    
    cmp ecx, 7                  ; Compare length with 7
    jle SetDifficultyEasy       ; If length <= 7, it's Easy
    
    cmp ecx, 11                 ; Compare length with 11
    jle SetDifficultyMedium     ; If length <= 11, it's Medium
    
    ; Otherwise it's Hard
SetDifficultyHard:
    mov currentDifficulty, 3    ; Set difficulty to 3 (Hard)
    mov maxWrong, 4             ; Hard gets 4 wrong guesses
    mov timeLimit, 30           ; Hard gets 30 seconds
    jmp SetDifficultyDone
    
SetDifficultyMedium:
    mov currentDifficulty, 2    ; Set difficulty to 2 (Medium)
    mov maxWrong, 6             ; Medium gets 6 wrong guesses
    mov timeLimit, 45           ; Medium gets 45 seconds
    jmp SetDifficultyDone
    
SetDifficultyEasy:
    mov currentDifficulty, 1    ; Set difficulty to 1 (Easy)
    mov maxWrong, 8             ; Easy gets 8 wrong guesses
    mov timeLimit, 60           ; Easy gets 60 seconds
    
SetDifficultyDone:
    ; ====================================================================
    ; INITIALIZE GAME STATE VARIABLES
    ; ====================================================================
    
    ; Initialize letterMask (all positions to 0 = not revealed)
    lea edi, letterMask         ; Load address of letterMask
    xor eax, eax                ; EAX = 0 (loop counter)
    
    mov ecx, wordLength         ; ECX = wordLength (for loop count)
    
InitLetterMaskLoop:
    cmp eax, ecx                ; Compare counter with word length
    jge InitLetterMaskDone      ; If counter >= length, done
    
    mov byte ptr [edi + eax], 0 ; Set letterMask[counter] = 0
    add eax, 1                  ; EAX++
    jmp InitLetterMaskLoop
    
InitLetterMaskDone:
    ; Initialize guessedLetters (all 26 letters to 0 = not guessed)
    lea edi, guessedLetters     ; Load address of guessedLetters
    xor eax, eax                ; EAX = 0 (loop counter)
    
    mov ecx, 26                 ; Loop 26 times (for all letters A-Z)
    
InitGuessedLettersLoop:
    cmp eax, ecx                ; Compare counter with 26
    jge InitGuessedLettersDone  ; If counter >= 26, done
    
    mov byte ptr [edi + eax], 0 ; Set guessedLetters[counter] = 0
    add eax, 1                  ; EAX++
    jmp InitGuessedLettersLoop
    
InitGuessedLettersDone:
    ; Reset other game variables
    mov wrongCount, 0           ; No wrong guesses yet
    mov score, 0                ; No points yet
    mov hintUsed, 0             ; Hint not used yet
    mov timeElapsed, 0          ; Timer starts at 0
    mov gameState, 1            ; State 1 = Player 2 guessing
    
    ; Restore registers we saved
    pop edi
    pop ebx
    pop eax
    
    ret                         ; Return to caller
    
SetSecretWord ENDP

; ============================================================================
; PROCEDURE 2: GuessLetter
;
; PURPOSE: Process one letter guess from Player 2
;
; INPUT (parameter):
;   CL = ASCII code of guessed letter (A-Z, a-z, doesn't matter - we convert)
;
; OUTPUT:
;   Updates: letterMask, guessedLetters, wrongCount, score, gameState
;
; LOGIC:
; 1. Check if it's a valid guess (not already tried)
; 2. Mark this letter as guessed
; 3. Search for this letter in the secret word
; 4. If found: reveal positions, add points
; 5. If not found: increment wrong count
; 6. Check if game won or lost
;
; ============================================================================

PUBLIC GuessLetter

GuessLetter PROC
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; ====================================================================
    ; STEP 1: VALIDATE GAME STATE
    ; ====================================================================
    
    ; Check if gameState is 1 (guessing phase)
    movzx eax, gameState        ; AL = gameState
    cmp al, 1                   ; Is it 1?
    jne GuessLetterReturn       ; If not, return immediately (invalid state)
    
    ; ====================================================================
    ; STEP 2: CONVERT TO UPPERCASE
    ; ====================================================================
    
    ; If letter is lowercase (97-122), subtract 32 to make uppercase
    cmp cl, 97                  ; Is CL >= 97 (lowercase 'a')?
    jl AlreadyUppercase         ; If not, already uppercase
    
    cmp cl, 122                 ; Is CL <= 122 (lowercase 'z')?
    jg AlreadyUppercase         ; If not, already uppercase
    
    ; Convert lowercase to uppercase
    sub cl, 32                  ; CL -= 32
    
AlreadyUppercase:
    ; Now CL contains uppercase letter (A-Z)
    
    ; ====================================================================
    ; STEP 3: CALCULATE ALPHABET INDEX
    ; ====================================================================
    
    ; Index = ASCII - 65
    ; A = 65, so A-65 = 0
    ; B = 66, so B-65 = 1
    ; Z = 90, so Z-65 = 25
    
    mov al, cl                  ; AL = the letter
    sub al, 65                  ; AL -= 65 (now 0-25)
    
    movzx eax, al               ; Extend AL to EAX (0-25)
    mov ebx, eax                ; EBX = alphabet index (0-25)
    
    ; ====================================================================
    ; STEP 4: CHECK IF ALREADY GUESSED
    ; ====================================================================
    
    ; Load address of guessedLetters
    lea esi, guessedLetters     ; ESI = address of guessedLetters
    
    ; Check if guessedLetters[index] is already 1
    movzx ecx, byte ptr [esi + ebx] ; ECX = guessedLetters[EBX]
    cmp ecx, 1                  ; Is it 1?
    je GuessLetterReturn        ; If yes, letter already guessed - return
    
    ; ====================================================================
    ; STEP 5: MARK LETTER AS GUESSED
    ; ====================================================================
    
    mov byte ptr [esi + ebx], 1 ; guessedLetters[EBX] = 1
    
    ; ====================================================================
    ; STEP 6: SEARCH FOR LETTER IN SECRET WORD
    ; ====================================================================
    
    ; We need to find if CL (the guessed letter) appears in secretWord
    ; Load secretWord address
    lea esi, secretWord         ; ESI = address of secretWord
    lea edi, letterMask         ; EDI = address of letterMask
    
    ; Create a flag to track if we found the letter
    xor edx, edx                ; EDX = 0 (foundFlag - not found yet)
    
    ; Loop through each position in secretWord
    xor eax, eax                ; EAX = 0 (loop counter)
    mov ecx, wordLength         ; ECX = wordLength
    
SearchLoop:
    cmp eax, ecx                ; Compare counter with word length
    jge SearchDone              ; If counter >= length, exit loop
    
    ; Compare letter at position EAX with our guessed letter (CL)
    movzx ebx, byte ptr [esi + eax] ; EBX = secretWord[EAX]
    cmp bl, cl                  ; Compare with CL (guessed letter)
    jne NoMatch                 ; If no match, continue
    
    ; MATCH FOUND!
    ; Set letterMask[EAX] = 1 to reveal this letter
    mov byte ptr [edi + eax], 1 ; letterMask[EAX] = 1
    
    ; Set flag to indicate we found at least one match
    mov edx, 1                  ; EDX = 1 (foundFlag = true)
    
NoMatch:
    add eax, 1                  ; EAX++ (next position)
    jmp SearchLoop
    
SearchDone:
    ; ====================================================================
    ; STEP 7: UPDATE SCORE AND WRONG COUNT
    ; ====================================================================
    
    ; Check if we found the letter
    cmp edx, 1                  ; Is foundFlag == 1?
    jne LetterNotFound          ; If not, letter wasn't in word
    
    ; CORRECT GUESS - Letter was found in word
    ; Add points based on difficulty
    mov eax, currentDifficulty  ; EAX = difficulty (1, 2, or 3)
    
    ; Calculate points: Easy=10, Medium=15, Hard=25
    cmp al, 1                   ; Is difficulty Easy?
    je AddPointsEasy
    
    cmp al, 2                   ; Is difficulty Medium?
    je AddPointsMedium
    
    ; Must be Hard (difficulty = 3)
    add score, 25               ; Add 25 points for Hard
    jmp GuessLetterDone
    
AddPointsMedium:
    add score, 15               ; Add 15 points for Medium
    jmp GuessLetterDone
    
AddPointsEasy:
    add score, 10               ; Add 10 points for Easy
    jmp GuessLetterDone
    
LetterNotFound:
    ; WRONG GUESS - Letter was not in word
    ; Increment wrong count
    add wrongCount, 1           ; wrongCount++
    
GuessLetterDone:
    ; ====================================================================
    ; STEP 8: CHECK WIN/LOSS CONDITIONS
    ; ====================================================================
    
    ; Call CheckGameState procedure
    call CheckGameState
    
GuessLetterReturn:
    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret                         ; Return to caller
    
GuessLetter ENDP

; ============================================================================
; PROCEDURE 3: CheckGameState
;
; PURPOSE: Check if game won or lost
;
; INPUT: (reads from memory)
;   wrongCount, maxWrong, letterMask, wordLength, gameState
;
; OUTPUT:
;   Updates gameState if game ended
;   Updates score with bonus if game won
;
; LOGIC:
; 1. Check if wrongCount == maxWrong (lost)
; 2. Check if all letters revealed (won)
; 3. If won, calculate bonus points
;
; ============================================================================

CheckGameState PROC
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    ; ====================================================================
    ; CHECK LOSS CONDITION: wrongCount >= maxWrong?
    ; ====================================================================
    
    mov eax, wrongCount         ; EAX = wrongCount
    mov ecx, maxWrong           ; ECX = maxWrong
    
    cmp eax, ecx                ; Compare wrongCount with maxWrong
    jl CheckWinCondition        ; If wrongCount < maxWrong, check win
    
    ; wrongCount >= maxWrong - PLAYER LOST
    mov gameState, 3            ; Set state to 3 (lost)
    jmp CheckGameStateDone
    
    ; ====================================================================
    ; CHECK WIN CONDITION: All letters revealed?
    ; ====================================================================
    
CheckWinCondition:
    ; Loop through letterMask from 0 to wordLength-1
    ; If any position is 0 (not revealed), game is not won yet
    
    lea esi, letterMask         ; ESI = address of letterMask
    xor eax, eax                ; EAX = 0 (loop counter)
    mov ecx, wordLength         ; ECX = wordLength
    
CheckWinLoop:
    cmp eax, ecx                ; Compare counter with word length
    jge AllLettersRevealed      ; If counter >= length, all letters found!
    
    ; Check if letterMask[EAX] is 0
    movzx ebx, byte ptr [esi + eax] ; EBX = letterMask[EAX]
    cmp ebx, 0                  ; Is it 0 (not revealed)?
    je CheckGameStateDone       ; If yes, game not won yet - exit
    
    add eax, 1                  ; EAX++ (next position)
    jmp CheckWinLoop
    
AllLettersRevealed:
    ; ALL LETTERS REVEALED - PLAYER WON!
    mov gameState, 2            ; Set state to 2 (won)
    
    ; ====================================================================
    ; CALCULATE BONUS POINTS
    ; ====================================================================
    
    ; Bonus = (maxWrong - wrongCount) * 50 * difficulty_multiplier
    ; Easy: multiply by 1
    ; Medium: multiply by 1.5 (we'll do * 3 / 2)
    ; Hard: multiply by 2
    
    mov eax, maxWrong           ; EAX = maxWrong
    mov ecx, wrongCount         ; ECX = wrongCount
    sub eax, ecx                ; EAX = maxWrong - wrongCount (lives remaining)
    
    ; EAX now contains lives remaining
    ; Multiply by 50
    mov ecx, 50                 ; ECX = 50
    imul eax, ecx               ; EAX *= 50 (now = lives_remaining * 50)
    
    ; Apply difficulty multiplier
    mov ecx, currentDifficulty  ; ECX = difficulty (1, 2, or 3)
    
    cmp cl, 1                   ; Is difficulty Easy?
    je NoMultiplier             ; Easy gets 1x (no change)
    
    cmp cl, 2                   ; Is difficulty Medium?
    je Multiply1Point5          ; Medium gets 1.5x
    
    ; Must be Hard (difficulty = 3)
    mov ecx, 2                  ; Multiply by 2
    imul eax, ecx               ; EAX *= 2
    jmp BonusCalculated
    
Multiply1Point5:
    ; Multiply by 1.5 = multiply by 3 then divide by 2
    mov ecx, 3                  ; Multiply by 3
    imul eax, ecx               ; EAX *= 3
    mov ecx, 2                  ; Now divide by 2
    mov edx, 0                  ; EDX = 0 (for division)
    idiv ecx                    ; EAX = EAX / 2 (EDX has remainder)
    jmp BonusCalculated
    
NoMultiplier:
    ; Easy - no multiplier (already calculated correctly)
    
BonusCalculated:
    ; Add the bonus to score
    mov ecx, score              ; ECX = current score
    add ecx, eax                ; ECX += bonus
    mov score, ecx              ; Update score
    
    ; Also add to total score
    mov eax, totalScore         ; EAX = totalScore
    mov ecx, score              ; ECX = current game score
    add eax, ecx                ; EAX += current score
    mov totalScore, eax         ; Update totalScore
    
CheckGameStateDone:
    ; Restore registers
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret                         ; Return to caller
    
CheckGameState ENDP

; ============================================================================
; PROCEDURE 4: UseHint
;
; PURPOSE: Activate the hint (reveal category)
;
; INPUT: None
;
; OUTPUT:
;   Returns 1 in EAX if hint activated, 0 if already used
;
; ============================================================================

PUBLIC UseHint

UseHint PROC
    ; Check if hint already used
    movzx eax, hintUsed         ; AL = hintUsed (0 or 1)
    cmp al, 1                   ; Is it 1 (already used)?
    je HintAlreadyUsed          ; If yes, return 0
    
    ; Hint not used yet - activate it
    mov hintUsed, 1             ; Set hintUsed = 1
    mov eax, 1                  ; Return 1 (success)
    ret
    
HintAlreadyUsed:
    mov eax, 0                  ; Return 0 (already used)
    ret
    
UseHint ENDP

; ============================================================================
; PROCEDURE 5: ResetGame
;
; PURPOSE: Clear all state for next game
;
; ============================================================================

PUBLIC ResetGame

ResetGame PROC
    ; Save registers we'll use
    push eax
    push ecx
    push edi
    
    ; Reset gameState to 0 (waiting for Player 1 input)
    mov gameState, 0
    
    ; Reset score to 0 (each game starts fresh)
    mov score, 0
    
    ; Reset wrongCount to 0
    mov wrongCount, 0
    
    ; Reset hintUsed to 0
    mov hintUsed, 0
    
    ; Reset wordLength to 0
    mov wordLength, 0
    
    ; Reset timeElapsed to 0
    mov timeElapsed, 0
    
    ; Clear secretWord (set all 15 bytes to 0)
    lea edi, secretWord
    xor eax, eax
    xor ecx, ecx
    
ClearSecretWordLoop:
    cmp ecx, 15
    jge ClearSecretWordDone
    mov byte ptr [edi + ecx], 0
    add ecx, 1
    jmp ClearSecretWordLoop
    
ClearSecretWordDone:
    ; Clear guessedLetters (set all 26 bytes to 0)
    lea edi, guessedLetters
    xor eax, eax
    xor ecx, ecx
    
ClearGuessedLettersLoop:
    cmp ecx, 26
    jge ClearGuessedLettersDone
    mov byte ptr [edi + ecx], 0
    add ecx, 1
    jmp ClearGuessedLettersLoop
    
ClearGuessedLettersDone:
    ; Clear letterMask (set all 14 bytes to 0)
    lea edi, letterMask
    xor eax, eax
    xor ecx, ecx
    
ClearLetterMaskLoop:
    cmp ecx, 14
    jge ClearLetterMaskDone
    mov byte ptr [edi + ecx], 0
    add ecx, 1
    jmp ClearLetterMaskLoop
    
ClearLetterMaskDone:
    ; Restore registers
    pop edi
    pop ecx
    pop eax
    
    ret
    
ResetGame ENDP

; ============================================================================
; PROCEDURE 6: GetWrongCount
;
; PURPOSE: Return the current wrong guess count
;
; OUTPUT:
;   EAX = wrongCount
;
; ============================================================================

PUBLIC GetWrongCount

GetWrongCount PROC
    mov eax, wrongCount         ; EAX = wrongCount
    ret
    
GetWrongCount ENDP

; ============================================================================
; PROCEDURE 7: GetGameState
;
; PURPOSE: Return the current game state
;
; OUTPUT:
;   EAX = gameState (0-4)
;
; ============================================================================

PUBLIC GetGameState

GetGameState PROC
    movzx eax, gameState        ; AL = gameState (extend to 32-bit)
    ret
    
GetGameState ENDP

; ============================================================================
; PROCEDURE 8: GetScore
;
; PURPOSE: Return current game score
;
; OUTPUT:
;   EAX = score
;
; ============================================================================

PUBLIC GetScore

GetScore PROC
    mov eax, score              ; EAX = score
    ret
    
GetScore ENDP

; ============================================================================
; PROCEDURE 9: IsHintUsed
;
; PURPOSE: Check if hint was used
;
; OUTPUT:
;   EAX = hintUsed (0 or 1)
;
; ============================================================================

PUBLIC IsHintUsed

IsHintUsed PROC
    movzx eax, hintUsed         ; AL = hintUsed (extend to 32-bit)
    ret
    
IsHintUsed ENDP

; ============================================================================
; PROCEDURE 10: GetDifficulty
;
; PURPOSE: Return current difficulty
;
; OUTPUT:
;   EAX = currentDifficulty (1-3)
;
; ============================================================================

PUBLIC GetDifficulty

GetDifficulty PROC
    movzx eax, currentDifficulty ; AL = currentDifficulty
    ret
    
GetDifficulty ENDP

; ============================================================================
; PROCEDURE 11: GetTimeLimit
;
; PURPOSE: Return time limit for current difficulty
;
; OUTPUT:
;   EAX = timeLimit (seconds)
;
; ============================================================================

PUBLIC GetTimeLimit

GetTimeLimit PROC
    mov eax, timeLimit          ; EAX = timeLimit
    ret
    
GetTimeLimit ENDP

; ============================================================================
; PROCEDURE 12: GetTotalScore
;
; PURPOSE: Return total accumulated score
;
; OUTPUT:
;   EAX = totalScore
;
; ============================================================================

PUBLIC GetTotalScore

GetTotalScore PROC
    mov eax, totalScore         ; EAX = totalScore
    ret
    
GetTotalScore ENDP

; ============================================================================
; END OF CODE SECTION
; ============================================================================

END
