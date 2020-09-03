/datum/admins/proc/artifacts_panel()
	if (!(SSxenoarch?.initialized))
		alert("The Xenoarch subsystem hasn't initialized yet!")

	if (!SSxenoarch.artifact_spawning_turfs.len)
		alert("The Xenoarch subsystem seems to not have spawned any large artifact in the map. Lack of valid asteroid turfs?")

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
		<h2 style="text-align:center">Artifact Panel</h2>
		<table>
		<tr>
		<th style="width:1%">Artifact ID</th>
		<th style="width:1%">Status</th>
		<th style="width:3%">Type</th>
		<th style="width:1%">Primary Effect</th>
		<th style="width:1%">Secondary Effect</th>
		</tr>
		"}

	//First we list every large artifact that exists currently in the world.
	//non-anomaly artifacts such as Mysterious Cloning Pod and Replicator that were admin-spawned won't appear here as they do not have an Artifact ID, unless they get analyzed later.
	var/list/artifacts_checked_already = list()

	for(var/ID in excavated_large_artifacts)
		artifacts_checked_already += ID
		var/atom/A = excavated_large_artifacts[ID]
		if (!(A?.loc))
			if (!(ID in destroyed_large_artifacts))
				var/list/artifact_data = list(
					ID,
					"not_a_turf",
					"not /obj/machinery/artifact",
					"",
					"",
					)//a non-anomaly artifact was destroyed, no real way to know what type it was.
				destroyed_large_artifacts[ID] += artifact_data
			continue
		var/turf/T = get_turf(A)
		var/prim = ""
		var/sec = ""
		if (istype(A, /obj/machinery/artifact))
			var/obj/machinery/artifact/artifact = A
			if (artifact.primary_effect)
				prim = artifact.primary_effect.effecttype
			if (artifact.secondary_effect)
				sec = artifact.secondary_effect.effecttype
		dat += {"<tr>
			<td>[ID]</td>
			<td><font color='green'><b>Excavated</b><font> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[A.type]</td>
			<td>[prim]</td>
			<td>[sec]</td>
			</tr>
			"}

	//Next we list every large artifact that got destroyed
	for(var/ID in destroyed_large_artifacts)
		var/list/data = destroyed_large_artifacts[ID]
		if (!istype(data))
			continue
		var/turf/T = data[2]
		dat += {"<tr>
			<td>[data[1]]</td>
			<td><font color='red'><b>Destroyed</b><font> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[data[3]]</td>
			<td>[data[4]]</td>
			<td>[data[5]]</td>
			</tr>
			"}

	//Finally we list every large artifact still buried on the asteroid
	for (var/turf/unsimulated/mineral/M in SSxenoarch.artifact_spawning_turfs)
		if (!istype(M))
			continue
		if (!M.artifact_find)
			continue
		var/datum/artifact_find/A = M.artifact_find
		dat += {"<tr>
			<td>[A.artifact_id]</td>
			<td><b>Buried</b> <a href='?src=\ref[src];artifactpanel_jumpto=\ref[M]'>([M.x],[M.y],[M.z])</a></td>
			<td>[A.artifact_find_type]</td>
			<td>[(A.artifact_find_type == /obj/machinery/artifact) ? "???":""]</td>
			<td>[(A.artifact_find_type == /obj/machinery/artifact) ? "???":""]</td>
			</tr>
			"}
	dat += {"</table>
		</body>
		</html>
		"}

	usr << browse(dat, "window=artifactspanel;size=705x450")
