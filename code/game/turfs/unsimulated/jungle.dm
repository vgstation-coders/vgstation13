//jungle map.
#define T_JUNGLE 323 // 121.8 f / 49.85 c. it's hot out there.
#define JUNGLE_PRESSURE 1.2*ONE_ATMOSPHERE
#define MOLES_JUNGLE_STD (JUNGLE_PRESSURE*CELL_VOLUME/(T_JUNGLE*R_IDEAL_GAS_EQUATION)) // pressure is 3.25 atm. enough to be noticable, but not enough to be dangerous.
#define MOLES_JUNGLE_O2_STD (MOLES_JUNGLE_STD*0.5/JUNGLE_PRESSURE/ONE_ATMOSPHERE) // 0.5 atm PP. this is to remove the possability of oxygen toxicity. not that it matters, since spessmen has magic lungs.
#define MOLES_JUNGLE_CO2_STD 0.02*MOLES_JUNGLE_STD // for flavor. needs to be the lowest of 5 moles or .02. 5 moles because simplemobs break, .02 because muh immulsions.
#define MOLES_JUNGLE_N2_STD (MOLES_JUNGLE_STD-MOLES_JUNGLE_O2_STD-MOLES_JUNGLE_CO2_STD) // backfill the rest with N2, because there's no other inert gas.





//floors

/turf/unsimulated/floor/jungle
	temperature = T_JUNGLE
	oxygen = MOLES_JUNGLE_O2_STD
	nitrogen = MOLES_JUNGLE_N2_STD
	carbon_dioxide = MOLES_JUNGLE_CO2_STD
	plane = PLATING_PLANE
	intact=0
	var/DIGGING_BLOCKED = null // null = you can dig upwards when underground. otherwise, it's a string which is displayed to the user when they try to.
	var/plated_icon_override=null //used for the name plaque. NT COLONY Γ 8. in case you were wondering what font it uses: Liberation Sans Regular, 24pt. use two layers. one is #343434 and is above another that is #767676, offset by 1 pixel x and y.
	var/construction_allowed=FALSE //if we can add lattices and turn this into plating


/turf/unsimulated/floor/jungle/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	var/former_icoover=plated_icon_override
	.=..()
	if(.)
		var/turf/T=.
		if(istype(T,/turf/unsimulated/floor/jungle))
			var/turf/unsimulated/floor/jungle/JT=T
			JT.plated_icon_override=former_icoover
			if(former_icoover && istype(T,/turf/unsimulated/floor/jungle/path_plated))
				JT.icon_state=former_icoover

//gets drops when mined.
/turf/unsimulated/floor/jungle/proc/generate_loot(obj/item/C as obj, mob/user as mob)
	return

//returns 0.0 if it cannot. otherwise, returns a number as the object's tool speed.
/turf/unsimulated/floor/jungle/proc/item_terraforming_ispickaxe(obj/item/C)
	if(istype(C,/obj/item/weapon/pickaxe) && !istype(C,/obj/item/weapon/pickaxe/shovel))
		return (1/C.toolspeed)/2.5 //default toolspeed is 0.4. do this math because lower=faster, but we want higher=faster.
	if(istype(C,/obj/item/tool/crowbar))
		if(istype(C,/obj/item/tool/crowbar/halligan)) //halligans have a pick end.
			return 0.75
		return 0.5
	if(istype(C,/obj/item/weapon/kitchen/utensil/knife))  //for those daring prison escapes, also because it's funny.
		return 0.1
	return 0.0

/turf/unsimulated/floor/jungle/proc/item_terraforming_isshovel(obj/item/C)
	if(istype(C,/obj/item/weapon/pickaxe/shovel))
		return (1/C.toolspeed)/2.5
	if(istype(C,/obj/item/weapon/kitchen/utensil/spoon) || istype(C,/obj/item/weapon/kitchen/utensil/spork))  //see above
		return 0.1
	return 0.0

