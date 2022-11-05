/obj/item/clothing/accessory/spesstv_tactical_camera
	name = "\improper Spess.TV tactical camera"
	desc = "A compact, tactical camera with built-in Spess.TV integration. Fits on uniform, armor and headgear. It features a Team Security logo."
	icon_state = "small_camera" // Credits to https://github.com/discordia-space/CEV-Eris
	accessory_exclusion = ACCESSORY_LIGHT
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/obj/machinery/camera/arena/spesstv/internal_camera
	origin_tech = Tc_PROGRAMMING + "=2"
	mech_flags = MECH_SCAN_ILLEGAL

/obj/item/clothing/accessory/spesstv_tactical_camera/New()
	..()
	internal_camera = new(src)
	new /datum/action/item_action/toggle_streaming(src)

/obj/item/clothing/accessory/spesstv_tactical_camera/can_attach_to(obj/item/clothing/C)
	var/static/list/allowed_clothing = list(/obj/item/clothing/under, /obj/item/clothing/head, /obj/item/clothing/suit/armor)
	return is_type_in_list(C, allowed_clothing)

/obj/item/clothing/accessory/spesstv_tactical_camera/attack_self(mob/user)
	..()
	if(user.incapacitated())
		return
	if(!internal_camera.streamer)
		if(user.mind.GetRole(STREAMER))
			to_chat(user, "<span class='warning'>A camera is already linked to your Spess.TV account!</span>")
			return
		var/datum/role/streamer/new_streamer_role = new /datum/role/streamer
		if(!new_streamer_role.AssignToRole(user.mind, 1))
			new_streamer_role.Drop()
			to_chat(user, "<span class='warning'>Something went wrong during your registration to Spess.TV. Please try again.</span>")
			return
		new_streamer_role.team = ESPORTS_SECURITY
		new_streamer_role.camera = internal_camera
		new_streamer_role.set_camera(internal_camera)
		new_streamer_role.OnPostSetup()
		new_streamer_role.Greet(GREET_DEFAULT)
		new_streamer_role.AnnounceObjectives()
	if(internal_camera.streamer.antag != user.mind)
		to_chat(user, "<span class='warning'>You are not the registered user of this camera.</span>")
		return
	internal_camera.streamer.toggle_streaming()

/datum/action/item_action/toggle_streaming
	name = "Toggle streaming"

/datum/action/item_action/toggle_streaming/Trigger()
	var/obj/item/target_item = target
	target_item.attack_self(owner)
