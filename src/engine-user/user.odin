package core_user

/*

These are concepts the core engine layer relies on.

But they vary from game-to-game, so this package is for interfacing with the core.

*/

import "engine:utils"

//
// DRAW

Quad_Flags :: enum u8 {
	// #shared with the shader.glsl definition
	background_pixels = (1<<0),
	flag2 = (1<<1),
	flag3 = (1<<2),
}

ZLayer :: enum u8 {
	// Can add as many layers as you want in here.
	// Quads get sorted and drawn lowest to highest.
	// When things are on the same layer, they follow normal call order.
	nil,
	background,
	shadow,
	playspace,
	vfx,
	ui,
	tooltip,
	pause_menu,
	top,
}

Sprite_Name :: enum {
	nil,
	engine_logo,
	fmod_logo,
	player_still,
	shadow_medium,
	bg_repeat_tex0,
	player_death,
	player_run,
	player_idle,
    // Add new sprites by placing .pngs in `res/images` and adding names here.
}

sprite_data: [Sprite_Name]Sprite_Data = #partial {
	.player_idle = {frame_count=2},
	.player_run = {frame_count=3}
}

Sprite_Data :: struct {
	frame_count: int,
	offset: Vec2,
	pivot: utils.Pivot,
}

get_sprite_offset :: proc(img: Sprite_Name) -> (offset: Vec2, pivot: utils.Pivot) {
	data := sprite_data[img]
	offset = data.offset
	pivot = data.pivot
	return
}

get_frame_count :: proc(sprite: Sprite_Name) -> int {
	frame_count := sprite_data[sprite].frame_count
	if frame_count == 0 {
		frame_count = 1
	}
	return frame_count
}


//
// helpers

import "core:math/linalg"
Matrix4 :: linalg.Matrix4f32
Vec2 :: [2]f32
Vec3 :: [3]f32
Vec4 :: [4]f32