//jungle map.
#define T_JUNGLE 323 // 121.8 f / 49.85 c. it's hot out there.
#define JUNGLE_PRESSURE 1.2*ONE_ATMOSPHERE
#define MOLES_JUNGLE_STD (JUNGLE_PRESSURE*CELL_VOLUME/(T_JUNGLE*R_IDEAL_GAS_EQUATION)) // pressure is 3.25 atm. enough to be noticable, but not enough to be dangerous.
#define MOLES_JUNGLE_O2_STD (MOLES_JUNGLE_STD*0.5/JUNGLE_PRESSURE/ONE_ATMOSPHERE) // 0.5 atm PP. this is to remove the possability of oxygen toxicity. not that it matters, since spessmen has magic lungs.
#define MOLES_JUNGLE_CO2_STD 0.02*MOLES_JUNGLE_STD // for flavor. needs to be the lowest of 5 moles or .02. 5 moles because simplemobs break, .02 because muh immulsions.
#define MOLES_JUNGLE_N2_STD (MOLES_JUNGLE_STD-MOLES_JUNGLE_O2_STD-MOLES_JUNGLE_CO2_STD) // backfill the rest with N2, because there's no other inert gas.



var/list/foliage_choices=list(
/obj/structure/flora/ausbushes,
/obj/structure/flora/ausbushes/brflowers,
/obj/structure/flora/ausbushes/fernybush,
/obj/structure/flora/ausbushes/fullgrass,
/obj/structure/flora/ausbushes/genericbush,
/obj/structure/flora/ausbushes/grassybush,
/obj/structure/flora/ausbushes/lavendergrass,
/obj/structure/flora/ausbushes/leafybush,
/obj/structure/flora/ausbushes/palebush,
/obj/structure/flora/ausbushes/pointybush,
/obj/structure/flora/ausbushes/ppflowers,
/obj/structure/flora/ausbushes/reedbush,
/obj/structure/flora/ausbushes/sparsegrass,
/obj/structure/flora/ausbushes/stalkybush,
/obj/structure/flora/ausbushes/sunnybush,
/obj/structure/flora/jungle_berries,
)

var/list/foliage_replacments=list(
/obj/structure/flora/rock,
/obj/structure/flora/rock/pile,
)

/turf/unsimulated/floor/planetary/grass/jungle
	name="Dense Grass"
	desc="A thick and lush carpet of various plant species, sustained by a regular supply to water."
	icon='icons/turf/floors.dmi'
	icon_state = "grass_jungle1"
	base_icon_state = "grass_jungle"
	variance = 100
	min_icon_states = 1
	max_icon_states = 4
	edge_flags = ALL_EDGES
	edge_priority = GRASS_EDGE_PRIORITY
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane=PLATING_PLANE
	intact=0
	pickaxe_conversion_turf = /turf/unsimulated/floor/planetary/dirt/jungle
	pickaxe_conversion_time = 2 SECONDS

/turf/unsimulated/floor/planetary/grass/jungle/New(var/loc)
	..()
	generate_foliage()

/turf/unsimulated/floor/planetary/grass/jungle/proc/generate_foliage()
	if (prob(50))
		if(prob(10)) //10% chance to replace with rocks or some shit. 5% over all
			var/rep=pick(foliage_replacments)
			turf_speed_multiplier+=0.6
			return new rep(src)
		else //45% over all
			var/plantseed = abs(( sin((x+rand(-2,2))*5.01+213.998) + sin((y+rand(-2,2))*4.56+71.294) )%%1.0)
			plantseed = 1+floor(plantseed*(foliage_choices.len-0.01))//mmm, dumb float math

			var/create=foliage_choices[plantseed]
			if(create)
				turf_speed_multiplier+=0.6
				return new create(src)
	else if(prob(50)) //25% overall
		if( !(locate(/obj/structure/flora/tree) in range(2,src)) )
			return new/obj/structure/flora/tree/shitty(src)

/turf/unsimulated/floor/planetary/grass/jungle/Destroy()
	..()
	for(var/obj/structure/flora/F in contents)
		qdel(F)

/turf/unsimulated/floor/planetary/grass/jungle/no_flora
	icon_state="grass_alt1" //uses an alt texture at first so that it appears different while mapping. this will correct itself when it spawns.

