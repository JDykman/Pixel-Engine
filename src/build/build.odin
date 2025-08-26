/*

Build script.

Note: doesn't make sense to abstract this away for re-use.
There's too many project-specific settings here, so it's not worth the effort.

*/

#+feature dynamic-literals
package build

import path "core:path/filepath"
import "core:fmt"
import "core:os/os2"
import "core:os"
import "core:strings"
import "core:log"
import "core:reflect"
import "core:time"

// we are assuming we're right next to the engine collection
import logger "../engine/utils/logger"
import utils "../engine/utils"

EXE_NAME :: "game"

Target :: enum {
	windows,
	mac,
	linux,
}

main :: proc() {
	context.logger = logger.logger()
	context.assertion_failure_proc = logger.assertion_failure_proc

	//fmt.println(os2.args)

	start_time := time.now()

	// note, ODIN_OS is built in, but we're being explicit
	assert(ODIN_OS == .Windows || ODIN_OS == .Darwin || ODIN_OS == .Linux, "unsupported OS target")

	target: Target
	#partial switch ODIN_OS {
		case .Windows: target = .windows
		case .Darwin: target = .mac
		case .Linux: target = .linux
		case: {
			log.error("Unsupported os:", ODIN_OS)
			return
		}
	}
	fmt.println("Building for", target)

	// gen the generated.odin
	{
		file := "src/generated.odin"

		f, err := os.open(file, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
		if err != nil {
			fmt.eprintln("Error:", err)
		}
		defer os.close(f)
		
		using fmt
		fprintln(f, "//")
		fprintln(f, "// MACHINE GENERATED via build.odin")
		fprintln(f, "// do not edit by hand!")
		fprintln(f, "//")
		fprintln(f, "")
		fprintln(f, "package main")
		fprintln(f, "")
		fprintln(f, "Platform :: enum {")
		fprintln(f, "	windows,")
		fprintln(f, "	mac,")
		fprintln(f, "	linux,")
		fprintln(f, "}")
		fprintln(f, tprintf("PLATFORM :: Platform.%v", target))
	}

	fmt.println("Generated 'generated.odin'")
	
    // generate the shader
    // docs: https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md
    // Include GLSL for Linux, HLSL for Windows, and Metal for macOS so one generated file works cross-platform.
    utils.fire("tools/sokol-shdc", "-i", "src/engine/draw/shader_core.glsl", "-o", "src/engine-user/generated_shader.odin", "-l", "glsl410:hlsl5:metal_macos", "-f", "sokol_odin")

	fmt.println("Generated shader")
	
	out_dir : string
	switch target {
		case .windows: out_dir = "build/windows_debug"
		case .mac:     out_dir = "build/mac_debug"
		case .linux:   out_dir = "build/linux_debug"
	}

	if err := os2.make_directory_all(out_dir, 0o755); err != nil {
		log.fatal("Failed to create build directory:", err)
	}
	
	log.info("Build directory ensured:", out_dir)

	// build command
	{
		c: [dynamic]string = {
			"odin",
			"build",
			"src",
			"-debug",
			"-collection:engine=src/engine",
			"-collection:user=src",
			fmt.tprintf("-out:%v/%v.exe", out_dir, EXE_NAME),
		}
		utils.fire(..c[:])
	}

	// copy stuff into folder
	{
		// NOTE, if it already exists, it won't copy (to save build time)
		files_to_copy: [dynamic]string

		switch target {
			case .windows:
			append(&files_to_copy, "src/engine/sound/fmod/studio/lib/windows/x64/fmodstudio.dll")
			append(&files_to_copy, "src/engine/sound/fmod/studio/lib/windows/x64/fmodstudioL.dll")
			append(&files_to_copy, "src/engine/sound/fmod/core/lib/windows/x64/fmod.dll")
			append(&files_to_copy, "src/engine/sound/fmod/core/lib/windows/x64/fmodL.dll")

			case .mac:
			append(&files_to_copy, "src/engine/sound/fmod/studio/lib/darwin/libfmodstudio.dylib")
			append(&files_to_copy, "src/engine/sound/fmod/studio/lib/darwin/libfmodstudioL.dylib")
			append(&files_to_copy, "src/engine/sound/fmod/core/lib/darwin/libfmod.dylib")
			append(&files_to_copy, "src/engine/sound/fmod/core/lib/darwin/libfmodL.dylib")

			// TODO: Implement for linux
			case .linux:
				append(&files_to_copy, "src/engine/sound/fmod/studio/lib/linux/libfmodstudio.so")
				append(&files_to_copy, "src/engine/sound/fmod/studio/lib/linux/libfmodstudioL.so")
				append(&files_to_copy, "src/engine/sound/fmod/core/lib/linux/libfmod.so")
				append(&files_to_copy, "src/engine/sound/fmod/core/lib/linux/libfmodL.so")
		}

		for src in files_to_copy {
			dir, file_name := path.split(src)
			assert(os.exists(dir), fmt.tprint("directory doesn't exist:", dir))
			dest := fmt.tprintf("%v/%v", out_dir, file_name)
			if !os.exists(dest) {
				os2.copy_file(dest, src)
			}
		}
	}

	fmt.println("DONE in", time.diff(start_time, time.now()))
}


// value extraction example:
/*
target: Target
found: bool
for arg in os2.args {
	if strings.starts_with(arg, "target:") {
		target_string := strings.trim_left(arg, "target:")
		value, ok := reflect.enum_from_name(Target, target_string)
		if ok {
			target = value
			found = true
			break
		} else {
			log.error("Unsupported target:", target_string)
		}
	}
}
*/