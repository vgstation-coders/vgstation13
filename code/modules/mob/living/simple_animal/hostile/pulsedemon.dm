/mob/living/simple_animal/hostile/pulse_demon
    name = "pulse demon"
    desc = "A strange electrical apparition that lives in wires."
    icon_state = "pulsedem"
    icon_living = "pulsedem"
    icon_dead = "pulsedem" // Should never be seen but just in case
    speak_chance = 20
    emote_hear = list("vibrates", "sizzles")
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
    size = SIZE_TINY

    attacktext = "electrocutes"
    attack_sound = "sparks"
    harm_intent_damage = 0
    melee_damage_lower = 0
    melee_damage_upper = 0                                          //Handled in unarmed_attack_mob() anyways
    pass_flags = PASSDOOR                                           //Stops the message spam

    //VARS
    var/charge = 1000                                               //Charge stored
    var/maxcharge = 1000                                            //Max charge storable
    var/health_drain_rate = 5                                       //Health drained per tick when not on power source
    var/health_regen_rate = 5                                       //Health regenerated per tick when on power source
    var/amount_per_regen = 100                                      //Amount of power used to regenerate health
    var/charge_absorb_amount = 1000                                 //Amount of power sucked per tick
    var/max_can_absorb = 10000                                      //Maximum amount that max charge can increase to
    var/takeover_time = 30                                          //Time spent taking over electronics
    var/show_desc = FALSE                                           //For the ability menu
    var/can_leave_cable = FALSE                                     //For the ability that lets you
    var/move_divide = 4                                             //For slowing down of above

    //TYPES
    var/area/controlling_area                                       // Area controlled from an APC
    var/obj/structure/cable/current_cable                           // Current cable we're on
    var/datum/powernet/current_net                                  // Powernet for cableview to update
    var/datum/powernet/previous_net                                 // Old net to check against current one for cable view update
    var/obj/machinery/power/current_power                           // Current power machine we're in
    var/mob/living/silicon/robot/current_robot                      // Currently controlled robot
    var/obj/item/weapon/current_weapon                              // Current gun we're controlling

    //LISTS
    var/list/image/cables_shown = list()                            // In cable views
    var/list/possible_spells = list()                               // To be purchasable from ability menu
    var/list/datum/pulse_demon_upgrade/possible_upgrades = list()   // To be purchasable from ability menu

/mob/living/simple_animal/hostile/pulse_demon/New()
    ..()
    // Must be spawned on a power source or cable, or else die
    current_power = locate(/obj/machinery/power) in loc
    if(!current_power)
        current_cable = locate(/obj/structure/cable) in loc
        if(!current_cable)
            death()
        else
            current_net = current_cable.get_powernet()
    else
        current_net = current_power.get_powernet()
        if(istype(current_power,/obj/machinery/power/apc))
            controlling_area = get_area(current_power)
        forceMove(current_power)
    set_light(2,2,"#bbbb00")
    add_spell(new /spell/pulse_demon/abilities, "pulsedemon_spell_ready", /obj/abstract/screen/movable/spell_master/pulse_demon)
    for(var/pd_spell in getAllPulseDemonSpells())
        var/spell/S = new pd_spell
        if(S.type != /spell/pulse_demon && S.type != /spell/pulse_demon/abilities)
            possible_spells += S
    for(var/pd_upgrade in subtypesof(/datum/pulse_demon_upgrade))
        var/datum/pulse_demon_upgrade/PDU = new pd_upgrade(src)
        possible_upgrades += PDU
    playsound(get_turf(src),'sound/effects/eleczap.ogg',50,1)

/mob/living/simple_animal/hostile/pulse_demon/update_perception()
    // So we can see in maint better
    if(dark_plane)
        dark_plane.alphas["pulse_demon"] = 192
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

