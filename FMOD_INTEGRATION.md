# FMOD Integration for OdinGame2

## Overview
This project has been successfully integrated with FMOD (Firelight Technologies) audio engine for cross-platform sound functionality.

## Dependencies

### Linux (Arch)
```bash
# Install FMOD Engine and Studio
yay -S fmodengine fmodstudio

# Build Sokol C libraries
cd sauce/bald/sokol
./build_clibs_linux.sh
cd ../../..
```

### Windows
- Download FMOD Studio and Engine from https://www.fmod.com/
- Extract to appropriate directories
- Ensure FMOD libraries are in PATH or project directory

## Building

### Linux
```bash
./build_linux.sh
```

### Windows
```bash
build_windows.bat
```

## Running

### Linux
```bash
./run_linux.sh
```

### Windows
```bash
build\windows_debug\game.exe
```

## FMOD Library Paths

### Linux
- Core libraries: `/opt/fmodengine/api/core/lib/x86_64/`
- Studio libraries: `/opt/fmodengine/api/studio/lib/x86_64/`
- Runtime path set via `LD_LIBRARY_PATH`

### Windows
- Libraries should be in project directory or system PATH
- FMOD bindings expect libraries in `sauce/bald/sound/fmod/core/lib/windows/` and `sauce/bald/sound/fmod/studio/lib/windows/`

## Version Compatibility
- FMOD Engine: 2.03.07
- FMOD Studio: 2.02.24
- Bindings updated to support version 2.03.07

## Troubleshooting

### Library Not Found (Linux)
```bash
export LD_LIBRARY_PATH=/opt/fmodengine/api/core/lib/x86_64:/opt/fmodengine/api/studio/lib/x86_64:$LD_LIBRARY_PATH
```

### Version Mismatch
If you see version mismatch errors, ensure:
1. FMOD Engine and Studio versions are compatible
2. FMOD bindings version constants match installed libraries
3. Rebuild project after updating FMOD installations

## Cross-Platform Notes
- Linux: Uses dynamic libraries (.so files)
- Windows: Uses dynamic libraries (.dll files)
- Build scripts handle platform-specific linking
- FMOD bindings use build tags for platform-specific code
