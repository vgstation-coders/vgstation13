/mob/living/simple_animal/hostile/pulse_demon
    name = "pulse demon"
    desc = "A strange electrical apparition that lives in wires."
    icon_state = "pulsedem"
    icon_living = "pulsedem"
    icon_dead = "pulsedem_dead" // Should never be seen but just in case
    speak_chance = 20
    emote_hear = list("vibrates", "sizzles")
    response_help = "reaches their hand into"
    response_disarm = "pushes their hand through"
    response_harm = "punches their fist through"
    plane = ABOVE_PLATING_PLANE
    layer = PULSEDEMON_LAYER

    health = 50
    maxHealth = 50
    speed = 0.75
    move_to_delay = 1
    size = SIZE_TINY

    attacktext = "electrocutes"
    attack_sound = "sparks"

    var/charge = 1000
    var/maxcharge = 1000
    var/health_drain_rate = 5
    var/amount_per_regen = 100
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
            update_cableview()
    else
        current_net = current_power.get_powernet()
        if(istype(current_power,/obj/machinery/power/apc))
            controlling_area = get_area(current_power)
        forceMove(current_power)
    set_light(2,2,"#bbbb00")
    
/mob/living/simple_animal/hostile/pulse_demon/Life()
    current_power = locate(/obj/machinery/power) in loc
    if(current_power)
        if(current_power.avail() > amount_per_regen)
            current_power.add_load(amount_per_regen)
        else
            health -= health_drain_rate
    else
        current_cable = locate(/obj/structure/cable) in loc
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
    var/obj/machinery/power/new_power = locate(/obj/machinery/power) in NewLoc
    if(new_power && !current_power)
        current_power = new_power
        current_cable = null
        if(istype(current_power,/obj/machinery/power/apc))
            controlling_area = get_area(current_power)
        forceMove(current_power)
    else
        var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in NewLoc
        if(new_cable)
            current_cable = new_cable
            previous_net = current_net
            current_net = current_cable.get_powernet()
            current_power = null
            if(!isturf(loc))
                forceMove(get_turf(NewLoc))
            controlling_area = null
            if(current_net != previous_net)
                update_cableview()

/mob/living/simple_animal/hostile/pulse_demon/to_bump(var/atom/obstacle) // Copied from how adminbus does it
    if(can_move && !locate(/obj/machinery/power) in get_turf(obstacle))
        can_move = 0
        forceMove(get_step(src,src.dir))
        sleep(1)
        can_move = 1
    else
        return ..()

/mob/living/simple_animal/hostile/pulse_demon/Crossed(mob/user as mob)
    if(user != src && isliving(user))
        shockMob(user)
    return ..()

/obj/machinery/power/relaymove(mob/user as mob)
    if(istype(user,/mob/living/simple_animal/hostile/pulse_demon))
        user.forceMove(get_turf(src))
    
/mob/living/simple_animal/hostile/pulse_demon/ClickOn(var/atom/A, var/params)
    if(get_area(A) == controlling_area)
        A.attack_ai(src)
    ..()

/mob/living/simple_animal/hostile/pulse_demon/ex_act(severity)
    return

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

/mob/living/simple_animal/hostile/pulse_demon/proc/shockMob(mob/living/carbon/human/M as mob)
    if(current_net && current_net.avail)
        electrocute_mob(M, current_net, src, 2)
    else
        M.electrocute_act(30, src, 2)

/mob/living/simple_animal/hostile/pulse_demon/proc/update_cableview()
    if(client)
        for(var/image/current_image in cables_shown)
            client.images -= current_image
        if(current_cable)
            for(var/obj/structure/cable/C in current_net.cables)
                var/image/CI = image(C, C.loc, layer = ABOVE_LIGHTING_LAYER, dir = C.dir)
                CI.plane = ABOVE_LIGHTING_PLANE
                cables_shown += CI
                client.images += CI