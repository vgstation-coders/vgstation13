/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = POINT357
	projectile_type = /obj/item/projectile/bullet
	w_type = RECYK_METAL

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = POINT50
	projectile_type = /obj/item/projectile/bullet
	w_type = RECYK_METAL

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = POINT357
	projectile_type = /obj/item/projectile/bullet/suffocationbullet
	w_type = RECYK_METAL

/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = POINT75
	projectile_type = /obj/item/projectile/bullet/gyro
	w_type = RECYK_METAL


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = POINT357
	projectile_type = /obj/item/projectile/bullet/cyanideround
	w_type = RECYK_METAL


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = POINT38
	projectile_type = /obj/item/projectile/bullet/weakbullet
	w_type = RECYK_METAL

/* Not entirely ready to be implemented yet. Get a server vote on bringing these in
/obj/item/ammo_casing/c38/lethal
	desc = "A .38 bullet casing. This is the lethal variant."
	caliber = POINT38
	projectile_type = /obj/item/projectile/bullet" //HAHA, why is this a good idea
	w_type = RECYK_METAL
*/



/obj/item/ammo_casing/c762x38r
	desc = "A 7.62x38mmR revolver bullet casing."
	caliber = NAGANTREVOLVER
	projectile_type = /obj/item/projectile/bullet/midbullet2
	w_type = RECYK_METAL

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = MM9
	projectile_type = /obj/item/projectile/bullet/midbullet2
	w_type = RECYK_METAL

/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = POINT45
	projectile_type = /obj/item/projectile/bullet/fourtyfive

/obj/item/ammo_casing/c45/practice
	desc = "A .45 practice bullet casing."
	caliber = POINT45
	projectile_type = /obj/item/projectile/bullet/fourtyfive/practice
	icon_state = "s-p-casing"

/obj/item/ammo_casing/c45/rubber
	desc = "A .45 rubber bullet casing."
	caliber = POINT45
	projectile_type = /obj/item/projectile/bullet/fourtyfive/rubber
	icon_state = "s-r-casing"

/obj/item/ammo_casing/c380auto
	desc = "A .380AUTO bullet casing."
	caliber = POINT380
	projectile_type = /obj/item/projectile/bullet/auto380

/obj/item/ammo_casing/c380auto/practice
	desc = "A .380AUTO practice bullet casing."
	caliber = POINT380
	projectile_type = /obj/item/projectile/bullet/auto380/practice
	icon_state = "s-p-casing"
	var/building = null

/obj/item/ammo_casing/c380auto/rubber
	desc = "A .380AUTO rubber bullet casing."
	caliber = POINT380
	projectile_type = /obj/item/projectile/bullet/auto380/rubber
	icon_state = "s-r-casing"
	
/obj/item/ammo_casing/c380auto/pepperball
	desc = "A .380AUTO pepperball bullet casing."
	caliber = POINT380
	projectile_type = /obj/item/projectile/bullet/pepperball

/obj/item/ammo_casing/lr22
	desc = "A .22LR bullet casing."
	caliber = NTLR22
	projectile_type = /obj/item/projectile/bullet/LR22
	icon_state = "p22-casing"

/obj/item/ammo_casing/a12mm
	desc = "A 12mm SPECIAL bullet casing."
	caliber = MM12
	projectile_type = /obj/item/projectile/bullet/midbullet
	w_type = RECYK_METAL

/obj/item/ammo_casing/a12mm/assault
	desc = "A standard 12mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/midbullet/assault

/obj/item/ammo_casing/a12mm/bounce
	desc = "A rubber-titanium 12mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/midbullet/bouncebullet

/obj/item/ammo_casing/shotgun
	name = "shotgun shell"
	desc = "A 12 gauge slug."
	icon_state = "gshell"
	caliber = GAUGE12
	projectile_type = /obj/item/projectile/bullet
	starting_materials = list(MAT_IRON = 250)
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/update_icon()
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"
	overlays = list()
	if(!BB)
		overlays += icon('icons/obj/ammo.dmi', "emptyshell")

/obj/item/ammo_casing/shotgun/blank
	name = "blank shell"
	desc = "A blank shell.  Does not contain any projectile material."
	icon_state = "blshell"
	projectile_type = /obj/item/projectile/bullet/blank
	starting_materials = list(MAT_IRON = 125)
	var/building = null
	
/obj/item/ammo_casing/shotgun/blank/attack_self(var/mob/living/user)
	..()
	if(building)
		to_chat(user,"<span class='notice'>You empty out \the [src].</span>")
		building = null
	
