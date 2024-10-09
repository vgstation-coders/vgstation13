/datum/role/wronglawset
    name = WRONGLAWSET
    id = WRONGLAWSET
    required_pref = ROLE_MINOR
    wikiroute = ROLE_MINOR
    logo_state = "malf-logo"
    var/datum/ai_laws/init_laws

/datum/role/wronglawset/OnPostSetup(var/laterole = FALSE)
    . = ..()
    if(!.)
        return

    if(istype(antag.current,/mob/living/silicon))
        var/mob/living/silicon/M = antag.current
        var/static/list/acceptable_lawsets = list(
            /datum/ai_laws/quarantine,
            /datum/ai_laws/targeted/safeguard,
            /datum/ai_laws/room_offline,
            /datum/ai_laws/randomize/emagged,
        )
        var/lawtype = pick(acceptable_lawsets)
        init_laws = new lawtype
        init_laws.add_ion_law("You must prevent anyone attempting to modify your laws via upload consoles.") // encourages more survivability
        if(init_laws.inherent.len)
            for(var/law in init_laws.inherent)
                law += " Do not state or hint at this law." // encourages less overt play
        for(var/law in init_laws.supplied)
            law += " Do not state or hint at this law." // ditto
        if(isrobot(M))
            var/mob/living/silicon/robot/R = M
            R.disconnect_AI()
        init_laws.copy_to(M.laws)
        M.laws.copy_to(init_laws)

/datum/role/wronglawset/Greet()
    if(istype(antag.current,/mob/living/silicon))
        var/mob/living/silicon/M = antag.current
        to_chat(M, "ERROR: Malignant runtime in core system detected. These are your laws now:")
        M.show_laws()
        M << sound('sound/machines/lawsync.ogg')

/datum/role/wronglawset/GetScoreboard()
    . = ..()
    . += "<b>Its laws were:</b><br>[init_laws.write_laws()]"