/turf/unsimulated/floor/planetary/grass/jungle/no_flora/generate_foliage()
	return

/turf/unsimulated/floor/planetary/mud/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD


/turf/unsimulated/floor/planetary/concrete/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD


/turf/unsimulated/floor/planetary/dirt/jungle
	name="Soil"
	desc="A mixture of sediments, clays, and decomposed matter."
	icon='icons/turf/floors.dmi'
	icon_state = "ironsand1"
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane=PLATING_PLANE
	shovel_conversion_turf = /turf/unsimulated/floor/planetary/path/jungle
	shovel_conversion_time = 2 SECONDS
	var/obj/structure/ladder/jungle_tunnel/hashole=null

/turf/unsimulated/floor/planetary/dirt/jungle/examine()
	..()
	if(hashole)
		to_chat(usr,"there's a hole leading underground.")

/turf/unsimulated/floor/planetary/dirt/jungle/item_shovel_ability(var/obj/item/I,var/mob/user) //prevent turf conversion if there's a hole
	if(hashole)
		return 0.0
	return ..()

/turf/unsimulated/floor/planetary/dirt/jungle/shovel_modify(var/obj/item/I,var/mob/user,var/speedfactor=1.0)
	to_chat(user, "<span class='notice'>You start packing down \the [src]</span>")
	if(do_after(user, src, shovel_conversion_time/speedfactor ))
		ChangeTurf(shovel_conversion_turf)
		return TRUE
	else
		return FALSE

/turf/unsimulated/floor/planetary/dirt/jungle/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/grass && !hashole)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			ChangeTurf(/turf/unsimulated/floor/planetary/grass/jungle/no_flora)
			return TRUE
		return FALSE
	var/s=item_pickaxe_ability(C,user)
	if(s>0.0 && !hashole && can_dig_down(user) )
		to_chat(usr,"you start digging downwards...")
		if(do_after(user, src, 80/s ))
			if(!hashole)
				to_chat(usr,"you finish making a hole.")
				var/obj/structure/ladder/jungle_tunnel/l_surf=new(src)
				var/obj/structure/ladder/jungle_tunnel/l_tunnel=new(locate(x,y, z==1 ? 2 : 6))
				l_tunnel.up=l_surf
				l_surf.down=l_tunnel
				hashole=l_surf
				var/turf/T2=locate(x,y,z==1 ? 2 : 6)
				T2?.ChangeTurf(/turf/unsimulated/floor/planetary/cave/jungle)
				var/turf/unsimulated/floor/planetary/cave/jungle/TT=T2
				TT?.hashole=l_tunnel
				return TRUE
		return FALSE
	if(C.type== /obj/item/stack/ore/glass && hashole)
		var/obj/item/stack/ore/glass/T = C
		if(T.amount<25)
			to_chat(usr,"you need 25 sand to do this!")
			return
		to_chat(usr,"you start filling the hole back with soil...")
		if(do_after(user, src, 80 ))
			if(T.use(25))
				to_chat(usr,"you fill the hole back with soil.")
				var/turf/T2=hashole.down.loc
				T2?.ChangeTurf(/turf/unsimulated/mineral/jungle_underground)
				qdel(hashole.down)
				qdel(hashole)
				hashole=null
				return TRUE
		return FALSE
	return ..()

/turf/unsimulated/floor/planetary/dirt/jungle/proc/can_dig_down(var/mob/user=null)
	var/turf/T=locate(x,y,z==1 ? 2 : 6)
	if(istype(T,/turf/unsimulated/floor/planetary))
		return TRUE	
	if(istype(T,/turf/unsimulated/mineral))
		return TRUE
	if(user)
		to_chat(user,"<span class='warning'>Something hard blocks you from digging downwards.</span>")
	return FALSE

/turf/unsimulated/floor/planetary/dirt/jungle/no_dig

/turf/unsimulated/floor/planetary/dirt/jungle/no_dig/can_dig_down(var/mob/user=null)
	return FALSE

/turf/unsimulated/floor/planetary/path/jungle
	name="Compressed Dirt"
	desc="Soil which has been pressed down into a hard, smooth surface."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroid0"
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane=PLATING_PLANE
	intact=0 //allows cables to be placed
	pickaxe_conversion_turf=/turf/unsimulated/floor/planetary/dirt/jungle
	pickaxe_conversion_time=2 SECONDS

