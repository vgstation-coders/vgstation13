//Object and area definitions go here
//Please make all areas used in vaults one of these:
//  * subtype of /area/vault
//  * /area/vault/automap (preferred option)
//  * subtype of /area/vault/automap

/area/vault
	name = "mysterious structure"
	requires_power = 0
	icon_state = "firingrange"
	dynamic_lighting = 1

	holomap_draw_override = HOLOMAP_DRAW_EMPTY

	//Used for bizarre/odd/reference vaults, entering them causes the wild wasteland sound to play
	var/mysterious = FALSE

/area/vault/New()
	..()

	if(mysterious)
		//Create a narrator object to play a sound to everybody who enters the area
		narrator = new /obj/effect/narration/mystery_sound(null)

//Special area that can be used in map elements. When loaded, it creates a new area object and transfers all of its contents into it.
//This means that this area can be put into multiple map elements without any issues
/area/vault/automap

/area/vault/automap/spawned_by_map_element(datum/map_element/ME, list/objects)
	var/area/vault/automap/new_area = new src.type

	for(var/turf/T in src.contents)
		new_area.contents.Add(T)

		T.change_area(src, new_area)
		for(var/atom/allthings in T.contents)
			allthings.change_area(src, new_area)

	new_area.tag = "[new_area.type]/\ref[ME]"
	new_area.addSorted()

/area/vault/gingerbread_house

/area/vault/podstation
	requires_power = 1

/area/vault/mechclubhouse
	requires_power = 1

/area/vault/icetruck

/area/vault/asteroid

/area/vault/tommyboyasteroid
	requires_power = 1

/area/vault/satellite

/area/vault/factory

/area/vault/clownbase

/area/vault/gym

/area/vault/oldarmory

/area/vault/rust
	requires_power = 1

/area/vault/dancedance

/area/vault/dancedance/loot
	jammed = 2

/area/vault/spacepond

/area/vault/spacepond/wine_cellar

/area/vault/ioufort

/area/vault/hive_shuttle

/area/vault/rsvault

/area/vault/syndiecargo

/area/vault/black_site_prism
	jammed = 2

//prison vault

/area/vault/prison_ship
	requires_power = 1

/area/vault/prison

/obj/docking_port/destination/vault
	var/valid_random_destination = TRUE //If FALSE, random shuttle destination disks can't pick this docking port

/obj/item/weapon/disk/shuttle_coords/vault/prison
	destination = /obj/docking_port/destination/vault/prison

/obj/docking_port/destination/vault/prison
	areaname = "holding facility 10"

//listening outpost

/area/vault/listening
	requires_power = 1

/obj/item/weapon/disk/shuttle_coords/vault/listening
	destination = /obj/docking_port/destination/vault/listening

/obj/docking_port/destination/vault/listening
	areaname = "outpost V-24"
/area/vault/biodome
	requires_power = 1

//biodome

/obj/item/weapon/disk/shuttle_coords/vault/biodome
	destination = /obj/docking_port/destination/vault/biodome

/obj/docking_port/destination/vault/biodome
	areaname = "biodome"

/area/vault/brokeufo
	requires_power = 1

/area/vault/AIsat
	requires_power = 1

/area/vault/taxi_engi
	name = "\improper Destroyed Engineering"
	requires_power = 1

/area/vault/taxi_engi/engineering
	name = "\improper Engineering"

/area/vault/taxi_engi/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"

/area/vault/taxi_engi/mechanics
	name = "\improper Mechanics"
	icon_state = "mechanics"

/area/vault/taxi_engi/storage
	name = "\improper Storage"

/area/vault/taxi_engi/secure_storage
	name = "\improper Storage"
	icon_state = "engine_storage"

/area/vault/taxi_engi/engine
	name = "\improper Engine Room"
	icon_state = "engine_control"

/area/vault/taxi_engi/CE_office
	name = "\improper Chief Engineer Office"
	icon_state = "head_quarters"

/area/vault/taxi_engi/podbay
	name = "\improper Podbay"
	icon_state = "pod"

/area/vault/taxi_engi/lobby
	name = "\improper Lobby"
	icon_state = "engine_lobby"

/area/vault/ejectedengine
	requires_power = 1

