# VISUAL STUDIO 2022 SETUP - COMPLETE GUIDE

## THIS GUIDE WILL TEACH YOU HOW TO SET UP YOUR HANGMAN PROJECT IN VISUAL STUDIO 2022

Follow these steps EXACTLY in order. Each step depends on the previous one.

---

## STEP 1: DOWNLOAD AND INSTALL VISUAL STUDIO 2022 COMMUNITY EDITION

**WHAT IS VS 2022?**
Visual Studio 2022 is an IDE (Integrated Development Environment) - it's a program that helps you write, compile, and run C++ code. Community Edition is FREE.

**HOW TO INSTALL:**

1. Go to: https://visualstudio.microsoft.com/vs/community/
2. Click the blue "Download" button
3. Run the downloaded installer (.exe file)
4. When the installer starts, you'll see a checklist of components
5. **IMPORTANT**: Check the box for "Desktop development with C++"
6. This installs C++ compiler, libraries, and tools needed for our project
7. Click "Install" button (this takes 5-10 minutes)
8. When done, click "Launch"

**YOU SHOULD NOW SEE VISUAL STUDIO 2022 WINDOW**

---

## STEP 2: CREATE A NEW EMPTY C++ PROJECT

**WHY EMPTY?**
We want to start from nothing and add our files, so we know exactly what's in the project.

**HOW TO CREATE:**

1. In Visual Studio, click "File" menu at the top
2. Click "New"
3. Click "Project"
4. A dialog window appears with project templates
5. Search box at the top - type: "empty"
6. Find "Empty Project" (it has a blank icon)
7. Click it, then click "Next"
8. **PROJECT NAME**: Type `Hangman` (this is your project name)
9. **LOCATION**: Choose where to save (your Documents folder is fine)
10. Click "Create"

**YOU SHOULD NOW SEE YOUR EMPTY PROJECT IN SOLUTION EXPLORER (left panel)**

---

## STEP 3: ENABLE MASM (MICROSOFT MACRO ASSEMBLER)

**WHAT IS MASM?**
MASM is the assembler - it compiles x86 Assembly code to machine language. By default, VS doesn't know about Assembly files, so we need to enable it.

**HOW TO ENABLE:**

1. At the top menu, click "Project"
2. Click "Build Customizations..."
3. A dialog window appears
4. **LOOK FOR**: "masm (.targets, .props)" in the list
5. Check the checkbox next to it
6. Click "OK"

**MASM IS NOW ENABLED** - You can add .asm files to your project

---

## STEP 4: DOWNLOAD AND EXTRACT SFML

**WHAT IS SFML?**
SFML (Simple and Fast Multimedia Library) is a graphics library that makes drawing windows, buttons, text, and shapes easy.

**HOW TO DOWNLOAD:**

1. Go to: https://sfml-dev.org
2. Click "Download"
3. Find "SFML 2.6.1 for Visual Studio 2022 (32-bit)" - **IMPORTANT: MUST BE 32-BIT**
4. Click the download link
5. A .zip file downloads
6. Extract it (right-click → Extract All...)
7. You now have a folder called `SFML-2.6.1`
8. **MOVE THIS FOLDER** into your `Hangman` project folder (same location as your .sln file)
9. **RENAME IT** to just `SFML` (easier to type)

**NOW YOU HAVE:**
```
Hangman/
├── Hangman.sln (the project file)
├── Hangman/
│   └── (your .cpp, .h, .asm files go here)
└── SFML/ (the graphics library)
    ├── bin/
    ├── include/
    ├── lib/
    └── ... other folders
```

---

## STEP 5: ADD YOUR CODE FILES TO THE PROJECT

**WHAT FILES DO WE ADD?**
- Data.asm (Assembly variables)
- Logic.asm (Assembly procedures)
- Game.h (C++ header bridge)
- InputScreen.h / InputScreen.cpp
- GameScreen.h / GameScreen.cpp
- main.cpp

**HOW TO ADD FILES:**

**For Assembly files (Data.asm, Logic.asm):**

1. In Solution Explorer (left panel), right-click on "Source Files" folder
2. Click "Add" → "Existing Item"
3. Browse to where your .asm files are
4. Select Data.asm, click "Add"
5. Repeat for Logic.asm

**For C++ files (all .h and .cpp):**

1. For .h files: Right-click "Header Files" → "Add" → "Existing Item"
2. For .cpp files: Right-click "Source Files" → "Add" → "Existing Item"
3. Add them in this order:
   - Game.h (to Header Files)
   - InputScreen.h (to Header Files)
   - GameScreen.h (to Header Files)
   - InputScreen.cpp (to Source Files)
   - GameScreen.cpp (to Source Files)
   - main.cpp (to Source Files)

