module main

import os
import gg

[heap]
pub struct MPVPlayer {
mut:
	i_mpv_handle  &C.mpv_handle = unsafe { nil }
	i_mpv_context &C.mpv_render_context = unsafe { nil }

	i_mpv_should_draw bool

	i_pixels  [720][1280]u32
	i_texture &gg.Image = unsafe { nil }
pub mut:
	ctx &gg.Context = unsafe { nil }

	video_path string
}

pub fn (mut mpv MPVPlayer) init(_ voidptr) {
	// Init MPV crap
	mpv.i_mpv_handle = C.mpv_create()

	if C.mpv_initialize(mpv.i_mpv_handle) < 0 {
		panic('MPV init failed!')
	}

	// Software Param Context
	temp_adv_control_hack := int(0)

	params := [
		C.mpv_render_param{C.MPV_RENDER_PARAM_API_TYPE, 'sw'.str},
		C.mpv_render_param{C.MPV_RENDER_PARAM_ADVANCED_CONTROL, &temp_adv_control_hack},
		C.mpv_render_param{0, &voidptr(0)},
	]

	if C.mpv_render_context_create(&mpv.i_mpv_context, mpv.i_mpv_handle, params.data) < 0 {
		panic('Failed to init mpv sw context.')
	}

	// // Hacky stuff to get events working
	// // Not really sure if i need this....
	// on_mpv_events := fn [mut mpv] (_ &voidptr) {
	// 	println('EVENT')
	// }

	// on_mpv_render_update := fn [mut mpv] (_ &voidptr) {
	// 	mpv.i_mpv_should_draw = true
	// }

	// C.mpv_set_wakeup_callback(mpv.i_mpv_handle, on_mpv_events, &voidptr(0))
	// C.mpv_render_context_set_update_callback(mpv.i_mpv_handle, on_mpv_render_update, &voidptr(0))

	// Texture
	i_texture_id := mpv.ctx.new_streaming_image(1280, 720, 4, pixel_format: .rgba8)
	mpv.i_texture = mpv.ctx.get_cached_image_by_idx(i_texture_id)

	//
	mpv.play_video(mpv.video_path)
}

pub fn (mut mpv MPVPlayer) play_video(path string) {
	println('Playing: ${path}')
	C.mpv_command_async(mpv.i_mpv_handle, 0, [&char('loadfile'.str), &char(path.str), &char(0)].data)
}

[direct_array_access]
pub fn (mut mpv MPVPlayer) update_texture() {
	resolution := [1280, 720]
	pitch := int(5120) // magic number?

	rend_params := [
		C.mpv_render_param{C.MPV_RENDER_PARAM_SW_SIZE, resolution.data},
		C.mpv_render_param{C.MPV_RENDER_PARAM_SW_FORMAT, 'rgb0'.str},
		C.mpv_render_param{C.MPV_RENDER_PARAM_SW_STRIDE, &pitch},
		C.mpv_render_param{C.MPV_RENDER_PARAM_SW_POINTER, &mpv.i_pixels},
		C.mpv_render_param{0, &voidptr(0)},
	]

	r := C.mpv_render_context_render(mpv.i_mpv_context, rend_params.data)

	if r < 0 {
		unsafe {
			panic('Something went wrong: ${cstring_to_vstring(C.mpv_error_string(r))} | ${r}')
		}
	}

	// fuck it we ballin
	// converts RGB to ABGR
	for y in 0 .. 720 {
		for x in 0 .. 1280 {
			// 0XBB_GG_RR => 0xAA_BB_GG_RR
			mpv.i_pixels[y][x] = mpv.i_pixels[y][x] | (255 << 24)
		}
	}

	mpv.i_texture.update_pixel_data(&mpv.i_pixels)
}

pub fn (mut mpv MPVPlayer) draw(_ voidptr) {
	mpv.ctx.begin()

	mpv.update_texture()
	mpv.ctx.draw_image(0, 0, 1280, 720, mpv.i_texture)

	mpv.ctx.end()
}

fn main() {
	if os.args.len < 2 {
		eprintln('give path for the video.')
		exit(1)
	}

	video_path := os.args[1]

	mut window := &MPVPlayer{
		video_path: video_path
	}

	window.ctx = gg.new_context(
		width: 1280
		height: 720
		user_data: window
		// FNs
		init_fn: window.init
		frame_fn: window.draw
		// Events
		keydown_fn: fn (key gg.KeyCode, modifier gg.Modifier, _ voidptr) {
			if key == .q || key == .escape {
				println('Exiting!')
				exit(1)
			}
		}
	)

	window.ctx.run()
}
