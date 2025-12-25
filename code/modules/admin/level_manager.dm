/datum/admins/proc/level_manager()
	if (!map.zLevels.len)
		alert("This map has no z-levels!")
		return

	var/dat = {"<html>
		<head>
		<style>
		body {
			font-family: Arial, Helvetica, sans-serif;
			margin: 10px;
		}
		table {
			border-collapse: collapse;
			width: 100%;
			margin-bottom: 20px;
		}
		td, th {
			border: 1px solid #dddddd;
			padding: 8px;
			text-align: left;
		}
		tr:nth-child(even) {
			background-color: #f2f2f2;
		}
		.zlevel-header {
			background-color: #4a90d9;
			color: white;
			font-weight: bold;
		}
		.vlevel-header {
			background-color: #5cb85c;
			color: white;
			font-weight: bold;
		}
		.section-title {
			background-color: #333;
			color: white;
			padding: 10px;
			margin-top: 15px;
			margin-bottom: 5px;
		}
		.no-vlevels {
			color: #888;
			font-style: italic;
		}
		.info-cell {
			font-size: 0.9em;
			color: #555;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Level Manager</h2>
		<p style="text-align:center">[map.zLevels.len] Z-Level[map.zLevels.len != 1 ? "s" : ""] | [map.vLevels.len] Virtual Z-Level[map.vLevels.len != 1 ? "s" : ""]</p>
		"}

	for(var/z_index = 1 to map.zLevels.len)
		var/datum/zLevel/Z = map.zLevels[z_index]
		if(!Z)
			continue

		// Z-Level section header
		dat += {"<div class="section-title">Z-Level [z_index]: [Z.name] <a href='?_src_=vars;Vars=\ref[Z]'>\[VV\]</a></div>"}

		// Virtual Z-Levels for this Z-Level
		if(Z.virtual_z_levels.len)
			dat += {"<table>
				<tr class="vlevel-header">
					<th>VZ ID</th>
					<th>Name</th>
					<th>Size</th>
					<th>Offset (X, Y)</th>
					<th>Planet</th>
					<th>Mobs</th>
					<th>Players</th>
					<th>Actions</th>
				</tr>"}

			for(var/datum/virtual_z/V in Z.virtual_z_levels)
				var/planet_name = V.planet ? V.planet.name : "<span class='no-vlevels'>None</span>"
				var/size_name = "Unknown"
				if(V.size_x == ALLOCATION_FULL && V.size_y == ALLOCATION_FULL)
					size_name = "Full"
				else if(V.size_x == V.size_y)
					switch(V.size_x)
						if(ALLOCATION_SMALL)
							size_name = "Small"
						if(ALLOCATION_MEDIUM)
							size_name = "Medium"
						if(ALLOCATION_LARGE)
							size_name = "Large"
						else
							size_name = "[V.size_x]"
				else
					size_name = "[V.size_x]x[V.size_y]"
				var/list/mobs_list = V.get_mobs()
				var/list/players_list = V.get_players()
				dat += {"<tr>
					<td>[V.id]</td>
					<td>[V.name] <a href='?_src_=vars;Vars=\ref[V]'>\[VV\]</a></td>
					<td>[size_name]</td>
					<td>([V.x_offset], [V.y_offset])</td>
					<td>[planet_name]</td>
					<td>[mobs_list.len]</td>
					<td>[players_list.len]</td>
					<td><a href='?src=\ref[src];level_manager_jump=\ref[V]'>Jump To</a></td>
					</tr>"}

			dat += "</table>"
		else
			dat += {"<p class="no-vlevels">No virtual z-levels on this z-level.</p>"}

	dat += {"
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=levelmanager;size=600x400")
