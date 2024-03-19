//Turf
/turf/unsimulated/wall/meat
	name = "?"
	desc = null
	icon = 'icons/turf/meat.dmi'
	icon_state = "meat255"

/turf/unsimulated/wall/meat/canSmoothWith()
	return null

/turf/unsimulated/wall/guts
	name = "guts"
	desc = "Some kind of twisting intestinal layers."
	icon = 'icons/turf/meat.dmi'
	icon_state = "guts0"
	walltype = "guts"

/turf/unsimulated/wall/guts/canSmoothWith()
	var/static/list/smoothables = list(/turf/unsimulated/wall/guts)
	return smoothables

/turf/simulated/floor/plating/flesh
	name = "?"
	desc = null
	icon = 'icons/turf/meat.dmi'
	icon_state = "flesh"

/turf/simulated/floor/plating/flesh/New()
	..()
	var/image/img = image('icons/turf/rock_overlay.dmi', "flesh_overlay",layer = SIDE_LAYER)
	img.pixel_x = -4*PIXEL_MULTIPLIER
	img.pixel_y = -4*PIXEL_MULTIPLIER
	img.plane = relative_plane(ABOVE_TURF_PLANE)
	overlays += img

//Objects
/obj/item/voucher/free_item/scrip
	name = "scrip"
	desc = "Redeem at a Deepvein Trust vendor."
	freebies = list()
	vend_amount = 1
	single_items = 1
	shred_on_use = 1

/obj/item/voucher/free_item/scrip/liberator
	name = "liberator scrip"
	freebies = list(/obj/item/weapon/gun/energy/laser/liberator)

/obj/item/voucher/free_item/scrip/drill
	name = "drill scrip"
	freebies = list(/obj/item/weapon/pickaxe/drill)

/obj/item/voucher/free_item/scrip/lazarus
	name = "lazarus scrip"
	freebies = list(/obj/item/weapon/lazarus_injector)

/obj/item/voucher/free_item/scrip/rifle
	name = "rifle scrip"
	freebies = list(/obj/item/weapon/gun/projectile/hecate/hunting)

/obj/item/voucher/free_item/scrip/sausage
	name = "sausage scrip"
	freebies = list(/obj/item/weapon/reagent_containers/food/snacks/sausage)

/obj/item/voucher/free_item/scrip/threefiftyseven
	name = ".357 scrip"
	freebies = list(/obj/item/ammo_storage/box/a357)

/obj/machinery/vending/deepvein
	name = "\improper Deepvein Trust Company Store"
	desc = "Use your 'wages' here!"
	product_slogans = list(
		"Please have your scrip ready for vending."
	)
	product_ads = list(
		"Insert scrip."
	)
	vend_reply = "Scrip, scip, lovely scrip!"
	icon_state = "mining"
	vouched = list(
		/obj/item/weapon/pickaxe/drill = 10,
		/obj/item/weapon/lazarus_injector = 10,
		/obj/item/weapon/gun/energy/laser/liberator = 10,
		/obj/item/weapon/gun/projectile/hecate/hunting = 10,
		/obj/item/weapon/reagent_containers/food/snacks/sausage = 10,
		/obj/item/ammo_storage/box/a357 = 20
	)

/obj/item/weapon/card/id/deputy
	name = "deputy badge"
	desc = "A metal star that signifies one as a friend of Old Zounds. You're my favorite deputy."
	assignment = "Deputy"
	icon_state = "deputystar"
	//access = list(access_deputy)
	show_biometrics = FALSE

/obj/machinery/media/jukebox/folk
	name = "Old Timey Jukebox"

	change_cost = 0

	playlist_id="folk"
	// Must be defined on your server.
	playlists=list(
		"folk" = "House Specials"
	)

/obj/structure/uraninitecrystal
	name = "glowing crystal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crystal"
	light_color = "#00FF00"
	anchored = TRUE
	var/lit = 0

/obj/structure/uraninitecrystal/New()
	..()
	set_light(2, l_color = light_color)

/obj/structure/uraninitecrystal/bullet_act()
	rad_pulse(10)

/obj/structure/uraninitecrystal/kick_act()
	shake(1, 3)
	rad_pulse(10)

/obj/structure/uraninitecrystal/ex_act()
	rad_pulse(4)
	..()

/obj/structure/uraninitecrystal/proc/rad_pulse(remaining)
	lit += remaining
	lit = clamp(0,lit,40)
	if(!lit)
		set_light(2, l_color = light_color)
		return
	set_light(6, l_color = light_color)
	emitted_harvestable_radiation(get_turf(src), 20, range = 5)
	for(var/mob/living/carbon/M in view(src,3))
		var/rads = 50 * sqrt( 1 / (get_dist(M, src) + 1) )
		M.apply_radiation(round(rads/2),RAD_EXTERNAL)
	spawn(2 SECONDS)
		rad_pulse(-2) //After 2 seconds, recurse with decrement

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/dorf/New()
	..()
	reagents.add_reagent(MANLYDORF, 50)
	on_reagent_change()

/obj/structure/cartrail
	name = "rail"
	desc = "A hunk of shaped metal."
	icon = 'icons/obj/mining.dmi'
	icon_state = "rail"

/obj/structure/rustycart
	name = "rusty cart"
	desc = "This isn't going anywhere fast."
	//old icon and state in 'icons/obj/vehicles.dmi' "mining_cart"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "miningcar"
	anchored = TRUE
	density = TRUE

/obj/structure/flora/desert
	icon = 'icons/obj/flora/ausflora.dmi'
	shovelaway = TRUE