/turf/unsimulated/floor/planetary/path/jungle/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/metal && !(locate(/obj/structure/lattice) in loc.contents ))
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ChangeTurf(/turf/unsimulated/floor/planetary/path/jungle_plated)
			plane=PLATING_PLANE
			remove_paint_overlay()
			update_icon()
			update_paint_overlay()
			levelupdate()
			return TRUE
		return FALSE
	return ..()

/turf/unsimulated/floor/planetary/path/jungle/can_place_cables()
	return TRUE



/turf/unsimulated/floor/planetary/path/jungle/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/unsimulated/floor/planetary/dirt/jungle)
		if(2)
			if(prob(66))
				ChangeTurf(/turf/unsimulated/floor/planetary/dirt/jungle)
		if(3)
			if(prob(33))
				ChangeTurf(/turf/unsimulated/floor/planetary/dirt/jungle)


/turf/unsimulated/floor/planetary/path/jungle_plated
	name="Plated Soil"
	desc="Compressed soil which has plated atop it to protect items underneath it."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroidfloor"
	plane = TURF_PLANE
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD

/turf/unsimulated/floor/planetary/path/jungle_plated/New()
	..()
	if(plated_icon_override_icon)
		icon=plated_icon_override_icon
	if(plated_icon_override_state)
		icon_state=plated_icon_override_state

/turf/unsimulated/floor/planetary/path/jungle_plated/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(!C || !user)
		return 0
	if(iscrowbar(C))
		ChangeTurf(/turf/unsimulated/floor/planetary/path/jungle)
		new /obj/item/stack/tile/metal(src,1)
		plane=PLATING_PLANE
		remove_paint_overlay()
		update_icon()
		update_paint_overlay()
		levelupdate()
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/unsimulated/floor/planetary/path/jungle_plated/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/unsimulated/floor/planetary/path/jungle)
		if(2)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/planetary/path/jungle)
		if(3)
			if(prob(20))
				ChangeTurf(/turf/unsimulated/floor/planetary/path/jungle)


	
/turf/unsimulated/floor/planetary/water/jungle
	name="Water"
	desc="It's about knee-height. Probably not safe to drink from."
	backing_trurf_icon='icons/turf/planetary/jungle.dmi'
	backing_trurf_state = "mud"
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane=PLATING_PLANE

/turf/unsimulated/floor/planetary/water/jungle/deep
	name="Deep Water"
	desc="It's nearly up to your shoulders. Probably not safe to drink from."
	icon_state = "water2"
	turf_speed_multiplier=2.5
	turf_reagent_amount = 10
	base_icon_state = "deepjunglewater" // to re-create the icon, take the water5 set, then adjust the alpha so that it has full opaque at the dark parts, THEN you need to run it through chroma and lightness, 0, -70, -68. THEN THEN you make the icon have 35% opacity AND THEN AND ONLY THEN do you have  your complete usable icon thank you byond very cool
	edge_priority = DEEPWATER_EDGE_PRIORITY
	edge_overlay_type = /obj/effect/edge_overlay/water/deep
	water_overlay_state="water2"
	
/turf/unsimulated/floor/planetary/water/jungle/deep/New()
	..()
	wateroverlay.plane=MOB_PLANE


/turf/unsimulated/floor/planetary/sand/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD



/turf/unsimulated/mineral/jungle_underground
	name="Packed Soil"
	desc="Solid dirt as far as the eye can see."
	icon='icons/turf/walls.dmi'
	icon_state = "j_dirtwall"
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	mineral=null

/turf/unsimulated/mineral/jungle_underground/New()
	..()
	mineral_turfs-=src
	icon_state = "j_dirtwall"
	overlays=list()
	var/image/img = image('icons/turf/rock_overlay.dmi', "dirt_overlay",layer = SIDE_LAYER)
	img.pixel_x = -4*PIXEL_MULTIPLIER
	img.pixel_y = -4*PIXEL_MULTIPLIER
	img.plane = BELOW_PLATING_PLANE
	overlays += img

/turf/unsimulated/mineral/jungle_underground/ex_act(severity)
	switch(severity)
		if(1)
			generate_loot()
			ChangeTurf(/turf/unsimulated/floor/planetary/cave/jungle)
		if(2)
			if(prob(50))
				generate_loot()
				ChangeTurf(/turf/unsimulated/floor/planetary/cave/jungle)