/area/vault/ejectedengine/SMES
	name = "\improper Engine SMES"
	icon_state = "engine_smes"

/area/vault/ejectedengine/generator
	name = "\improper Generator Room"
	icon_state = "thermo_engine"

/area/vault/ejectedengine/gasstorage
	name = "\improper Engine Gas Storage"
	icon_state = "engine_storage"

/area/vault/ejectedengine/monitoring
	name = "Engine Monitoring"
	icon_state = "engiaux"

/area/vault/ejectedengine/burnroom
	name = "\improper Engine Hallway"
	icon_state = "engine"

/area/vault/droneship
	name = "\improper Drone Ship"
	requires_power = 1
	jammed = 2
	var/pod_code = "00000"

/area/vault/droneship/New()
	..()
	pod_code = "[rand(10000, 99999.0)]"

/area/vault/amelab
	name = "\improper Nanotrasen Experimental AME Lab"
	requires_power = 1

/area/vault/amelab/lab
	requires_power = 0
	jammed = 2
	color = "blue"

/obj/effect/blob/core/ame_lab
	name = "antimatter control unit"
	desc = "This device injects antimatter into connected shielding units. Wrench the device to set it...wait hold on, something's off..?"
	icon = 'icons/mob/blob/blob_AME_64x64.dmi'
	looks = "AME_new"
	asleep = TRUE
	no_ghosts_allowed = TRUE

/obj/item/weapon/paper/amelab1
	name = "paper- 'Initial Report'"
	info = "I have arrived at the lab. The builders have just finished setting up the atmos and have departed. The station is using so little power that the P.A.C.M.A.N. in the maintenance is more than enough to recharge the APC. Centcomm should send the parts for the reactor by tomorrow, I can't wait to build it."

/obj/item/weapon/paper/amelab2
	name = "paper- 'Second Report'"
	info = "The cargo shuttle dropped the parts about an hour ago and I've somehow already finished assembling the Antimatter Engine. In fact, the lab is running on its power right now. It's such a fool-proof system, you just pulse the parts with a multitool and it assembles on its own, not sure how anyone could mess it up really. I've shutdown the P.A.C.M.A.N., it might come in handy later in case of emergency. Antimatter is a much more efficient energy source, with just one jar this small lab could stay online for aeons."

/obj/item/weapon/paper/amelab3
	name = "paper- 'Third Report'"
	info = "As instructed in Phase One of the experiment, I've started slowly raising the fuel injection. The engine seems to remain stable at up to 4 units of antimatter per injection, beyond that it quickly starts losing structural integrity and the injections become quite loud. I have determined that the highest safe amount of fuel units per injection is equal to twice the amount of cores."

/obj/item/weapon/paper/amelab4
	name = "paper- 'Fourth Report'"
	info = "Centcomm has shipped me some much larger fuel jars in preparation for Phase Two. A scientist will be coming, an Anomalist specifically. I'm not quite versed into Exotic Particle science but they will test alternative ways to raise the power output. This can go wrong in so many ways but we're all well aware of the risks, and the pay is good enough. Worst case scenario the lab explodes and we'll be the only casualties."

/obj/item/weapon/paper/amelab5
	name = "paper- 'Fifth Report'"
	info = "The anomalist has started their experiments on the engine, they brought various devices and machines I do not recognize. Regardless, the radiations their tools emit seem to have a positive effect on the power output. Looks like we're on the verge of a technological breakthrough! With the last deliveries we also ordered a portable SMES kit. If we can export enough surplus energy we might not only earn ourselves a bonus, but also prove the commercial applications of the enhanced AME."

/obj/item/weapon/paper/amelab6
	name = "paper- 'Sixth Report'"
	info = "Something went wrong, very wrong. The AME isn't outputting any power anymore but will not shutdown. More worrying even, the engine appears to be emitting its own exotic particles now, different from those we were using until now. The rate of particle production seems to be slowly rising at a constant rate. You will find attached to this report all the data we could gather from it. Please advise."