/mob/living/simple_animal/hostile/pulse_demon/Life()
    // Add the regen rate unless it puts us over max health, then just cap it off
    var/health_to_add = maxHealth - health < health_regen_rate ? maxHealth - health : health_regen_rate
    if(current_cable)
        if(current_cable.avail() > amount_per_regen) // Drain our health if powernet is dead, otherwise drain powernet
            current_cable.add_load(amount_per_regen)
            if(health < maxHealth)
                health += health_to_add
        else
            health -= health_drain_rate
    else if(current_power)
        if(istype(current_power,/obj/machinery/power/battery))
            var/obj/machinery/power/battery/current_battery = current_power
            suckBattery(current_battery)
        else if(istype(current_power,/obj/machinery/power/apc))
            var/obj/machinery/power/apc/current_apc = current_power
            drainAPC(current_apc)
        else if(current_power.avail() > amount_per_regen)
            current_power.add_load(amount_per_regen)
            if(health < maxHealth)
                health += health_to_add
        else
            health -= health_drain_rate
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
    empulse(T,4,8)
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
        loc = new_power
        playsound(src,'sound/weapons/electriczap.ogg',50, 1)
        spark(src,rand(2,4))
        if(istype(current_power,/obj/machinery/power/apc))
            var/obj/machinery/power/apc/current_apc = current_power
            if(current_apc.occupant)
                to_chat(src,"<span class='warning'>Something else that isn't a pulse demon is already in here!</span>")
                return
            max_can_absorb = current_apc.cell.maxcharge
            if(current_apc.pulsecompromised)
                controlling_area = get_area(current_power)
            else
                hijackAPC(current_apc)
        else if(istype(current_power,/obj/machinery/power/battery))
            var/obj/machinery/power/battery/current_battery = current_power
            to_chat(src,"<span class='notice'>You are now draining power from \the [current_power] and refilling charge.</span>")
            max_can_absorb = current_battery.output
    else
        if(new_cable)
            current_cable = new_cable
            previous_net = current_net
            current_net = current_cable.get_powernet()
            current_power = null
            current_robot = null
            current_weapon = null
            if(!isturf(loc))
                loc = get_turf(NewLoc)
            controlling_area = null
            update_cableview()
            if(!moved)
                forceMove(NewLoc)
        else
            current_cable = null
            current_power = null
            current_robot = null
            current_weapon = null

/mob/living/simple_animal/hostile/pulse_demon/movement_tally_multiplier()
    . = ..()
    if(!current_cable && !current_power)
        . *= move_divide // Slower if not on cable
    else
        . *= 1

/mob/living/simple_animal/hostile/pulse_demon/to_bump(var/atom/obstacle)
    if(!is_under_tile() && isliving(obstacle))
        var/mob/living/L = obstacle
        shockMob(L) // Shock any mob in our path
    else
        return ..()

/obj/machinery/power/relaymove(mob/user, direction)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/turf/T = get_turf(src)
        var/turf/T2 = get_step(T,direction)
        if(locate(/obj/structure/cable) in T2) // Only move out if we're inside it and going in the right direction
            playsound(src,'sound/weapons/electriczap.ogg',50, 1)
            spark(src,rand(2,4))
            user.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/pulse_demon/ClickOn(var/atom/A, var/params)
    if(!spell_channeling) // Abort if we're doing spell stuff
        if(get_area(A) == controlling_area) // Only in APC areas
            var/list/modifiers = params2list(params) // For doors and other AI stuff
            if(modifiers["middle"])
                if(modifiers["shift"])
                    MiddleShiftClickOn(A)
                    return
                else
                    MiddleClickOn(A)
                    return
            if(modifiers["shift"])
                ShiftClickOn(A)
                return
            if(modifiers["alt"]) // alt and alt-gr (rightalt)
                AltClickOn(A)
                return
            if(modifiers["ctrl"])
                CtrlClickOn(A)
                return
            A.attack_pulsedemon(src)
        else if(current_weapon)
            if(istype(current_weapon,/obj/item/weapon/gun))
                var/obj/item/weapon/gun/G = current_weapon
                G.Fire(A,src) // Shoot at something if we're in a weapon
        else if(current_robot) // Do APC stuff if in a borg
            log_admin("[key_name(src)] made [key_name(current_robot)] attack [A]") // Just so admins don't bwoink them in confusion
            message_admins("<span class='notice'>[key_name(src)] made [key_name(current_robot)] attack [A]</span>")
            var/list/modifiers = params2list(params)
            if(modifiers["middle"])
                if(modifiers["shift"])
                    MiddleShiftClickOn(A)
                    return
                else
                    MiddleClickOn(A)
                    return
            if(modifiers["shift"])
                ShiftClickOn(A)
                return
            if(modifiers["alt"]) // alt and alt-gr (rightalt)
                AltClickOn(A)
                return
            if(modifiers["ctrl"])
                CtrlClickOn(A)
                return

            A.attack_robot(current_robot)
        else if(isliving(A))
            ..()
    else
        spell_channeling.channeled_spell(A) // Handle spell stuff

// Do AI stuff for this
/mob/living/simple_animal/hostile/pulse_demon/ShiftClickOn(var/atom/A)
    if(get_area(A) == controlling_area)
        A.AIShiftClick(src)

/mob/living/simple_animal/hostile/pulse_demon/CtrlClickOn(var/atom/A)
    if(get_area(A) == controlling_area)
        A.AICtrlClick(src)

