module main

import gg
import sync

const c_win_width = 1280
const c_win_height = 720
const c_win_font_size = 30

//
@[heap]
pub struct MPVPlayer {
mut:
	i_mpv_handle  &MPVHandle        = unsafe { nil }
	i_mpv_context &MPVRenderContext = unsafe { nil }

	i_mpv_should_draw bool

	i_pixels  [c_win_height][c_win_width]u32
	i_texture &gg.Image = unsafe { nil }

	i_lock &sync.Mutex = sync.new_mutex()

	i_video_duration f64
	i_video_position f64
pub mut:
	ctx &gg.Context = unsafe { nil }

	video_path string
}

pub fn (mut mpv MPVPlayer) init(_ voidptr) {
	// Init MPV crap
	mpv.i_mpv_handle = C.mpv_create()

	C.mpv_set_option_string(mpv.i_mpv_handle, 'vo'.str, 'libmpv'.str)

	if C.mpv_initialize(mpv.i_mpv_handle) < 0 {
		panic('MPV init failed!')
	}

	// Software Param Context
	temp_adv_control_hack := int(0)

	params := [
		MPVRenderParameter{C.MPV_RENDER_PARAM_API_TYPE, 'sw'.str},
		MPVRenderParameter{C.MPV_RENDER_PARAM_ADVANCED_CONTROL, &temp_adv_control_hack},
		MPVRenderParameter{0, &voidptr(0)},
	]

	if C.mpv_render_context_create(&mpv.i_mpv_context, mpv.i_mpv_handle, params.data) < 0 {
		panic('Failed to init mpv sw context.')
	}

	// Callbacks
	on_mpv_events := fn [mut mpv] (_ voidptr) {
		spawn mpv.on_mpv_events()
	}

	C.mpv_set_wakeup_callback(mpv.i_mpv_handle, on_mpv_events, 0)

	// Observe props
	C.mpv_observe_property(mpv.i_mpv_handle, 0, 'duration'.str, C.MPV_FORMAT_DOUBLE)
	C.mpv_observe_property(mpv.i_mpv_handle, 0, 'time-pos'.str, C.MPV_FORMAT_DOUBLE)

	// Texture
	i_texture_id := mpv.ctx.new_streaming_image(c_win_width, c_win_height, 4,
		pixel_format: .rgba8
	)
	mpv.i_texture = mpv.ctx.get_cached_image_by_idx(i_texture_id)

	//
	mpv.play_video(mpv.video_path)

	// gg
	mpv.ctx.set_text_cfg(size: c_win_font_size)
}

pub fn (mut mpv MPVPlayer) play_video(path string) {
	println('Playing: ${path}')
	C.mpv_command_async(mpv.i_mpv_handle, 0, [&char('loadfile'.str), &char(path.str), &char(0)].data)
}

pub fn (mut mpv MPVPlayer) toggle_video_playback() {
	C.mpv_command_async(mpv.i_mpv_handle, 0, [&char('cycle'.str), &char('pause'.str), &char(0)].data)
}

pub fn (mut mpv MPVPlayer) on_mpv_events() {
	for {
		event := C.mpv_wait_event(mpv.i_mpv_handle, 0)

		if event.event_id == C.MPV_EVENT_NONE {
			break
		}

		if event.event_id == C.MPV_EVENT_PROPERTY_CHANGE {
			prop := event.data

			mpv.i_lock.@lock()

			// HACK: c moment
			if unsafe { cstring_to_vstring(prop.name) } == 'time-pos' {
				if prop.format == C.MPV_FORMAT_DOUBLE {
					mpv.i_video_position = unsafe { *(&f64(prop.data)) }
				}
			} else if unsafe { cstring_to_vstring(prop.name) } == 'duration' {
				if prop.format == C.MPV_FORMAT_DOUBLE {
					mpv.i_video_duration = unsafe { *(&f64(prop.data)) }
				}
			}

			mpv.i_lock.unlock()
		}
	}
}

@[direct_array_access]
pub fn (mut mpv MPVPlayer) update_texture() {
	resolution := [c_win_width, c_win_height]

	pitch := int(4 * c_win_width)

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
	for y in 0 .. c_win_height {
		for x in 0 .. c_win_width {
			// 0XBB_GG_RR => 0xAA_BB_GG_RR
			mpv.i_pixels[y][x] = mpv.i_pixels[y][x] | (255 << 24)
		}
	}

	unsafe {
		mpv.i_texture.update_pixel_data(&u8(&mpv.i_pixels)) // inb4 this used to work without the casting.
	}
}

pub fn (mut mpv MPVPlayer) draw_texture() {
	t_res := mpv.ctx.window_size()

	// Note: some bullshit math to make the video always centered and fits into the window.
	mut factor := f64(c_win_height) / f64(t_res.height)

	if factor == 0.0 {
		factor = 1.0
	}

	mpv.ctx.draw_image((t_res.width - int(c_win_width / factor)) / 2, 0, int(c_win_width / factor),
		int(c_win_height / factor), mpv.i_texture)
}

pub fn (mut mpv MPVPlayer) draw_overlay() {
	t_res := mpv.ctx.window_size()

	current_minutes := int(mpv.i_video_position / 60.0)
	current_seconds := int(mpv.i_video_position) % 60

	total_minutes := int(mpv.i_video_duration / 60.0)
	total_seconds := int(mpv.i_video_duration) % 60

	playing_at_str := '${current_minutes:02}:${current_seconds:02}/${total_minutes:02}:${total_seconds:02}'

	text_width := mpv.ctx.text_width(playing_at_str) + 10

	// Overlay
	mpv.ctx.draw_rect_filled(0, t_res.height - c_win_font_size, text_width, c_win_font_size,
		gg.Color{0, 0, 0, 100})

	mpv.ctx.draw_text(5, t_res.height - c_win_font_size, playing_at_str,
		color: gg.Color{255, 255, 255, 255}
		align: .left
		size: c_win_font_size
	)
}

pub fn (mut mpv MPVPlayer) draw(_ voidptr) {
	mpv.ctx.begin()

	mpv.update_texture()
	mpv.draw_texture()

	// Some overlay info
	mpv.draw_overlay()

	mpv.ctx.end()
}
