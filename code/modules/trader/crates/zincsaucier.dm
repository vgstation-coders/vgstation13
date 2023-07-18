//6+4+8 = 18
var/global/list/chef_stuff = list(
	//three of a kind
	/obj/item/clothing/glasses/hud/hydro,/obj/item/clothing/glasses/hud/hydro,/obj/item/clothing/glasses/hud/hydro,
	/obj/item/weapon/storage/bag/plants/reaper,/obj/item/weapon/storage/bag/plants/reaper,/obj/item/weapon/storage/bag/plants/reaper,
	//two of a kind
	/obj/item/fish_eggs/seadevil,/obj/item/fish_eggs/seadevil, //fish_items.dm
	/obj/item/apiary/langstroth,/obj/item/apiary/langstroth,
	//one of a kind
	/obj/item/weapon/vinyl/echoes, //media/jukebox.dm
	/obj/item/sushimat,
	/obj/structure/dishwasher,
	/obj/item/cricketfarm,
	/obj/structure/bed/chair/vehicle/mower,
	/obj/structure/closet/crate/flatpack/ancient/condiment_dispenser,
	/obj/item/weapon/storage/box/darts,
	/obj/item/weapon/reagent_containers/glass/mantinivessel
	)

/obj/structure/closet/crate/freezer/zincsaucier
	name = "Zinc Saucier's crate"
	desc = "Experimental service equipment from the famous gameshow 'Zinc Saucier'. Considered a lesser title by some, but it has double prize money."

/obj/structure/closet/crate/freezer/zincsaucier/New()
	..()
	for(var/i = 1 to 6)
		if(!chef_stuff.len)
			return
		var/path = pick_n_take(chef_stuff)
		new path(src)

var/list/sushi_recipes = list()
var/list/acceptable_sushi_inputs = list()
/obj/item/sushimat
	name = "bottomless sushi mat"
	desc = "Since the 1800s, top researchers, clowns, and magicians have known that there are alternate dimensions full of one object repeated forever. Previously this was thought to be limited to just dimensions of colorful handkerchiefs, doves, etc. -- but this mat connects to limitless rice to feed your sushi addiction."
	w_class = W_CLASS_LARGE
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "sushimat"
	var/lastroll = 0

/obj/item/sushimat/New()
	..()
	if(!sushi_recipes.len)
		for(var/type in subtypesof(/datum/recipe))
			var/datum/recipe/validrecipe = new type
			if(!validrecipe.items || validrecipe.items.len != 2)
				qdel(validrecipe)
				continue //More than just boiled rice + something
			if(!(/obj/item/weapon/reagent_containers/food/snacks/boiledrice in validrecipe.items))
				qdel(validrecipe)
				continue //Boiled rice is not in recipe
			//Edit the recipe for the mat to no longer require rice
			validrecipe.items -= /obj/item/weapon/reagent_containers/food/snacks/boiledrice
			sushi_recipes += validrecipe
	for(var/datum/recipe/recipe in sushi_recipes)
		for (var/item in recipe.items)
			acceptable_sushi_inputs += item

#define FLICKFRAMES 11
/obj/item/sushimat/attackby(obj/item/I, mob/user)
	if(!is_type_in_list(I,acceptable_sushi_inputs))
		return ..()
	if(lastroll + FLICKFRAMES > world.time)
		return
	for(var/datum/recipe/R in sushi_recipes)
		if(istype(I, R.items[1])) //Compare to the only remaining item in the recipe
			flick("sushimat-flickfast", src)
			lastroll = world.time
			playsound(loc, 'sound/effects/bamboo_rattle.ogg', 75, 1, -1)
			visible_message("<span class='notice'>[user] rolls the sushi!</span>")
			qdel(I)
			spawn(FLICKFRAMES)
				var/obj/item/newsushi = new R.result(src)
				newsushi.forceMove(loc) //to trigger multispawners
#undef FLICKFRAMES

var/global/global_cricket_population = 0

/obj/item/cricketfarm
	name = "cricket farm"
	desc = "Contains space crickets. Feeder, terrarium, and grinder all in one. Just don't tip it over."
	w_class = W_CLASS_HUGE
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "cricketfarm"
	var/population = 2
	var/eggs = 5
	var/flourmode = TRUE

/obj/item/cricketfarm/New()
	processing_objects += src

/obj/item/cricketfarm/Destroy()
	processing_objects -= src
	..()