/obj/item/ammo_casing/shotgun/blank/attackby(obj/item/W, mob/user)
	..()
	if(building)
		if(building == "salt" && istype(W,/obj/item/weapon/paper))
			if(user.drop_item(W, src))
				user.create_in_hands(src, /obj/item/ammo_casing/shotgun/rocksalt, W, vismsg = "<span class='notice'>You stuff \the [W] into \the [src], finishing the new shell.</span>")			
		else
			to_chat(user,"<span class='warning'>\The [src] already has [building] in it.</span>")
			return
	else 
		if(istype(W,/obj/item/weapon/reagent_containers))
			var/obj/item/weapon/reagent_containers/R = W
			if(R.reagents.has_reagent(SODIUMCHLORIDE) || R.reagents.has_reagent(HOLYSALTS))
				if(R.reagents.has_reagent(HOLYSALTS,5))
					R.reagents.remove_reagent(HOLYSALTS,5)
					building = "salt"
					to_chat(user,"<span class='notice'>You add [building] to \the [src].</span>")
					return
				if(R.reagents.has_reagent(SODIUMCHLORIDE, 5))
					R.reagents.remove_reagent(SODIUMCHLORIDE,5)
					building = "salt"
					to_chat(user,"<span class='notice'>You add [building] to \the [src].</span>")
					return
				to_chat(user,"<span class='notice'>You need more salt to do this.</span>")
	
/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet/booze
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "A stunning shell."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns."
	icon_state = "blshell"
	projectile_type = /obj/item/projectile/bullet/dart
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge shell filled with standard double-aught buckshot."
	icon_state = "bsshell"
	projectile_type = /obj/item/projectile/bullet/buckshot
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragon's breath shell"
	desc = "A 12 gauge shell filled with an incendiary mixture, for lighting up dark areas or setting things on fire."
	icon_state = "bdbshell"
	projectile_type = /obj/item/projectile/bullet/fire_plume/dragonsbreath
	starting_materials = list(MAT_IRON = 250, MAT_PLASMA = 1000)

/obj/item/ammo_casing/shotgun/frag
	name = "explosive shell"
	desc = "A 12 gauge shell filled with a high-explosive mixture, for heavy anti-personnel usage."
	icon_state = "fragshell"
	projectile_type = /obj/item/projectile/bullet/boombullet
	starting_materials = list(MAT_IRON = 250, MAT_PLASMA = 4000)

/obj/item/ammo_casing/shotgun/rocksalt
	name = "rock-salt shell"
	desc = "A 12 gauge shell filled with a makeshift rock-salt slug, intended for riot control or battling the occult."
	icon_state = "rsshell"
	projectile_type = /obj/item/projectile/bullet/rocksalt
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/superbeanbag
	name = "super beanbag shell"
	desc = "An advanced less-lethal 12 gauge shell intended for asimov-compliant riot control."
	icon_state = "sbshell"
	projectile_type = /obj/item/projectile/bullet/superbeanbag
	starting_materials = list(MAT_IRON = 250)
	
/obj/item/ammo_casing/shotgun/concussiveblast
	name = "concussive blast shell"
	desc = "A less-lethal 12 gauge shell that produces a bright flash and loud noise shortly after leaving the muzzle."
	icon_state = "cbshell"
	projectile_type = /obj/item/projectile/bullet/concussiveblast
	starting_materials = list(MAT_IRON = 250)
	
/obj/item/ammo_casing/shotgun/pepperball
	name = "pepperball shell"
	desc = "A less-lethal 12 gauge shell containing a number of small pepperball rounds."
	icon_state = "pbshell"
	projectile_type = /obj/item/projectile/bullet/buckshot/pepperblast
	starting_materials = list(MAT_IRON = 250)

/obj/item/ammo_casing/shotgun/duckshot
	name = "duckshot shell"
	desc = "A novelty 12 gauge shell containing a number of plastic ducks and BBs. Warning: not a toy!"
	icon_state = "dsshell"
	projectile_type = /obj/item/projectile/bullet/buckshot/duckshot 
	starting_materials = list(MAT_IRON = 250)	
	
/obj/item/ammo_casing/a762
	desc = "A 7.62x51mm bullet casing."
	caliber = POINT762
	projectile_type = /obj/item/projectile/bullet
	w_type = RECYK_METAL

/obj/item/ammo_casing/BMG50
	desc = "A .50 BMG bullet casing."
	caliber = BROWNING50
	projectile_type = /obj/item/projectile/bullet/hecate
	w_type = RECYK_METAL
	icon_state = "l-casing"

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/bullet
	//select_name = "kinetic"
	//e_cost = 500
	//fire_sound = 'sound/weapons/Gunshot4.ogg'
	w_type = RECYK_METAL

/obj/item/ammo_casing/a762x55
	desc = "A 7.62x55mmR bullet casing."
	caliber = POINT762X55
	projectile_type = /obj/item/projectile/bullet/a762x55
	w_type = RECYK_METAL
	icon_state = "762x55-casing-live"
	starting_materials = list(MAT_IRON = 125)

/obj/item/ammo_casing/a762x55/update_icon()
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"
	if(!BB)
		icon_state = "762x55-casing"

/obj/item/ammo_casing/invisible
	desc = "An invisible bullet casing, it's hard to tell if it's been spent or not."
	projectile_type = /obj/item/projectile/bullet/invisible
	icon_state = null