//shared construction code.
/turf/unsimulated/floor/jungle/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return FALSE
	for(var/obj/structure/flora/F in contents)
		return ..()
	if(!construction_allowed)
		return ..()

	if(C.type== /obj/item/stack/tile/metal) // lattice -> plating
		var/obj/item/stack/tile/T = C
		for(var/obj/structure/lattice/L in contents)
			if(L.type!=/obj/structure/lattice) //catches wood latices
				return TRUE //return true to prevent us adding plating to pathes since they both use metal tiles
			if(T.use(1))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				qdel(L)
				ChangeTurf(/turf/simulated/floor/plating)
				remove_paint_overlay()
				update_icon()
				update_paint_overlay()
				levelupdate()
				return TRUE
	if(C.type==/obj/item/stack/rods) //add latice
		for(var/obj/structure/lattice/L in contents)
			to_chat(user, "<span class='notice'>There's already a lattice here</span>")
			return FALSE
		var/obj/item/stack/rods/R=C
		if(R.use(1))
			new/obj/structure/lattice(src)
			return TRUE
	if(C.type== /obj/item/stack/tile/wood) // wood lattice -> wood plating
		var/obj/item/stack/tile/T = C
		for(var/obj/structure/lattice/wood/L in contents)
			if(T.use(1))
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				qdel(L)
				ChangeTurf(/turf/simulated/floor/plating/deck/airless)
				remove_paint_overlay()
				update_icon()
				update_paint_overlay()
				levelupdate()
				return TRUE
	if(C.type==/obj/item/stack/sheet/wood) //add wood latice
		for(var/obj/structure/lattice/L in contents)
			to_chat(user, "<span class='notice'>There's already a lattice here</span>")
			return FALSE
		var/obj/item/stack/sheet/wood/W=C
		if(W.use(1))
			new/obj/structure/lattice/wood(src)
			return TRUE
	return ..()

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

/turf/unsimulated/floor/jungle/grass
	name="Jungle Grass"
	desc="A thick and lush carpet of various plant species, sustained by a regular supply to water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass_alt1"
	turf_speed_multiplier=1.1 // tall grass.
	construction_allowed=TRUE

/turf/unsimulated/floor/jungle/grass/New(var/loc,var/NO_GROW=FALSE)
	..()
	footstep_sound = sounds_grass
	footstep_sound_barefoot = sounds_grass
	footstep_sound_claw = sounds_grass
	if(NO_GROW)
		return

	//var/area/A = loc
	//if(prob( (A.type!=/area/surface/jungle) ? 50 : 100 )) //populated areas have less plants. DOESN'T WORK. IS NULL. WHYYYYYYYYYYYYY
	if (prob(50))
		if(prob(10)) //10% chance to replace with rocks or some shit. 5% over all
			var/rep=pick(foliage_replacments)
			new rep(src)
			turf_speed_multiplier+=0.6
		else //45% over all
			var/plantseed = abs(( sin((x+rand(-2,2))*5.01+213.998) + sin((y+rand(-2,2))*4.56+71.294) )%%1.0)
			plantseed = 1+floor(plantseed*(foliage_choices.len-0.01))//mmm, dumb float math

			var/create=foliage_choices[plantseed]
			if(create)
				new create(src)
				turf_speed_multiplier+=0.6
	else if(prob(50)) //25% overall
		if( !(locate(/obj/structure/flora/tree) in range(2,src)) )
			new/obj/structure/flora/tree/shitty(src)


/turf/unsimulated/floor/jungle/grass/Destroy()
	..()
	for(var/obj/structure/flora/F in contents)
		qdel(F)

/turf/unsimulated/floor/jungle/grass/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(!C || !user)
		return 0
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0 && !(locate(/obj/structure/flora) in contents))
		to_chat(user, "<span class='notice'>You start breaking up the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
			new /obj/item/stack/tile/grass(src,1)


/turf/unsimulated/floor/jungle/grass/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2.0)
			if(prob(70))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3.0)
			if(prob(40))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)

/turf/unsimulated/floor/jungle/grass/New()
	..()
	icon_state="grass_alt[rand(1,4)]"

/turf/unsimulated/floor/jungle/grass/no_flora //BYOND...
/turf/unsimulated/floor/jungle/grass/no_flora/New(var/loc)
	..(loc,TRUE)


