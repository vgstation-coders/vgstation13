//////////////////////
// molotov cocktail //
//  by Hinaichigo   //
//////////////////////

/obj/item/weapon/reagent_containers/food/drinks/beer
		var/molotov = 0
		var/lit = 0
		var/brightness_lit = 4
/obj/item/weapon/reagent_containers/food/drinks/beer/attackby(var/obj/item/I, mob/user as mob)
		if(istype(I, /obj/item/weapon/reagent_containers/glass/rag) && !molotov)  //obj/item/weapon/kitchen/utensil/fork
				user << "<span  class='notice'>You stuff the [I] into the mouth of the [src].</span>"
				del(I)
				flags ^= OPENCONTAINER
				molotov = 1
				name = "incendiary cocktail"
				desc = "A rag stuffed into a bottle."
				update_icon()
				slot_flags = SLOT_BELT
		else if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = I
				if(WT.isOn())
						light()
						update_brightness(user)
		else if(istype(I, /obj/item/weapon/lighter))
				var/obj/item/weapon/lighter/L = I
				if(L.lit)
						light()
						update_brightness(user)
		else if(istype(I, /obj/item/weapon/match))
				var/obj/item/weapon/match/M = I
				if(M.lit)
						light()
						update_brightness(user)
		else if(istype(I, /obj/item/device/assembly/igniter))
				var/obj/item/candle/C = I
				if(C.lit)
						light()
						update_brightness(user)
		else if(istype(I, /obj/item/clothing/mask/cigarette))
				var/obj/item/candle/C = I
				if(C.lit)
						light()
						update_brightness(user)
		else if(istype(I, /obj/item/candle))
				var/obj/item/candle/C = I
				if(C.lit)
						light()
						update_brightness(user)
		return

/obj/item/weapon/reagent_containers/food/drinks/beer/proc/light(var/flavor_text = "\red [usr] lights the [name].")
		if(!src.lit && src.molotov)
				src.lit = 1
				for(var/mob/O in viewers(usr, null))
						O.show_message(flavor_text, 1)
				processing_objects.Add(src)
				update_icon()

/obj/item/weapon/reagent_containers/food/drinks/beer/proc/update_brightness(var/mob/user = null)
	if(lit)
		if(loc == user)
			user.SetLuminosity(user.luminosity + brightness_lit)
		else if(isturf(loc))
			SetLuminosity(brightness_lit)
	else
		if(loc == user)
			user.SetLuminosity(user.luminosity - brightness_lit)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/weapon/reagent_containers/food/drinks/beer/pickup(mob/user)
	if(lit)
		user.SetLuminosity(user.luminosity + brightness_lit)
		SetLuminosity(0)


/obj/item/weapon/reagent_containers/food/drinks/beer/dropped(mob/user)
	if(lit)
		user.SetLuminosity(user.luminosity - brightness_lit)
		SetLuminosity(brightness_lit)

/obj/item/weapon/reagent_containers/food/drinks/beer/throw_impact(atom/hit_atom)
		..()
		if(molotov)
				new /obj/item/weapon/shard(src.loc)
				src.visible_message("\red The [src.name] shatters!","\red You hear a shatter!")
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, 1)
				if(reagents.total_volume)
						src.reagents.reaction(hit_atom, TOUCH)
						spawn(5) src.reagents.clear_reagents()
				invisibility = INVISIBILITY_MAXIMUM
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, src.loc)
				spark_system.start()
				spawn(50)
						del(src)

/obj/item/weapon/reagent_containers/food/drinks/beer/process()
		var/turf/loca = get_turf(src)
		if(lit)
				loca.hotspot_expose(700, 1000)
		return


/obj/item/weapon/reagent_containers/food/drinks/beer/update_icon()
		..()
		overlays.Cut()
		if(molotov)
				overlays += image('icons/obj/grenade.dmi', icon_state = "molotov_rag")
		if(molotov && lit)
				overlays += image('icons/obj/grenade.dmi', icon_state = "molotov_fire") //todo: make lit sprite
		else
				item_state = initial(item_state)
		if(ishuman(src.loc))
				var/mob/living/carbon/human/H = src.loc
				H.update_inv_belt()



////////  Could be expanded upon:
//  make it work with more chemicals and reagents, more like a chem grenade
//  only allow the bottle to be stuffed if there are certain reagents inside, like fuel
//  different flavor text for different means of lighting
//  new fire overlay - current is edited version of the IED one
//  a chance to not break, if desired
//  fingerprints appearing on the object, which might already happen, and the shard
//  belt sprite and new hand sprite
//	ability to put out with water or otherwise
//	burn out after a time causing the contents to ignite
//	different refuse upon breaking, such as a broken bottle
//	generalize to all bottles
//	some easy way of obtaining or making rags such as by cutting up sheets
//	make into its own item type so they could be spawned full of fuel with New()
//	the rag can store chemicals as well so maybe the rag's chemicals could react with the bottle's chemicals before or upon breaking