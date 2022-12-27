/obj/structure/closet/crate/medical/yantar
	name = "Yantar medical crate"
	desc = "From the forbidden 'X' laboratory focused on medical research."
	has_lock_type = null

var/global/list/yantar_stuff = list(
	//3 of a kind
	/obj/item/weapon/depocket_wand/suit,/obj/item/weapon/depocket_wand/suit,/obj/item/weapon/depocket_wand/suit,
	//1 of a kind
	/obj/item/weapon/storage/trader_chemistry,
	/obj/structure/closet/crate/flatpack/ancient/chemmaster_electrolyzer,
	/obj/structure/largecrate/secure/frankenstein,
	)

/obj/structure/closet/crate/medical/yantar/New()
	..()
	for(var/i = 1 to 6)
		if(!yantar_stuff.len)
			return
		var/path = pick_n_take(yantar_stuff)
		new path(src)

/obj/item/weapon/storage/trader_chemistry
	name = "chemist's pallet"
	desc = "Everything you need to make art."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_chemistry/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/peridaxon(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/rezadone(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/large/supermatter(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
	new /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer(src)

/obj/structure/largecrate/secure/frankenstein
	name = "medical livestock crate"
	desc = "An access-locked crate containing medical horrors. Handlers are advised to scream 'It's alive!' repeatedly."
	req_access = list(access_surgery)
	mob_path = null
	bonus_path = /mob/living/carbon/human/frankenstein

/obj/item/weapon/depocket_wand/suit
	name = "suit sensing wand"
	desc = "Used by medical staff to ensure compliance with vitals tracking regulations and to save vocal cord wear from demanding it over communications systems."
	var/wand_mode = 3

/obj/item/weapon/depocket_wand/suit/attack_self(mob/user)
	var/static/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[wand_mode + 1]) in modes
	if(user.incapacitated())
		return
	wand_mode = modes.Find(switchMode) - 1

	switch(wand_mode)
		if(0)
			to_chat(user, "<span class='notice'>\The [src] will now disable suit remote sensing equipment.</span>")
		if(1)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report whether the wearer is live or dead.</span>")
		if(2)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report vital lifesigns.</span>")
		if(3)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report vital lifesigns as well as coordinate positions.</span>")

/obj/item/weapon/depocket_wand/suit/scan(mob/living/carbon/human/H, mob/living/user)
	var/obj/item/clothing/under/suit = H.w_uniform
	if(!suit)
		to_chat(user, "<span class='warning'>\The [H] is not wearing a suit.</span>")
		return
	if(!suit.has_sensor)
		to_chat(user, "<span class='warning'>\The [H]'s suit does not have sensors.</span>")
		return
	if(suit.has_sensor >= 2)
		to_chat(user, "<span class='warning'>\The [H]'s suit sensor controls are locked.</span>")
		return
	suit.sensor_mode = wand_mode
	switch(suit.sensor_mode)
		if(0)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to disable suit remote sensing equipment with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to disable suit remote sensing equipment.</span>")
		if(1)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to whether the wearer is live or dead with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report whether the wearer is live or dead.</span>")
		if(2)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to report vital lifesigns with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report vital lifesigns.</span>")
		if(3)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to report vital lifesigns as well as coordinate positions with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report vital lifesigns as well as coordinate positions.</span>")
	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors set to [wand_mode] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Set [H.name]'s suit sensors ([H.ckey]).</font>")
	log_attack("[user.name] ([user.ckey]) has set [H.name]'s suit sensors ([H.ckey]) to [wand_mode].")

