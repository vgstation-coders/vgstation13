#define PULSEDEMON_APC_CHARGE_MULTIPLIER 2

/mob/living/simple_animal/hostile/pulse_demon
	name = "Pulse Demon"
	desc = "A strange electrical apparition that lives in wires."
	icon_state = "pulsedem"
	icon_living = "pulsedem"
	icon_dead = "pulsedem" // Should never be seen but just in case
	speak_chance = 20
	emote_hear = list("vibrates", "sizzles")
	emote_sound = list("sound/voice/pdvoice1.ogg","sound/voice/pdvoice2.ogg","sound/voice/pdvoice3.ogg")
	response_help = "reaches their hand into"
	response_disarm = "pushes their hand through"
	response_harm = "punches their fist through"
	plane = ABOVE_PLATING_PLANE
	layer = PULSEDEMON_LAYER

	see_in_dark = 8
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	health = 50
	maxHealth = 50
	speed = 1
	flying = 1
	size = SIZE_TINY
	density = 0 //people walk over you isntead of bumping

	attacktext = "electrocutes"
	attack_sound = "sparks"
	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0											//Handled in unarmed_attack_mob() anyways
	pass_flags = PASSDOOR //| PASSMOB									//Stops the message spam

	//VARS
	var/charge = 1000												//Charge stored
	var/maxcharge = 1000											//Max charge storable
	var/health_drain_rate = 5										//Health drained per tick when not on power source
	var/health_regen_rate = 5										//Health regenerated per tick when on power source
	var/amount_per_regen = 100										//Amount of power used to regenerate health
	var/charge_absorb_amount = 1000									//Amount of power sucked per tick
//	var/max_can_absorb = 10000										//Maximum amount that max charge can increase to
	var/takeover_time = 30											//Time spent taking over electronics
	var/show_desc = FALSE											//For the ability menu
	var/can_leave_cable = FALSE										//For the ability that lets you
	var/draining = TRUE												//For draining power or not
	var/move_divide = 16											//when unlocked, ability lets you move out of cables with a BIG slowdown
	var/powerloss_alerted = FALSE									//Prevent spam notifying
	var/health_lock = 0												//Goes down every tick, while this is on it prevents the Pulse Demon from regenerating

	//TYPES
	var/area/controlling_area										// Area controlled from an APC
	var/obj/structure/cable/current_cable							// Current cable we're on
	var/obj/machinery/power/current_power							// Current power machine we're in
	var/mob/living/silicon/robot/current_robot						// Currently controlled robot
	var/obj/machinery/bot/current_bot								// Currently controlled bot
	var/obj/item/weapon/current_weapon								// Current gun we're controlling

	//LISTS
	var/list/image/cables_shown = list()							// In cable views
	var/list/possible_spells = list()								// To be purchasable from ability menu
	var/list/datum/pulse_demon_upgrade/possible_upgrades = list()	// To be purchasable from ability menu

/mob/living/simple_animal/hostile/pulse_demon/New()
	..()
	// Must be spawned on a power source or cable, or else die
	current_power = locate(/obj/machinery/power) in loc
	if(!current_power)
		current_cable = locate(/obj/structure/cable) in loc
		if(!current_cable)
			death()
	else
		if(istype(current_power,/obj/machinery/power/apc))
			controlling_area = get_area(current_power)
		forceMove(current_power)
	set_light(1.5,2,"#bbbb00")
	add_spell(new /spell/pulse_demon/abilities, "pulsedemon_spell_ready", /obj/abstract/screen/movable/spell_master/pulse_demon)
	add_spell(new /spell/pulse_demon/toggle_drain, "pulsedemon_spell_ready", /obj/abstract/screen/movable/spell_master/pulse_demon)
	for(var/pd_spell in getAllPulseDemonSpells())
		var/spell/S = new pd_spell
		if(S.type != /spell/pulse_demon && S.type != /spell/pulse_demon/abilities && S.type != /spell/pulse_demon/toggle_drain)
			possible_spells += S
	for(var/pd_upgrade in subtypesof(/datum/pulse_demon_upgrade))
		var/datum/pulse_demon_upgrade/PDU = new pd_upgrade(src)
		possible_upgrades += PDU
	playsound(get_turf(src),'sound/effects/eleczap.ogg',50,1)

/mob/living/simple_animal/hostile/pulse_demon/update_perception()
	// So we can see in maint better
	if(client && client.darkness_planemaster)
		client.darkness_planemaster.alpha = 192
	update_cableview()