/obj/item/cricketfarm/examine(mob/user)
	..()
	to_chat(user,"<span class='warning'>There is an indicator readout. Crickets: [population], Eggs: [eggs]</span>")
	to_chat(user,"<span class='info'>Use help intent to pick up. Use disarm or grab intent to swap modes. Use harm intent or alt-click to grind crickets.</span>")

/obj/item/cricketfarm/update_icon()
	var/adj
	switch(population)
		if(17 to 20)
			adj = "-high"
		if(12 to 16)
			adj = "-mid"
		if(7 to 11)
			adj = "-low"
		if(0 to 6)
			adj = ""
	icon_state = "cricketfarm[adj]"

/obj/item/cricketfarm/attack_hand(mob/user)
	if(isturf(loc) && user.a_intent != I_HELP)
		if(!usr.Adjacent(src) || usr.incapacitated())
			return
		if(user.a_intent == I_HURT)
			makefood(user)
		else
			flourmode = !flourmode
			to_chat(user,"<span class='notice'>You set \the [src] to make [flourmode ? "flour" : "meat"].</span>")
	else
		..()

/obj/item/cricketfarm/AltClick(mob/user)
	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return
	makefood(user)

/obj/item/cricketfarm/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = I
		if(istype(H.stored_mob,/mob/living/simple_animal/cricket))
			qdel(H.stored_mob)
			qdel(H)
			population++
			update_icon()
			return
	else if(istype(I, /obj/item/weapon))
		escape()
	else
		..()

/obj/item/cricketfarm/process()
	if(prob(population*4))
		spawn(rand(0,3)) //Slightly offset sounds to be more natural
			playsound(src, 'sound/effects/cricket_chirp.ogg', 25)
	if(eggs && population < 20 && global_cricket_population < 100) //Hatch one egg
		eggs--
		population++
		global_cricket_population++
		update_icon()
	if(eggs<100)
		for(var/i = 1 to round(population/2)) //For each complete breeding pair, 15% chance per tick to lay 1-5 eggs
			if(prob(15))
				eggs += rand(1,5)

/obj/item/cricketfarm/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	..()
	escape()

/obj/item/cricketfarm/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(!..())
		escape()

/obj/item/cricketfarm/kick_act(mob/user)
	..()
	escape()

/obj/item/cricketfarm/SlipDropped(var/mob/living/user, var/slip_dir, var/slipperiness = TURF_WET_WATER)
	..()
	escape()

/obj/item/cricketfarm/proc/escape()
	playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
	visible_message("<span class='warning'>The lid on \the [src] clatters unevenly!</span>")
	if((animal_count[/mob/living/simple_animal/cricket] < 20) && population>0)
		for(var/i = 1 to max(rand(2,4),round(population/3)+rand(-1,1)))
			new /mob/living/simple_animal/cricket(loc)
			population--
	update_icon()

/obj/item/cricketfarm/proc/makefood(mob/user)
	if(population+eggs<7 || population<5)
		if(user)
			to_chat(user,"<span class='notice'>The crickets need more time to populate.</span>")
		return
	playsound(src, 'sound/machines/blenderfast.ogg', 50, 1)
	if(flourmode == FALSE)
		for(var/i= 1 to min(5,population))
			new /obj/item/weapon/reagent_containers/food/snacks/meat/cricket(loc)
			population--
			global_cricket_population--
	else
		population -= 5
		global_cricket_population -=5
		var/obj/item/weapon/reagent_containers/food/condiment/C = new(loc)
		C.reagents.add_reagent(FLOUR,10*min(5,population))

/obj/structure/dishwasher
	name = "vacuum dishwasher"
	desc = "It washes and repairs dishes, drawing them in from a distance. You can fit it on a table."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "dishwasher"
	pass_flags = PASSTABLE
	anchored = FALSE
	density = TRUE
	layer = OPEN_DOOR_LAYER//so plates always appear properly above them
	var/effective_range = 7
	var/active = FALSE

/obj/structure/dishwasher/New()
	..()
	processing_objects += src

/obj/structure/dishwasher/Destroy()
	processing_objects -= src
	..()

/obj/structure/dishwasher/attackby(obj/item/I, mob/user)
	if(I.is_wrench(user))
		wrenchAnchor(user,I, 4 SECONDS)
	else if(istype(I, /obj/item/trash/plate) || istype(I, /obj/effect/decal/cleanable/broken_plate))
		if(user.drop_item(I,loc))
			handle(I)
	else
		..()

