/obj/item/voucher
	name = "vendor's voucher"
	desc = "A slip of electropaper used for accessing special features of brand vending machines."
	icon = 'icons/obj/vouchers.dmi'
	icon_state = "voucher"
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 0

	var/shred_on_use = 1

//Vouchers that get turned into an item based on regular check-ins
/obj/item/voucher/warp
	name = "warp voucher"
	desc = "Uses bluespace technology to send you an item once certain conditions are met."
	var/redeem_path

/obj/item/voucher/warp/New()
	..()
	processing_objects += src

/obj/item/voucher/warp/Destroy()
	processing_objects -= src
	..()

/obj/item/voucher/warp/process()
	if(vouch_condition())
		var/turf/T = get_turf(src)
		var/obj/item/I = new redeem_path(T)
		T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',anim_plane = EFFECTS_PLANE)
		var/mob/M = get_holder_of_type(src,/mob)
		if(M)
			M.put_in_hands(I)
		visible_message("\The [src] vanishes in a warp-flash, leaving behind a brand new [I.name].")
		qdel(src)

/obj/item/voucher/warp/proc/vouch_condition()
	return FALSE

/obj/item/voucher/warp/kinetic_accelerator
	name = "warp voucher - kinetic accelerator"
	desc = "Uses bluespace technology to send you an item once certain conditions are met. This one is triggered by entering an NT designated mining area."
	redeem_path = /obj/item/weapon/gun/energy/kinetic_accelerator

/obj/item/voucher/warp/kinetic_accelerator/vouch_condition()
	var/turf/T = get_turf(src)
	if(istype(T.loc, /area/mine/explored)||istype(T.loc, /area/mine/unexplored))
		return TRUE
	return FALSE

/obj/item/voucher/free_item
	name = "free products voucher"
	desc = "A slip of electropaper redeemable for any brand product from a particular brand of vending machines."
	var/list/freebies = list() //what we will actually spawn - types
	var/single_items = 0 //if we can only vend each one once
	var/vend_amount = 0 //how many items we make the machine spit out

//Test case
/obj/item/voucher/free_item/hot_drink
	name = "free hot drink voucher"
	desc = "Perk Up Your Day, with this handy free hot drink from your trusted name-brand vending machines."

	freebies = list(/obj/item/weapon/reagent_containers/food/drinks/coffee, /obj/item/weapon/reagent_containers/food/drinks/tea, /obj/item/weapon/reagent_containers/food/drinks/h_chocolate)
	vend_amount = 1
	shred_on_use = 0

/obj/item/voucher/free_item/snack
	name = "free snack voucher"
	desc = "Perk Up Your Day, with this handy free snack from your trusted name-brand vending machines."

	freebies = list(/obj/item/weapon/reagent_containers/food/snacks/candy,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen,/obj/item/weapon/reagent_containers/food/snacks/chips,/obj/item/weapon/reagent_containers/food/snacks/sosjerky,/obj/item/weapon/reagent_containers/food/snacks/no_raisin,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie,/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers)
	vend_amount = 1
	shred_on_use = 0

/obj/item/voucher/free_item/donk
	name = "free donk-pocket voucher"
	desc = "Perk Up Your Day, with this handy free snack from your trusted name-brand vending machines."

	freebies = list(/obj/item/weapon/reagent_containers/food/snacks/donkpocket/self_heating)
	vend_amount = 1
	shred_on_use = 0

/obj/item/voucher/free_item/glowing //This one gives you special voucher-only items!
	name = "glowing voucher"
	desc = "Don't bother appealing to a vendomat without this!"
	icon_state = "glowingvoucher"
	freebies = list(/obj/item/weapon/glowstick, /obj/item/weapon/glowstick/red, /obj/item/weapon/glowstick/blue, /obj/item/weapon/glowstick/yellow, /obj/item/weapon/glowstick/magenta)
	vend_amount = 5 //All five types
	single_items = 1 //One of each
	shred_on_use = 1

/obj/item/voucher/free_item/glowing/New()
	..()
	set_light(1.4,2,"#FFFF00")

/obj/item/voucher/free_item/glockammo
	name = "ammo voucher"
	desc = "Load up! Redeem at a SecTech for two magazines of criminal-stopping .380AUTO ammunition."
	icon_state = "secvoucher"
	freebies = list(/obj/item/ammo_storage/magazine/m380auto,/obj/item/ammo_storage/magazine/m380auto/rubber)
	vend_amount = 2
	single_items = 1

/obj/item/voucher/free_item/medical_safe
	name = "medibot voucher"
	desc = "Stay healthy! This voucher entitles you to a single (1) Nanotrasen Advanced Medibot! Redeem at a NanoMedPlus."
	icon_state = "medvoucher"
	freebies = list(/obj/item/weapon/medbot_cube)
	vend_amount = 1
	single_items = 1