/mob/living/simple_animal/hostile/pulse_demon/regular_hud_updates()
	..()
	if(client && hud_used)
		if(!hud_used.vampire_blood_display)
			hud_used.pulsedemon_hud()
		hud_used.vampire_blood_display.maptext_width = WORLD_ICON_SIZE
		hud_used.vampire_blood_display.maptext_height = WORLD_ICON_SIZE
		hud_used.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:2px'>C:<br><font color='#FFFF00'>[charge/1000]kW</font></div>"

		if(healths)
			if (health >= maxHealth)
				healths.icon_state = "health0"
			else if (health >= 3*maxHealth/4)
				healths.icon_state = "health1"
			else if (health >= maxHealth/2)
				healths.icon_state = "health2"
			else if (health >= maxHealth/4)
				healths.icon_state = "health3"
			else if (health > 0)
				healths.icon_state = "health4"
			else
				healths.icon_state = "health5"

/mob/living/simple_animal/hostile/pulse_demon/Stat()
	..()
	if(statpanel("Status"))
		stat(null, text("Charge stored: [charge]W"))
		stat(null, text("Max charge stored: [maxcharge]W"))
		stat(null, text("Health: [health]/[maxHealth]"))
		stat(null, text("Draining power sources: [draining ? "Yes" : "No"]"))
		stat(null, text("Drain rate: [charge_absorb_amount]"))
		stat(null, text("APC takeover time: [takeover_time] seconds"))

/mob/living/simple_animal/hostile/pulse_demon/proc/update_glow()
	var/range = 2 + (log(2,charge+1)-log(2,50000)) / 2
	range = max(range, 1.5)  //negative lights due to logarithms when?
	//1.5 <= 25k
	//2   at 50k
	//2.5 at 100k
	//3   at 200k
	//3.5 at 400k, etc
	set_light(range, 2, "#bbbb00")

/mob/living/simple_animal/hostile/pulse_demon/proc/power_lost()
	health -= health_drain_rate
	if(!powerloss_alerted)
		to_chat(src, "You have lost power!")
		powerloss_alerted = TRUE
		//TODO add a sound

/mob/living/simple_animal/hostile/pulse_demon/proc/power_restored()
	if(!health_lock)
		var/health_to_add = maxHealth - health < health_regen_rate ? maxHealth - health : health_regen_rate
		if(health < maxHealth)
			health = min(maxHealth, health + health_to_add)
	if(powerloss_alerted)
		to_chat(src, "Power restored.")
		powerloss_alerted = FALSE
		//TODO add a sound

/mob/living/simple_animal/hostile/pulse_demon/Life()
	update_glow()
	if(health_lock)
		health_lock = max(--health_lock, 0)
		if(!health_lock) //Tell the Pulse Demon it's all good.
			to_chat(src, "<span class='good'>You can regenerate again!</span>")
	if(current_cable)
		if(current_cable.avail() < amount_per_regen) // Drain our health if powernet is dead, otherwise drain powernet
			power_lost()
		else
			power_restored()
			current_cable.add_load(amount_per_regen, POWER_PRIORITY_BYPASS)
	else if(current_power)
		if(istype(current_power,/obj/machinery/power/battery) && draining)
			var/obj/machinery/power/battery/current_battery = current_power
			suckBattery(current_battery)
		else if(istype(current_power,/obj/machinery/power/apc) && draining)
			var/obj/machinery/power/apc/current_apc = current_power
			drainAPC(current_apc)
		if(current_power.avail() < amount_per_regen)
			power_lost()
		else
			power_restored()
			//current_cable.add_load(amount_per_regen, POWER_PRIORITY_BYPASS) //TODO fix this, current cable is null and runtimes; i have no idea where else to draw power from
	else if(can_leave_cable) // Health drains if not on cable with leaving ability on
		health -= health_drain_rate
	else
		death() // Die if not in or on anything
	regular_hud_updates()
	standard_damage_overlay_updates()
	..()

/mob/living/simple_animal/hostile/pulse_demon/death(var/gibbed = 0)
	..()
	var/turf/T = get_turf(src)
	spark(src,rand(2,4))
	var/heavyemp_radius = min(charge/50000, 20)
	var/lightemp_radius = min(charge/25000, 25)
	empulse(T, heavyemp_radius, lightemp_radius)
	playsound(T,"pd_wail_sound",50,1)
	qdel(src) // We vaporise into thin air