/obj/structure/flora/desert/barrelcactus
	name = "barrel cactus"
	desc = "That's a barrel. Wait, no."
	anchored = TRUE
	icon_state = "barrelcactus_1"

/obj/structure/flora/desert/barrelcactus/New()
	..()
	icon_state = "barrelcactus_[rand(1,2)]"

/obj/structure/flora/desert/barrelcactus/Crossed(atom/movable/AM)
	..()
	if(iscarbon(AM))
		var/mob/living/carbon/L = AM
		L.reagents.add_reagent(FEVERFEW,3) //This will take 15 ticks to clear, doing about 22 brute (but brute regens easily)
		to_chat(L, "<span class='danger'>You prick yourself on \the [src].</span>")

/obj/structure/flora/desert/saguaro
	name = "saguaro cactus"
	desc = "The space saguaro gets its name from the Earth saguaro, which comes from an indigenous Opata word that refers to saguaros."
	density = TRUE
	pass_flags_self = PASSTABLE | PASSGLASS
	anchored = TRUE
	icon_state = "saguaro_1"

/obj/structure/flora/desert/saguaro/Bumped(atom/movable/AM)
	..()
	if(iscarbon(AM))
		var/mob/living/carbon/L = AM
		L.reagents.add_reagent(FEVERFEW,3)
		to_chat(L, "<span class='danger'>You prick yourself on \the [src].</span>")

/obj/structure/flora/desert/saguaro/New()
	..()
	icon_state = "saguaro_[rand(1,2)]"

/obj/structure/flora/desert/tumbleweed
	name = "tumbleweed"
	desc = "Please, just tumble away. You might need my help some day. Tumble away."
	icon_state = "tumbleweed"

/obj/structure/flora/desert/tumbleweed/New()
	..()
	processing_objects += src

/obj/structure/flora/desert/tumbleweed/Destroy()
	processing_objects -= src
	..()

/obj/structure/flora/desert/tumbleweed/process()
	if(prob(98))
		return
	throw_at(get_turf(pick(orange(7,src))), 10,2)

/obj/structure/sarcophagus
	name = "sarcophagus"
	desc = "Although often associated with Egyptians, sarcophagus is a Greek word meaning 'eater of flesh'. It refers to any stone burial receptacle."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguestone"

///////////////Effects//////////////

/obj/effect/floating_candle
	name = "floating candle"
	desc = "The ghost of a candle? This is extremely cursed."
	icon = 'icons/obj/candle.dmi'
	icon_state = "floatcandle"
	anchored = TRUE

/obj/effect/floating_candle/New()
	..()
	set_light(4, 2, LIGHT_COLOR_CYAN)

/obj/effect/tractorbeam
	name = "tractor beam"
	desc = "???"
	icon = null
	icon_state = null
	anchored = TRUE
	density = TRUE
	var/turf/endpoint

/obj/effect/tractorbeam/New()
	..()
	set_light(4, 8, LIGHT_COLOR_HALOGEN)
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "tractor beam")
			endpoint = get_turf(L)
			break

/obj/effect/tractorbeam/Bumped(atom/movable/AM)
	AM.forceMove(endpoint)
	if(ismob(AM))
		AM << 'sound/music/xfiles.ogg'
		to_chat(AM, "<span class='warning'>Gravity seems to lapse as you float into the sky!</span>")

//Landmarks
/obj/effect/landmark/respawner/desert
	name = "Wild West respawner"

///Spells
/mob/living/proc/mountup()
	for(var/spell/mountup/M in spell_list)
		M.cast(src,src)
		return

/spell/mountup
	name = "Mount Up"
	desc = "Mount a steed."
	charge_max = 0
	spell_flags = 0
	cast_delay = 2 SECONDS
	var/obj/effect/overlay/my_overlay
	var/active = FALSE
	var/remembered_speed

/spell/mountup/New()
	..()
	my_overlay = new /obj/effect/overlay/horsebroom_mount

/spell/mountup/choose_targets(var/mob/user = usr)
	return list(user)

/spell/mountup/perform(mob/user = usr, skipcharge = 0, list/target_override)
	cast_delay = active ? 0 : initial(cast_delay)
	..()

/spell/mountup/cast(var/list/targets, var/mob/user)
	if(!active)
		var/choosefile = pick('sound/items/jinglebell1.ogg','sound/items/jinglebell2.ogg','sound/items/jinglebell3.ogg')
		playsound(user, choosefile, 100, 1)
		user.register_event(/event/damaged, src, nameof(src::dismount()))
		user.overlays.Add(my_overlay)
		active = TRUE
		if(istype(user,/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = user
			remembered_speed = SA.speed
			SA.speed = max(0.6, SA.speed-0.4)
	else
		dismount()

/spell/mountup/proc/dismount(kind, amount)
	var/mob/living/user = src.holder
	playsound(user, 'sound/voice/cow.ogg', 100, 1)
	user.overlays.Remove(my_overlay)
	user.unregister_event(/event/damaged, src, nameof(src::dismount()))
	active = FALSE
	if(istype(user,/mob/living/simple_animal))
		var/mob/living/simple_animal/SA = user
		SA.speed = remembered_speed

/obj/effect/overlay/horsebroom_mount
	name = "steed"
	icon = 'icons/mob/in-hand/left/items_lefthand.dmi'
	icon_state = "horsebroom0"
	layer = VEHICLE_LAYER
	plane = FLOAT_PLANE + 2
	mouse_opacity = 0 // Probably does nothing on overlays