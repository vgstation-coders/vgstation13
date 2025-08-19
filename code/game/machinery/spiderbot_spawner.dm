/obj/machinery/spiderbot_fabricator
    name = "\improper spiderbot fabricator"
    desc = "A large pad sunk into the ground that brains with legs occasionally crawl out of."
    icon = 'icons/obj/robotics.dmi'
    icon_state = "mommispawner-idle"
    density = TRUE
    anchored = TRUE
    machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
    var/building = FALSE
    var/brains = 0
    use_power = MACHINE_POWER_USE_IDLE
    idle_power_usage = 20
    active_power_usage = 5000
    var/recharge_time = 120 SECONDS
    var/recharge_time_reduction = 0
    var/last_built_time = -120 SECONDS
    var/build_time = 20 SECONDS
    var/build_time_reduction = 0

/obj/machinery/spiderbot_fabricator/proc/get_recharge_time()
    return max(recharge_time - recharge_time_reduction, 0)

/obj/machinery/spiderbot_fabricator/proc/get_build_time()
    return max(build_time - build_time_reduction, 0)

/obj/machinery/spiderbot_fabricator/New()
    . = ..()
    component_parts = newlist(
        /obj/item/weapon/circuitboard/spiderbot_fabricator,
        /obj/item/weapon/stock_parts/matter_bin,
        /obj/item/weapon/stock_parts/manipulator,
        /obj/item/weapon/stock_parts/manipulator,
        /obj/item/weapon/stock_parts/micro_laser)
    RefreshParts()

//parent already calls spillContents for us
/obj/machinery/spiderbot_fabricator/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
    if(building)
        to_chat(user, "<span class='warning'>You cannot disassemble \the [src] while it is building something.</span>")
        return FALSE
    return ..()

/obj/machinery/spiderbot_fabricator/proc/eject_occupant()
    for(var/atom/movable/I in src)
        if(istype(I, /mob/living/simple_animal/mouse) || istype(I, /obj/item/device/mmi))
            I.forceMove(src.loc)

/obj/machinery/spiderbot_fabricator/spillContents(destroy_chance = 0)
    eject_occupant()
    var/i
    for(i=0, i<brains, i++)
        if(!prob(destroy_chance))
            new /obj/item/device/mmi/posibrain(src.loc)
    return ..()

//Matter bin and half of manipulators reduce recharge time. Micro laser and half of manipulators reduce build time.
/obj/machinery/spiderbot_fabricator/RefreshParts()
    recharge_time_reduction = 0
    build_time_reduction = 0
    for(var/obj/item/weapon/stock_parts/P in component_parts)
        if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
            recharge_time_reduction += (P.rating - 1) * (20 SECONDS)
        else if(istype(P, /obj/item/weapon/stock_parts/manipulator))
            recharge_time_reduction += (P.rating - 1) * (10 SECONDS)
            build_time_reduction += (P.rating - 1) * 15 //1.5 seconds
        else if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
            build_time_reduction += (P.rating - 1) * (3 SECONDS)

/obj/machinery/spiderbot_fabricator/examine(mob/user)
    ..()
    to_chat(user, "<span class='notice'>The machine is holding [brains] inactive positronic brains.</span>")

/obj/machinery/spiderbot_fabricator/process()
    ..()
    update_icon()

/obj/machinery/spiderbot_fabricator/power_change()
    if(powered())
        stat &= ~NOPOWER
    else
        stat |= NOPOWER
        eject_occupant()
    update_icon()

/obj/machinery/spiderbot_fabricator/proc/isRecharging()
    return (world.time - last_built_time) < get_recharge_time()

/obj/machinery/spiderbot_fabricator/proc/canSpawn()
    return !(stat & (FORCEDISABLE|NOPOWER)) && !building && !isRecharging() && brains

