/mob
	var/obj/abstract/screen/plane/master/master_plane
	var/obj/abstract/screen/backdrop/backdrop
	var/obj/abstract/screen/plane/self_vision/self_vision
	var/seedarkness = 1

/mob/proc/create_lighting_planes()

	if (master_plane)
		client.screen -= master_plane
		qdel(master_plane)
		master_plane = null

	if (backdrop)
		client.screen -= backdrop
		qdel(backdrop)
		backdrop = null

	if (self_vision)
		client.screen -= self_vision
		qdel(self_vision)
		self_vision = null


	master_plane = new(client)
	backdrop = new(client)
	self_vision = new(client)

	client.screen |= master_plane
	client.screen |= backdrop
	client.screen |= self_vision

	update_darkness()
	lazy_register_event(/lazy_event/on_before_move, src, /mob/proc/check_dark_vision)

/mob/proc/update_darkness()
	if(seedarkness)
		master_plane.color = LIGHTING_PLANEMASTER_COLOR
	else
		master_plane.color = ""