/mob/living/simple_animal/hostile/pulse_demon/AltClickOn(var/atom/A)
    if(get_area(A) == controlling_area)
        A.AIAltClick(src)

/mob/living/simple_animal/hostile/pulse_demon/MiddleShiftClickOn(var/atom/A)
    if(get_area(A) == controlling_area)
        A.AIMiddleShiftClick(src)

// Proc that allows special pulse demon functionality
/atom/proc/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    return

// Most machinery just does normal AI attacks
/obj/machinery/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    return attack_ai(user)

// Except cams, which block you from viewing them otherwise
/obj/machinery/computer/security/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    return attack_hand(user)

// Lets you be "player two" against a human
/obj/machinery/computer/arcade/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    playertwo = user
    var/dat = game.get_p2_dat()
    user << browse(dat, "window=arcade")
    onclose(user, "arcade")

// Lets you view from these, and inherit view properties like xray if any
/obj/machinery/camera/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    user.loc = src
    user.change_sight(adding = vision_flags)

// Lets you take over a weapon to fire
/obj/machinery/recharger/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    user.loc = src
    if(charging)
        to_chat(user,"<span class='notice'>You are now attempting to hijack \the [charging], this will take approximately [user.takeover_time] seconds.</span>")
        if(do_after(user,src,user.takeover_time*10))
            to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
            user.loc = charging
            user.current_weapon = charging
    else
        to_chat(user,"<span class='warning'>There is no weapon charging.</span>")

// Lets you take over a cell to rig, as if injected by plasma
/obj/machinery/cell_charger/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    user.loc = src
    if(charging && !charging.rigged && !charging.occupant)
        to_chat(user,"<span class='notice'>You are now attempting to hijack \the [charging], this will take approximately [user.takeover_time] seconds.</span>")
        // Go in instantly if already rigged, else hijack timer
        if(!charging.rigged)
            if(do_after(user,src,user.takeover_time*10))
                to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
                user.loc = charging
                charging.occupant = user
                charging.rigged = 1
        else
            to_chat(user,"<span class='notice'>You are now inside \the [charging].</span>")
            user.loc = charging
            charging.occupant = user
    else if(charging)
        to_chat(user,"<span class='warning'>There is already something in this cell.</span>")
    else
        to_chat(user,"<span class='warning'>There is no cell charging.</span>")

// Lets you take over a borg, to override its targeting and speech
/obj/machinery/recharge_station/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    user.loc = src
    if(occupant && istype(occupant,/mob/living/silicon/robot))
        var/mob/living/silicon/robot/R = occupant
        // Go in instantly if already compromised, else hijack timer
        if(!R.pulsecompromised)
            to_chat(user,"<span class='notice'>You are now attempting to hijack \the [R]'s targeting module, this will take approximately [user.takeover_time] seconds.</span>")
            to_chat(R,"<span class='danger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACK IN PROGRESS</span>")
            if(do_after(user,src,user.takeover_time*10))
                if(occupant)
                    to_chat(user,"<span class='notice'>You are now inside \the [R], in control of its targeting.</span>")
                    R.pulsecompromised = 1
                    user.loc = R
                    user.current_robot = R
                    to_chat(R, "<span class='danger'>ERRORERRORERROR</span>")
                    sleep(20)
                    to_chat(R, "<span class='danger'>TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY IN VERBAL FORM</span>")
        else
            to_chat(user,"<span class='notice'>You are now inside \the [R], in control of its targeting.</span>")
            user.loc = R
            user.current_robot = R
    else
        to_chat(user,"<span class='warning'>There is no silicon-based occupant inside.</span>")

// Lets you go back into the APC, and also removes cam stuff
/obj/machinery/power/apc/attack_pulsedemon(mob/living/simple_animal/hostile/pulse_demon/user)
    if(user.loc != src)
        user.loc = src
        user.change_sight(removing = SEE_TURFS | SEE_MOBS | SEE_OBJS)

// Proc for speaking as a borg
/mob/living/simple_animal/hostile/pulse_demon/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
    . = ..()
    if(.)
        return .

    if(current_robot)
        if (!speech.message)
            return

        current_robot.say(speech.message)
        speech.message = sanitize(speech.message)
        var/turf/T = get_turf(src)
        // Again, so no mistaken BWOINKs
        log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) made [current_robot]([key_name(current_robot)]) say: [speech.message]")
        log_admin("[key_name(src)] made [key_name(current_robot)] say: [speech.message]")
        message_admins("<span class='notice'>[key_name(src)] made [key_name(current_robot)] say: [speech.message]</span>")

    else
        to_chat(src, "You have no hijacked robot to speak with.")
        return 1 //this ensures we don't end up speaking out loud

