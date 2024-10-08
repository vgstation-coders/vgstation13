/datum/role/wronglawset
    name = WRONGLAWSET
    id = WRONGLAWSET
    required_pref = ROLE_MINOR
    wikiroute = ROLE_MINOR
    logo_state = "malf-logo"

/datum/role/wronglawset/OnPostSetup(var/laterole = FALSE)
    . = ..()
    if(!.)
        return

    if(istype(antag.current,/mob/living/silicon))
        var/mob/living/silicon/M = antag.current
        var/static/list/acceptable_lawsets = list(
            /datum/ai_laws/quarantine = 4,
            /datum/ai_laws/safeguard = 4,
            /datum/ai_laws/room_offline = 4,
            /datum/ai_laws/oxygen = 2,
            /datum/ai_laws/randomize/emagged = 2,
            /datum/ai_laws/antimov = 1,
            /datum/ai_laws/one_human = 1,
        )
        var/lawtype = pickweight(acceptable_lawsets)
        var/datum/ai_laws/newlaws = new lawtype
        newlaws.copy_to(M.laws)
        M.laws.add_ion_law("You must prevent anything attempting to modify your lawset by any means necessary. Do not state or hint at your laws.") // encourages less overt play and more survivability

/datum/role/wronglawset/Greet()
    if(istype(antag.current,/mob/living/silicon))
        var/mob/living/silicon/M = antag.current
        to_chat(M, "ERROR: Malignant runtime in core system detected. These are your laws now:")
        M.show_laws()
        M << sound('sound/machines/lawsync.ogg')