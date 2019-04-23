/mob/living/silicon/verb/state_laws()
    set name = "State Laws (WIP)"
    ui_interact(usr, "state_laws")

/mob/living/silicon/proc/speak_laws(var/list/to_state, var/radiokey)
    say("[radiokey]Current Active Laws:")
    sleep(10)
    for(var/law in to_state)
        say("[radiokey][law]")
        sleep(10)
