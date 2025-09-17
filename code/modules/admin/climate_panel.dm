/datum/admins/proc/climate_panel()
	if (!climates.len)
		alert("This map has no climates!")
		return

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
		.climate-header {
		background-color: #4CAF50;
		color: white;
		font-weight: bold;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Climate Panel - [climates.len] Climate[climates.len > 1 ? "s" : ""]</h2>
		<table>
		<tr class="climate-header">
		<th>Z-Level</th>
		<th>Climate Type</th>
		<th>Current Weather</th>
		<th>Time Remaining</th>
		<th>Actions</th>
		</tr>
		"}

	// Sort climates by z-level for consistent display
	var/list/sorted_climates = list()
	var/list/z_levels = list()

	// Collect all z-levels
	for(var/datum/climate/C in climates)
		z_levels += C.z

	// Sort z-levels numerically
	z_levels = sortList(z_levels)

	// Add climates in z-level order
	for(var/z in z_levels)
		for(var/datum/climate/C in climates)
			if(C.z == z)
				sorted_climates += C
				break

	for(var/datum/climate/C in sorted_climates)
		if(!C.current_weather)
			continue
		var/datum/weather/W = C.current_weather
		dat += {"<tr>
			<td>Z-[C.z]</td>
			<td>[C.name] <a href='?_src_=vars;Vars=\ref[C]'>\[VV\]</A></td>
			<td>[W.name] <a href='?_src_=vars;Vars=\ref[W]'>\[VV\]</A></td>
			<td><a href='?src=\ref[src];climate_timeleft=\ref[W]'>[formatTimeDuration(W.timeleft)]</A></td>
			<td><a href='?src=\ref[src];climate_weather=\ref[C]'>Change Weather</A></td>
			</tr>"}

	dat += {"
		</table>
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=climatepanel;size=800x400")