/obj/structure/dishwasher/attack_hand(mob/user)
	if(!usr.Adjacent(src) || usr.incapacitated())
		return
	if(!anchored)
		to_chat(user,"<span class='warning'>\The [src] needs to be anchored first!<span>")
		return
	active = !active
	playsound(loc,'sound/misc/click.ogg',30,0,-1)
	if (active)
		icon_state = "dishwasher_on"
	else
		icon_state = "dishwasher"
	to_chat(user,"<span class='notice'>You toggle \the [src] [active ? "on" : "off"].</span>")

/obj/structure/dishwasher/process()
	if(!active)
		return
	for(var/obj/effect/decal/cleanable/broken_plate/BP in view(effective_range, src))
		if(BP.loc != loc)
			playsound(BP.loc, 'sound/effects/vacuum.ogg', 25, 1)
			playsound(loc, 'sound/effects/vacuum.ogg', 25, 1)
		handle(BP)
	for(var/obj/item/trash/plate/P in view(effective_range,src))
		if(P.clean)
			continue
		if(P.loc != loc)
			playsound(P.loc, 'sound/effects/vacuum.ogg', 25, 1)
			playsound(loc, 'sound/effects/vacuum.ogg', 25, 1)
		handle(P)

/obj/structure/dishwasher/PreImpact(atom/movable/mover, speed)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/O = mover
		if(!istype(O, /obj/item/trash/plate) && !istype(O, /obj/effect/decal/cleanable/broken_plate))
			return
		handle(O)
		return -1 //This halts the object without smashing it
	else
		return FALSE

/obj/structure/dishwasher/proc/handle(obj/O)
	var/obj/item/trash/plate/potential_stack = pref_stack(O)
	var/obj/item/trash/plate/P
	if(istype(O, /obj/item/trash/plate))
		P = O
		vacuum_anim(O)
	else if(istype(O, /obj/effect/decal/cleanable/broken_plate))
		vacuum_anim(O)
		qdel(O)
		P = new(src)
	else
		return
	P.clean = TRUE
	P.update_icon()
	if(potential_stack)
		P.forceMove(potential_stack)
		potential_stack.plates += P
		spawn(5)
			potential_stack.update_icon()
			playsound(loc, 'sound/effects/refill.ogg', 25, 1)
	else
		P.alpha = 0
		spawn(5)//so we don't see the same plate appear twice
			P.alpha = 255
			playsound(loc, 'sound/effects/refill.ogg', 25, 1)
		P.forceMove(loc)

/obj/structure/dishwasher/proc/vacuum_anim(var/obj/O)
	var/offset_x = ((O.x - x) * 32) + O.pixel_x
	var/offset_y = ((O.y - y) * 32) + O.pixel_y
	var/atom/movable/overlay/animation = anim(target = src,a_icon = 'icons/effects/effects.dmi',a_icon_state = "shieldsparkles",sleeptime = 15, lay = PROJECTILE_LAYER, offX = offset_x, offY = offset_y, col = "#C1FFFA", alph = 200, plane = EFFECTS_PLANE)
	var/image/I = image('icons/effects/effects.dmi',"")
	I.appearance = O.appearance
	animation.overlays += I
	animate(animation, pixel_x = 0, pixel_y = 0, time = 5, easing = SINE_EASING|EASE_OUT)
	spawn(5)
		qdel(animation)

/obj/structure/dishwasher/proc/pref_stack(obj/to_stack)
	for(var/obj/item/trash/plate/P in loc)
		if(P==to_stack)
			continue
		if(P.plates.len >= 9)
			continue
		return P //return any plate with less than 9 plates stacked in it
	//otherwise return null


/proc/hydro_hud_scan(var/mob/living/carbon/human/user, var/obj/o)
	if(!ishuman(user))
		return
	if(istype(user) && user.is_wearing_item(/obj/item/clothing/glasses/hud/hydro))
		to_chat(user, "<span class='good'>Would you like to know more?</span> <a href='?src=\ref[user.glasses];scan=\ref[o]'>\[Scan\]</a>")

/obj/item/clothing/glasses/hud/hydro
	name = "hydroHUD"
	desc = "A heads-up display that displays information on plants and farm animals. It appears to feature corrective lenses too."
	icon_state = "hydrohud"
	item_state = "rwelding-g"
	nearsighted_modifier = -3
	var/obj/item/device/analyzer/plant_analyzer/my_analyzer

/obj/item/clothing/glasses/hud/hydro/New()
	..()
	my_analyzer = new /obj/item/device/analyzer/plant_analyzer(src)

