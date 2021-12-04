
//Something to remember destroyed artifacts without keeping the atom floating in nullspace
/datum/artifact_postmortem_data
	var/artifact_id = "<error>-000"
	var/turf/last_loc = null
	var/artifact_type = null
	var/primary_effect = ""
	var/primary_trigger
	var/secondary_effect = ""
	var/secondary_trigger

/datum/artifact_postmortem_data/New(var/atom/artifact,var/ignore = FALSE,var/error = FALSE)
	if (!artifact)
		if (!error)//if we know we're generating an corrupted archive, just return so we can fill in the data manually afterwards.
			qdel(src)
		return
	var/found = FALSE
	for(var/ID in excavated_large_artifacts)
		if (excavated_large_artifacts[ID] == artifact)
			excavated_large_artifacts -= ID
			artifact_id = ID
			found = TRUE
	if (!found)
		if (ignore)
			qdel(src)
			return
		else
			artifact_id = generate_artifact_id()

	last_loc = get_turf(artifact)
	artifact_type = artifact.type

	if (istype(artifact, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = artifact
		if (A.primary_effect)
			primary_effect = A.primary_effect.effecttype
			if (A.primary_effect.trigger)
				primary_trigger = A.primary_effect.trigger.triggertype
		if (A.secondary_effect)
			secondary_effect = A.secondary_effect.effecttype
			if (A.secondary_effect.trigger)
				secondary_trigger = A.secondary_effect.trigger.triggertype

	destroyed_large_artifacts[artifact_id] = src

////////////////////////The Actual Panel//////////////////////////////////////

/datum/admins/proc/artifacts_panel()
	if (!(SSxenoarch?.initialized))
		to_chat(usr,"<span class='danger'>The Xenoarch subsystem hasn't initialized yet!</span>")

	else if (!SSxenoarch?.artifact_spawning_turfs.len)
		to_chat(usr,"<span class='danger'>The Xenoarch subsystem seems to not have spawned any large artifact in the map. Lack of valid asteroid turfs?</span>")

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
				var/datum/artifact_postmortem_data/corrupted = new(null, FALSE, TRUE)
				corrupted.artifact_id = ID
				corrupted.last_loc = "not_a_turf"
				corrupted.artifact_type = "error: no postmortem artifact data generated"
				destroyed_large_artifacts[ID] += corrupted
			continue
		var/turf/T = get_turf(A)
		var/prim = ""
		var/prim_t = ""
		var/sec = ""
		var/sec_t = ""
		if (istype(A, /obj/machinery/artifact))
			var/obj/machinery/artifact/artifact = A
			if (artifact.primary_effect)
				prim = artifact.primary_effect.effecttype
				if (artifact.primary_effect.trigger)
					prim_t = artifact.primary_effect.trigger.triggertype
			if (artifact.secondary_effect)
				sec = artifact.secondary_effect.effecttype
				if (artifact.secondary_effect.trigger)
					sec_t = artifact.secondary_effect.trigger.triggertype
		dat += {"<tr>
			<td>[ID]</td>
			<td><font color='green'><b>Excavated</b><font> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[A.type] <a href='?_src_=vars;Vars=\ref[A]'>\[VV\]</a> <a href='?_src_=vars;mark_object=\ref[A]'>\[mark datum\]</a></td>
			<td>[prim][prim_t ? " ([prim_t])" : ""]</td>
			<td>[sec][sec_t ? " ([sec_t])" : ""]</td>
			</tr>
			"}

	//Next we list every large artifact that got destroyed
	for(var/ID in destroyed_large_artifacts)
		var/datum/artifact_postmortem_data/data = destroyed_large_artifacts[ID]
		if (!istype(data))
			continue
		var/turf/T = data.last_loc
		dat += {"<tr>
			<td>[data.artifact_id]</td>
			<td><font color='red'><b>Destroyed</b><font> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[data.artifact_type]</td>
			<td>[data.primary_effect][data.primary_trigger ? " ([data.primary_trigger])" : ""]</td>
			<td>[data.secondary_effect][data.secondary_trigger ? " ([data.secondary_trigger])" : ""]</td>
			</tr>
			"}
	for(var/ID in razed_large_artifacts)
		var/datum/artifact_postmortem_data/data = razed_large_artifacts[ID]
		if (!istype(data))
			continue
		var/turf/T = data.last_loc
		dat += {"<tr>
			<td>[data.artifact_id]</td>
			<td><font color='red'><b>Razed</b><font> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[data.artifact_type]</td>
			<td>[data.primary_effect][data.primary_trigger ? " ([data.primary_trigger])" : ""]</td>
			<td>[data.secondary_effect][data.secondary_trigger ? " ([data.secondary_trigger])" : ""]</td>
			</tr>
			"}

	//Finally we list every large artifact still buried on the asteroid
	for(var/obj/structure/boulder/boulder in boulders)
		if (!boulder.artifact_find)
			continue
		var/turf/T = get_turf(boulder)
		var/datum/artifact_find/A = boulder.artifact_find
		dat += {"<tr>
			<td>[A.artifact_id]</td>
			<td><b>Boulder</b> [istype(T)?"(<a href='?src=\ref[src];artifactpanel_jumpto=\ref[T]'>[T.x],[T.y],[T.z]</a>)":"(Unknown)"]</td>
			<td>[A.artifact_find_type]</td>
			<td>[(A.artifact_find_type == /obj/machinery/artifact) ? "???":""]</td>
			<td>[(A.artifact_find_type == /obj/machinery/artifact) ? "???":""]</td>
			</tr>
			"}
	if (SSxenoarch)
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

	usr << browse(dat, "window=artifactspanel;size=840x450")