/obj/item/weapon/paper/amelab7
	name = "paper- 'Final Report'"
	info = "We've drained the engine room of oxygen, somehow this seems to have slowed down the increase in exotic particles. After reading the data that came with our previous report Centcomm decided to completely abort the project. A shuttle will come by to extract us shortly, which is either a testament to how valuable we are, or how dangerous the engine has actually become. I like to hope it's both. I leave those notes here should Centcomm decide to resume the experiments. <b>Most importantly I advise against trying to put any more fuel inside the engine</b>."

/obj/item/weapon/storage/bag/clipboard/amelab/New()
	..()
	var/list/papers = list()
	papers += new /obj/item/weapon/paper/amelab1(src)
	papers += new /obj/item/weapon/paper/amelab2(src)
	papers += new /obj/item/weapon/paper/amelab3(src)
	papers += new /obj/item/weapon/paper/amelab4(src)
	papers += new /obj/item/weapon/paper/amelab5(src)
	papers += new /obj/item/weapon/paper/amelab6(src)
	papers += new /obj/item/weapon/paper/amelab7(src)

	for (var/obj/item/weapon/paper/P in papers)
		P.update_icon()
		P.mouse_opacity = 2
		toppaper = P

	update_icon()

/obj/item/weapon/disk/shuttle_coords/vault/amelab
	name = "Experimental AME Lab shuttle destination disk"
	desc = "This satellite could be repurposed as a comfortable hang-out. Although we might want to keep the lab properly sealed."
	destination = /obj/docking_port/destination/vault/amelab

/obj/docking_port/destination/vault/amelab
	areaname = "Nanotrasen Experimental AME Lab"


/area/vault/meteorlogical
	name = "\improper Meteorlogical Station"

/area/vault/icecomet
	jammed = 2

/area/vault/assistantlair
	jammed = 2


/area/vault/research
	requires_power = 1
	name = "\improper Medical Research Facility"

/obj/machinery/power/apc/frame/research_vault
	make_alerts = FALSE

/obj/docking_port/destination/vault/research
	valid_random_destination = FALSE
	areaname = "Medicial Research Facility"

/obj/item/weapon/disk/shuttle_coords/vault/research
	destination = /obj/docking_port/destination/vault/research

/obj/item/weapon/gun/projectile/pistol/empty
	max_shells = 0
	spawn_mag = FALSE

/obj/item/ammo_casing/c9mm/empty
	projectile_type = null

/area/vault/satelite

/area/vault/spy_sat
	name = "\improper Donk Co. Comm-sniffer satellite C-VI"

/area/vault/spy_sat/deployment
	name = "\improper Undocumented interstellar satellite deployment"


/area/vault/rattlemebones
	jammed = 2

/area/vault/zathura

/area/vault/zathura/surroundings
	dynamic_lighting = FALSE
	mysterious = TRUE

/area/vault/ironchef
	name = "Kitchen Coliseum" //Not improper

/obj/effect/narration/mystery_sound
	play_sound = 'sound/effects/wildwasteland.ogg'


/area/vault/beach_party


/obj/machinery/door/poddoor/droneship
	name = "\improper OSIPR Pod-Door"
	id_tag = "denied"

/obj/machinery/door/poddoor/droneship/New()
	..()
	var/area/A = get_area(src)
	if(A && istype(A,/area/vault/droneship))
		var/area/vault/droneship/DS = A
		id_tag = DS.pod_code

/obj/item/weapon/p_folded/ball/droneship
	name = "crushed ball of paper"

/obj/item/weapon/p_folded/ball/droneship/New()
	..()
	qdel(unfolded)
	unfolded = new /obj/item/weapon/paper/crumpled/droneship(src)

/obj/item/weapon/paper/crumpled/droneship
	name = "paper- 'OSIPR Pod-Door ID'"
	info = "denied"

/obj/item/weapon/paper/crumpled/droneship/New()
	var/area/A = get_area(src)
	if(A && istype(A,/area/vault/droneship))
		var/area/vault/droneship/DS = A
		info = "[DS.pod_code]"

/mob/living/simple_animal/hostile/monster/cyber_horror/quiet
	speak_chance = 1 //shut the fuck up

/obj/item/weapon/bananapeel/traitorpeel/curse
	name = "cursed banana peel"
	desc = "A peel from a banana, surrounded by an evil aura of trickery and mischief. "

	anchored = 1
	cant_drop = 1

	slip_power = 10

