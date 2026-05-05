// ============================================================================
// FILE: Game.h
// PURPOSE: Bridge between C++ and Assembly code
//
// WHAT IS THIS FILE?
// This header file tells C++ about the Assembly procedures and variables.
// It's like a translator between two languages.
//
// extern C: This tells the C++ compiler "don't use C++ name mangling"
// Name mangling = C++ modifies function names to include type information
// Assembly doesn't do this, so we need extern C to keep plain names
// ============================================================================

#ifndef GAME_H
#define GAME_H

// This tells C++ compiler: use plain C names, not C++ mangled names
extern "C" {
    // ====================================================================
    // ASSEMBLY PROCEDURES (functions we can call from C++)
    // ====================================================================
    
    // SetSecretWord: Initialize game with Player 1's word
    // Parameters: word = pointer to the word text, length = number of letters
    void SetSecretWord(const char* word, int length);
    
    // GuessLetter: Process one guess from Player 2
    // Parameter: letter = the ASCII code of the letter guessed
    void GuessLetter(char letter);
    
    // ResetGame: Clear all state for a new game
    void ResetGame();
    
    // GetWrongCount: Return how many wrong guesses so far
    // Returns: integer (0 to maxWrong)
    int GetWrongCount();
    
    // GetGameState: Return current game state
    // Returns: 0 = Player 1 input, 1 = Player 2 guessing, 2 = won, 3 = lost
    int GetGameState();
    
    // GetScore: Return points earned in current game
    // Returns: integer (points)
    int GetScore();
    
    // IsHintUsed: Check if hint was already used
    // Returns: 1 = used, 0 = available
    int IsHintUsed();
    
    // UseHint: Activate the hint (show category)
    // Returns: 1 = hint activated, 0 = already used
    int UseHint();
    
    // GetDifficulty: Return current difficulty level
    // Returns: 1 = Easy, 2 = Medium, 3 = Hard
    int GetDifficulty();
    
    // GetTimeLimit: Return time allowed for this difficulty
    // Returns: seconds (60 for Easy, 45 for Medium, 30 for Hard)
    int GetTimeLimit();
    
    // GetTotalScore: Return accumulated total score across all games
    // Returns: points (accumulates, never resets during session)
    int GetTotalScore();
    
    // ====================================================================
    // ASSEMBLY VARIABLES (data we can read and write from C++)
    // ====================================================================
    
    // secretWord: The word Player 1 typed (what Player 2 guesses)
    // Size: 15 bytes (14 letters + 1 null terminator)
    extern char secretWord[15];
    
    // selectedCategory: The category Player 1 selected
    // Size: 20 bytes (enough for "Famous Person" or any category)
    extern char selectedCategory[20];
    
    // letterMask: Which letters have been correctly revealed
    // Size: 14 bytes (one per letter position)
    // Value: 0 = hidden as underscore, 1 = revealed
    extern char letterMask[14];
    
    // guessedLetters: Which letters A-Z have been tried
    // Size: 26 bytes (one per letter A-Z)
    // Value: 0 = not guessed, 1 = guessed
    extern char guessedLetters[26];
    
    // wordLength: How many letters in the secret word
    extern int wordLength;
    
    // wrongCount: Current number of wrong guesses
    extern int wrongCount;
    
    // maxWrong: Maximum wrong guesses allowed for this difficulty
    extern int maxWrong;
    
    // score: Points earned in current game
    extern int score;
    
    // totalScore: Total points across all games in this session
    extern int totalScore;
    
    // gameState: What stage the game is in
    extern char gameState;
    
    // currentDifficulty: Current difficulty (1=Easy, 2=Medium, 3=Hard)
    extern char currentDifficulty;
    
    // timeLimit: Seconds allowed for this difficulty
    extern int timeLimit;
    
    // timeElapsed: Seconds that have passed so far
    extern int timeElapsed;
    
    // hintUsed: Has the category hint been used?
    extern char hintUsed;
    
    // isDailyChallenge: Are we in daily challenge mode?
    extern char isDailyChallenge;
    
    // dailyChallengeWord: The special daily challenge word
    extern char dailyChallengeWord[15];
    
    // dailyChallengeCategory: The daily challenge category
    extern char dailyChallengeCategory[20];
}

#endif
