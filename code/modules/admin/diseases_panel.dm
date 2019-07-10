/datum/admins/proc/diseases_panel()
	if (!disease2_list || !disease2_list.len)
		alert("There are no pathogen in the round currently!")
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
		<h2 style="text-align:center">Disease Panel</h2>
		<table>
		<tr>
		<th style="width:2%">Disease ID</th>
		<th style="width:1%">Origin</th>
		<th style="width:1%">in Database?</th>
		<th style="width:1%">Infected People</th>
		<th style="width:1%">Infected Items</th>
		<th style="width:1%">in Growth Dishes</th>
		</tr>
		"}

	for (var/ID in disease2_list)
		var/datum/disease2/disease/D = disease2_list[ID]
		var/infctd_mobs = 0
		var/infctd_mobs_dead = 0
		var/infctd_items = 0
		var/dishes = 0
		for (var/mob/living/L in mob_list)
			if (ID in L.virus2)
				infctd_mobs++
				if (L.stat == DEAD)
					infctd_mobs_dead++
		for (var/obj/item/I in infected_items)
			if (ID in I.virus2)
				infctd_items++
		for (var/obj/item/weapon/virusdish/dish in virusdishes)
			if (dish.contained_virus)
				if (ID == "[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]")
					dishes++
		var/nickname = ""
		if (ID in virusDB)
			var/datum/data/record/v = virusDB[ID]
			nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
		dat += {"<tr>
			<td><a href='?src=\ref[src];diseasepanel_examine=\ref[D]'>[D.form] #[add_zero("[D.uniqueID]", 4)]-[add_zero("[D.subID]", 4)][nickname]</a></td>
			<td>[D.origin]</td>
			<td><a href='?src=\ref[src];diseasepanel_toggledb=\ref[D]'>[(ID in virusDB) ? "Yes" : "No"]</a></td>
			<td><a href='?src=\ref[src];diseasepanel_infectedmobs=\ref[D]'>[infctd_mobs][infctd_mobs_dead ? " (including [infctd_mobs_dead] dead)" : "" ]</a></td>
			<td><a href='?src=\ref[src];diseasepanel_infecteditems=\ref[D]'>[infctd_items]</a></td>
			<td><a href='?src=\ref[src];diseasepanel_dishes=\ref[D]'>[dishes]</a></td>
			</tr>
			"}

	dat += {"</table>
		</body>
		</html>
		"}

	usr << browse(dat, "window=diseasespanel;size=705x450")
