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
		var/wintercoat = new /obj/item/clothing/suit/wintercoat(get_turf(src))
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

/obj/structure/closet/cabinet/medivault/New()
	..()
	sleep(2)
	new /obj/item/weapon/storage/box/masks(src)
	new /obj/item/weapon/storage/backpack/satchel_med(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/head/bio_hood/virology(src)
	new /obj/item/clothing/suit/bio_suit/virology(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/weapon/paper/pamphlet/medivault(src)

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

/obj/structure/closet/gimmick/russian/New()
	..()
	sleep(2)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/head/ushanka(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)
	new /obj/item/clothing/under/soviet(src)


/obj/structure/closet/gimmick/tacticool
	name = "tacticool gear closet"
	desc = "It's a storage unit for Tacticool gear."
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/gimmick/tacticool/New()
	..()
	sleep(2)
	new /obj/item/clothing/glasses/eyepatch(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/gloves/swat(src)
	new /obj/item/clothing/gloves/swat(src)
	new /obj/item/clothing/head/helmet/tactical/swat(src)
	new /obj/item/clothing/head/helmet/tactical/swat(src)
	new /obj/item/device/flashlight/tactical(src)
	new /obj/item/device/flashlight/tactical(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/suit/armor/swat(src)
	new /obj/item/clothing/suit/armor/swat(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)
	new /obj/item/clothing/under/syndicate/tacticool(src)


/obj/structure/closet/thunderdome
	name = "\improper Thunderdome closet"
	desc = "Everything you need!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	anchored = 1

/obj/structure/closet/thunderdome/New()
	..()
	sleep(2)

/obj/structure/closet/thunderdome/tdred
	name = "red-team Thunderdome closet"

/obj/structure/closet/thunderdome/tdred/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/clothing/suit/armor/tdome/red(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)

/obj/structure/closet/thunderdome/tdgreen
	name = "green-team Thunderdome closet"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/thunderdome/tdgreen/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/clothing/suit/armor/tdome/green(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/melee/energy/sword(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/gun/energy/laser(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/melee/baton/loaded(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)
	new /obj/item/clothing/head/helmet/thunderdome(src)