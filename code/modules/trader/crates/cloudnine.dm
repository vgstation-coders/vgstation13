/obj/structure/closet/crate/internals/cloudnine
	name = "Cloud IX engineering crate"
	desc = "The Cloud IX engineering facility hangs in the atmosphere of the eponymous gas giant. But are the workers happy? Nein."

//3+8+7=18
var/global/list/cloudnine_stuff = list(
	//3 of a kind
	/obj/item/airshield_projector,/obj/item/airshield_projector,/obj/item/airshield_projector,
	//2 of a kind
	/obj/item/vaporizer,/obj/item/vaporizer,
	/obj/item/device/multitool/omnitool,/obj/item/device/multitool/omnitool,
	/obj/item/supermatter_shielding/frass,/obj/item/supermatter_shielding/frass,
	/mob/living/simple_animal/hamster,/mob/living/simple_animal/hamster,
	//1 of a kind
	/obj/item/clothing/gloves/golden,
	/obj/machinery/power/antiquesynth,
	/obj/item/weapon/am_containment/decelerator,
	/obj/structure/largecrate/secure/magmaw,
	/obj/item/wasteos,
	/obj/item/weapon/storage/toolbox/master,
	/obj/item/device/modkit/antiaxe_kit,
	)

/obj/structure/closet/crate/internals/cloudnine/New()
	..()
	for(var/i = 1 to 6)
		if(!cloudnine_stuff.len)
			return
		var/path = pick_n_take(cloudnine_stuff)
		new path(src)

/obj/item/supermatter_shielding/frass
	name = "\improper F.R.A.S.S. sphere"
	desc = "Frequency-reticulated anti-supermatter safeguard. A refinement of the S.A.S.S. design that is reusable but dazes its user more. It should prevent you from getting annihilated by supermatter. It looks like a brown marble floating in a vibrating gas inside a glass orb."
	stunforce = 30
	infinite = TRUE

#define HAMSTER_MOVEDELAY 1
/mob/living/simple_animal/hamster
	name = "colossal hamster"
	desc = "Cricetus robustus. Roughly the size of a capybara, this species of hamster was bred to power treadmill engines."
	icon_state = "hammy"
	icon_living = "hammy"
	icon_dead = "hammy-dead"
	response_help = "pets"
	treadmill_speed = 10
	health = 100
	maxHealth = 100
	min_oxy = 0
	speak_chance = 2
	emote_hear = list("squeaks deeply")
	var/obj/my_wheel

/mob/living/simple_animal/hamster/Life()
	if(!..())
		return 0
	if(!my_wheel && isturf(loc))
		var/obj/machinery/power/treadmill/T = locate(/obj/machinery/power/treadmill) in loc
		if(T)
			wander = FALSE
			my_wheel = T
		else
			wander = TRUE
	if(my_wheel)
		hamsterwheel(20)

/mob/living/simple_animal/hamster/proc/hamsterwheel(var/repeat)
	if(repeat < 1 || stat)
		return
	if(!my_wheel || my_wheel.loc != loc) //no longer share a tile with our wheel
		wander = TRUE
		my_wheel = null
		return
	step(src,my_wheel.dir)
	delayNextMove(HAMSTER_MOVEDELAY)
	sleep(HAMSTER_MOVEDELAY)
	hamsterwheel(repeat-1)

/mob/living/simple_animal/hamster/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M && !isUnconscious() && M.a_intent == I_HELP)
		M.delayNextAttack(2 SECONDS)
		var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
		heart.plane = ABOVE_HUMAN_PLANE
		flick_overlay(heart, list(M.client), 20)
		if(!my_wheel)
			flick("hammy-rest", src)
		emote("me", EMOTE_AUDIBLE, pick("flattens amicably.","fluffs up.","puffs out her cheeks.","shuts her eyes contentedly."))

#undef HAMSTER_MOVEDELAY

/obj/item/clothing/gloves/golden
	name = "golden gloves"
	desc = "An impressive fashion statement. Gold is an excellent conductor, meaning these won't help much against shocks. The insides are lined with strange high-tech sacs filled with an unidentified fluid which lubricates the outside. It comes with a cryptic note reading: touch the supermatter."
	icon_state = "golden"
	item_state = "yellow"
	siemens_coefficient = 2
	permeability_coefficient = 0.05
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	_color = "golden"

