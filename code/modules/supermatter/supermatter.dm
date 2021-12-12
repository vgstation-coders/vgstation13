#define NITROGEN_RETARDATION_FACTOR 4        //Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 10                //Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500                //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 750        //Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1                //Higher == more overall power

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600

#define WARNING_DELAY 30 		//seconds between warnings.
#define AUDIO_WARNING_DELAY 30

/obj/machinery/power/supermatter
	name = "\improper Supermatter Crystal"
	desc = "A strangely translucent and iridescent crystal. <span class='warning'>You get headaches just from looking at it.</span>"
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 0

	mech_flags = MECH_SCAN_FAIL

	var/max_luminosity = 8 // Now varies based on power.

	light_color = LIGHT_COLOR_YELLOW

	// What it's referred to in the alerts
	var/short_name = "Crystal"

	var/gasefficency = 0.25

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/warning_point = 100
	var/audio_warning_point=500
	var/emergency_point = 700
	var/explosion_point = 1000

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0                        // Time in 1/10th of seconds since the last sent warning
	var/lastaudiowarning = 0

	var/power = 0
	var/power_loss_modifier = 2500 // Higher == less power lost every process(). Was 500. With three emitters and no O2, power should tend towards 13935.5 J.
	var/max_power = 2000 // Used for lighting scaling.

	var/list/last_data = list("temperature" = 293, "oxygen" = 0.2)
	var/oxygen = 0				  // Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//        var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

	// Monitoring shit
	var/frequency = 1333
	var/datum/radio_frequency/radio_connection

	//Add types to this list so it doesn't make a message or get desroyed by the Supermatter on touch.
	var/list/message_exclusions = list(/obj/effect/sparks,/obj/effect/overlay/hologram)
	machine_flags = MULTITOOL_MENU

	var/has_exploded = 0 // increments each times it tries to explode so we may track how it may occur more than once

/obj/machinery/power/supermatter/airflow_hit(atom/A)
	if(ismovable(A))
		var/atom/movable/movingA = A
		Bumped(movingA)
	. = ..()

/obj/machinery/power/supermatter/shard //Small subtype, less efficient and more sensitive, but less boom.
	name = "\improper Supermatter Shard"
	short_name = "Shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='warning'>You get headaches just from looking at it.</span>"
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"

	warning_point = 50
	audio_warning_point=400
	emergency_point = 500
	explosion_point = 900

	gasefficency = 0.125
	power_loss_modifier = 500 // With three emitters and no O2, power should tend towards 2643.1 J

	explosion_power = 8 // WAS 3 - N3X

	max_luminosity = 5
	max_power=3000

	light_type = LIGHT_SOFT_FLICKER
	lighting_flags = IS_LIGHT_SOURCE

/obj/machinery/power/supermatter/New()
	. = ..()
	radio = new (src)

/obj/machinery/power/supermatter/shard/New()
	. = ..()
	if(Holiday == APRIL_FOOLS_DAY)
		icon_state = "darkmatter_shard_chad"
		base_icon_state = "darkmatter_shard_chad"
		desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='warning'>You are confident this is literally the best engine on the station, no other engine can compare to the intelligence required to set it up nor the unparalleled power output. All those idiot engineers will set up the Singularity, the TEG, the AME, but they all kneel to those who set up the SME. What are you waiting for? If this doesn't produce enough power to power the station for billions of years then you are doing it wrong.</span>"

/obj/machinery/power/supermatter/initialize()
	..()
	set_frequency(frequency) //also broadcasts

/obj/machinery/power/supermatter/Destroy()
	new /datum/artifact_postmortem_data(src,TRUE)//we only archive those that were excavated
	qdel(radio)
	radio = null
	radio_controller.remove_object(src, frequency)
	radio_connection = null
	. = ..()

/obj/machinery/power/supermatter/proc/explode(var/mob/user)
	has_exploded++
	var/turf/T = get_turf(src)
	if (has_exploded <= 1)
		if(!istype(universe,/datum/universal_state/supermatter_cascade))
			var/turf/turff = get_turf(src)
			new /turf/unsimulated/wall/supermatter(turff)
			SetUniversalState(/datum/universal_state/supermatter_cascade)
			explosion(turff, explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1, whodunnit = user)
			empulse(turff, 100, 200, 1)
	else if (has_exploded == 2)// yeah not gonna report it more than once to not flood the logs if it glitches badly
		log_admin("[name] at [T.loc] has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")
		message_admins("[name] at [T.loc]([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")

	qdel(src)
	if (has_exploded > 1)
		stack_trace("[name] at [T.loc] has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")

