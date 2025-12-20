/datum/admins/proc/mobs_panel()
	var/dat = {"<html>
		<head>
		<style>
		table, h2 {
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
		.header-row {
			background-color: #4a90d9;
			color: white;
			font-weight: bold;
		}
		.paused {
			background-color: #ffcccc;
		}
		.active {
			background-color: #ccffcc;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Mobs Panel</h2>
		<p style="text-align:center">Total Mobs: [mob_list.len] | Processing: [mob_list.len - SSmob.paused] | Paused: [SSmob.paused]</p>
		<table>
		<tr class="header-row">
			<th>Z-Level</th>
			<th>Name</th>
			<th>Status</th>
			<th>Actions</th>
		</tr>
		"}

	for(var/i = 1; i <= map.zLevels.len; i++)
		var/datum/zLevel/Z = map.zLevels[i]
		var/is_paused = SSmob.paused_z[Z]
		var/status_class = is_paused ? "paused" : "active"
		var/status_text = is_paused ? "PAUSED" : "ACTIVE"

		dat += {"<tr class="[status_class]">
			<td>Z-[i]</td>
			<td>[Z.name ? Z.name : Z.type] <a href='?_src_=vars;Vars=\ref[Z]'>\[VV\]</a></td>
			<td>[status_text]</td>
			<td>
				<a href='?src=\ref[src];mobs_panel_clients=1;mobs_z=[i]'>Players</a> |
				<a href='?src=\ref[src];mobs_panel_paused=1;mobs_z=[i]'>Paused Mobs</a> |
				<a href='?src=\ref[src];mobs_panel_all=1;mobs_z=[i]'>All Mobs</a> |
				<a href='?src=\ref[src];mobs_panel_toggle=1;mobs_z=[i]'>Toggle</a>
			</td>
		</tr>"}

	dat += {"
		</table>
		<br>
		<p style="text-align:center"><a href='?src=\ref[src];mobs_panel_refresh=1'>Refresh</a></p>
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=mobspanel;size=800x500")