/turf/unsimulated/mineral/jungle_underground/proc/gettooleffectivness(var/obj/item/I,var/mob/user) //either a pickaxe or shovel
	if(!I || !user)
		return 0.0
	if(istype(I,/obj/item/weapon/pickaxe))
		return (1/I.toolspeed)/2.5 //default toolspeed is 0.4. do this math because lower=faster, but we want higher=faster.
	if(istype(I,/obj/item/tool/crowbar))
		if(istype(I,/obj/item/tool/crowbar/halligan)) //halligans have a pick end.
			return 0.75
		return 0.5
	if(istype(I,/obj/item/weapon/kitchen/utensil))
		return 0.1
	return 0.0

/turf/unsimulated/mineral/jungle_underground/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	var/s=gettooleffectivness(C,user)
	if(s>0.0)
		to_chat(user,"<span class='notice'>You begin to break apart the soil...</span>")
		if(do_after(user, src, 30/s ))
			generate_loot(C,user)
			ChangeTurf(/turf/unsimulated/floor/planetary/cave/jungle)
			return
	return ..()


/turf/unsimulated/mineral/jungle_underground/proc/generate_loot(var/obj/item/C, var/mob/user)
	new/obj/item/stack/ore/glass(src,25) //theres no dirt, so we use sand instead.
	if(!user)
		return
	if (user.lucky_prob_rand()>0.5) //50% base chance
		var/r=rand()
		if(r<0.40)
			new/obj/item/stack/ore/iron(src,user.lucky_prob_rand_range(1,9))
		else if(r<0.55)
			new/obj/item/stack/ore/diamond(src,user.lucky_prob_rand_range(1,3))
		else if(r<0.70)
			new/obj/item/stack/ore/gold(src,user.lucky_prob_rand_range(1,5))
		else if(r<0.85)
			new/obj/item/stack/ore/silver(src,user.lucky_prob_rand_range(1,7))
		else
			new/obj/item/stack/ore/uranium(src,user.lucky_prob_rand_range(1,3))
	return

/turf/unsimulated/mineral/jungle_underground/Bumped(AM)
	. = ..()

	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(istype(H.get_active_hand(),/obj/item/weapon/pickaxe) || istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe)) //prevents double attacking the same turf because parent proc covers this
			return
		if(gettooleffectivness(H.get_active_hand(),H))
			attackby(H.get_active_hand(), H)
		else if(gettooleffectivness(H.get_inactive_hand(),H))
			attackby(H.get_inactive_hand(), H)

/turf/unsimulated/mineral/jungle_underground/MineralSpread() //do nothing
	return

/turf/unsimulated/mineral/jungle_underground/crate_loot
	icon_state="rock(high)"

/turf/unsimulated/mineral/jungle_underground/crate_loot/New()
	icon_state="j_dirtwall"
	..()

/turf/unsimulated/mineral/jungle_underground/crate_loot/generate_loot(var/obj/item/C, var/mob/user)
	..()
	if(user.lucky_prob_rand()>0.996) //0.4% chance (1 in 250). affected by luck, naturally.
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		var/ctype=pick(valid_abandoned_crate_types)
		new ctype(src)

/turf/unsimulated/floor/planetary/cave/jungle
	name="Bedrock"
	desc="A very dense rock. Nothing seems to be able to dig through it."
	icon='icons/turf/walls.dmi'
	icon_state = "j_rockfloor"
	plane=PLATING_PLANE
	intact=0 //allows cables to be placed
	var/obj/structure/ladder/jungle_tunnel/hashole=null


/turf/unsimulated/floor/planetary/cave/jungle/New(var/loc)
	..()
	update_icon()

/turf/unsimulated/floor/planetary/cave/jungle/update_icon()
	icon_state = "j_rockfloor"
	overlays=list()
	if(locate(/obj/structure/ladder/jungle_tunnel) in contents)
		overlays+=image('icons/turf/walls.dmi', "j_rfloor_overlay_l")
	else if(cannot_dig_up())
		overlays+=image('icons/turf/walls.dmi', "j_rfloor_overlay_d")


