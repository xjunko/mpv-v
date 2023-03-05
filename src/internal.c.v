// わたしの未成年観測

// C Header(s) to include
#include <mpv/client.h>
#include <mpv/render.h>
#pkgconfig --libs --cflags mpv

// Structs
[typedef]
struct C.mpv_handle {}

[typedef]
struct C.mpv_render_context {}

[typedef]
struct C.mpv_event {
pub:
	event_id int
}

[typedef]
struct C.mpv_render_param {
pub:
	@type int
	data  &voidptr
}

[typedef]
struct C.size_t {
}

[typedef]
struct C.mpv_opengl_init_params {
pub:
	get_proc_address     fn (&char)
	get_proc_address_ctx &voidptr
}

// Functions
fn C.mpv_create() &C.mpv_handle
fn C.mpv_initialize(&C.mpv_handle) int
fn C.mpv_destroy(&C.mpv_handle)

fn C.mpv_request_log_messages(&C.mpv_handle, &u8) int

fn C.mpv_render_context_create(&&C.mpv_render_context, &C.mpv_handle, []C.mpv_render_param) int
fn C.mpv_render_context_render(&C.mpv_render_context, []C.mpv_render_param) int
fn C.mpv_render_context_update(&C.mpv_render_context) u64
fn C.mpv_render_context_free(&C.mpv_render_context)

fn C.mpv_set_wakeup_callback(&C.mpv_handle, &voidptr, &voidptr)
fn C.mpv_render_context_set_update_callback(&C.mpv_handle, &voidptr, &voidptr)

fn C.mpv_command_async(&C.mpv_handle, u64, []&char) int

fn C.mpv_wait_event(&C.mpv_handle, f64) &C.mpv_event

fn C.mpv_error_string(int) &char