---

## STEP 6: CONFIGURE EACH .ASM FILE AS ASSEMBLY (CRITICAL!)

**WHY THIS STEP?**
By default, VS tries to compile .asm files as C++ code, which causes errors. We need to tell it they're Assembly files.

**HOW TO CONFIGURE:**

For each .asm file (Data.asm and Logic.asm):

1. In Solution Explorer, find the .asm file
2. Right-click on it
3. Click "Properties"
4. A properties window opens
5. Look for "Item Type" (near the top)
6. Change it from "C/C++ compiler" to "Microsoft Macro Assembler"
7. Click "Apply" then "OK"

**REPEAT THIS FOR BOTH .ASM FILES**

---

## STEP 7: SET PROJECT ARCHITECTURE TO x86 (32-BIT)

**WHY 32-BIT?**
Our Assembly code uses 32-bit registers (EAX, EBX, etc.). 64-bit won't work with our code.

**HOW TO CHANGE:**

1. At the very top of Visual Studio, find the platform dropdown
2. It probably says "x64" (64-bit)
3. Click the dropdown arrow
4. Select "x86" (32-bit)
5. If you don't see x86, click "Configuration Manager" and add it

**IMPORTANT: Your project is now 32-bit**

---

## STEP 8: CONFIGURE SFML PATHS IN PROJECT PROPERTIES

**WHAT ARE WE DOING?**
We're telling Visual Studio where to find SFML header files and library files.

**HOW TO CONFIGURE:**

1. At the top, click "Project" menu
2. Click "Properties"
3. A large Properties window opens

**ADD INCLUDE PATH:**
1. Left panel: expand "VC++ Directories"
2. Click "Include Directories"
3. At the right, click the dropdown arrow
4. Click "Edit..."
5. A dialog appears
6. Click the "New Folder" icon (yellow folder with +)
7. Type the path to SFML include: `C:\Users\YourUsername\YourPath\Hangman\SFML\include`
   - Replace "YourUsername" and "YourPath" with your actual paths
8. Click OK

**ADD LIBRARY PATH:**
1. Left panel: expand "VC++ Directories"
2. Click "Library Directories"
3. Click dropdown arrow → "Edit..."
4. Click "New Folder" icon
5. Type: `C:\Users\...\Hangman\SFML\lib`
6. Click OK

**ADD LIBRARY FILES:**
1. Left panel: expand "Linker"
2. Click "Input"
3. Right panel: find "Additional Dependencies"
4. Click the dropdown arrow
5. Click "Edit..."
6. Type these exact names (one per line):
   ```
   sfml-graphics-d.lib
   sfml-window-d.lib
   sfml-system-d.lib
   ```
7. Click OK

(The "-d" means debug versions - use these for testing. Later you can use non-debug versions for release)

8. Click "OK" to close the Properties window

---

## STEP 9: COPY SFML DLL FILES

**WHAT ARE DLL FILES?**
DLL files are the actual SFML library code. They must be in the same folder as your .exe file when you run the program, or it will crash.