/turf/unsimulated/floor/jungle/mud
	name="Mud"
	desc="A viscous mixture of water and soil."
	turf_speed_multiplier=2 //mud is difficult to travel over
	icon='icons/turf/walls.dmi'
	icon_state = "rock(high)"

/turf/unsimulated/floor/jungle/mud/New()
	..()
	icon_state="ironsand[rand(1,15)]"


/turf/unsimulated/floor/jungle/concrete
	name="Concrete"
	desc="Or is it asphalt?"
	icon='icons/turf/new_snow.dmi'
	icon_state = "concrete"
	DIGGING_BLOCKED = "Something hard blocks the way."

/turf/unsimulated/floor/jungle/concrete/ex_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2)
			if(prob(25))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3)
			if(prob(5))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)


/turf/unsimulated/floor/jungle/dirt
	name="Soil"
	desc="A mixture of sediments, clays, and decomposed matter."
	icon_state = "ironsand1"
	var/obj/structure/ladder/jungle_tunnel/hashole=null
	construction_allowed=TRUE

/turf/unsimulated/floor/jungle/dirt/examine()
	..()
	if(hashole)
		to_chat(usr,"there's a hole leading underground.")

/turf/unsimulated/floor/jungle/dirt/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/grass && !hashole)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			ChangeTurf(/turf/unsimulated/floor/jungle/grass/no_flora)
	var/s=0.0
	s=item_terraforming_isshovel(C)
	if(s>0.0 && !hashole)
		to_chat(user, "<span class='notice'>You start packing down the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/path)
	s=item_terraforming_ispickaxe(C)
	if(s>0.0 && !hashole)
		to_chat(usr,"you start digging downwards...")
		if(do_after(user, src, 80/s ))
			if(!hashole)
				to_chat(usr,"you finish making a hole.")
				var/obj/structure/ladder/jungle_tunnel/l_surf=new(src)
				var/obj/structure/ladder/jungle_tunnel/l_tunnel=new(locate(x,y,2))
				l_tunnel.up=l_surf
				l_surf.down=l_tunnel
				hashole=l_surf
				var/turf/T2=locate(x,y,2)
				T2?.ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
				var/turf/unsimulated/floor/jungle/bedrock/TT=T2
				TT?.hashole=l_tunnel
			return
	if(C.type== /obj/item/stack/ore/glass && hashole)
		var/obj/item/stack/ore/glass/T = C
		if(T.amount<50)
			to_chat(usr,"you need 50 sand to do this!")
			return
		to_chat(usr,"you start filling the hole back with soil...")
		if(do_after(user, src, 80 ))
			if(T.use(50))
				to_chat(usr,"you fill the hole back with soil.")
				var/turf/T2=hashole.down.loc
				T2?.ChangeTurf(/turf/unsimulated/floor/jungle/underground)
				qdel(hashole.down)
				qdel(hashole)
				hashole=null


/turf/unsimulated/floor/jungle/path
	name="Compressed Dirt"
	desc="Soil which has been pressed down into a hard, smooth surface."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroid0"
	construction_allowed=TRUE

/turf/unsimulated/floor/jungle/path/attackby(obj/item/C as obj, mob/user as mob)
	.=..()
	if(!C || !user)
		return 0
	if(C.type== /obj/item/stack/tile/metal && !.)
		var/obj/item/stack/tile/T = C
		if(T.use(1))
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			ChangeTurf(/turf/unsimulated/floor/jungle/path_plated)
			plane=TURF_PLANE
			remove_paint_overlay()
			update_icon()
			update_paint_overlay()
			levelupdate()
			return
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0)
		to_chat(user, "<span class='notice'>You start breaking up the soil</span>")
		if(do_after(user, src, 20/s ))
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)


/turf/unsimulated/floor/jungle/path/can_place_cables()
	return TRUE

/turf/unsimulated/floor/jungle/path/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(2)
			if(prob(66))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
		if(3)
			if(prob(33))
				ChangeTurf(/turf/unsimulated/floor/jungle/dirt)