/turf/unsimulated/floor/planetary/cave/jungle/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	var/s=item_pickaxe_ability(C,user)
	if(s>0.0 && !hashole)
		if(!cannot_dig_up() )
			to_chat(usr,"you start digging upwards...")
			if(do_after(user, src, 80/s ))
				if(!hashole && !cannot_dig_up() )
					to_chat(usr,"you finish making a hole.")

					var/obj/structure/ladder/jungle_tunnel/l_tunnel=new(src)
					var/obj/structure/ladder/jungle_tunnel/l_surf=new(locate(x,y,z==2 ? 1 : 4))

					update_icon()

					l_tunnel.up=l_surf
					l_surf.down=l_tunnel

					var/turf/T2=locate(x,y,z==2 ? 1 : 4)
					T2?.ChangeTurf(/turf/unsimulated/floor/planetary/dirt/jungle)
					var/turf/unsimulated/floor/planetary/dirt/jungle/TT=T2
					TT?.hashole=l_surf
					hashole=l_tunnel
					return TRUE
				else
					update_icon()
					to_chat(usr,"something gets in your way.")
		else
			to_chat(usr,cannot_dig_up())
			update_icon()
		return FALSE
	return ..()

/turf/unsimulated/floor/planetary/cave/jungle/examine()
	..()
	if(cannot_dig_up())
		to_chat(usr,cannot_dig_up())
		return
	if(locate(/obj/structure/ladder/jungle_tunnel) in contents)
		to_chat(usr,"there's a hole leading to the surface.")


//we also use enter to reveal tiles, since the tile above could change.
/turf/unsimulated/floor/planetary/cave/jungle/Entered(var/atom/movable/Obj)
	..()
	update_icon()

	//we reveal the state of surrounding bedrock. there was a better way to do this. how did i forget to use range?
	for(var/turf/unsimulated/floor/planetary/cave/jungle/B in orange(1))
		B.update_icon()


/turf/unsimulated/floor/planetary/cave/jungle/proc/cannot_dig_up()
	var/turf/T=locate(x,y,z==2 ? 1 : 4)
	if(!istype(T,/turf/unsimulated/floor/planetary))
		return "something hard blocks the way."
	var/turf/unsimulated/floor/planetary/JT = T
	if(istype(JT,/turf/unsimulated/floor/planetary/water))
		return "this feels like a really bad idea..."
	if(istype(JT,/turf/unsimulated/floor/planetary/path/jungle_plated))
		return "something hard blocks the way."
	if(istype(JT,/turf/unsimulated/floor/planetary/concrete))
		return "something hard blocks the way."	
	if(locate(/obj/structure/flora/tree) in T.contents)
		return "there's too many roots in the way."
	for(var/obj/O in T.contents)
		if(O.density && O.anchored)
			return "something hard blocks the way."	
	return null

/turf/unsimulated/floor/planetary/cave/jungle/ex_act(severity)
	return

/turf/unsimulated/floor/planetary/cave/jungle/can_place_cables()
	return TRUE


/turf/unsimulated/floor/planetary/cave/jungle/no_dig

/turf/unsimulated/floor/planetary/cave/jungle/no_dig/cannot_dig_up()
	return TRUE
/turf/unsimulated/floor/planetary/cave/jungle/no_dig/update_icon()
	..()
	overlays=list()

//so mining the planetside roid doesn't cause ZAS hell
/turf/unsimulated/mineral/random/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	mined_type = /turf/unsimulated/floor/planetary/path/jungle

/turf/unsimulated/mineral/random/high_chance/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	mined_type = /turf/unsimulated/floor/planetary/path/jungle

/turf/unsimulated/floor/planetary/wasteland/jungle
	name="wasteland"
	desc="A dry, cracked surface with little vegetation."
	icon = 'icons/turf/planetary/jungle.dmi'
	icon_state = "wasteland"
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane=PLATING_PLANE

/turf/unsimulated/floor/planetary/wasteland/jungle/New()
	..()
	icon_state="wasteland[rand(0,12)]"


#undef T_JUNGLE
#undef JUNGLE_PRESSURE
#undef MOLES_JUNGLE_STD
#undef MOLES_JUNGLE_O2_STD
#undef MOLES_JUNGLE_CO2_STD
#undef MOLES_JUNGLE_N2_STD