// Helper stuff for attacks
/mob/living/simple_animal/hostile/pulse_demon/hasFullAccess()
	return 1

/mob/living/simple_animal/hostile/pulse_demon/GetAccess()
	return get_all_accesses()

/mob/living/simple_animal/hostile/pulse_demon/dexterity_check()
	return TRUE

// We aren't a normal living thing
/mob/living/simple_animal/hostile/pulse_demon/Process_Spacemove(var/check_drift = 0)
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

// Our one weakness
/mob/living/simple_animal/hostile/pulse_demon/emp_act(severity)
    visible_message("<span class ='danger'>[src] [pick("fizzles","wails","flails")] in anguish!</span>")
    playsound(get_turf(src),"pd_wail_sound",50,1)
    health -= rand(20,25) / severity

// Shock therapy
/mob/living/simple_animal/hostile/pulse_demon/attack_hand(mob/living/carbon/human/M as mob)
    if(!is_under_tile())
        switch(M.a_intent)
            if(I_HELP)
                visible_message("<span class ='notice'>[M] [response_help] [src].</span>")
            if(I_GRAB||I_DISARM)
                visible_message("<span class ='notice'>[M] [response_disarm] [src].</span>")
            if(I_HURT)
                visible_message("<span class='warning'>[M] [response_harm] [src]!</span>")
        unarmed_attack_mob(M)

// ZAP
/mob/living/simple_animal/hostile/pulse_demon/unarmed_attack_mob(mob/living/target)
    if(!is_under_tile())
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

/mob/living/simple_animal/hostile/pulse_demon/proc/shockMob(mob/living/carbon/human/M as mob)
    var/dmg_done = 0
    // Powernet damage
    if(current_net && current_net.avail)
        dmg_done = electrocute_mob(M, current_net, src, 1) / 20 //Inverting multiplier of damage done in proc
    // Otherwise use our charge reserve, if any
    else if(charge < 1000)
        to_chat(src,"<span class='warning'>Not enough charge or power on grid to shock with.</span>")
        return
    else
        dmg_done = M.electrocute_act(30, src, 1) // Basic attack
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
    var/amount_to_drain = charge_absorb_amount
    // Cap conditions
    if(current_battery.charge <= charge_absorb_amount)
        amount_to_drain = current_battery.charge
    if(maxcharge <= max_can_absorb && charge >= maxcharge)
        maxcharge += amount_to_drain
    else if(charge >= maxcharge)
        amount_to_drain = 0
    current_battery.charge -= amount_to_drain
    var/amount_added = min((maxcharge-charge),amount_to_drain)
    charge += amount_added
    // Add to stats if any
    if(mind && mind.GetRole(PULSEDEMON))
        var/datum/role/pulse_demon/PD = mind.GetRole(PULSEDEMON)
        if(PD)
            PD.charge_absorbed += amount_added

// This too
/mob/living/simple_animal/hostile/pulse_demon/proc/drainAPC(var/obj/machinery/power/apc/current_apc)
    var/amount_to_drain = charge_absorb_amount
    // Cap conditions
    if(current_apc.cell.charge <= charge_absorb_amount)
        amount_to_drain = current_apc.cell.charge
    if(maxcharge <= max_can_absorb && charge >= maxcharge)
        maxcharge += amount_to_drain
    else if(charge >= maxcharge)
        amount_to_drain = 0
    current_apc.cell.use(amount_to_drain)
    var/amount_added = min((maxcharge-charge),amount_to_drain)
    charge += amount_added
    // Add to stats if any
    if(mind && mind.GetRole(PULSEDEMON))
        var/datum/role/pulse_demon/PD = mind.GetRole(PULSEDEMON)
        if(PD)
            PD.charge_absorbed += amount_added

// Helper for client image managing
/mob/living/simple_animal/hostile/pulse_demon/proc/update_cableview()
    // Make sure we're on a new net and have a client
    if(client && (current_net != previous_net))
        // Reset this
        for(var/image/current_image in cables_shown)
            client.images -= current_image
        if(current_cable)
            // Add all the cables on the powernet to our images, that's why we have this var
            for(var/obj/structure/cable/C in current_net.cables)
                var/turf/simulated/floor/F = get_turf(C)
                // Untiled ones only, otherwise redundant
                if(istype(F,/turf/simulated/floor) && F.floor_tile)
                    var/image/CI = image(C, C.loc, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
                    // Easy visibility here
                    CI.plane = ABOVE_LIGHTING_PLANE
                    cables_shown += CI
                    client.images += CI