/obj/item/airshield_projector
	name = "airshield projector"
	desc = "Exploits Maxwellian Daemons to hold each individual gas particle in place in a defined area. They won't open or close doors for you, though."
	icon = 'icons/obj/device.dmi'
	icon_state = "airprojector"
	var/list/projected = list()
	var/max_proj = 6
	var/list/ignore_types = list(/obj/structure/table, /obj/structure/rack, /obj/item/weapon/storage)

/obj/item/airshield_projector/preattack(atom/target, mob/user , proximity)
	var/turf/to_shield = get_turf(target)
	if(is_type_in_list(target, ignore_types) && user.Adjacent(to_shield))
		return FALSE
	if(projected.len < max_proj && istype(to_shield) && (!locate(/obj/effect/airshield) in to_shield))
		playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
		var/obj/effect/airshield/A = new(to_shield)
		A.owner = src
		projected += A
		visible_message("<span class='notice'>\The [user] deploys \the [A].</span>")
		return TRUE
	return FALSE

//not to be confused with the structure in airshield.dm
/obj/effect/airshield
	name = "airshield"
	desc = "A shield that allows only non-gasses to pass through."
	mouse_opacity = 1
	icon_state = "planner"
	opacity = FALSE
	mouse_opacity = FALSE
	density = FALSE
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	maptext_x = 11
	maptext_y = 8
	var/obj/item/airshield_projector/owner
	var/life = 9

/obj/effect/airshield/New()
	..()
	countdown()

/obj/effect/airshield/proc/countdown()
	maptext = "<span style=\"color:#FF8C00;font-size:12px;\">[life]</span>"
	spawn(1 SECONDS)
		life--
		if(life>0)
			countdown()
		else
			if(owner)
				owner.projected -= src
			update_nearby_tiles(loc)
			qdel(src)

/obj/effect/airshield/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover))
		return ..()
	return FALSE

/obj/item/weapon/am_containment/decelerator
	name = "antimatter decelerator"
	desc = "A large experimental antimatter tank that refuels 25x faster than its regular counterparts."
	icon_state = "jar_big"
	fuel = 10000
	fuel_max = 10000
	gauge_offset = 2

/obj/item/weapon/am_containment/decelerator/receive_pulse(power)
	fuel = min(fuel_max, fuel + round(power))

#define OMNIMODE_WIRE 0
#define OMNIMODE_TOOL 1
/obj/item/device/multitool/omnitool
	name = "omnitool"
	desc = "Combining the power of wirecutters and a multitool. For power cables, works as a multitool when you stand on top and use it. It also allows the user to remotely access APCs and air alarms."
	icon_state = "omnitool"
	origin_tech = Tc_ENGINEERING + "=4"
	sharpness = 1
	force = 6
	req_access = list(access_engine_minor)
	var/mode = OMNIMODE_TOOL
	w_type = RECYK_ELECTRONIC
	flammable = TRUE

/obj/item/device/multitool/omnitool/attack_self(mob/user)
	mode = !mode
	to_chat(user, "<span class='notice'>You toggle the tool into [mode ? "multitool" : "wirecutter"] mode.</span>")

/obj/item/device/multitool/omnitool/is_wirecutter(mob/user)
	return !mode

/obj/item/device/multitool/omnitool/is_multitool(mob/user)
	return mode

var/list/omnitoolable = list(/obj/machinery/alarm,/obj/machinery/power/apc)

/obj/item/device/multitool/omnitool/preattack(atom/target, mob/user, proximity)
	if(proximity)
		if(is_type_in_list(target.type,omnitoolable))
			target.attack_hand(user)
		return FALSE //immediately continue if in reach
	if(can_connect(target, user) && is_type_in_list(target.type,omnitoolable))
		target.attack_hand(user)
		return TRUE

/mob/living/proc/omnitool_connect(atom/target)
	var/obj/item/device/multitool/omnitool/O = get_active_hand()
	if(istype(O))
		return O.can_connect(target,src)
	return FALSE

/obj/item/device/multitool/omnitool/proc/can_connect(atom/target, mob/user)
	var/client/C
	if(user)
		C = user.client
	else
		var/mob/M = loc
		if(!istype(M))
			return FALSE
		C = M.client
	if(!C)
		return FALSE
	if(!allowed(user))
		return FALSE
	return get_dist(target,src) <= C.view

#undef OMNIMODE_WIRE
#undef OMNIMODE_TOOL