/obj/item/weapon/melee/morningstar/catechizer
	name = "The Catechizer"
	desc = "An unholy weapon forged eons ago by a servant of Nar-Sie."
	origin_tech = null
	force = 37
	throwforce = 30
	throw_speed = 3
	throw_range = 5

/obj/effect/landmark/catechizer_spawn //Multiple of these are put in a single area. One of these landmark will contain a true catachizer, others only mimics
	name = "catechizer spawn"

/obj/machinery/door/poddoor/vault_rust
	id_tag = "tokamak_yadro_ventilyatsionnyy" // Russian for "tokamak_core_vent"

/obj/machinery/door_control/vault_rust
	name   = "tokamak yadro ventilyatsionnyy"
	id_tag = "tokamak_yadro_ventilyatsionnyy"

/obj/item/weapon/fuel_assembly/trilithium
	name = "trilithium fuel rod assembly"

/obj/item/weapon/fuel_assembly/trilithium/New()
	. = ..()
	rod_quantities["Trilithium"] = 300

/obj/machinery/power/apc/frame/rust_vault
	make_alerts = FALSE

/obj/machinery/power/apc/frame/rust_vault/initialize()
	. = ..()
	name = "regulyator moshchnosti oblast'"

/obj/machinery/power/generator/rust_vault
	name = "termoelektricheskiy generator metki dva"

	thermal_efficiency = 0.90

/obj/machinery/power/battery_port/rust_vault
	name = "raz\"yem pitaniya"

/obj/machinery/power/rust_core/rust_vault
	name = "\improper Razmnozitel' Ustojcivogo Sostojanija Termojadernyj versija sem' tokamak yadro"

/obj/machinery/vending/engineering/rust_vault
	name = "\improper Robco instrumental'shchik"

/obj/item/device/rcd/rpd/rust_vault
	name = "\improper Bystroye Ustroystvo Truboprovodov (BUT)"

/obj/item/device/rcd/matter/engineering/rust_vault
	name = "\improper Bystroye Stroitel'stvo Ustroystv (BSU)"

