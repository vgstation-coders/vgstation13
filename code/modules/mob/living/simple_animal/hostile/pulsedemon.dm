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
    speed = 0.75
    move_to_delay = 1
    size = SIZE_TINY

    attacktext = "electrocutes"
    attack_sound = "sparks"
    harm_intent_damage = 0
    melee_damage_lower = 0
    melee_damage_upper = 0 //Handled in unarmed_attack_mob() anyways

    var/charge = 1000
    var/maxcharge = 1000
    var/health_drain_rate = 5
    var/amount_per_regen = 100
    var/takeover_time = 30
    var/area/controlling_area
    var/obj/structure/cable/current_cable
    var/datum/powernet/current_net
    var/datum/powernet/previous_net
    var/obj/machinery/power/current_power
    var/can_move=1
    var/list/image/cables_shown = list()

/mob/living/simple_animal/hostile/pulse_demon/New()
    ..()
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

/mob/living/simple_animal/hostile/pulse_demon/update_perception()
    if(client && client.darkness_planemaster)
        client.darkness_planemaster.alpha = 192    
    update_cableview()

/mob/living/simple_animal/hostile/pulse_demon/Life()
    if(current_power)
        if(current_power.avail() > amount_per_regen)
            current_power.add_load(amount_per_regen)
        else
            health -= health_drain_rate
    else
        if(current_cable)
            if(current_cable.avail() > amount_per_regen)
                current_cable.add_load(amount_per_regen)
            else
                health -= health_drain_rate
        else
            death()
    ..()

/mob/living/simple_animal/hostile/pulse_demon/death(var/gibbed = 0)
    ..()
    qdel(src)

/mob/living/simple_animal/hostile/pulse_demon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
    if(!locate(/obj/structure/cable) in NewLoc || !locate(/obj/machinery/power) in NewLoc)
        return
    ..()
    var/turf/simulated/floor/F = get_turf(src)
    if(istype(F,/turf/simulated/floor) && !F.floor_tile && prob(25))
        spark(src,rand(2,4))
    var/obj/machinery/power/new_power = locate(/obj/machinery/power) in NewLoc
    if(new_power && !current_power)
        loc = new_power
        current_power = new_power
        current_cable = null
        playsound(src,'sound/weapons/electriczap.ogg',50, 1)
        spark(src,rand(2,4))
        if(istype(current_power,/obj/machinery/power/apc))
            var/obj/machinery/power/apc/current_apc = current_power
            if(current_apc.pulsecompromised)
                controlling_area = get_area(current_power)
            else
                to_chat(src,"<span class='notice'>You are now attempting to hack \the [current_apc], this will take approximately [takeover_time] seconds.</span>")
                if(do_after(src,current_apc,takeover_time*10))
                    current_apc.pulsecompromised = 1
                    controlling_area = get_area(current_power)
                    to_chat(src,"<span class='notice'>Takeover complete.</span>")
                    if(mind && mind.antag_roles.len)
                        var/datum/role/pulse_demon/PD = locate(/datum/role/pulse_demon) in mind.antag_roles
                        if(PD)
                            PD.controlled_apcs.Add(current_apc)
                            to_chat(src,"<span class='notice'>You are now controlling [PD.controlled_apcs.len] APCs.</span>")
    else
        var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in NewLoc
        if(new_cable)
            current_cable = new_cable
            previous_net = current_net
            current_net = current_cable.get_powernet()
            current_power = null
            if(!isturf(loc))
                loc = get_turf(NewLoc)
            controlling_area = null
            update_cableview()

/mob/living/simple_animal/hostile/pulse_demon/to_bump(var/atom/obstacle) // Copied from how adminbus does it
    if(can_move && !locate(/obj/machinery/power) in get_turf(obstacle))
        can_move = 0
        forceMove(get_step(src,src.dir))
        sleep(1)
        can_move = 1
    else
        return ..()

/mob/living/simple_animal/hostile/pulse_demon/Crossed(mob/user)
    var/turf/simulated/floor/F = get_turf(src)
    if(istype(F,/turf/simulated/floor) && !F.floor_tile && user != src && isliving(user))
        shockMob(user)
    return ..()

