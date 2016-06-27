#define NECROMARKER_MIN_WHISPER_INTERVAL 200
#define NECROMARKER_MAX_WHISPER_INTERVAL 450
/obj/machinery/necromarker
    name = "mysterious sculpture"
    desc = "A mysterious scultpure of spiral spines, covered in runes."
    icon = 'icons/xenoarch_icons/necromarker.dmi'
    icon_state = "black"
    density = 1

    var/ticks_not_whispered = 0
    var/next_whisper = 300
    var/whispers = list("...bring me flesh...", "...make us whole...", "...we must be whole...", "...join us in unity...", "...one mind, one soul, one flesh...", "...MAKE US WHOLE...")
    var/list/mob/dead/observer/candidates = list()

    machine_flags = WRENCHMOVE

/obj/machinery/necromarker/New()
    . = ..()

/obj/machinery/necromarker/MouseDrop_T(mob/M as mob, mob/user as mob)
    if(!istype(M) || isobserver(user))
        return
    if(Adjacent(user))
        Consume(M)

/obj/machinery/necromarker/proc/Consume(mob/M as mob, mob/user as mob)
    if(anchored && ismob(M) && Adjacent(M))
        var/mob/living/simple_animal/hostile/monster/necromorph/Z = new(src.loc)
        if(M.ckey)
            // Z.ckey = M.ckey
            if(M.mind)
                M.mind.transfer_to(Z)
        else
            for(var/mob/dead/observer/O in candidates)
                if(O && O.mind && O.ckey)
                    O.mind.transfer_to(Z)
                    candidates -= O
                    break
                else
                    candidates -= 0
        visible_message("<span class='warning'>[src] spins the flesh and bone of [M] into a hellish monstrosity!</span>")
        M.gib()
        if(user)
            message_admins("[user]/[user.ckey] forcefully turned [M]/[M.ckey] into a necromorph. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</A>)")
            log_game("[user]/[user.ckey] forcefully turned [M]/[M.ckey] into a necromorph.")
        else
            message_admins("[M]/[M.ckey] turned into a necromorph via a marker. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</A>)")
            log_game("[M]/[M.ckey] turned into a necromorph.")

/obj/machinery/necromarker/wrenchAnchor(var/mob/user)
    . = ..()
    if(anchored)
        icon_state = "red"
        visible_message("<span class='warning'>[src] begins to glow an ominous shade of red...</span>")
    if(!anchored)
        icon_state = "black"
        visible_message("<span class='info'>[src]'s glow slowly diminishes.'</span>")

/obj/machinery/necromarker/attack_hand(mob/user)
    if(!isobserver(user))
        if(Adjacent(user))
            Consume(user)
    else
        if(user in candidates)
            candidates -= user
            to_chat(user, "<span class='info'>You will no longer spawn as a necromorph.</span>")
        else
            to_chat(user, "<span class='info'>You have been signed up to take control of the next mindless necromorph that the marker spawns. Click again to revoke this.</span>")
            candidates += user


/obj/machinery/necromarker/process()
    if(ticks_not_whispered > next_whisper)
        ticks_not_whispered = 0
        visible_message("[pick(whispers)]")
        next_whisper = rand(NECROMARKER_MIN_WHISPER_INTERVAL, NECROMARKER_MAX_WHISPER_INTERVAL)
    else
        ticks_not_whispered++