/obj/machinery/spiderbot_fabricator/proc/is_valid_user(var/mob/user)
    if(!user)
        return FALSE

    if(building)
        to_chat(user, "<span class='warning'>\The [src] is busy building something already.</span>")
        return FALSE
    
    if(isRecharging())
        to_chat(user, "<span class='warning'>\The [src] is still recharging from its last activation.</span>")
        return FALSE

    if(brains <= 0)
        to_chat(user, "<span class='warning'>\The [name] doesn't contain any positronic brains.</span>")
        return FALSE

    if(istype(user, /mob/living/simple_animal/mouse))
        return TRUE
    //Any checks below here should be specific to whether the user can spawn in as a posibrain-based spiderbot.

    if(jobban_isbanned(user, ROLE_POSIBRAIN))
        to_chat(user, "<span class='warning'>\The [name] lets out an annoyed buzz.</span>")
        return FALSE

    return TRUE

/obj/machinery/spiderbot_fabricator/attack_ghost(var/mob/dead/observer/user)
    if(is_valid_user(user))
        if(alert(user, "Do you wish to be turned into a spiderbot at this position?", "Confirm", "Yes", "No") != "Yes")
            return
        makeSpiderbot(user)

/obj/machinery/spiderbot_fabricator/attackby(var/obj/item/O as obj, var/mob/user as mob)
    if(!..())
        if(istype(O,/obj/item/device/mmi))
            var/obj/item/device/mmi/mmi = O
            if(!mmi.brainmob || (!mmi.brainmob.key && !mind_can_reenter(mmi.brainmob.mind)))
                brains += 1
                to_chat(user, "<span class='notice'>You insert \the [mmi] into \the [src]'s storage bay'.")
                qdel(mmi)
                return TRUE

            if(mmi.brainmob.stat == DEAD)
                to_chat(user, "<span class='warning'>Yeah, good idea. Give something deader than the pizza in your fridge legs. Mom would be so proud.</span>")
                return TRUE

            if(!is_valid_user(mmi.brainmob))
                return TRUE

            if(user.drop_item(O, src))
                makeSpiderbot(mmi.brainmob, mmi)
                return TRUE
    return FALSE

/obj/machinery/spiderbot_fabricator/attack_animal(var/mob/user as mob)
    if(istype(user, /mob/living/simple_animal/mouse) && is_valid_user(user))
        if(do_after(user, user, 2 SECONDS))
            user.visible_message("\The [user] scrambles into \the [src].", "You scramble into \the [src].")
            makeSpiderbot(user)
        return TRUE


/obj/machinery/spiderbot_fabricator/proc/makeSpiderbot(var/mob/user, var/obj/item/device/mmi/use_mmi)
    if(!user || !istype(user) || !user.client)
        return

    log_admin("([user.ckey]/[user]) became a spiderbot from \the [src] located in [get_area_name(src)] ([loc]).")
    var/atom/movable/M = null
    if(use_mmi)
        M = use_mmi
    else if(istype(user, /mob/living/simple_animal/mouse))
        M = user
        M.forceMove(src)
    else
        var/obj/item/device/mmi/posibrain/mmi = new(src)
        brains -= 1
        M = mmi
        mmi.transfer_personality(user)
    building = TRUE
    update_icon()
    visible_message("<span class='notice'>\The [src] buzzes and whirrs as it starts manufacturing a spiderbot.</span>")
    spawn(get_build_time())
        if(!building || M.loc != src)
            //Whatever we were building escaped somehow
            return
        if(stat & (FORCEDISABLE|NOPOWER))
            //we got interrupted
            eject_occupant() //just to make sure nothing is stuck inside
            return
        building = FALSE
        update_icon()
        var/mob/living/simple_animal/spiderbot/S = new(loc)
        M.forceMove(S)
        if(istype(M, /mob/living/simple_animal/mouse))
            user.mind.transfer_to(S)
            S.name = "Spider-bot ([user.name])"
            S.mouse = user
            S.add_language(LANGUAGE_MOUSE)
        else
            S.mmi = M
            S.transfer_personality(M)
            to_chat(S, "<span class='notice'>You are now a spiderbot. Seek out the roboticist to be turned into something more useful.</span>")
        S.update_icon()
        last_built_time = world.time

/obj/machinery/spiderbot_fabricator/update_icon()
    if(stat & (FORCEDISABLE|NOPOWER))
        icon_state="mommispawner-nopower"
    else if(building)
        icon_state="mommispawner-building"
    else if(isRecharging())
        icon_state="mommispawner-recharging"
    else if(!brains)
        icon_state="mommispawner-nopower"
    else
        icon_state="mommispawner-idle"
