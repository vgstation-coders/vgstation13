/obj/structure/closet/cabinet
	name = "cabinet"
	desc = "Old will forever be in fashion."
	icon_state = "cabinet_closed"
	icon_closed = "cabinet_closed"
	icon_opened = "cabinet_open"
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3

/obj/structure/closet/cabinet/canweld()
	return 0

/obj/structure/closet/cabinet/snow
	name = "snow gear cabinet"
	desc = "A cabinet filled with snow gear for extra-station activity."
	var/obj/structure/hanger_rail/hanger_rail

/obj/structure/closet/cabinet/snow/New()
	..()
	hanger_rail = new (src)

/obj/structure/closet/cabinet/snow/close()
	. = ..()
	if(.)
		unlock_atom(hanger_rail)
		hanger_rail.forceMove(src)

/obj/structure/closet/cabinet/snow/open()
	. = ..()
	if(.)
		hanger_rail.forceMove(get_turf(src))
		lock_atom(hanger_rail)

/obj/structure/closet/cabinet/snow/Destroy()
	..()
	qdel(hanger_rail)
	hanger_rail = null

/obj/structure/hanger_rail
	icon = 'icons/obj/closet.dmi'
	icon_state = "hanger_rail"
	name = "hanger rail"
	desc = "This rail is for holding NT standard-issue winter coats."
	var/coats = 4
	density = 0
	anchored = 1
	flags = FPRINT
	layer = ABOVE_OBJ_LAYER

/obj/structure/hanger_rail/attack_hand(var/mob/user,params,proximity)
	..()
	if(!proximity)
		return
	if(coats)
		to_chat(user,"<span class='notice'>You remove a pair of boots and a coat from the hanger.</span>")
		add_fingerprint(user)
		var/winterboots = new /obj/item/clothing/shoes/winterboots(get_turf(src))
		user.put_in_inactive_hand(winterboots)
		var/wintercoat = new /obj/item/clothing/suit/storage/wintercoat(get_turf(src))
		user.put_in_active_hand(wintercoat)
		coats--
		update_icon()

/obj/structure/hanger_rail/update_icon()
	overlays.Cut()
	for(var/i = 1 to coats)
		overlays += image(icon,"coat[i]")

/obj/structure/hanger_rail/New()
	..()
	update_icon()

/obj/structure/closet/cabinet/medivault
	name = "old cabinet"
	desc = "This cabinet has been gathering dust, and hasn't been disturbed in some years."

/obj/structure/closet/cabinet/medivault/atoms_to_spawn()
	return list(
		/obj/item/weapon/storage/box/masks,
		/obj/item/weapon/storage/backpack/satchel_med,
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/head/bio_hood/virology,
		/obj/item/clothing/suit/bio_suit/virology,
		/obj/item/clothing/shoes/white,
		/obj/item/weapon/paper/pamphlet/medivault,
	)

/obj/structure/closet/acloset
	name = "strange closet"
	desc = "It looks alien!"
	icon_state = "acloset"
	icon_closed = "acloset"
	icon_opened = "aclosetopen"


/obj/structure/closet/gimmick
	name = "administrative supply closet"
	desc = "It's a storage unit for things that have no right being here."
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	anchored = 0

/obj/structure/closet/gimmick/russian
	name = "russian surplus closet"
	desc = "It's a storage unit for Russian standard-issue surplus."
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/gimmick/russian/atoms_to_spawn()
	return list(
		/obj/item/clothing/head/ushanka = 5,
		/obj/item/clothing/under/soviet = 5,
	)


/obj/structure/closet/gimmick/tacticool
	name = "tacticool gear closet"
	desc = "It's a storage unit for Tacticool gear."
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/gimmick/tacticool/atoms_to_spawn()
	return list(
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/gloves/swat = 2,
		/obj/item/clothing/head/helmet/tactical/swat = 2,
		/obj/item/device/flashlight/tactical = 2,
		/obj/item/clothing/mask/gas = 2,
		/obj/item/clothing/shoes/swat = 2,
		/obj/item/clothing/suit/armor/swat = 2,
		/obj/item/clothing/under/syndicate/tacticool = 2,
	)


/obj/structure/closet/thunderdome
	name = "\improper Thunderdome closet"
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	anchored = 1

/obj/structure/closet/thunderdome/tdred
	name = "red-team Thunderdome closet"

/obj/structure/closet/thunderdome/tdred/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/armor/tdome/red = 3,
		/obj/item/weapon/melee/energy/sword = 3,
		/obj/item/weapon/gun/energy/laser = 3,
		/obj/item/weapon/melee/baton/loaded = 3,
		/obj/item/weapon/storage/box/flashbangs = 3,
		/obj/item/clothing/head/helmet/thunderdome = 3,
	)

/obj/structure/closet/thunderdome/tdgreen
	name = "green-team Thunderdome closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/thunderdome/tdgreen/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/armor/tdome/green = 3,
		/obj/item/weapon/melee/energy/sword = 3,
		/obj/item/weapon/gun/energy/laser = 3,
		/obj/item/weapon/melee/baton/loaded = 3,
		/obj/item/weapon/storage/box/flashbangs = 3,
		/obj/item/clothing/head/helmet/thunderdome = 3,
	)

