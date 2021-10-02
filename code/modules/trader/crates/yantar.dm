/obj/structure/closet/crate/medical/yantar
	name = "Yantar medical crate"
	desc = "From the forbidden 'X' laboratory focused on medical research."
	has_lock_type = null

var/global/list/yantar_stuff = list(
	//1 of a kind
	/obj/item/weapon/storage/trader_chemistry,
	/obj/structure/closet/crate/flatpack/ancient/chemmaster_electrolyzer,
	/obj/structure/largecrate/secure/frankenstein,
	)

/obj/structure/closet/crate/medical/yantar/New()
	..()
	for(var/i = 1 to 3)
		if(!yantar_stuff.len)
			return
		var/path = pick_n_take(yantar_stuff)
		new path(src)

/obj/structure/largecrate/secure/frankenstein
	name = "medical livestock crate"
	desc = "An access-locked crate containing medical horrors. Handlers are advised to scream 'It's alive!' repeatedly."
	req_access = list(access_surgery)
	mob_path = null
	bonus_path = /mob/living/carbon/human/frankenstein

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