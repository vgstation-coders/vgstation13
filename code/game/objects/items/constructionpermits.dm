/* construction permits. Think blueprints but accessible to all engies and does NOT count as the antag steal objective
these cannot rename rooms that are in by default BUT can rename rooms that are created via blueprints/permit  */

/obj/item/blueprints/construction_permit
	name = "construction permit"
	desc = "An electronic permit designed to register a room for the use of APC and air alarms"
	icon = 'icons/obj/items.dmi'
	icon_state = "permit"
	attack_verb = list("attacks", "baps", "hits")
	w_class = W_CLASS_TINY


	can_rename_areas = list(AREA_BLUEPRINTS)


/obj/item/blueprints/construction_permit/interact()
	var/area/A = get_area()
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>This permit is for the creation of new rooms only; you cannot change existing rooms.</small><hr>
"}
	switch (get_area_type())
		if (AREA_SPACE)
			text += {"
<p>According the permit, you are now in <b>outer space</b>, Beware the space carp.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as new area.</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According the permit, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may not change the existing rooms, only create new ones and rename them.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place isn't noted on the permit's records.</p>
"}
		if (AREA_BLUEPRINTS)
			text += {"
<p>According to the blueprints, you are now in <b>\"[A.name]\"</b> This place seems to be relatively new on the permit.</p>"}
			text += "<p>You may <a href='?src=\ref[src];action=edit_area'>move an amendment</a> to the drawing.</p>"

		else
			return
	text += "</BODY></HTML>"
	usr << browse(text, "window=construction permit")
	onclose(usr, "construction permit")