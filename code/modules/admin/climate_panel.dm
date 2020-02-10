/datum/admins/proc/climate_panel()
	if (!map.climate)
		alert("This map has no climate!")
		return

	var/datum/climate/C = map.climate
	var/datum/weather/W = C.current_weather
	var/dat = {"<html>
		<head>
		<style>
		table,h2 {
		font-family: Arial, Helvetica, sans-serif;
		border-collapse: collapse;
		}
		td, th {
		border: 1px solid #dddddd;
		padding: 8px;
		}
		tr:nth-child(even) {
		background-color: #dddddd;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Climate Panel</h2>
		Climate: <a href='?_src_=vars;Vars=\ref[map.climate]'>\[VV\]</A><BR>
		Current Weather: [W.name] <a href='?_src_=vars;Vars=\ref[W]'>\[VV\]</A> (<a href='?src=\ref[src];climate_timeleft=\ref[W]'>Remaining</A>: [formatTimeDuration(W.timeleft)])<BR>
		<a href='?src=\ref[src];climate_weather=\ref[C]'>Quick-Change Weather</A>
		"}

	dat += {"
		</body>
		</html>
		"}

	usr << browse(dat, "window=climatepanel;size=360x175")