/obj/machinery/power/supermatter/shard/explode(var/mob/user)
	has_exploded++
	var/turf/T = get_turf(src)
	if (has_exploded <= 1)
		explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1, whodunnit = user)
		empulse(get_turf(src), 100, 200, 1)
	else if (has_exploded == 2)// yeah not gonna report it more than once to not flood the logs if it glitches badly
		log_admin("[name] at [T.loc] has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")
		message_admins("[name] at [T.loc]([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")
	qdel(src)
	if (has_exploded > 1)
		stack_trace("[name] at [T.loc] has tried exploding despite having already exploded once. Looks like it wasn't properly deleted (gcDestroyed = [gcDestroyed]).")

/obj/machinery/power/supermatter/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	Bumped(AM)
	return TRUE

/obj/machinery/power/supermatter/ex_act(severity,var/mob/whodunnit)
	switch(severity)
		if(3.0)
			return //Should be improved
		else
			return explode(whodunnit)

/obj/machinery/power/supermatter/shard/singularity_act(current_size, obj/machinery/singularity/S)
	var/super = FALSE
	var/prints = ""
	if(src.fingerprintshidden)
		prints = ", all touchers: [list2params(src.fingerprintshidden)]"
	if(current_size == STAGE_FIVE)
		S.expand(STAGE_SUPER, 1)
		super = TRUE
	log_admin("[super ? "New super singularity made" : "Singularity gained 15000 energy"] by eating a SM shard with prints: [prints]. Last touched by [src.fingerprintslast].")
	message_admins("[super ? "New super singularity made" : "Singularity gained 15000 energy"] by eating a SM shard with prints: [prints]. Last touched by [src.fingerprintslast].")
	qdel(src)
	return 15000

/obj/machinery/power/supermatter/singularity_act(current_size, obj/machinery/singularity/S)
	var/prints = ""
	var/ssgss = FALSE
	if(src.fingerprintshidden)
		prints = ", all touchers: [list2params(src.fingerprintshidden)]"
	if(current_size == STAGE_SUPER) // and this is to go even further beyond
		if(!istype(universe,/datum/universal_state/supermatter_cascade))
			SetUniversalState(/datum/universal_state/supermatter_cascade)
		S.expand(STAGE_SSGSS, 1)
		ssgss = TRUE
	log_admin("[ssgss ? "New SSGSS made" : "Singularity gained 20000 energy"] by eating a SM crystal with prints: [prints]. Last touched by [src.fingerprintslast].")
	message_admins("[ssgss ? "New SSGSS made" : "Singularity gained 20000 energy"] by eating a SM crystal with prints: [prints]. Last touched by [src.fingerprintslast].")
	qdel(src)
	return 20000

/obj/machinery/power/supermatter/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/structure/closet/crate/secure/large/reinforced))
		return 1
	. = ..()

/obj/machinery/power/supermatter/proc/stability()
	return round((damage / explosion_point) * 100)

