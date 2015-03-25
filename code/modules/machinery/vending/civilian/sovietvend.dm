//MOTHERBUSLAND
/obj/machinery/vending/sovietvend
	name = "KomradeVendtink"
	desc = "Rodina-mat' zovyot!"
	icon_state = "soviet"
	vend_reply = "The fascist and capitalist svin'ya shall fall komrade!"
	product_ads = "Quality worth waiting in line for!; Get Hammer and Sickled!; Sosvietsky soyuz above all!; With capitalist pigsky, you would have paid a fortunetink!"
	product_slogans = "Craftink in Motherland herself!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/clothing/shoes/jackboots = 20, /obj/item/clothing/head/squatter_hat = 20, /obj/item/clothing/under/squatter_outfit = 20, /obj/item/clothing/under/russobluecamooutfit = 20, /obj/item/clothing/head/russobluecamohat = 20)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 4, /obj/item/clothing/mask/balaclava = 4, /obj/item/clothing/suit/russofurcoat = 4, /obj/item/clothing/head/russofurhat = 4)

	pack = /obj/structure/vendomatpack/sovietvend

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | EMAGGABLE


/obj/machinery/vending/sovietvend/emag(mob/user)
	if(!emagged)
		user << "<span class='warning'>As you slide the emag on the machine, you can hear something unlocking inside, and the machine starts emitting an evil glow.</span>"
		message_admins("[key_name_admin(user)] unlocked a Sovietvend's DANGERMODE")
		contraband[/obj/item/clothing/head/helmet/space/rig/soviet] = 3
		contraband[/obj/item/clothing/suit/space/rig/soviet] = 3
		contraband[/obj/item/weapon/gun/energy/laser/LaserAK] = 4
		src.build_inventory(contraband, 1)
		emagged = 1
		overlays = 0
		var/image/dangerlay = image(icon,"[icon_state]-dangermode",LIGHTING_LAYER+1)
		overlays_vending[2] = dangerlay
		update_icon()
		return 1
	return

//SovietVend++
/obj/machinery/vending/sovietvend/DANGERMODE
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/clothing/shoes/jackboots = 20, /obj/item/clothing/head/squatter_hat = 20, /obj/item/clothing/under/squatter_outfit = 20, /obj/item/clothing/under/russobluecamooutfit = 20, /obj/item/clothing/head/russobluecamohat = 20)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 4, /obj/item/clothing/mask/balaclava = 4, /obj/item/clothing/suit/russofurcoat = 4, /obj/item/clothing/head/russofurhat = 4, /obj/item/clothing/head/helmet/space/rig/soviet = 3, /obj/item/clothing/suit/space/rig/soviet = 3, /obj/item/weapon/gun/energy/laser/LaserAK = 4)

	pack = /obj/structure/vendomatpack/sovietvend//can be reloaded with the same packs as the regular one

/obj/machinery/vending/sovietvend/DANGERMODE/New()
	..()
	emagged = 1
	overlays = 0
	var/image/dangerlay = image(icon,"[icon_state]-dangermode",LIGHTING_LAYER+1)
	overlays_vending[2] = dangerlay
	update_icon()