module main

import os
import gg

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
		window_title: "World's Simplest Video Player"
		width: c_win_width
		height: c_win_height
		user_data: window
		// FNs
		init_fn: window.init
		frame_fn: window.draw
		// Events
		keydown_fn: fn (key gg.KeyCode, modifier gg.Modifier, mut mpv MPVPlayer) {
			if key_quit.contains(key) {
				println('Exiting!')
				exit(1)
			}

			if key_toggle_play.contains(key) {
				println('Toggling playback.')
				mpv.toggle_video_playback()
			}
		}
	)

	window.ctx.run()
}