/turf/unsimulated/floor/jungle/path_plated
	name="Plated Soil"
	desc="Compressed soil which has plated atop it to protect items underneath it."
	icon='icons/turf/floors.dmi'
	icon_state = "asteroidfloor"
	plane = TURF_PLANE
	DIGGING_BLOCKED = "Something hard blocks the way."

/turf/unsimulated/floor/jungle/path_plated/New()
	..()
	if(plated_icon_override)
		icon_state=plated_icon_override

/turf/unsimulated/floor/jungle/path_plated/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(!C || !user)
		return 0
	if(iscrowbar(C))
		ChangeTurf(/turf/unsimulated/floor/jungle/path)
		new /obj/item/stack/tile/metal(src,1)
		plane=PLATING_PLANE
		remove_paint_overlay()
		update_icon()
		update_paint_overlay()
		levelupdate()
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/unsimulated/floor/jungle/path_plated/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/unsimulated/floor/jungle/path)
		if(2)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/path)
		if(3)
			if(prob(20))
				ChangeTurf(/turf/unsimulated/floor/jungle/path)



/turf/unsimulated/floor/jungle/water
	name="Water"
	desc="It's about knee-height. Probably not safe to drink from."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water5"
	turf_speed_multiplier=1.75
	plane = ABOVE_OBJ_PLANE
	DIGGING_BLOCKED = "Something tells you that this is a really bad idea."
	turf_reagents = list(WATER=1.0)
	reagent_interaction_flags = TURF_REAGENT_ENTER | TURF_REAGENT_FILLS_CONTAINERS
	turf_reagent_amount = 5

/turf/unsimulated/floor/jungle/water_deep
	name="Deep Water"
	desc="It's nearly up to your shoulders. Probably not safe to drink from."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water2"
	turf_speed_multiplier=2.5
	plane = MOB_PLANE
	DIGGING_BLOCKED = "Something tells you that this is a really bad idea."
	turf_reagents = list(WATER=1.0)
	reagent_interaction_flags = TURF_REAGENT_ENTER | TURF_REAGENT_FILLS_CONTAINERS
	turf_reagent_amount = 10


/turf/unsimulated/floor/jungle/sand
	name="Sand"
	desc="Rocks which have been eroded over countless centuries into a fine powder. A wonderful material for castles!"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	construction_allowed=TRUE


/turf/unsimulated/floor/jungle/underground
	name="Packed Soil"
	density=1
	opacity=1
	desc="Solid dirt as far as the eye can see."
	icon='icons/turf/walls.dmi'
	icon_state = "gingerbread15"
	var/loosened=FALSE // you dig with a pickaxe, too, dumbass.


/turf/unsimulated/floor/jungle/underground/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
		if(2)
			if(prob(50))
				ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
			else
				loosened=TRUE
		if(3)
			if(prob(75))
				loosened=TRUE


/turf/unsimulated/floor/jungle/underground/attackby(obj/item/C as obj, mob/user as mob)
	if(!C || !user)
		return 0
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0)
		if (loosened)
			to_chat(user, "<span class='notice'>The soil is already loose.</span>")
		else
			to_chat(user, "<span class='notice'>You start to loosen the soil...</span>")
			if(do_after(user, src, 20/s ))
				loosened=TRUE
	s=item_terraforming_isshovel(C)
	if(s>0.0)
		to_chat(user, loosened ? "<span class='notice'>You begin to break apart the soil...</span>" : "<span class='notice'>You struggle to break up the soil...</span>")
		if(do_after(user, src, (loosened ? 20 : 60)/s ))
			generate_loot(C,user)
			ChangeTurf(/turf/unsimulated/floor/jungle/bedrock)
			return


/turf/unsimulated/floor/jungle/underground/generate_loot(var/obj/item/C, var/mob/user)
	new/obj/item/stack/ore/glass(src,50) //theres no dirt, so we use sand instead.
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

/turf/unsimulated/floor/jungle/bedrock
	name="Bedrock"
	desc="A very dense rock. Nothing seems to be able to dig through it."
	icon='icons/turf/walls.dmi'
	icon_state = "mariahive_noanimation"
	var/obj/structure/ladder/jungle_tunnel/hashole=null
	construction_allowed=TRUE


