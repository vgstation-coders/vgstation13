// For creating a

/datum/admins/proc/admin_arena_panel()
	var/dat = {"<html>
		<head>
		<style>
		table,h2 {
		font-family: Arial, Helvetica, sans-serif;
		border-collapse: collapse;
		width: 100%;
		}
		td, th {
		border: 1px solid #dddddd;
		padding: 8px;
		text-align: left;
		}
		tr:nth-child(even) {
		background-color: #dddddd;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Admin Arena Panel</h2>
		<p style="text-align:center">
		<a href='?src=\ref[src];admin_arena_panel_create=1'>Create Arena</a> |
		<a href='?src=\ref[src];admin_arena_panel_load_file=1'>Load Arena from File</a> |
		<a href='?src=\ref[src];admin_arena_panel_load_preset=1'>Load Arena From Presets</a> |
		<a href='?src=\ref[src];admin_arena_panel_add_prep_room=1'>Create Prep Room</a>
		</p>
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=adminarenapanel;size=800x400")