/obj/machinery/power/relaymove(mob/user, direction)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        var/turf/T = get_turf(src)
        var/turf/T2 = get_step(T,direction)
        if(locate(/obj/structure/cable) in T2)
            playsound(src,'sound/weapons/electriczap.ogg',50, 1)
            spark(src,rand(2,4))
            user.forceMove(get_turf(src))

/atom/proc/attack_pulsedemon(mob/user)
    return

/obj/machinery/attack_pulsedemon(mob/user)
    return attack_ai(user)

/obj/machinery/computer/security/attack_pulsedemon(mob/user)
    return attack_hand(user)

/obj/machinery/computer/arcade/attack_pulsedemon(mob/user)
    user.loc = src
    playertwo = user
	var/dat = game.get_p2_dat()

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")

/obj/machinery/camera/attack_pulsedemon(mob/user)
    user.loc = src
    user.change_sight(adding = vision_flags)

/obj/machinery/power/apc/attack_pulsedemon(mob/user)
    if(user.loc != src)
        user.loc = src
        user.change_sight(removing = SEE_TURFS | SEE_MOBS | SEE_OBJS)

/mob/living/simple_animal/hostile/pulse_demon/ClickOn(var/atom/A, var/params)
    if(get_area(A) == controlling_area)
        A.attack_pulsedemon(src)
    else if(ismob(A) || ismecha(A) || isvehicle(A))
        ..()

/mob/living/silicon/hasFullAccess()
	return 1

/mob/living/silicon/GetAccess()
	return get_all_accesses()

/mob/living/simple_animal/hostile/pulse_demon/dexterity_check()
	return TRUE

/mob/living/simple_animal/hostile/pulse_demon/Process_Spacemove(var/check_drift = 0)
	return TRUE

/mob/living/simple_animal/hostile/pulse_demon/ex_act(severity)
    return

/mob/living/simple_animal/hostile/pulse_demon/bullet_act(var/obj/item/projectile/Proj)
    visible_message("<span class ='warning'>The [Proj] goes right through \the [src]!</span>")
    return

/mob/living/simple_animal/hostile/pulse_demon/kick_act(mob/living/carbon/human/user)
    visible_message("<span class ='notice'>[user]'s foot goes right through \the [src]!</span>")
    shockMob(user)

/mob/living/simple_animal/hostile/pulse_demon/bite_act(mob/living/carbon/human/user)
    visible_message("<span class ='notice'>[user] attempted to taste \the [src], for no particular reason, and got rightfully burned.</span>")
    shockMob(user)

/mob/living/simple_animal/hostile/pulse_demon/emp_act(severity)
    visible_message("<span class ='danger'>[src] [pick("fizzles","wails","flails")] in anguish!</span>")
    health -= rand(20,25) / severity

/mob/living/simple_animal/hostile/pulse_demon/attack_hand(mob/living/carbon/human/M as mob)
    switch(M.a_intent)
        if(I_HELP)
            visible_message("<span class ='notice'>[M] [response_help] [src].</span>")
        if(I_GRAB||I_DISARM)
            visible_message("<span class ='notice'>[M] [response_disarm] [src].</span>")
        if(I_HURT)
            visible_message("<span class='warning'>[M] [response_harm] [src]!</span>")
    shockMob(M)

/mob/living/simple_animal/hostile/pulse_demon/unarmed_attack_mob(mob/living/target)
    shockMob(target)
    ..()

/mob/living/simple_animal/hostile/pulse_demon/proc/shockMob(mob/living/carbon/human/M as mob)
    if(current_net && current_net.avail)
        electrocute_mob(M, current_net, src, 2)
    else
        M.electrocute_act(30, src, 2)

/mob/living/simple_animal/hostile/pulse_demon/proc/update_cableview()
    if(client && (current_net != previous_net))
        for(var/image/current_image in cables_shown)
            client.images -= current_image
        if(current_cable)
            for(var/obj/structure/cable/C in current_net.cables)
                var/turf/simulated/floor/F = get_turf(C)
                if(istype(F,/turf/simulated/floor) && F.floor_tile)
                    var/image/CI = image(C, C.loc, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
                    CI.plane = ABOVE_LIGHTING_PLANE
                    cables_shown += CI
                    client.images += CI