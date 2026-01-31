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
		<th>Sector</th>
		<th>Climate Type</th>
		<th>Current Weather</th>
		<th>Time Remaining</th>
		<th>Actions</th>
		</tr>
		"}

	// Sort climates by z-level for consistent display
	var/list/sorted_climates = list()
	var/list/z_levels = list()

	for(var/datum/climate/C in climates)
		if(!(C.z in z_levels))
			z_levels += C.z
	z_levels = sortList(z_levels)
	for(var/z in z_levels)
		for(var/datum/climate/C in climates)
			if(C.z == z)
				sorted_climates += C

	for(var/datum/climate/C in sorted_climates)
		var/datum/weather/W = C.current_weather
		var/sector_display = C.allocation ? "([C.allocation.sector[1]], [C.allocation.sector[2]])" : "N/A"
		var/weather_display = W ? "[W.name] <a href='?_src_=vars;Vars=\ref[W]'>\[VV\]</A>" : "<font color='red'>ERROR: NULL</font>"
		var/timeleft_display = W ? "<a href='?src=\ref[src];climate_timeleft=\ref[W]'>[formatTimeDuration(W.timeleft)]</A>" : "<font color='red'>N/A</font>"
		dat += {"<tr>
			<td>Z-[C.z]</td>
			<td>[sector_display]</td>
			<td>[C.name] <a href='?_src_=vars;Vars=\ref[C]'>\[VV\]</A></td>
			<td>[weather_display]</td>
			<td>[timeleft_display]</td>
			<td><a href='?src=\ref[src];climate_weather=\ref[C]'>Change Weather</A> | <a href='?src=\ref[src];climate_restart=\ref[C]'>Restart</A></td>
			</tr>"}

	dat += {"
		</table>
		</body>
		</html>
		"}

	usr << browse(HTML_SKELETON(dat), "window=climatepanel;size=800x400")
