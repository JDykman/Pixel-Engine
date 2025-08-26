@echo off
echo Building OdinGame2 for Windows...

REM Build the project
odin build src/game.odin -out:build/windows_debug/game.exe -debug

echo Build complete!
echo Run with: build\windows_debug\game.exe