/obj/machinery/power/supermatter/process()

	var/turf/L = loc
	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(istype(L, /turf/space))	// Stop processing this stuff if we've been ejected.
		return

	// Let's add beam energy first.
	for(var/obj/effect/beam/emitter/B in beams)
		power += B.get_damage() * config_bullet_energy

	var/stability = stability()
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status

		var/list/audio_sounds = list('sound/AI/supermatter_integrity_before.ogg')
		var/play_alert = 0
		var/audio_offset = 0
		var/current_zlevel = L.z
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			var/warning=""
			var/offset = 0

			audio_sounds += vox_num2list(stability)
			audio_sounds += list('sound/AI/supermatter_integrity_after.ogg')

			// Damage still low.
			if(damage >= damage_archived) // The damage is still going up
				warning = "Danger! [short_name] hyperstructure instability detected, now at [stability]%."
				offset=150

				if(damage > emergency_point)
					warning = "[uppertext(short_name)] INSTABILITY AT [stability]%. DELAMINATION IMMINENT - EVACUATE IMMEDIATELY."
					offset=0
					audio_sounds += list('sound/AI/supermatter_delam.ogg')
					//audio_offset = 100
				play_alert = (damage > audio_warning_point)
			else
				warning = "[short_name] hyperstructure returning to safe operating levels. Instability: [stability]%"
			var/datum/speech/speech = radio.create_speech(warning, frequency=COMMON_FREQ, transmitter=radio)
			speech.name = "Supermatter [short_name] Monitor"
			speech.job = "Automated Announcement"
			speech.as_name = "Supermatter [short_name] Monitor"
			Broadcast_Message(speech, level = list(current_zlevel))
			qdel(speech)

			lastwarning = world.timeofday - offset

		if(play_alert && (world.timeofday - lastaudiowarning) / 10 >= AUDIO_WARNING_DELAY)
			for(var/sf in audio_sounds)
				play_vox_sound(sf,current_zlevel,null)
			lastaudiowarning = world.timeofday - audio_offset

		if(damage > explosion_point)
			for(var/mob/living/mob in living_mob_list)
				if(mob.z != src.z)//only make it effect mobs on the current Z level.
					continue
				if(istype(mob, /mob/living/carbon/human))
					//Hilariously enough, running into a closet should make you get hit the hardest.
					mob:hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
				var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(mob, src) + 1) )
				mob.apply_radiation(rads, RAD_EXTERNAL)

			explode()

	broadcast_status()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/datum/gas_mixture/removed = env.remove_volume(gasefficency * CELL_VOLUME)

	if(!removed || !removed.total_moles)
		damage += max((power-1600)/10, 0)
		power = min(power, 1600)
		return 1

	damage_archived = damage
	damage = max( damage + ( (removed.temperature - 800) / 150 ) , 0 )
	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	oxygen = clamp((removed[GAS_OXYGEN] - removed[GAS_NITROGEN] * NITROGEN_RETARDATION_FACTOR) / MOLES_CELLSTANDARD, 0, 1) //0 unless O2>80%. At 99%, ~0.6

	var/temp_factor = 100

	if(oxygen > 0.8)
		// with a perfect gas mix, make the power less based on heat
		icon_state = "[base_icon_state]_glow"
	else
		// in normal mode, base the produced energy around the heat
		temp_factor = 60
		icon_state = base_icon_state

	power = max( (removed.temperature * temp_factor / T0C) * oxygen + power, 0) //Total laser power plus an overload

	//We've generated power, now let's transfer it to the collectors for storing/usage
	transfer_energy()
	last_data["temperature"] = removed.temperature
	last_data["oxygen"] = oxygen

	var/device_energy = power * REACTION_POWER_MODIFIER

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
	removed.temperature += (device_energy / THERMAL_RELEASE_MODIFIER)

	removed.temperature = max(0, min(removed.temperature, 2500))

	//Calculate how much gas to release
	removed.adjust_multi(
		GAS_PLASMA, max(device_energy / PLASMA_RELEASE_MODIFIER, 0),
		GAS_OXYGEN, max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0))

	env.merge(removed)

	for(var/mob/living/carbon/human/l in view(src, min(7, round(power ** 0.25)))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/scanner/meson))
			l.hallucination = max(0, min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)) ) ) )

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 50) * sqrt(1/(max(get_dist(l, src), 1)))
		l.apply_radiation(rads, RAD_EXTERNAL)

	power -= (power/power_loss_modifier)**3

	var/light_value = clamp(round(clamp(power / max_power, 0, 1) * max_luminosity), 0, max_luminosity)

	// Lighting based on power output.
	set_light(light_value, light_value / 2)

	return 1


/obj/machinery/power/supermatter/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return ..()	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
	else
		damage += Proj.damage * config_bullet_energy

	return ..()

/obj/machinery/power/supermatter/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/machinery/power/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		attack_ai(user)

/obj/machinery/power/supermatter/kick_act(mob/living/H)
	..()

	Consume(H)

