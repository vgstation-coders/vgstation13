// Delete all atoms of a given type in a zone

/datum/admins
	var/x_min_del = 0
	var/x_max_del = 0
	var/y_min_del = 0
	var/y_max_del = 0
	var/z_del = 0
	var/type_del = null

/datum/admins/proc/mass_delete_in_zone()
	set category = "Server"
	set desc="Delete all atoms of a given type in a zone."
	set name="Mass delete in zone"
	if (!check_rights(R_SERVER))
		to_chat(src, "<span class='warning'>You need +SERVER to do this.</span>")
		return FALSE

	src = usr.client.holder // why lummox why
	
	var/list/dat = list()
	dat += {"<h3>Mass deletion in a zone</h3>"
	"Delete all the atoms of a given type in a zone given by z, x, and y coordinates."
	"<br/>"
	"<b>Z-level:</b> <a href='?src=\ref[src];change_zone_del=z_del;'>[z_del]</a> <br/>"
	"<br/>"
	"<b>X-min:</b> <a href='?src=\ref[src];change_zone_del=x_min_del;'>[x_min_del]</a> <br/>"
	"<b>X-max:</b> <a href='?src=\ref[src];change_zone_del=x_max_del;'>[x_max_del]</a> <br/>"
	"<br/>"
	"<b>Y-min:</b> <a href='?src=\ref[src];change_zone_del=y_min_del;'>[y_min_del]</a> <br/>"
	"<b>Y-max:</b> <a href='?src=\ref[src];change_zone_del=y_max_del;'>[y_max_del]</a> <br/>"
	"<br/>"
	"<b>Type:</b>  <a href='?src=\ref[src];change_zone_del=type;'>[type_del ? type_del : "No type"]</a> <br/>"
	"<br/>"
	"<a href='?src=\ref[src];change_zone_del=exec'>Delete it.</a>'"}

	usr << browse(jointext(dat, ""), "window=mass_del_in_zone;size=490x310")