/mob/living/simple_animal/hostile/pulse_demon/proc/is_under_tile()
	var/turf/simulated/floor/F = get_turf(src)
	return istype(F,/turf/simulated/floor) && F.floor_tile

/mob/living/simple_animal/hostile/pulse_demon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/obj/machinery/power/new_power = locate(/obj/machinery/power) in NewLoc
	var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in NewLoc
	if(!can_leave_cable) // If the ability isn't on
		if(!new_cable && !new_power) // Restrict movement to cables
			return
	var/moved = FALSE // To stop unnecessary forceMove calls
	if(..())
		moved = TRUE
	if(!is_under_tile() && prob(25))
		spark(src,rand(2,4))
	if(new_power)
		current_power = new_power
		current_cable = null
		forceMove(new_power.loc)
		playsound(src,'sound/weapons/electriczap.ogg',50, 1)
		spark(src,rand(2,4))
		if(istype(current_power,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/current_apc = current_power
			if(current_apc.occupant)
				to_chat(src,"<span class='warning'>Something else that isn't a pulse demon is already in here!</span>")
				return
			if(current_apc.pulsecompromised)
				controlling_area = get_area(current_power)
				to_chat(src, "<span class='notice'>You can interact with various electronic objects in the room while connected to the APC.</span>")
			else
				hijackAPC(current_apc)
			if(draining)
				to_chat(src,"<span class='notice'>You are now draining power from \the [current_power] and refilling charge.</span>")
		else if(istype(current_power,/obj/machinery/power/battery) && draining)
			to_chat(src,"<span class='notice'>You are now draining power from \the [current_power] and refilling charge.</span>")
	else
		if(new_cable)
			current_cable = new_cable
			current_power = null
			current_robot = null
			current_bot = null
			current_weapon = null
			if(!isturf(loc))
				loc = get_turf(NewLoc)
			controlling_area = null
			if(!moved)
				forceMove(NewLoc)
		else
			current_cable = null
			current_power = null
			current_robot = null
			current_bot = null
			current_weapon = null

/mob/living/simple_animal/hostile/pulse_demon/movement_tally_multiplier()
	. = ..()
	if(!current_cable && !current_power)
		. *= move_divide // Slower if not on cable
	else
		. *= 1

/obj/machinery/power/relaymove(mob/user, direction)
	if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
		var/mob/living/simple_animal/hostile/pulse_demon/PD = user
		var/turf/T = get_turf(src)
		var/turf/T2 = get_step(T,direction)
		if(locate(/obj/structure/cable) in T2 || PD.can_leave_cable) // Only move out if we're inside it and going in the right direction
			playsound(src,'sound/weapons/electriczap.ogg',50, 1)
			spark(src,rand(2,4))
			user.forceMove(get_turf(src))

// Proc for speaking as a borg
/mob/living/simple_animal/hostile/pulse_demon/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(.)
		return .

	if(current_robot)
		if (!speech.message)
			return 1
		current_robot.say(speech.message)
		speech.message = sanitize(speech.message)
		var/turf/T = get_turf(src)
		// Again, so no mistaken BWOINKs
		log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) made [current_robot]([key_name(current_robot)]) say: [speech.message]")
		log_admin("[key_name(src)] made [key_name(current_robot)] say: [speech.message]")
		message_admins("<span class='notice'>[key_name(src)] made [key_name(current_robot)] say: [speech.message]</span>")
		return 1 // This ensures we don't end up speaking by ourselves too

	else if(current_bot && istype(current_bot,/obj/machinery/bot/buttbot))
		if (!speech.message)
			return 1
		var/obj/machinery/bot/buttbot/BB = current_bot
		if(prob(BB.buttchance) && !findtext(speech.message,"butt"))
			sleep(rand(1,3))
			BB.say(buttbottify(speech.message, 3, 9)) // 3 times as intense
			BB.fart()
			score.buttbotfarts++
			return 1 // This ensures we don't end up speaking by ourselves too

	else
		playsound(loc, "[pick(emote_sound)]", 50, 1) // Play sound if in an intercom or not
		var/radio = locate(/obj/item/device/radio) in loc
		var/holopad = locate(/obj/machinery/hologram/holopad) in loc
		if(!radio && !holopad) // if not in a machine you can speak out of, just sizzle
			emote("me", MESSAGE_HEAR, "[pick(emote_hear)].") // Just do normal NPC emotes if not in them
			return 1 // To stop speaking normally

// Helper stuff for attacks
/mob/living/simple_animal/hostile/pulse_demon/hasFullAccess()
	return 1

/mob/living/simple_animal/hostile/pulse_demon/GetAccess()
	return get_all_accesses()

/mob/living/simple_animal/hostile/pulse_demon/dexterity_check()
	return TRUE

/mob/living/simple_animal/hostile/pulse_demon/ex_act(severity)
	return

// We aren't tangible
/mob/living/simple_animal/hostile/pulse_demon/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class ='warning'>The [Proj] goes right through \the [src]!</span>")
	return

// Dumb moves
/mob/living/simple_animal/hostile/pulse_demon/kick_act(mob/living/carbon/human/user)
	if(!is_under_tile())
		visible_message("<span class ='notice'>[user]'s foot goes right through \the [src]!</span>")
		shockMob(user)

/mob/living/simple_animal/hostile/pulse_demon/bite_act(mob/living/carbon/human/user)
	if(!is_under_tile())
		visible_message("<span class ='notice'>[user] attempted to taste \the [src], for no particular reason, and got rightfully burned.</span>")
		shockMob(user)

/mob/living/simple_animal/hostile/pulse_demon/PreImpact(atom/movable/A, speed) //don't get hit by thrown stuff
	return TRUE

/mob/living/simple_animal/hostile/pulse_demon/electrocute_act() //don't get killed by powercreeper vines
	return

/mob/living/simple_animal/hostile/pulse_demon/check_airflow_movable()
	return FALSE

// Our one weakness
/mob/living/simple_animal/hostile/pulse_demon/emp_act(severity)
	visible_message("<span class ='danger'>[src] [pick("fizzles","wails","flails")] in anguish!</span>")
	to_chat(src, "<span class='warning'>You have been blasted by an EMP and cannot regenerate for a while!</span>")
	playsound(get_turf(src),"pd_wail_sound",50,1)
	health -= round(max(25, round(maxHealth/4)), 1) //Takes 1/4th of max health as damage if health is big enough
	health_lock = 5 //EMP prevents the Pulse Demon from regenerating

// Shock therapy
/mob/living/simple_animal/hostile/pulse_demon/attack_hand(mob/living/carbon/human/M as mob)
	if(!is_under_tile())
		switch(M.a_intent)
			if(I_HELP)
				visible_message("<span class ='notice'>[M] [response_help] [src].</span>")
			if(I_GRAB,I_DISARM)
				visible_message("<span class ='notice'>[M] [response_disarm] [src].</span>")
			if(I_HURT)
				visible_message("<span class='warning'>[M] [response_harm] [src]!</span>")
		unarmed_attack_mob(M)

// Still not tangible
/mob/living/simple_animal/hostile/pulse_demon/attackby(obj/item/W as obj, mob/user as mob)
	if(!is_under_tile())
		var/obj/item/weapon/cell/C = W.get_cell()
		if(C && C.charge)
			C.use(charge_absorb_amount)
			to_chat(user, "<span class='warning'>You touch \the [src] with \the [W] and \the [src] drains it!</span>")
			to_chat(src, "<span class='notice'>[user] touches you with \the [W] and you drain its power!</span>")
		visible_message("<span class ='notice'>The [W] goes right through \the [src].</span>")
		shockMob(user,W.siemens_coefficient)

// In our way
/mob/living/simple_animal/hostile/pulse_demon/to_bump(var/atom/obstacle)
	if(!is_under_tile() && isliving(obstacle))
		var/mob/living/L = obstacle
		shockMob(L) // Shock any mob in our path
	else
		return ..()

// ZAP
/mob/living/simple_animal/hostile/pulse_demon/unarmed_attack_mob(mob/living/target)
	if(!is_under_tile() && target != src)
		do_attack_animation(target, src)
		shockMob(target)
		INVOKE_EVENT(src, /event/unarmed_attack, "attacker" = target, "attacked" = src)

// For AI, also to stop us smashing tables
/mob/living/simple_animal/hostile/pulse_demon/UnarmedAttack(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		unarmed_attack_mob(L)

// We don't do these
/mob/living/simple_animal/hostile/pulse_demon/RangedAttack(atom/A)
	return

// Common function for all
/mob/living/simple_animal/hostile/pulse_demon/proc/shockMob(mob/living/carbon/human/M as mob, var/siemens_coeff = 1)
	var/dmg_done = 0
	// Powernet damage
	if(current_cable && current_cable.powernet && current_cable.powernet.avail)
		dmg_done = electrocute_mob(M, current_cable.powernet, src, siemens_coeff) / 20 //Inverting multiplier of damage done in proc
	// Otherwise use our charge reserve, if any
	else if(charge < 1000)
		to_chat(src,"<span class='warning'>Not enough charge or power on grid to shock with.</span>")
		return
	else
		dmg_done = M.electrocute_act(30, src, siemens_coeff) // Basic attack
		charge -= 1000
	add_logs(src, M, "shocked ([dmg_done]dmg)", admin = (src.ckey && M.ckey) ? TRUE : FALSE) //Only add this to the server logs if both mobs were controlled by player

// Called in entering an APC
/mob/living/simple_animal/hostile/pulse_demon/proc/hijackAPC(var/obj/machinery/power/apc/current_apc)
	to_chat(src,"<span class='notice'>You are now attempting to hack \the [current_apc], this will take approximately [takeover_time] seconds.</span>")
	current_apc.pulsecompromising = 1
	if(do_after(src,current_apc,takeover_time*10))
		current_apc.pulsecompromising = 0
		current_apc.pulsecompromised = 1
		controlling_area = get_area(current_power)
		to_chat(src,"<span class='notice'>Takeover complete.</span>")
		// Add to the stats if we can
		if(mind && mind.GetRole(PULSEDEMON))
			var/datum/role/pulse_demon/PD = mind.GetRole(PULSEDEMON)
			if(PD)
				PD.controlled_apcs.Add(current_apc)
				to_chat(src,"<span class='notice'>You are now controlling [PD.controlled_apcs.len] APCs.</span>")
	else
		current_apc.pulsecompromising = 0

// Called in Life() per tick
/mob/living/simple_animal/hostile/pulse_demon/proc/suckBattery(var/obj/machinery/power/battery/current_battery)
	var/max_can_absorb = current_battery.outputlevel //only raise maxcharge up to the SMES' output level
	var/amount_to_drain = charge_absorb_amount * 10 //so you don't need to idle for 10 minutes
	if(current_battery.charge <= amount_to_drain)
		amount_to_drain = current_battery.charge
	if(maxcharge <= max_can_absorb && charge >= maxcharge)
		maxcharge = min(maxcharge + amount_to_drain, max_can_absorb)
	var/amount_added = min(maxcharge-charge,amount_to_drain)
	charge += amount_added
	current_battery.charge -= amount_added
	// Add to stats if any
	if(mind && mind.GetRole(PULSEDEMON))
		var/datum/role/pulse_demon/PD = mind.GetRole(PULSEDEMON)
		if(PD)
			PD.charge_absorbed += amount_added

// This too
/mob/living/simple_animal/hostile/pulse_demon/proc/drainAPC(var/obj/machinery/power/apc/current_apc)
	//draining APC batteries has no upper limit on maxpower due to uhhh galvanic isolation
	var/amount_to_drain = charge_absorb_amount
	// Cap conditions
	if(current_apc.cell.charge <= amount_to_drain)
		amount_to_drain = current_apc.cell.charge
	maxcharge += amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER //multiplier to balance the pitiful powercells in APCs
	charge += amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER
	current_apc.cell.use(amount_to_drain)

	// Add to stats if any
	if(mind && mind.GetRole(PULSEDEMON))
		var/datum/role/pulse_demon/PD = mind.GetRole(PULSEDEMON)
		if(PD)
			PD.charge_absorbed += amount_to_drain

// Helper for client image managing
/mob/living/simple_animal/hostile/pulse_demon/proc/update_cableview()
	// Make sure we have a client
	if(client)
		// Reset this
		for(var/image/current_image in cables_shown)
			client.images -= current_image
		cables_shown.Cut()
		// Go through all powernets in the game
		for(var/datum/powernet/current_net in powernets)
			// Add all the cables on the powernet to our images, that's why we have this var
			for(var/obj/structure/cable/C in current_net.cables)
				var/image/CI = image(C, get_turf(C), layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
				// Easy visibility here
				CI.plane = ABOVE_LIGHTING_PLANE
				cables_shown += CI
				client.images += CI
