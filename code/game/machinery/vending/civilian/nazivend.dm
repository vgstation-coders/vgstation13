//HEIL ADMINBUS
/obj/machinery/vending/nazivend
	name = "Nazivend"
	desc = "Remember the gorrilions lost."
	icon_state = "nazi"
	vend_reply = "SIEG HEIL!"
	product_ads = "BESTRAFEN die Juden.;BESTRAFEN die Alliierten."
	product_slogans = "Das Vierte Reich wird zuruckkehren!;ENTFERNEN JUDEN!;Billiger als die Juden jemals geben!;Rader auf dem adminbus geht rund und rund.;Warten Sie, warum wir wieder hassen Juden?- *BZZT*"
	products = list(/obj/item/clothing/head/stalhelm = 20, /obj/item/clothing/head/panzer = 20, /obj/item/clothing/suit/soldiercoat = 20, /obj/item/clothing/under/soldieruniform = 20, /obj/item/clothing/shoes/jackboots = 20)
	contraband = list(/obj/item/clothing/head/naziofficer = 10, /obj/item/clothing/suit/officercoat = 10, /obj/item/clothing/under/officeruniform = 10)

	pack = /obj/structure/vendomatpack/nazivend

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EJECTNOTDEL | EMAGGABLE
	
/obj/machinery/vending/nazivend/emag(mob/user)
	if(!emagged)
		user << "<span class='warning'>As you slide the emag on the machine, you can hear something unlocking inside, and the machine starts emitting an evil glow.</span>"
		message_admins("[key_name_admin(user)] unlocked a Nazivend's DANGERMODE")
		contraband[/obj/item/clothing/head/helmet/space/rig/nazi] = 3
		contraband[/obj/item/clothing/suit/space/rig/nazi] = 3
		contraband[/obj/item/weapon/gun/energy/plasma/MP40k] = 4
		src.build_inventory(contraband, 1)
		emagged = 1
		overlays = 0
		var/image/dangerlay = image(icon,"[icon_state]-dangermode",LIGHTING_LAYER+1)
		overlays_vending[2] = dangerlay
		update_icon()
		return 1
	return

//NaziVend++
/obj/machinery/vending/nazivend/DANGERMODE
	products = list(/obj/item/clothing/head/stalhelm = 20, /obj/item/clothing/head/panzer = 20, /obj/item/clothing/suit/soldiercoat = 20, /obj/item/clothing/under/soldieruniform = 20, /obj/item/clothing/shoes/jackboots = 20)
	contraband = list(/obj/item/clothing/head/naziofficer = 10, /obj/item/clothing/suit/officercoat = 10, /obj/item/clothing/under/officeruniform = 10, /obj/item/clothing/head/helmet/space/rig/nazi = 3, /obj/item/clothing/suit/space/rig/nazi = 3, /obj/item/weapon/gun/energy/plasma/MP40k = 4)

	pack = /obj/structure/vendomatpack/nazivend //can be reloaded with the same packs as the regular one

/obj/machinery/vending/nazivend/DANGERMODE/New()
	..()
	emagged = 1
	overlays = 0
	var/image/dangerlay = image(icon,"[icon_state]-dangermode",LIGHTING_LAYER+1)
	overlays_vending[2] = dangerlay
	update_icon()