/obj/item/weapon/paper/tommyboy
	name = "failed message transcript"
	info = {"This is Major Tom to Ground Control<br>
			I'm stepping through the door<br>
			And I'm floating in the most peculiar way<br>
			And the stars look very different today<br>
			For here am I sitting in my tin can<br>
			Far above the world<br>
			Planet Earth is blue<br>
			And there's nothing I can do.
			"}

/obj/item/weapon/paper/asteroidfield
	name = "dear diary"
	info = {"It's all HONKING HONKED.  I left for bananium and it HONKED itself to pieces!  Our planet is HONKED!  What am I going to do?"}

/obj/machinery/atmospherics/binary/msgs/rust_vault
	name = "\improper Magnitno Priostanovleno Blok Khraneniya Gaza"

/obj/item/weapon/paper/iou
	name = "paper- 'IOU'"
	info = "I owe you a rod of destruction. Redeemable at Milliway's at the end of time."

/obj/machinery/telecomms/relay/preset/vault_listening
	id = "syndicate relay"
	hide = 1
	toggled = 0
	autolinkers = list("hub")

/obj/machinery/power/apc/no_alerts/vault_listening/initialize()
	. = ..()
	name = "\improper Listening Outpost APC"

/obj/machinery/power/apc/no_alerts/vault_taxi/initialize()
	. = ..()

/obj/machinery/power/battery/smes/vault_listening
	chargelevel = 30000
	chargemode  = TRUE

/obj/machinery/power/solar/control/vault_listening
	track = 2 // Automatic

/obj/machinery/floodlight/on/New()
	..()
	on = 1
	set_light()
	update_icon()

/obj/machinery/floodlight/on/infinite
	cell = /obj/item/weapon/cell/infinite

/obj/machinery/bot/farmbot/duey
	name = "Duey"
	desc = "Looks like a maintenance droid, repurposed for botany management. Seems the years haven't been too kind."
	health = 150
	maxhealth = 150
	icon_state = "duey0"
	icon_initial = "duey"
	Max_Fertilizers = 50

/obj/structure/ladder/spacepond/ground
	name = "wine cellar"
	id = "spacepond"
	height = 1

/obj/structure/ladder/spacepond/winecellar
	name = "space cabin"
	id = "spacepond"
	height = 0

/mob/living/silicon/decoy/AIvault/New()
	name = pick(ai_names)
	icon_state = "ai-malf"
	..()

/obj/machinery/power/apc/no_alerts/vault_AIsat/initialize()
	. = ..()
	name = "\improper AI Satellite APC"

/obj/machinery/turret/portable/AIvault
	req_access = list(access_ai_upload)
	check_records = 1
	criminals = 1
	auth_weapons = 1
	stun_all = 1
	check_anomalies = 1
	ai = 1

/obj/machinery/turret/portable/AIvault/New()
	installed = new/obj/item/weapon/gun/energy/laser/retro/ancient(src)
	..()
	if(prob(25))
		dir = pick(alldirs)
		die()

/obj/item/weapon/gun/energy/laser/retro/ancient
	name = "ancient laser gun"
	desc = "Once a highly dangerous weapon, this laser has degraded over decades into a still somewhat dangerous weapon."
	projectile_type = /obj/item/projectile/beam/retro/weak

/obj/item/projectile/beam/retro/weak
	damage = 15

/turf/simulated/floor/engine/old
	icon_state = "engineold"

/obj/machinery/camera/noview/New()
	..()
	network = list()
	cameranet.removeCamera(src)

/obj/effect/landmark/corpse/engineer/old
	generate_random_mob_name = 1
	mutantrace = "Skellington"
	corpseradio = /obj/item/device/radio/headset
	corpseback = /obj/item/weapon/storage/backpack
	corpsebelt = null

/obj/machinery/light/burnt
	spawn_with_bulb = /obj/item/weapon/light/tube/burned

/obj/structure/closet/welded/New()
	..()
	welded = 1
	update_icon()

/obj/machinery/portable_atmospherics/canister/old
	filled = 0.8
	volume = 50000

/obj/machinery/portable_atmospherics/canister/old/pressure_overlays(var/state)
	var/static/list/status_overlays_pressure = list(
		image(icon, "old-o0"),
		image(icon, "old-o1"),
		image(icon, "old-o2"),
		image(icon, "old-o3")
	)

	return status_overlays_pressure[state]

/obj/machinery/portable_atmospherics/canister/old/other_overlays(var/state)
	var/static/list/status_overlays_other = list(
		image(icon, "old-open"),
		image(icon, "old-connector")
	)

	return status_overlays_other[state]

/obj/machinery/portable_atmospherics/canister/old/process()
	..()
	can_label = 0

/obj/machinery/portable_atmospherics/canister/old/attack_ai()
	return

/obj/machinery/portable_atmospherics/canister/old/plasma
	name = "Canister: \[Toxins\]"
	icon_state = "orangeold"
	canister_color = "orangeold"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/old/plasma/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_PLASMA, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/obj/machinery/portable_atmospherics/canister/old/oxygen
	name = "Canister: \[Oxygen\]"
	icon_state = "blueold"
	canister_color = "blueold"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/old/oxygen/New(loc)
	..(loc)
	air_contents.adjust_gas(GAS_OXYGEN, (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
	update_icon()

/mob/living/simple_animal/hostile/retaliate/malf_drone/vault
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS
	speak_chance = 1

/obj/machinery/atmospherics/unary/vent/visible
	level = LEVEL_ABOVE_FLOOR

/obj/machinery/computer/ejectedengine/engine
	name = "Engine Ejection Console"
	desc = "Allows access to the engine ejection system."
	icon_state = "engine1"
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/ejectedengine/engine/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = text("<B>Engine Ejection Module</B><HR>\nStatus: Ejected<BR>\n<BR>\nCountdown: N/60 \[Reset\]<BR>\n<BR>\nEngine Ejected!<BR>\n<BR>\n<A href='?src=\ref[];mach_close=computer'>Close</A>", user)
	user << browse(dat, "window=computer;size=400x500")

/obj/machinery/computer/ejectedengine/shield
	name = "Shield Control Console"
	desc = "Controls the station's external shielding."
	icon_state = "escape"
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/ejectedengine/shield/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = text("<B>Shield Generator Control</B><HR>\n<font color=red>Error:</font> Cannot locate projector array<BR>\n<font color=red>Error:</font> Cannot locate shield capacitors<BR>\n<font color=red>Error:</font> Cannot locate command signal<BR>\n<BR>\n<A href='?src=\ref[];mach_close=computer'>Close</A>", user)
	user << browse(dat, "window=computer;size=400x500")

/obj/machinery/door/firedoor/red
	name = "\improper Firelock"
	desc = "Emergency air-tight shutter, for keeping fires contained."
	icon = 'icons/obj/doors/Doorfire.dmi'

/obj/effect/landmark/stonefier
	name = "STONIFIER"
	desc = "Turns all mobs on this turf into statues forever. Used for map editing!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "statue"

	layer = 100
	plane = 100
	//So that it's more visible in the map editor

/obj/effect/landmark/stonefier/New()
	var/turf/T = get_turf(src)

	spawn()
		for(var/mob/living/L in T)
			L.turn_into_statue(1, 1)

	qdel(src)

/obj/item/weapon/paper/feeding_schedule
	name = "note"
	info = {"
	Reminder to wear full body coverage when being anywhere near the cockatrice pen. As Forrest has already shown you (may he forever bloom in the black peat), shorts are NOT a substitute for pants - borrow your friend's if yours are damaged or lost.
	<br>
	And remember to update the computer database after feeding!<br>
	"}

/obj/effect/trap/cockatrice_notice //When triggered, cockatrices turn and hiss at you
	name = "cockatrice trigger"

/obj/effect/trap/cockatrice_notice/can_activate(atom/movable/AM)
	if(istype(AM, /mob/living/simple_animal/hostile/retaliate/cockatrice))
		return 0

	return ..()

/obj/effect/trap/cockatrice_notice/activate(atom/movable/AM)
	for(var/mob/living/simple_animal/hostile/retaliate/cockatrice/CO in view(7))
		if(CO.isDead())
			continue

		CO.face_atom(AM)
		CO.visible_message("<span class='notice'>\The [CO] looks at \the [AM] and hisses angrily!</span>")


/* Spy Sat stuff */

/obj/machinery/power/magtape_deck
	name = "magnetic tape drive"
	desc = "A primitive way of storing information. Used because of its longevity over most digital counterparts."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"

	active_power_usage = 500
	density = 1

/obj/machinery/power/magtape_deck/New()
	..()
	connect_to_network()

/obj/machinery/power/magtape_deck/process()
	if(stat & BROKEN)
		return
	var/powered = 1

	if(surplus() < active_power_usage)
		powered = 0

	if(powered && stat & NOPOWER)
		stat &= ~NOPOWER
		update_icon()
	else if (!powered && !(stat & NOPOWER))
		stat |= NOPOWER
		update_icon()

/obj/machinery/power/magtape_deck/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "[initial(icon_state)]0"
	else
		icon_state = "[initial(icon_state)]1"

/obj/machinery/power/magtape_deck/emp_act(severity)
	if(prob(50/severity))
		set_broken()

/obj/machinery/power/magtape_deck/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				set_broken()
		if(3)
			if (prob(25))
				set_broken()

/obj/machinery/power/magtape_deck/proc/set_broken()
	if(stat & BROKEN)
		return
	stat |= BROKEN
	update_icon()

/obj/machinery/power/magtape_deck/blob_act()
	if (prob(75))
		set_broken()


/obj/machinery/power/magtape_deck/syndicate
	desc = "A primitive way of storing information. Used because of its longevity over most digital counterparts.\
	It appears to have a microphone and speaker attached."
	var/codephrase
	var/list/potential_codewords = list()
	var/encrypted_codephrase
	var/triggered
	flags = FPRINT | HEAR

/obj/machinery/power/magtape_deck/syndicate/New()
	..()
	potential_codewords = adjectives.Copy()
	for(var/i in potential_codewords)
		if(length(i) > 6)
			potential_codewords.Remove(i)
			continue
		var/noti = lowertext(i)
		for(var/ii = 1 to length(noti))
			var/asciichar = text2ascii(noti,ii)
			if(asciichar < 97 && asciichar > 122)
				potential_codewords.Remove(i)
				break
	generate_codephrase()

/obj/machinery/power/magtape_deck/syndicate/proc/generate_codephrase()
	triggered = 0
	codephrase = lowertext(pick(potential_codewords)) //Picks a word, long or short
	encrypted_codephrase = ""
	var/offset = rand(1,5) //Picks the offset
	for(var/i = 1 to length(codephrase)) //Goes through each character
		var/char_value = text2ascii(codephrase,i)-97 //Find the value of the character at that point, between a and z respectively (Converts to lower case)
		var/new_char = ascii2text(((char_value+offset)%26)+97) //Adds the offset to the value, then converts it back to a character
		encrypted_codephrase += new_char //Then adds it to the codephrase

/obj/machinery/power/magtape_deck/syndicate/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(stat & (BROKEN|NOPOWER))
		return
	if(speech.speaker && !speech.frequency)
		if(findtext(speech.message, codephrase))
			if(!triggered)
				triggered = TRUE
				say("Codephrase accepted. Welcome, Agent. Releasing gathered information and current co-ordinates of home base.")
				new /obj/item/weapon/disk/tech_disk/random(get_turf(src))
				new /obj/item/weapon/disk/shuttle_coords/vault/satellite_deployment(get_turf(src))

/obj/machinery/power/magtape_deck/syndicate/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	say(encrypted_codephrase)


/obj/machinery/power/magtape_deck/syndicate/attack_ghost(mob/user)
	if(isjustobserver(user))
		return
	..()

/obj/item/weapon/disk/tech_disk/random/New()
	..()
	var/possible_research = pick(subtypesof(/datum/tech))
	stored = new possible_research
	stored.level = rand(1,stored.max_level)

/obj/item/weapon/disk/shuttle_coords/vault/satellite_deployment
	destination = /obj/docking_port/destination/vault/satellite_deployment

/obj/docking_port/destination/vault/satellite_deployment
	areaname = "satellite deployment base"


/obj/machinery/door/poddoor/satellite_deployment
	id_tag = "spacetime"

/obj/machinery/door/poddoor/preopen/satellite_deployment
	id_tag = "spacetime"

/obj/machinery/door_control/satellite_deployment
	id_tag = "spacetime"

/obj/item/weapon/paper/satellite_deployment/no_smoking
	name = "Note to all would-be smokers"
	info = {"If you'll take a minute to look around, you'll notice we don't have<br>
			any regular atmospheric regulation like most station, and due to our predicament of <br>
			being on an asteroid lodged in bluespace, we can't afford to install atmospheric regulation.<br>
			So from now on smoking is prohibited except for in the pod bay<br>
			When you're done, toggle the pod bay doors to get that stink out of here.<br>
			<br>
			P.S. Make sure there's nobody still standing in the pod bay when you do vent it.<br>
			We can't afford regular replacement staff, so try not to kill one another.<br>
			~ Ensign Willhelm
			"}

/obj/item/weapon/paper/satellite_deployment/space_saving
	name = "Discussion on space allocation"
	info = {"As you are aware we don't have much in the ways of room, but the engineer insists that<br>
		despite engineering consisting of 2 glorified petrol engines and an SMES, he needs all the space<br>
		he can get.<br>
		For now, let's just focus on the feng-shui of the place. I've placed an order for some nice carpets,<br>
		and plant pots for the relaxation rooms.<br>
		~ Ensign Willhelm
		"}

/obj/item/weapon/paper/satellite_deployment/complaints
	name = "Complaints"
	info = {"Getting real tired of Willhelm's shit.<br>
		The pod bay doors only have a button on the outside, how does he expect us to trust one another smoking?<br>
		Engineering is bigger than most other rooms and it has barely anything functional in it<br>
		Medical is undersupplied as fuck, we don't even have a defibrilator<br>
		Where the hell are we supposed to sleep anyway? We've got two break rooms and no beds!<br>
		And don't get me started on the fucking weapon distribution.<br>
		Why does the chef get a minigun while medical gets a syringe gun?
		"}

/obj/item/weapon/paper/satellite_deployment/complaints_reply
	name = "Regarding complaints"
	info = {"Complaining is not good for crew morale.<br>
		It draws unwanted attention towards the negative side of serving here. Look on the bright side.<br>
		After an extended investigation, the station medical doctor has been forced to resign over his outburst<br>
		and all paper-usage is now under lockdown.<br>
		Let's keep working. Comms are offline for the time-being as we pass close to NT space.<br>
		~ Ensign Willhelm
		"}

/obj/item/weapon/paper/satellite_deployment/further_complaints
	name = "Further complaints"
	info = {"It wasn't the medical doctor, you half-witted clown.<br>
		Now what do we do if somebody gets hurt?<br>
		You'd best watch your step around the pod bay, Ensign. Lest you find out.
		"}

/obj/item/weapon/reagent_containers/food/snacks/pie/acid_filled
	name = "acid pie"
	desc = "Tangy tasting!"

/obj/item/weapon/reagent_containers/food/snacks/pie/acid_filled/New()
	..()
	reagents.clear_reagents()
	var/room_remaining = reagents.maximum_volume
	var/poly_to_add = rand(room_remaining/10,room_remaining/2)
	reagents.add_reagent(PACID, poly_to_add)
	room_remaining -= poly_to_add
	var/sulph_to_add = rand(room_remaining/10,room_remaining/2)
	reagents.add_reagent(SACID, sulph_to_add)
	room_remaining -= sulph_to_add
	reagents.add_reagent(NUTRIMENT, room_remaining)

/obj/item/weapon/reagent_containers/spray/chemsprayer/lube/New()
	..()
	reagents.add_reagent(LUBE, rand(50,volume))

/obj/effect/decal/cleanable/blood/stattrack //Not the same as tracks. Less nonsense required, for aesthetic purposes only
	icon_state = "tracks"
	random_icon_states = null

//Iron Chef

/obj/item/weapon/disk/shuttle_coords/vault/ironchef
	destination = /obj/docking_port/destination/vault/ironchef

/obj/docking_port/destination/vault/ironchef
	areaname = "Kitchen Coliseum"

/obj/item/clothing/gloves/ironchefgauntlets
	name = "Iron Chef gauntlets"
	desc = "Awarded to one whose confection achieves perfection, to one whose cuisine reigns supreme, to one whose foodstuff is the goodstuff."
	icon_state = "powerfist"
	siemens_coefficient = 0
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/weapon/reagent_containers/glass/beaker/vial/flavor
	name = "essence of pure flavor"
	desc = "This will really knock any dish up a notch. Bam!"

/obj/item/weapon/reagent_containers/glass/beaker/vial/flavor/New()
	..()
	reagents.add_reagent(MINDBREAKER, 25)

/obj/item/weapon/reagent_containers/glass/beaker/vial/radium/New()
	..()
	reagents.add_reagent(RADIUM, 25)

/obj/machinery/microwave/upgraded
	component_parts = newlist(\
		/obj/item/weapon/circuitboard/microwave,\
		/obj/item/weapon/stock_parts/micro_laser/high/ultra,\
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,\
		/obj/item/weapon/stock_parts/console_screen\
	)


/obj/machinery/turret/russian
	faction = "russian"

/obj/machinery/turret/russian/New()
	installed = new /obj/item/weapon/gun/energy/laser(src)

// Minisat stuff

/obj/item/weapon/disk/shuttle_coords/vault/minisat
	name = "NT microstation shuttle destination disk"
	destination = /obj/docking_port/destination/vault/minisat

/obj/docking_port/destination/vault/minisat
	name = "NT Microstation 1"

/area/vault/mini_station
	name = "NT Microstation Hallway"
	icon_state = "hallC"

/area/vault/mini_station_entrance
	name = "NT Microstation Entrance"
	icon_state = "entry"

/area/vault/mini_station_kitchen
	name = "NT Microstation Kitchen"
	icon_state = "bar"

/area/vault/mini_station_medbay
	name = "NT Microstation Medbay"
	icon_state = "medbay"

/area/vault/mini_station_engineering
	name = "NT Microstation Engineering"
	icon_state = "engine"

/area/vault/mini_station_botany
	name = "NT Microstation Botany"
	icon_state = "hydro"

/area/vault/mini_station_construction
	name = "NT Microstation Construction Room"
	icon_state = "construction"