/obj/item/wasteos
	name = "\improper Box of Waste-Os!(TM)"
	desc = "Now with extra supermatter chunks! An ill-fated breakfast mixup at the cereal factory led to a discovery that you can suspend supermatter in chemical waste. My God, nobody deserves a mixup that bad."
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "toxiccereal"
	flags = FPRINT | OPENCONTAINER


/obj/item/wasteos/New()
	..()
	create_reagents(60)
	reagents.add_reagent(CHEMICAL_WASTE, 50)

/obj/item/wasteos/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/dropper) || istype(I, /obj/item/weapon/reagent_containers/syringe))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		to_chat(user,"<span class='danger'>\The [I] hits something inside \the [src] and is eradicated!</span>")
		qdel(I)
		return

	else
		..()

/obj/item/wasteos/on_reagent_change()
	if(reagents && reagents.reagent_list.len > 1 + reagents.has_reagent(ETHANOL))
	//If more than one, or two if ethanol present
		reagents.isolate_any_reagent(list(CHEMICAL_WASTE, ETHANOL))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	if(!reagents.has_reagent(CHEMICAL_WASTE))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		visible_message("<span class='danger'>The chunks burn through through \the [src]!</span>")
		var/turf/T = get_turf(src)
		for(var/i = 1 to 3)
			new /obj/item/supermatter_splinter(T)
		qdel(src)
	..()

/obj/item/weapon/storage/toolbox/master
	name = "master toolbox"
	desc = "The mark of a true artisan engineer. Fully insulated, too! Use in hand to engage the safety grip. Can quick-gather materials."
	icon_state = "toolbox_shiny"
	item_state = "toolbox_shiny"
	siemens_coefficient = 0
	allow_quick_gather = TRUE
	use_to_pickup = TRUE

/obj/item/weapon/storage/toolbox/master/attack_self(mob/user)
	cant_drop = !cant_drop
	to_chat(user,"<span class='notice'>You [cant_drop ? "engage" : "disengage"] the safety grip.</span>")

/obj/item/weapon/fireaxe/antimatter
	name = "antimatter fireaxe"
	desc = "Whatever exotic, entropic material this is made out of, it's definitely not antimatter. Use to inhale gasses and cool them, use again to release and exhale them. It seems to take up curiously little space."
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "fireaxe-antimatter"
	item_state = "fireaxe-antimatter0"
	flags = FPRINT | TWOHANDABLE
	w_class = W_CLASS_TINY
	var/datum/gas_mixture/removed

/obj/item/weapon/fireaxe/antimatter/update_wield(mob/living/carbon/user)
	..()
	item_state = "fireaxe-antimatter[wielded ? 1 : 0]"
	force = wielded ? 18 : initial(force) //much less deadly than a matter fireaxe

	var/turf/simulated/S = get_turf(loc)
	var/datum/gas_mixture/air_contents = S.return_air()
	var/zone/Z
	if(wielded)
		if(!istype(S))
			to_chat(user,"<span class='warning'>\The [src] can't inhale here.</span>")
			return
		Z = S.zone
		if(Z)
			for(var/turf/T in Z.contents)
				for(var/obj/effect/fire/F in T)
					F.Extinguish()
		removed = air_contents.remove_volume(20 * CELL_VOLUME)
		if(removed && removed.temperature > T20C)
			removed.temperature = T20C

	else
		if(!removed)
			return //nothing to exhale
		if(istype(S))
			air_contents.merge(removed)
		QDEL_NULL(removed)
	visible_message("<span class='sinister'>\The [src] [wielded ? "in" : "ex"]hales.</span>")
	playsound(loc, 'sound/effects/spray.ogg', 50, 1)
	var/image/void = image('icons/effects/effects.dmi',user ? user : src,"bhole3")
	flick_overlay(void, clients_in_moblist(view(7,loc)), 1 SECONDS)
	void.plane = ABOVE_HUMAN_PLANE
	if(user)
		user.delayNextAttack(2 SECONDS)
		user.update_inv_hands()

/obj/structure/largecrate/secure/magmaw
	name = "engineering livestock crate"
	desc = "An access-locked crate containing a magmaw. Handlers are advised to stand back when administering plasma to the animal."
	req_access = list(access_engine_minor)
	mob_path = /mob/living/simple_animal/hostile/asteroid/magmaw
	bonus_path = null //originally was /obj/item/stack/sheet/mineral/plasma resulting in immediate FIRE