/obj/item/clothing/glasses/hud/hydro/Destroy()
	my_analyzer = null
	..()

/obj/item/clothing/glasses/hud/hydro/Topic(href, href_list)
	. = ..()
	if (.)
		return

	if(href_list["scan"])
		my_analyzer.afterattack(locate(href_list["scan"]), usr, TRUE)

/*/obj/item/clothing/glasses/hud/hydro/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_hydro_hud(M)*/

/obj/item/weapon/storage/bag/plants/reaper
	name = "reaper bag"
	desc = "A plantbag with a built in miniscythe. It's farmerific! It can hold inedible things like logs."
	icon_state = "reaperbag"
	sharpness_flags = SHARP_BLADE|SERRATED_BLADE
	sharpness = 1
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/grown","/obj/item/seeds","/obj/item/weapon/grown", "/obj/item/weapon/reagent_containers/food/snacks/meat", "/obj/item/weapon/reagent_containers/food/snacks/egg", "/obj/item/weapon/reagent_containers/food/snacks/honeycomb", "/obj/item/weapon/grown")

/obj/structure/bed/chair/vehicle/mower
	name = "ride mower"
	desc = "A precision mower. It can make quick work of vine outbreaks, but its blades have the accuracy for weed removal from trays, too."
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "mower"
	can_have_carts = TRUE
	headlights = TRUE

/obj/structure/bed/chair/vehicle/mower/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 0 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = 0 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER)
		)

/obj/machinery/portable_atmospherics/hydroponics/Crossed(var/atom/movable/AM)
	if(istype(AM,/obj/structure/bed/chair/vehicle/mower))
		weedlevel = 0
		update_icon_after_process = TRUE
	..()

/obj/effect/plantsegment/Crossed(var/atom/movable/AM)
	if(istype(AM,/obj/structure/bed/chair/vehicle/mower))
		die_off()
	..()

/obj/item/weapon/reagent_containers/glass/mantinivessel
	name = "enchanted vessel"
	desc = "Now that's a fancy cup - is that a scratched off Wizard Federation sigil? It really calls out for a martini, though."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "mantinivessel"

/obj/item/weapon/reagent_containers/glass/mantinivessel/on_reagent_change()
	if(reagents.has_any_reagents(list(MARTINI,VODKAMARTINI,SAKEMARTINI,ESPRESSOMARTINI,DRIESTMARTINI)))
		playsound(src,'sound/items/butterflyknife.ogg', 50, 1)
		var/turf/T = get_turf(src)
		T.turf_animation('icons/effects/effects.dmi',"butterfly_out")
		visible_message("<span class='notice'>\The [src] stands up!</span>")
		new /mob/living/simple_animal/hostile/mantini(T)
		qdel(src)
	..()

/mob/living/simple_animal/hostile/mantini
	name = "mantini"
	desc = "Your ever-loyal magical barmans' aide."
	icon = 'icons/mob/hostile_humanoid.dmi'
	faction = "neutral"
	stop_automated_movement_when_pulled = TRUE
	environment_smash_flags = FALSE
	icon_state = "mantini"
	icon_living = "mantini"
	speak_emote = list("clinks")
	speak_chance = 2
	turns_per_move = 5
	response_help  = "shakes the hand of"
	response_disarm = "shoves"
	response_harm   = "kicks"
	min_oxy = 0
	minbodytemp = 0
	maxbodytemp = MELTPOINT_STEEL
	search_objects = 3 //ignore mobs entirely

