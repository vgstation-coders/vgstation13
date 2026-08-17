// Renders an arena panel action as a clickable link, or a greyed-out label when it isn't available yet.
/datum/admins/proc/arena_panel_button(href_key, label, enabled = TRUE)
	if(enabled)
		return "<a href='?src=\ref[src];[href_key]=1'>[label]</a>"
	return "<span style='color: gray;'>[label]</span>"

// Describes the current arena (with a jump link), or "None" if one hasn't been created.
/datum/admins/proc/arena_panel_arena_status()
	if(!current_admin_arena)
		return "None"
	var/turf/bl = current_admin_arena.bottom_left
	return "Exists at ([bl.x], [bl.y], [bl.z]) [formatJumpTo(bl, "\[Jump\]")]"

// Lists each prep room's coordinates (with jump links), one per line, or "None" if there aren't any.
/datum/admins/proc/arena_panel_prep_room_status()
	var/list/lines = list()
	for(var/obj/effect/admin_arena_prep_room_marker/marker in active_prep_rooms)
		var/turf/T = get_turf(marker)
		if(!T)
			continue
		lines += "([T.x], [T.y], [T.z]) [formatJumpTo(T, "\[Jump\]")] <a href='?src=\ref[src];admin_arena_panel_remove_prep_room=\ref[marker]'>\[Remove\]</a>"
	if(!lines.len)
		return "None"
	return jointext(lines, "<br>")

/datum/admins/proc/admin_arena_panel()
	var/datum/admin_arena_round/arena_round = current_admin_arena_round
	var/arena_exists = (current_admin_arena != null)
	var/round_active = (arena_round != null)
	var/can_begin_combat = (arena_round != null && arena_round.in_arena && !arena_round.combat_started)

	var/dat = {"<html>
		<head>
		<style>
		body {
		font-family: Arial, Helvetica, sans-serif;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Admin Arena Panel</h2>
		<h3>Status</h3>
		<p>
		<b>Arena:</b> [arena_panel_arena_status()]<br>
		<b>Prep Rooms:</b><br>
		[arena_panel_prep_room_status()]
		</p>
		<h3>Arena Setup</h3>
		<p>
		[arena_panel_button("admin_arena_panel_create", "Create Arena")]<br>
		[arena_panel_button("admin_arena_panel_load_file", "Load Arena from File")]<br>
		[arena_panel_button("admin_arena_panel_load_preset", "Load Arena From Presets")]<br>
		[arena_panel_button("admin_arena_panel_add_prep_room", "Create Prep Room")]
		</p>
		<h3>Round Management</h3>
		<p>
		[arena_panel_button("admin_arena_panel_begin_round", "Begin New Round", arena_exists && !round_active)]<br>
		[arena_panel_button("admin_arena_panel_send_to_arena", "Send Contestants To Arena", round_active)]<br>
		[arena_panel_button("admin_arena_panel_begin_combat", "Begin Combat", can_begin_combat)]<br>
		[arena_panel_button("admin_arena_panel_end_round", "End Round", round_active)]<br>
		[arena_panel_button("admin_arena_panel_reset_round", "Reset Round", round_active)]
		</p>
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=adminarenapanel;size=800x400")
