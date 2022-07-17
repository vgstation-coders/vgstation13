var/global/list/camera_bugs = list()
/obj/item/device/handtv
	name = "handheld tv"
	desc = "A handheld tv meant for remote viewing."
	icon_state = "handtv"
	w_class = W_CLASS_TINY
	var/obj/item/device/camera_bug/current
	var/network

/obj/item/device/handtv/attack_self(mob/user as mob)
	if(!network && user.mind)
		network = "\ref[user.mind]"
	var/list/cameras = list()
	for(var/obj/item/device/camera_bug/C in camera_bugs)
		if(C.network == network)
			cameras += C
	if(!cameras.len)
		to_chat(user, "<span class='warning'>No camera bugs found.</span>")
		return
	var/list/friendly_cameras = new/list()

	for (var/obj/item/device/camera_bug/C in cameras)
		friendly_cameras.Add(C.c_tag)
	var/target = input("Select the camera to observe", null) as null|anything in sortList(friendly_cameras)
	if (!target)
		user.unset_machine()
		user.reset_view(user)
		return
	for(var/obj/item/device/camera_bug/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if(user.stat)
		return
	if(target)
		user.client.eye = target
		user.set_machine(src)
		src.current = target
	else
		user.unset_machine()
		return

/obj/item/device/handtv/check_eye(var/mob/user as mob)
	if ( loc != user || !user.is_holding_item(src) || user.incapacitated() || user.blinded || !current || !current.active )
		return null
	user.reset_view(current)
	return 1
