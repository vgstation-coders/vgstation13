/obj/item/weapon/storage/box/syndicate/
	New()
		..()
		var/tagname = pickweight(list("bloodyspai" = 100, "stealth" = 100, "screwed" = 100, "guns" = 100, "murder" = 100, "freedom" = 100, "hacker" = 100, "lordsingulo" = 100, "smoothoperator" = 100, "psycho" = 100, "hotline" = 100, "balloon" = 1))

		switch (tagname)
			if("bloodyspai")
				new /obj/item/clothing/under/chameleon(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)

			if("stealth")
				new /obj/item/weapon/gun/energy/crossbow(src)
				new /obj/item/weapon/pen/paralysis(src)
				new /obj/item/device/chameleon(src)


			if("screwed")
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/effect/spawner/newbomb/timer/syndicate(src)
				new /obj/item/device/powersink(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)


			if("guns")
				new /obj/item/weapon/gun/projectile(src)
				new /obj/item/ammo_storage/box/a357(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/plastique(src)


			if("murder")
				new /obj/item/weapon/melee/energy/sword(src)
				new /obj/item/clothing/glasses/thermal/syndi(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/clothing/shoes/syndigaloshes(src)
				new /obj/item/weapon/storage/belt/skull(src)


			if("freedom")
				var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
				O.imp = new /obj/item/weapon/implant/freedom(O)
				O.update()
				O.name= "Freedom"
				var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
				U.imp = new /obj/item/weapon/implant/uplink(U)
				U.update()
				U.name = "Uplink"


			if("hacker")
				new /obj/item/weapon/aiModule/freeform/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/device/encryptionkey/binary(src)


			if("lordsingulo")
				new /obj/item/beacon/syndicate(src)
				new /obj/item/clothing/suit/space/syndicate(src)
				new /obj/item/clothing/head/helmet/space/syndicate(src)
				new /obj/item/weapon/card/emag(src)


			if("smoothoperator")
				new /obj/item/weapon/gun/projectile/pistol(src)
				new /obj/item/gun_part/silencer(src)
				new /obj/item/clothing/gloves/knuckles/spiked(src)
				new /obj/item/weapon/soap/syndie(src)
				new /obj/item/weapon/storage/bag/trash(src)
				new /obj/item/bodybag(src)
				new /obj/item/clothing/under/suit_jacket(src)
				new /obj/item/clothing/shoes/laceup(src)


			if("psycho")
				new /obj/item/clothing/suit/raincoat(src)
				new /obj/item/clothing/under/suit_jacket(src)
				new /obj/item/weapon/soap/syndie(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/weapon/card/id/syndicate(src)
				new /obj/item/weapon/card/emag(src)
				new /obj/item/weapon/newspaper(src)
				new /obj/item/weapon/fireaxe(src)


			if("hotline")
				new /obj/item/clothing/under/bikersuit(src)
				new /obj/item/clothing/head/helmet/biker(src)
				new /obj/item/clothing/shoes/mime/biker(src)
				new /obj/item/clothing/gloves/bikergloves(src)
				new /obj/item/clothing/mask/gas/voice(src)
				new /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver(src)
				new /obj/item/weapon/storage/pill_bottle/hyperzine(src)
				new /obj/item/weapon/card/id/syndicate(src)


			if("balloon")
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
				new /obj/item/toy/syndicateballoon(src)
		tag = tagname


/obj/item/weapon/storage/box/syndie_kit
	name = "Box"
	desc = "A sleek, sturdy box"
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "Freedom Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/imp_compress/New()
	new /obj/item/weapon/implanter/compressed(src)
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"

/obj/item/weapon/storage/box/syndie_kit/imp_explosive/New()
	new /obj/item/weapon/implanter/explosive(src)
	..()
	return

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "Uplink Implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/New()
	..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()
	return

/obj/item/weapon/storage/box/syndie_kit/space
	name = "Space Suit and Helmet"

/obj/item/weapon/storage/box/syndie_kit/space/New()
	..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	return

/obj/item/weapon/storage/box/syndie_kit/surveillance
	name = "box (S)"

/obj/item/weapon/storage/box/syndie_kit/surveillance/New()
	..()
	new /obj/item/device/handtv(src)
	new /obj/item/weapon/storage/box/surveillance(src)
	return

/obj/item/weapon/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/weapon/storage/box/syndie_kit/conversion/New()
	..()
	new /obj/item/weapon/conversion_kit(src)
	new /obj/item/ammo_storage/box/a357(src)
	return

/obj/item/weapon/storage/box/syndie_kit/greytide
	name = "box (GT)"

	New()
		..()
		var/obj/item/weapon/implanter/O = new(src)
		O.imp = new /obj/item/weapon/implant/traitor(O)
		O.update()

/obj/item/weapon/storage/box/syndie_kit/boolets
	name = "Shotgun shells"

	New()
		..()
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)
		new /obj/item/ammo_casing/shotgun/fakebeanbag(src)

/obj/item/weapon/storage/box/syndie_kit/ammo
	name = "box (spare ammo)"

/obj/item/weapon/storage/box/syndie_kit/ammo/New()
	..()
	new /obj/item/ammo_storage/speedloader/a357(src)
	return

/obj/item/weapon/storage/box/syndie_kit/flaregun
	name = "box (modified flare gun)"

/obj/item/weapon/storage/box/syndie_kit/flaregun/New()
	..()
	new /obj/item/weapon/gun/projectile/flare/syndicate(src)
	new /obj/item/ammo_storage/box/flare(src)
	return

/obj/item/weapon/storage/box/syndie_kit/explosive_hug
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/explosive_hug/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/antisocial(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	return
