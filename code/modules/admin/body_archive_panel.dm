/datum/admins/proc/body_archive_panel()
	if (!body_archives || !body_archives.len)
		alert("No body archive has been created yet. Either nobody has spawned yet or something has gone wrong.")
		return

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
		<h2 style="text-align:center">Body Archive Panel</h2>
		<table>
		<tr>
		<th style="width:1%">Key</th>
		<th style="width:1%">Name</th>
		<th style="width:1%">Rank</th>
		<th style="width:0.5%">Naked Copy</th>
		<th style="width:0.5%">Clothed Copy</th>
		<th style="width:0.5%">Transfer</th>
		<th style="width:1%">Mob Type</th>
		</tr>
		"}

	for (var/datum/body_archive/archive in body_archives)
		var/archivename = archive.name
		if (!archivename)
			archive.name = "(blank)"
		dat += {"<tr>
			<td>[archive.key]</td>
			<td><a href='?src=\ref[src];bodyarchivepanel_focus=\ref[archive]'>[archivename]</a></td>
			<td>[archive.rank]</td>
			<td><a href='?src=\ref[src];bodyarchivepanel_spawnnaked=\ref[archive]'>\[SPAWN\]</a></td>
			<td><a href='?src=\ref[src];bodyarchivepanel_spawnclothed=\ref[archive]'>\[SPAWN\]</a></td>
			<td><a href='?src=\ref[src];bodyarchivepanel_transfer=\ref[archive]'>\[TRANSFER\]</a></td>
			<td><i>[archive.mob_type]</i></td>
			</tr>
			"}

	dat += {"</table>
		</body>
		</html>
		"}

	usr << browse(dat, "window=bodyarchivepanel;size=860x640")