**WHERE ARE THEY?**
Inside `Hangman\SFML\bin\` folder

**WHERE TO COPY?**
To: `Hangman\Debug\` folder (this is where your .exe file is created)

**HOW TO COPY:**

1. Open File Explorer (Windows Explorer)
2. Navigate to: `Hangman\SFML\bin\`
3. Find these files:
   - sfml-graphics-d.dll
   - sfml-window-d.dll
   - sfml-system-d.dll
4. Copy them (Ctrl+C)
5. Navigate to: `Hangman\Debug\`
6. Paste them (Ctrl+V)

**NOW YOUR .EXE FILE CAN FIND THESE LIBRARIES**

---

## STEP 10: BUILD THE PROJECT (COMPILE)

**WHAT IS BUILDING?**
Building means compiling - converting your code (Assembly and C++) into a .exe file the computer can run.

**HOW TO BUILD:**

1. In Visual Studio, press `Ctrl+Shift+B` on your keyboard
2. OR click "Build" menu → "Build Solution"
3. At the bottom, an "Output" panel appears
4. You'll see messages while it compiles

**LOOK FOR THESE MESSAGES:**

**SUCCESS** (ideal):
```
========== Build: 1 succeeded, 0 failed ==========
```
This means everything compiled correctly! Skip to STEP 11.

**ERRORS** (common problems):
If you see red error messages, here are common ones and fixes:

| Error | Fix |
|-------|-----|
| "cannot open include file 'SFML/Graphics.hpp'" | Include path wrong - recheck Step 8 |
| "cannot open Irvine32.lib" | (We're not using Irvine in this version - skip this) |
| "unresolved external symbol SetSecretWord" | .asm file not set to MASM compiler - recheck Step 6 |
| "sfml-graphics-d.lib not found" | Library path wrong in Step 8 |
| "LNK1112: module machine type x64 conflicts with x86" | Not set to x86 - recheck Step 7 |
| "Entry point must be defined" | main.cpp missing or not compiled |

**READ THE ERROR MESSAGE CAREFULLY** - it tells you what's wrong and often where!

---

## STEP 11: RUN THE GAME!

**HOW TO RUN:**

1. Press `F5` on your keyboard
2. OR click Debug → Start Debugging at top menu
3. Visual Studio compiles (if needed) and runs your program

**EXPECTED RESULT:**
A window should appear titled "Hangman - Player vs Player"

**IF IT DOESN'T OPEN:**
1. Check the Debug folder - is your .exe there?
2. Check if DLL files are in Debug folder (Step 9)
3. Check if you got any build errors (Step 10)

**IF WINDOW OPENS BUT CRASHES:**
1. Error message? Read it carefully
2. Most common: DLL files missing - copy them again (Step 9)
3. Fonts not found? Change font paths in InputScreen.cpp and GameScreen.cpp (replace `C:\Windows\Fonts\arial.ttf` with a path that exists on your computer)

---

## STEP 12: CUSTOMIZE FONT PATHS (IMPORTANT FOR YOUR SYSTEM)

**WHY?**
The code looks for fonts at `C:\Windows\Fonts\arial.ttf` but this path might be different on your computer.

**HOW TO FIX:**

1. Open File Explorer on your computer
2. Paste this in the address bar: `C:\Windows\Fonts`
3. Look for a font file (any .ttf file like `arial.ttf` or `calibri.ttf`)
4. Right-click it, select "Properties", copy its full path
5. Open your .cpp files and find all `.loadFromFile()` lines
6. Replace the path with your actual font path

**EXAMPLE:**
```cpp
// OLD:
titleFont.loadFromFile("C:\\Windows\\Fonts\\arial.ttf");

// NEW (if you find it in a different location):
titleFont.loadFromFile("C:\\Windows\\Fonts\\calibri.ttf");
```

---

## YOU'RE DONE! 🎉

Your Hangman game is now set up and running in Visual Studio 2022!

---

## TROUBLESHOOTING CHECKLIST

If something doesn't work, check these in order:

- [ ] Visual Studio 2022 installed with C++ tools?
- [ ] SFML 2.6.1 (32-bit) downloaded and extracted to Hangman\SFML\?
- [ ] All 6 code files added to project?
- [ ] Both .asm files set to "Microsoft Macro Assembler" compiler?
- [ ] Project set to x86 (32-bit) architecture?
- [ ] SFML Include Directories path correct in properties?
- [ ] SFML Library Directories path correct in properties?
- [ ] SFML library names added (sfml-graphics-d.lib, etc.)?
- [ ] SFML .dll files copied to Debug folder?
- [ ] Font paths valid on your system?
- [ ] Project builds successfully (Ctrl+Shift+B)?
- [ ] Game runs (F5) without crashing?

---

## COMMON MISTAKES TO AVOID

❌ **DON'T**: Download SFML 64-bit instead of 32-bit
❌ **DON'T**: Forget to set .asm files to MASM compiler
❌ **DON'T**: Forget to copy DLL files to Debug folder
❌ **DON'T**: Use incorrect paths (copy-paste from file properties)
❌ **DON'T**: Change architecture to x64 after setting it to x86

---

## FOR BEGINNERS: WHAT HAPPENS WHEN YOU PRESS F5

1. Visual Studio calls the C++ compiler (converts .cpp/.h to .obj files)
2. Visual Studio calls MASM (converts .asm files to .obj files)
3. Visual Studio calls the linker (connects all .obj files together)
4. Linker creates main.exe in Hangman\Debug\ folder
5. Visual Studio runs main.exe
6. Your Hangman game window appears!

---

## NEXT STEPS AFTER SUCCESSFUL BUILD

1. **Play the game** and test all features
2. **If bugs appear**, check the Assembly logic in Logic.asm
3. **If graphics weird**, check drawing code in GameScreen.cpp
4. **If can't compile**, check error messages and this guide again

---

**GOOD LUCK WITH YOUR HANGMAN GAME!** 🎮

If you have questions, re-read the relevant section or google the specific error message.
