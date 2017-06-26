/mob
	var/obj/screen/plane/master/master_plane
	var/obj/screen/plane/dark/dark_plane
	var/obj/backdrop/backdrop

/mob/Login()
	. = ..()
	if(!dark_plane)
		dark_plane = new(client)
	else
		client.screen |= dark_plane
	if(!master_plane)
		master_plane = new(client)
	else
		client.screen |= master_plane
	if(!backdrop)
		backdrop = new(client)
	else
		client.screen |= backdrop

/mob/dead/observer/Login()
	. = ..()
	if(client)
		update_darkness()

/mob/dead/observer/proc/update_darkness()
	if(seedarkness)
		master_plane.color = LIGHTING_PLANEMASTER_COLOR
	else
		master_plane.color = ""

/mob/living/carbon/human/update_contained_lights(var/list/specific_contents)
	. = ..(contents-(internal_organs+organs))