/turf/unsimulated/floor/jungle/bedrock/New(var/loc)
	if(locate(/obj/structure/ladder/jungle_tunnel) in contents)
		icon_state="mariahive_noanimation_l"

	if(cannot_dig_up())
		icon_state="mariahive_noanimation_d"

/turf/unsimulated/floor/jungle/bedrock/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(!C || !user)
		return 0
	var/s=0.0
	s=item_terraforming_ispickaxe(C)
	if(s>0.0 && !hashole)
		if(!cannot_dig_up() )
			to_chat(usr,"you start digging upwards...")
			if(do_after(user, src, 80/s ))
				if(!hashole && !cannot_dig_up() )
					to_chat(usr,"you finish making a hole.")
					icon_state="mariahive_noanimation_l"

					var/obj/structure/ladder/jungle_tunnel/l_tunnel=new(src)
					var/obj/structure/ladder/jungle_tunnel/l_surf=new(locate(x,y,1))

					l_tunnel.up=l_surf
					l_surf.down=l_tunnel

					var/turf/T2=locate(x,y,1)
					T2?.ChangeTurf(/turf/unsimulated/floor/jungle/dirt)
					var/turf/unsimulated/floor/jungle/dirt/TT=T2
					TT?.hashole=l_surf
					hashole=l_tunnel
				else
					to_chat(usr,"something gets in your way.")
				return
		else
			to_chat(usr,cannot_dig_up() || "something solid prevents you from tunneling upwards.")


/turf/unsimulated/floor/jungle/bedrock/examine()
	..()
	if(icon_state=="mariahive_noanimation_d")
		to_chat(usr,cannot_dig_up() || "it seems that there's something solid above you that you won't be able to dig through.")
		return
	if(icon_state=="mariahive_noanimation_l")
		to_chat(usr,"there's a hole leading to the surface.")


//we also use enter to reveal tiles, since the tile above could change.
/turf/unsimulated/floor/jungle/bedrock/Entered(var/atom/movable/Obj,var/recursive=TRUE)
	if(recursive)
		..()
	icon_state="mariahive_noanimation"

	if(locate(/obj/structure/ladder/jungle_tunnel) in contents)
		icon_state="mariahive_noanimation_l"

	if(cannot_dig_up())
		icon_state="mariahive_noanimation_d"

	if(recursive) //we reveal the state of surrounding bedrock. there's probably a better way to do this.
		var/turf/T2=get_step(src,NORTH)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,SOUTH)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,EAST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,WEST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,NORTHEAST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,SOUTHEAST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,NORTHWEST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)
		T2=get_step(src,SOUTHWEST)
		if(T2 && T2.type==/turf/unsimulated/floor/jungle/bedrock)
			T2.Entered(Obj,FALSE)

/turf/unsimulated/floor/jungle/bedrock/proc/cannot_dig_up()
	var/turf/T=locate(x,y,1)
	if(!istype(T,/turf/unsimulated/floor/jungle))
		return "something hard blocks the way."
	var/turf/unsimulated/floor/jungle/JT = T
	if(JT.DIGGING_BLOCKED)
		return JT.DIGGING_BLOCKED
	if(locate(/obj/structure/flora/tree) in T.contents)
		return "there's too many roots in the way."
	return null

/turf/unsimulated/floor/jungle/bedrock/ex_act(severity)
	return

/turf/unsimulated/floor/jungle/bedrock/can_place_cables()
	return TRUE

/turf/unsimulated/floor/jungle/worldborder
	density=TRUE
	opacity=TRUE
	name="Strangely hard and tall rock"
	desc="you cannot go this way..."
	icon='icons/turf/walls.dmi'
	icon_state="rock"

/turf/unsimulated/floor/jungle/worldborder/ex_act(severity)
	return
/turf/unsimulated/floor/jungle/worldborder/attackby(obj/item/C as obj, mob/user as mob)
	return

#undef T_JUNGLE
#undef JUNGLE_PRESSURE
#undef MOLES_JUNGLE_STD
#undef MOLES_JUNGLE_O2_STD
#undef MOLES_JUNGLE_CO2_STD
#undef MOLES_JUNGLE_N2_STD