/obj/machinery/power/supermatter/bite_act(mob/living/H)
	H.visible_message("<span class='danger'>[H] attempts to bite \the [src]!</span>", "<span class='userdanger'>You attempt to take a bite out of \the [src]. Your last thought before you burn to ashes is \"Touching it would've been a much wiser decision.\"")

	Consume(H)

/obj/machinery/power/supermatter/attack_ghost(mob/user as mob)
	attack_ai(user)

/obj/machinery/power/supermatter/attack_ai(mob/user as mob)
	var/stability = num2text(round((damage / explosion_point) * 100))
	to_chat(user, "<span class = \"info\">Matrix Instability: [stability]%</span>")
	to_chat(user, "<span class = \"info\">Damage: [format_num(damage)]</span>")// idfk what units we're using.

	to_chat(user, "<span class = \"info\">Power: [format_num(power)]J</span>")// Same


/obj/machinery/power/supermatter/attack_hand(mob/user as mob)
	var/obj/item/clothing/gloves/golden/G = user.get_item_by_slot(slot_gloves)
	if(istype(G))
		to_chat(user,"<span class='warning'>Carefully extending a single finger, you nearly touch the supermatter before the gloves stop you -- repulsed by and absorbing some kind of charge.</span>")
		if(G.siemens_coefficient > -1)
			G.siemens_coefficient = -1
			G.icon_state = "golden-awakened"
			G.desc = "Gloves imbued with the power of the supermatter. They absorb electrical shocks to heal the wearer."
			to_chat(user, "<span class='good'>Some of the power of the supermatter remains trapped in the gloves, changing their properties!</span>")
		return
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	emitted_harvestable_radiation(get_turf(src), power, range = 15)

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	. = ..()
	if(.)
		return .

	if(issilicon(user))
		return attack_hand(user)

	user.visible_message("<span class='warning'>\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class='danger'>You touch \the [W] to \the [src] when everything suddenly goes silent.</span>\n<span class='notice'>\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class='warning'>Everything suddenly goes silent.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_radiation(50, RAD_EXTERNAL)


/obj/machinery/power/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /obj/machinery/power/supermatter))
		AM.visible_message("<span class='sinister'>As \the [src] bumps into \the [AM] an otherworldly resonance ringing begins to shake the room, you ponder for a moment all the incorrect choices in your life that led you here, to this very moment, to witness this. You take one final sigh before it all ends.</span>")
		sleep(10) //Adds to the hilarity
		score["shardstouched"]++
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		explode()
		return
	if(istype(AM, /obj/item/supermatter_splinter))
		AM.visible_message("<span class='sinister'>As \the [AM] collides with \the [src], </span><span class = 'warning'>rather than exploding, \the [AM] fuses to \the [src].</span>")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		power_loss_modifier *= 1.5
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		qdel(AM)
		return
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [src] is slammed into by \the [AM], inducing a resonance... \his body begins to glow and catch aflame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(!is_type_in_list(AM, message_exclusions))
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return ..()

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)

/obj/machinery/power/supermatter/shard/Bumped(atom/AM)
	..()
	if(istype(AM, /obj/item/supermatter_splinter))
		if(power_loss_modifier >= 2500)
			visible_message("<span class = 'sinister'>As \the [AM] fuses to \the [src], \the [src] begins to glow an overworldly shimmer as it begins to pull additional mass from the environment around itself...</span>")
			new/obj/effect/overlay/gravitywell(loc)
			spawn(6 SECONDS)
				if(gcDestroyed)
					return //Something went wrong, oh no
				var/turf/T = get_turf(src)
				qdel(src)
				new /obj/machinery/power/supermatter(T)


/obj/machinery/power/supermatter/proc/Consume(atom/A)
	if(isliving(A))
		. = A.supermatter_act(src, SUPERMATTER_DUST)
		if(ismouse(A)) //>implying mice are going to follow the rules
			return .
		power += 200
	else
		. = A.supermatter_act(src, SUPERMATTER_DELETE)

	power += 200

	for(var/mob/living/l in range(10,src)) //Some poor sod got eaten, go ahead and irradiate people nearby.
		if(l == A) //It's the guy that just died.
			continue
		var/rads = 75 * sqrt( 1 / (get_dist(l, src) + 1) )
		if(l.apply_radiation(rads, RAD_EXTERNAL))
			visible_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find yourself covered in fresh radiation burns.</span>", "<span class=\"warning\">The unearthly ringing subsides and you notice you have fresh radiation burns.</span>")