/mob/living/simple_animal/hostile/mantini/CanAttack(var/atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(istype(the_target, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/weapon/reagent_containers/D = the_target
		if(isturf(D.loc) && D.is_empty())
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/mantini/AttackingTarget()
	if(istype(target,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/weapon/reagent_containers/D = target
		D.reagents.add_reagent(MARTINI,30)
	else
		..()

/mob/living/simple_animal/hostile/mantini/FindHidden(var/atom/hidden_target)
	return FALSE



/obj/item/apiary/langstroth
	name = "\improper Langstroth hive"
	desc = "A vertically-modular tray-based apiary. You can simply reach in with your hand and smokers will protect you while you harvest honeycombs."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "langstroth_item"
	buildtype = /obj/machinery/apiary/langstroth


/obj/item/weapon/storage/box/darts
	name = "darts box"
	desc = "Everything you need to set up darts."
	items_to_spawn = list(
		/obj/item/dartboard,
		/obj/item/dart/yellow,
		/obj/item/dart/yellow,
		/obj/item/dart/yellow,
		/obj/item/dart/blue,
		/obj/item/dart/blue,
		/obj/item/dart/blue
	)

/obj/item/dartboard
	name = "dartboard"
	desc = "Step right up and test your skill."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "dartboard_closed"
	layer = BELOW_OBJ_LAYER //above tables but below objects like darts

/obj/item/dartboard/update_icon()
	icon_state = "dartboard[anchored ? "" : "_closed"]"

/obj/item/dartboard/preattack(var/atom/A, var/mob/user, proximity_flag)
	if(!proximity_flag)
		return ..()
	if(isturf(A) && A.density && isturf(user.loc))
		//This is a dense turf, let's mount to it.
		user.drop_item(src, user.loc)
		dir = get_dir(A, user)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 * PIXEL_MULTIPLIER : 32 * PIXEL_MULTIPLIER)
		pixel_y = (dir & 3)? (dir ==1 ? -32 * PIXEL_MULTIPLIER: 32 * PIXEL_MULTIPLIER) : 0
		anchored = TRUE
		update_icon()
		return FALSE
	else
		return ..()

/obj/item/dartboard/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/item))
		var/obj/item/I = mover
		if(I.sharpness>=1 && I.throwing)
			return FALSE //collide
	return TRUE

/obj/item/dartboard/hitby(var/atom/movable/AM)
	if(!istype(AM, /obj/item))
		return ..()
	var/obj/item/I = AM
	if(I.sharpness < 1)
		return ..()
	visible_message("<span class='notice'>\The [I] lodges in \the [src]!</span>")
	I.pixel_x = pixel_x + rand(-10,10)
	I.pixel_y = pixel_y + rand(-10,10)
	I.forceMove(loc)
	if(istype(I,/obj/item/dart))
		score(AM)

/obj/item/dartboard/attackby(obj/item/I, mob/user)
	if(iscrowbar(I) && anchored)
		anchored = FALSE
		update_icon()
		dir = SOUTH
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.put_in_hands(src)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	else
		..()

/obj/item/dartboard/proc/score(obj/item/dart/D,speed,user)
	var/aim = clamp(round(D.aim),1, 5)
	var/scorezone = 0
	for(var/i = 1 to aim) //take aim attempts at aiming for a good spot
		scorezone = max(scorezone, rand(1,21))
	if(scorezone == 21)
		scorezone = 25 //the 21st zone is actually the bullseye zone
		D.pixel_x = pixel_x
		D.pixel_y = pixel_y //Make sure it's centered

	var/luck = clamp(round(D.luck/2), 1, 50) //+50 luck from drunk
	luck += rand(1,100)
	if(luck >= 98 && scorezone != 25) //2% base, but up to 52% with drunk; bullseye can only double
		scorezone *= 3
	else if(luck >= 80)
		scorezone *= 2
	visible_message("<span class='good'>\The [D] scored [scorezone]!</span>")
	playsound(loc, 'sound/items/hammer_strike.ogg', 75, 1, -1)

/obj/item/dart
	name = "throwing dart"
	desc = "A dart designed for recreational throwing. It's not very deadly as a weapon. When stacked, only one dart will be thrown at a time."
	icon = 'icons/obj/items_weird.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 5
	throwforce = 10
	sharpness = 1.2
	sharpness_flags = SHARP_TIP
	melt_temperature = MELTPOINT_STEEL
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = W_CLASS_TINY
	var/aim = 1
	var/luck = 1

/obj/item/dart/throw_at(var/atom/A, throw_range, throw_speed)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		var/common_data = 1
		if(H.reagents.reagent_list) //Sanity
			for(var/datum/reagent/ethanol/E in H.reagents.reagent_list)
				if(isnum(E.data))
					common_data += E.data
		aim = H.reagents.get_sportiness()
		luck = common_data
	..()

//Note to future coders: these sprites have large invisible low-alpha boxes around them to make clicking them easier.
/obj/item/dart/yellow
	name = "yellow dart"
	icon_state = "dartyellow"

/obj/item/dart/blue
	name = "blue dart"
	icon_state = "dartblue"

/obj/machinery/apiary/langstroth
	name = "\improper Langstroth hive"
	apiary_icon = "langstroth"

/obj/machinery/apiary/langstroth/attack_hand(mob/user)
	if(harvest_honeycombs())
		playsound(loc, 'sound/effects/fan.ogg', 75, 1, -1)
		visible_message("<span class='good'>\The [itemform] fans smoke, calming the residents for the harvest.</span>")