/obj/machinery/power/supermatter/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] suicidally slams \himself head first into the [src], inducing a resonance... \his body begins to glow and catch aflame before flashing into ash, never to be seen again.</span>")
	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
	Consume(user)
	return SUICIDE_ACT_CUSTOM

/obj/machinery/power/supermatter/blob_act()
	explode()

/obj/machinery/power/supermatter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)
	broadcast_status()

#define SMM_RANGE 26
/obj/machinery/power/supermatter/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new()
	signal.transmission_method = SIGNAL_RADIO
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "SM",
		"instability" = stability(),
		"damage" = damage,
		"power" = power,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, RADIO_ATMOSIA, SMM_RANGE)
	return 1
#undef SMM_RANGE

/obj/machinery/power/supermatter/canClone(var/obj/O)
	return istype(O, /obj/machinery/power/supermatter)

/obj/machinery/power/supermatter/clone(var/obj/machinery/power/supermatter/O)
	id_tag = O.id_tag
	set_frequency(O.frequency)
	return 1

/obj/machinery/computer/supermatter
	name = "supermatter monitoring computer"
	desc = "Monitors ambient temperature and stability of a linked shard to provide early warning information regarding delamination. Can be linked up to supermatter with a matching frequency and id_tag using a multitool. While using a multitool on supermatter is safe, Nanotrasen accepts no responsibility or liability for sudden rushes of wind or radiation poisoning."
	icon_state = "sme"
	circuit = "/obj/item/weapon/circuitboard/supermatter"
	light_color = LIGHT_COLOR_YELLOW
	var/frequency = 1333
	var/datum/radio_frequency/radio_connection
	var/obj/machinery/power/supermatter/linked = null //Gets cleared in process if the shard explodes
	//"LIST" BUTTON
	var/screen = 0 //0 = Main display, 1 = select target
	var/list/cached_smlist = list()

/obj/machinery/computer/supermatter/initialize()
	..()
	set_frequency(frequency)

/obj/machinery/computer/supermatter/process()
	if(linked && linked.gcDestroyed)
		linked = null
	..()

/obj/machinery/computer/supermatter/receive_signal(datum/signal/signal, var/receive_method as num, var/receive_param)
	..()
	//Become unlinked if we receive a new signal from the thing we're linked from.
	if(linked && signal.source && signal.source == linked)
		linked = null
	//Link to broadcasts with our id_tag
	if(id_tag == signal.data["tag"] && istype(signal.source,/obj/machinery/power/supermatter))
		linked = signal.source

/obj/machinery/computer/supermatter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/computer/supermatter/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/computer/supermatter/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/supermatter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (gcDestroyed || !get_turf(src) || !anchored)
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	var/data[0]
	data["screen"] = screen
	if(linked) //We really want to be linked, but the template can survive even without a link
		data["id"] = linked.id_tag
		data["temperature"] = linked.last_data["temperature"]
		data["stability"] = linked.stability()
		if(!istype(linked.loc, /turf)||istype(linked.loc, /turf/space))
			data["dps"] = 0 //If crated or in space, damage is exactly 0
			data["oxygen"] = 0 //This doesn't really matter because power isn't generated in this state
		else
			data["dps"] = (linked.last_data["temperature"]-800)/150
			data["oxygen"] = linked.last_data["oxygen"]*100
		var/area/SME_loc = get_area(linked)
		data["location"] = SME_loc.name
	else
		data["id"] = FALSE

	if(screen)
		cached_smlist = list()
		for(var/obj/machinery/power/supermatter/SM in radio_connection.devices[RADIO_ATMOSIA])
			var/area/sm_loc = get_area(SM)
			if(sm_loc) //Otherwise it's nullspaced or something
				cached_smlist.Add(list(list("type" =  SM.name, "id" = SM.id_tag, "location" = sm_loc.name)))
		data["smlist"] = cached_smlist
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "supermatter.tmpl", name, 520, 340)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update()

/obj/machinery/computer/supermatter/Topic(href, href_list)
	. = ..()
	if(.)
		return .
	if(href_list["list"])
		screen = !screen

	return TRUE
