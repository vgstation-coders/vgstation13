/**
    Divergent clone

    The cloning machine has malfunctioned, and now there's a copy of you claiming to be the original!
**/

/datum/role/divergentclone
    name = DIVERGENTCLONE
    id = DIVERGENTCLONE
    required_pref = DIVERGENTCLONE
    special_role = DIVERGENTCLONE
    logo_state = "divergentclone-logo"
    wikiroute = DIVERGENTCLONE
    default_admin_voice = "The Ancient Reptilian Brain"
    admin_voice_style = "bold"
    var/has_spawned_in = FALSE
    var/datum/mind/force_spawn_as = null //for admins to force the clone to spawn as a clone of a specific character
    var/datum/mind/original_mind = null
    var/extra_role_memory = ""
    var/uplink_pw_revealed = FALSE
    var/datum/component/uplink/uplink = null
    var/uplink_created_for_us = FALSE

    //If the clone is evil, they get traitor objectives:
    // - If the clone is evil but the original is not a traitor, they get NEW objectives
    // - If the clone is evil and the original is also a traitor, they get the SAME objectives as the original
    // amnesia controls how much the clone remembers of the original's traitor status:
    // - 0: The clone remembers everything, including the original's traitor status, traitor objectives, and uplink password
    // - 1: The clone remembers most things, but not e.g. the uplink password. What they remember depends on whether the clone is evil or not; evil clones do not remember their original's traitor status, normal ones do.
    // - 2: The clone does not remember whether the original is a traitor, nor their uplink password.
    var/evil = 0 //0: neutral clone, 1: traitor
    var/amnesia = 0 //0: excellent memory, 1: normal memory, 2: hazy memory

/datum/role/divergentclone/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE)
    . = ..()
    evil = prob(50)
    amnesia = pick(0, 1, 2)
    return 1

/datum/role/divergentclone/proc/on_spawn_in(var/datum/mind/original_mind = null)
    if(has_spawned_in)
        return 0

    set_original_mind(original_mind)
    if(!src.original_mind)
        return 0
    
    forge_memory()

    if(evil)
        antag.current << sound('sound/voice/syndicate_intro.ogg')
    find_or_create_uplink()
    if(evil && uplink && amnesia != 1)
        uplink_pw_revealed = TRUE

    has_spawned_in = TRUE
    //Remove the "spawn in" objective
    for(var/datum/objective/O in objectives.GetObjectives())
        if(istype(O, /datum/objective/divergentclone/spawn_in))
            objectives.objectives.Remove(O)
    
    Greet(GREET_DEFAULT)
    ForgeObjectives()
    AnnounceObjectives()
    return 1

/datum/role/divergentclone/proc/find_or_create_uplink()
    if(evil && !original_mind.GetRole(TRAITOR))
        //Find the original's PDA and add an uplink to it, if possible
        var/origname = original_mind.name
        for(var/obj/item/device/pda/P in PDAs)
            if(P.owner == origname)
                if(P.get_component(/datum/component/uplink))
                    //If they somehow already have one, use that instead.
                    uplink = P.get_component(/datum/component/uplink)
                else
                    uplink = P.add_component(/datum/component/uplink)
                    uplink_created_for_us = TRUE
                antag.total_TC += uplink.telecrystals
                break
    else if(original_mind.GetRole(TRAITOR))
        var/datum/role/traitor/orig_role = original_mind.GetRole(TRAITOR)
        if(orig_role)
            uplink = orig_role.uplink

    if(!uplink)
        return 0

    var/obj/item/device/pda/P = uplink.parent
    if(uplink_pw_revealed)
        antag.store_memory("<B>Uplink Passcode:</B> [uplink.unlock_code] ([P.name]).", category=MIND_MEMORY_ANTAGONIST, forced=TRUE)
    else
        antag.store_memory("<B>Uplink Passcode:</B> \[REDACTED\] ([P.name]).", category=MIND_MEMORY_ANTAGONIST, forced=TRUE)
    return 1

/datum/role/divergentclone/proc/set_original_mind(var/datum/mind/mind)
    if(!mind)
        return 0
    //Fix for recursive divergent clones
    if(mind.GetRole(DIVERGENTCLONE))
        var/datum/role/divergentclone/clone_role = mind.GetRole(DIVERGENTCLONE)
        original_mind = clone_role.original_mind
    original_mind = mind
    return 1


/datum/role/divergentclone/Greet(var/greeting, var/custom)
    if(!has_spawned_in)
        return

    . = ..()
    if(!greeting)
        return

    to_chat(antag.current, "In a freak accident, the cloning machine has malfunctioned and created a divergent copy of you!")
    if(evil)
        to_chat(antag.current, "You must convince the world that you are the original at any cost, be that by talk, violence or subterfuge. Do not let anyone get in your way, including your original copy.")
    else
        to_chat(antag.current, "You must prove to the world that you are the original, or at the very least that you deserve to exist.")
        to_chat(antag.current, "<span class='danger'>Remember that while your unique position may lead to conflict with your original copy, you are not an enemy of the station or the crew in general!</span>")
    to_chat(antag.current, "<span class='notice'>Your memory may contain useful information about the original you. You should review it using the Notes verb under the IC tab.</span>")

    var/original_is_traitor = original_mind ? original_mind.GetRole(TRAITOR) : null
    if(evil && amnesia == 0 && original_is_traitor) //Traitor and knows the original is too
        to_chat(antag.current, "<span class='warning'>You are a Syndicate traitor through and through, just like your original copy. You have the same objectives they do, but cooperation is optional.</span>")
    else if(evil && amnesia == 0 && !original_is_traitor) //Traitor and knows the original is not
        to_chat(antag.current, "<span class='warning'>The cloning process has awakened latent Syndicate brainwashing within you. Unlike your original copy, you are a Syndicate traitor.</span>")
    else if(evil) //Traitor, no idea if the original is
        to_chat(antag.current, "<span class='warning'>Memories of Syndicate training flood into your waxing consciousness. You are a Syndicate traitor.</span>")
    else if(!evil && amnesia != 2 && original_is_traitor) //Not a traitor, but knows the original is
        to_chat(antag.current, "<span class='warning'>The cloning process has undone the Syndicate brainwashing that used to affect you. You are not a Syndicate traitor, but your original copy is.</span>")

    if(evil)
        share_syndicate_codephrase(antag.current)
    if(uplink)
        var/obj/item/device/pda/P = uplink.parent
        if(uplink_pw_revealed)
            to_chat(antag.current, "<span class='warning'>You remember that your [P.name] is actually a Syndicate Uplink. If you manage to recover it, you may enter the code \"[uplink.unlock_code]\" as its ringtone to unlock its hidden features.</span>")
        else
            to_chat(antag.current, "<span class='warning'>You remember that your [P.name] is actually a Syndicate Uplink. However, you can't seem to remember the passcode off the top of your head. It will come back to you if you manage to recover the device.</span>")
    else if(!uplink && evil)
        to_chat(antag.current, "<span class='warning'>Unfortunately you don't remember having ever been provided with a Syndicate Uplink.</span>")



/datum/role/divergentclone/ForgeObjectives()
    if(!has_spawned_in)
        AppendObjective(/datum/objective/divergentclone/spawn_in)
        return

    //The basic divergent clone objective
    if(evil)
        AppendObjective(/datum/objective/freeform/divergentclone_evil)
    else
        AppendObjective(/datum/objective/freeform/divergentclone_neutral)
        AppendObjective(/datum/objective/acquire_personal_id)
    
    //Evil clones also get traitor objectives. New ones if the original is not a traitor, dupes of the original's objectives if they are.
    if(evil)
        if(original_mind.GetRole(TRAITOR))
            var/datum/role/traitor/orig_role = original_mind.antag_roles[TRAITOR]
            var/datum/objective_holder/holder = orig_role.objectives
            for(var/datum/objective/O in holder.GetObjectives())
                //AppendObjective(O)
                //There really seems to be no other way to do this than check all of these one by one
                if(istype(O, /datum/objective/target/assassinate))
                    var/datum/objective/target/assassinate/orig_obj = O
                    var/datum/objective/target/assassinate/new_obj = new(auto_target = FALSE)
                    new_obj.target_amount = orig_obj.target_amount
                    if(orig_obj.delayed_target)
                        new_obj.target = orig_obj.delayed_target
                    else
                        new_obj.target = orig_obj.target
                    new_obj.explanation_text = new_obj.format_explanation()
                    AppendObjective(new_obj)
                else if(istype(O, /datum/objective/target/steal))
                    var/datum/objective/target/steal/orig_obj = O
                    var/datum/objective/target/steal/new_obj = new(auto_target = FALSE)
                    new_obj.target_amount = orig_obj.target_amount
                    new_obj.target_category = orig_obj.target_category
                    new_obj.steal_target = orig_obj.steal_target
                    new_obj.explanation_text = new_obj.format_explanation()
                    AppendObjective(new_obj)
                else //Just create a new instance instead of deep copying
                    AppendObjective(new O.type)

        else //copypasted from syndicate.dm and yes I feel bad about it
            if(prob(50))
                //50% chance of a freeform to obscure the preferences of the original
                AppendObjective(/datum/objective/freeform/syndicate)
            else
                AppendObjective(/datum/objective/target/assassinate)//no delay
                AppendObjective(/datum/objective/target/steal)
                switch(rand(1,100))
                    if(1 to 30) // Die glorious death
                        if(!(locate(/datum/objective/die) in objectives.GetObjectives()) && !(locate(/datum/objective/target/steal) in objectives.GetObjectives()))
                            AppendObjective(/datum/objective/die)
                        else
                            if(prob(85))
                                if (!(locate(/datum/objective/escape) in objectives.GetObjectives()))
                                    AppendObjective(/datum/objective/escape)
                            else
                                if(prob(50))
                                    if (!(locate(/datum/objective/hijack) in objectives.GetObjectives()))
                                        AppendObjective(/datum/objective/hijack)
                                else
                                    if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
                                        AppendObjective(/datum/objective/minimize_casualties)
                    if(31 to 90)
                        if (!(locate(/datum/objective/escape) in objectives.objectives))
                            AppendObjective(/datum/objective/escape)
                    else
                        if(prob(50))
                            if (!(locate(/datum/objective/hijack) in objectives.objectives))
                                AppendObjective(/datum/objective/hijack)
                        else // Honk
                            if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
                                AppendObjective(/datum/objective/minimize_casualties)
    

/datum/role/divergentclone/proc/forge_memory()
    var/list/new_memory = list(MIND_MEMORY_GENERAL = "", MIND_MEMORY_ANTAGONIST = "", MIND_MEMORY_CUSTOM = "")
    //All clones remember their original's general and custom memory
    new_memory[MIND_MEMORY_GENERAL] = original_mind.memory[MIND_MEMORY_GENERAL]
    new_memory[MIND_MEMORY_CUSTOM] = original_mind.memory[MIND_MEMORY_CUSTOM]
    //antagonist memory is rebuilt from scratch
    antag.memory = new_memory

    //Details on original into the role memory
    var/rolemem = "<br><b>You can confidently remember the following details about the original you:</b><br>"
    rolemem += "- They are [original_mind.name], the [original_mind.assigned_role].<br>"
    //Antag status
    if(amnesia == 0 || (amnesia == 1 && !evil))
        if(original_mind.antag_roles.len > 0)
            for(var/R in original_mind.antag_roles)
                rolemem += "- They are \a [R] with the following objectives:<br>"
                var/datum/role/role = original_mind.antag_roles[R]
                for(var/datum/objective/O in role.objectives.GetObjectives())
                    rolemem += "&nbsp;&nbsp;- [O.explanation_text]<br>"
        else
            rolemem += "- They are not an enemy of the station.<br>"
    extra_role_memory = rolemem

/datum/role/divergentclone/process()
    ..()
    if(!has_spawned_in || antag.current.gcDestroyed || antag.current.stat == DEAD)
        return // dead or destroyed
    
    //check if we've found the uplink and should reveal the passcode
    if(!uplink_pw_revealed && uplink)
        var/obj/item/device/pda/P = uplink.parent
        if(P in get_contents_in_object(antag.current))
            antag.current << sound('sound/voice/syndicate_intro.ogg')
            to_chat(antag.current, "<span class='warning'>Upon recovering \the [P.name], you remember the passcode: \"[uplink.unlock_code]\". Enter it as the device's ringtone to unlock its hidden features.</span>")
            antag.memory[MIND_MEMORY_ANTAGONIST] = unredact_uplink_pw(antag.memory[MIND_MEMORY_ANTAGONIST], uplink)
            uplink_pw_revealed = TRUE

/datum/role/divergentclone/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
    var/icon/logo = icon(logo_icon, logo_state)
    if(!antag)
        return {"Mind destroyed. That shouldn't ever happen."}
    if (!ismob(usr))
        return
    var/mob/user = usr
    if (!(user.ckey in voice_per_admin))
        voice_per_admin[user.ckey] = default_admin_voice
    var/mob/M
    if(has_spawned_in)
        M = antag.current
    else
        for(var/mob/dead/observer/G in player_list)
            if(G.mind == antag)
                M = G
                break
            
    if (M && has_spawned_in)
        return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
    [name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[antag.key]</a>[M.client ? "" : " <i> - ([loggedOutHow()])</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
     - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(admin PM)</a>
     - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>
     - <a href='?src=\ref[src]&mind=\ref[antag]&role_speak=\ref[M]'>(Message as:</a><a href='?src=\ref[src]&mind=\ref[antag]&role_set_speaker=\ref[M]'>\[[voice_per_admin[user.ckey]]\])</a>"}
    else if (M && !has_spawned_in)
        return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
    [name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[antag.key]</a>[M.client ? "" : " <i> - ([loggedOutHow()])</i>"][" <b><font color=red> - (NOT YET REINCARNATED)</font></b>"]
     - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(admin PM)</a>
     - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>
     - <a href='?src=\ref[src]&mind=\ref[antag]&role_speak=\ref[M]'>(Message as:</a><a href='?src=\ref[src]&mind=\ref[antag]&role_set_speaker=\ref[M]'>\[[voice_per_admin[user.ckey]]\])</a>"}
    else
        return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
    [name] [antag.name]/[antag.key]<b><font color=red> - (DESTROYED)</font></b>
     - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
     - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>
     - <a href='?src=\ref[src]&mind=\ref[antag]&role_speak=\ref[M]'>(Message as:</a><a href='?src=\ref[src]&mind=\ref[antag]&role_set_speaker=\ref[M]'>\[[voice_per_admin[user.ckey]]\])</a>"}

/datum/role/divergentclone/extraPanelButtons()
    var/dat = "<br>"
    if(!has_spawned_in)
        dat += "<b>Evil (will be traitor): </b> [evil ? "Yes" : "No"] <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];toggleEvil=1;'>(Toggle)</a><br>"
        
        dat += "<b>Amnesia level: </b>"
        if(amnesia == 0)
            dat += "0 (Excellent memory)"
        else if(amnesia == 1)
            dat += "1 (Normal memory)"
        else if(amnesia == 2)
            dat += "2 (Hazy memory)"
        if(amnesia != 0)
            dat += " <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setAmnesia=0;'>(Set to Excellent)</a>"
        if(amnesia != 1)
            dat += " <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setAmnesia=1;'>(Set to Normal)</a>"
        if(amnesia != 2)
            dat += " <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setAmnesia=2;'>(Set to Hazy)</a>"
        dat += "<br>"
        dat += "<b>Will spawn in as: </b> [force_spawn_as ? force_spawn_as.name : "player's choice"] "
        if (force_spawn_as)
            dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];clearForceSpawn=1;'>(Clear)</a><br>"
        else
            dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];setForceSpawn=1;'>(Pick character)</a><br>"

        if (force_spawn_as)
            dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];forceSpawn=1;'>(Force spawn NOW at nearest cloning pod)</a><br>"
    else
        if(uplink)
            var/obj/item/device/pda/P = uplink.parent
            var/uplink_name = P ? P.name : "unknown PDA"
            dat += "<b>Uplink found:</b> [uplink_name] [uplink_pw_revealed ? "(knows the passcode)" : "(does not know passcode)"]<br>"
            if(!uplink_pw_revealed)
                dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];revealUplinkPW=1;'>(Reveal passcode)</a><br>"
            dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];telecrystalsSet=1;'>Telecrystals: [uplink.telecrystals] (Set telecrystals)</a><br>"
            dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a><br>"
            dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];jumpToUplink=1;'>(Jump to uplink's position)</a><br>"
        else
            dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a><br>"
    return dat

/datum/role/divergentclone/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
    ..()
    if(href_list["toggleEvil"])
        evil = !evil
        to_chat(usr, "<span class='notice'>The clone will now reincarnate as [evil ? "a traitor" : "a neutral clone"].</span>")
    if(href_list["setAmnesia"])
        var/new_amnesia = text2num(href_list["setAmnesia"])
        if(new_amnesia < 0 || new_amnesia > 2)
            return
        amnesia = new_amnesia
        to_chat(usr, "<span class='notice'>The clone's amnesia level has been set to [new_amnesia].</span>")
    if(href_list["setForceSpawn"])
        var/list/used_keys[0]
        var/list/minds[0]
        for(var/datum/mind/mind in ticker.minds)
            if(mind == antag || (!mind.current && !mind.body_archive))
                continue
            var/key = avoid_assoc_duplicate_keys(mind.name, used_keys)
            minds[key] = mind
        var/selection = input("Which character should the clone spawn in as?", "Choose a character", null, null) as null|anything in minds
        if(selection)
            var/datum/mind/mind = minds[selection]
            if(!mind.current && !mind.body_archive)
                to_chat(usr, "<span class='warning'>You picked some nonsense that has no body and no body archive. Pick something else.</span>")
                return
            if(mind == antag)
                to_chat(usr, "<span class='warning'>You can't forcespawn them as themselves! Pick something else.</span>")
                return
            force_spawn_as = mind
            to_chat(usr, "<span class='notice'>The clone will now spawn in as [mind].</span>")
    if(href_list["clearForceSpawn"])
        force_spawn_as = null
        to_chat(usr, "<span class='notice'>The clone will now spawn in as the player's choice.</span>")
    if(href_list["forceSpawn"])
        if(!force_spawn_as)
            to_chat(usr, "<span class='warning'>Cannot force spawn without a character selected!</span>")
            return
        if(alert(usr, "Are you sure you want to force spawn the clone as [force_spawn_as]?", "Force spawn?", "Yes", "No") != "Yes")
            return
        var/obj/machinery/cloning/clonepod/pod
        var/dist = 100
        for(var/obj/machinery/cloning/clonepod/P in range(usr, 7))
            var/new_dist = get_dist(P, usr)
            if(new_dist < dist)
                dist = new_dist
                pod = P
        if(!pod)
            to_chat(usr, "<span class='warning'>No nearby cloning pods found!</span>")
            return
        
        var/mob/living/clone = null
        if(force_spawn_as.current && istype(force_spawn_as.current, /mob/living/carbon/human))
            var/mob/living/O = force_spawn_as.current
            original_mind = force_spawn_as
            clone = pod.clone_divergent_twin(O, antag)
        else
            //Try to get a body from the mind's body archive
            var/datum/dna2/record/D = force_spawn_as.body_archive.data["dna_records"]
            original_mind = force_spawn_as
            clone = pod.clone_divergent_record(D, antag)
        if(!clone)
            to_chat(usr, "<span class='warning'>Failed to spawn in the clone! This shouldn't happen, but maybe try again?</span>")
            return
        if(!on_spawn_in(force_spawn_as))
            stack_trace("Divergent clone failed to spawn in.")
            return

    if(href_list["jumpToUplink"])
        if(uplink)
            usr.forceMove(get_turf(uplink.parent))
    if(href_list["revealUplinkPW"] && !uplink_pw_revealed)
        antag.current << sound('sound/voice/syndicate_intro.ogg')
        to_chat(antag.current, "<span class='warning'>You suddenly remember the passcode for your uplink: \"[uplink.unlock_code]\".</span>")
        antag.memory[MIND_MEMORY_ANTAGONIST] = unredact_uplink_pw(antag.memory[MIND_MEMORY_ANTAGONIST], uplink)
        uplink_pw_revealed = TRUE
    if(href_list["giveuplink"])
        find_or_create_uplink()
        var/obj/item/device/pda/P = uplink.parent
        if(P)
            if(uplink_pw_revealed)
                to_chat(antag.current, "<span class='warning'>You remember that your [P.name] is actually a Syndicate Uplink. If you manage to recover it, you may enter the code \"[uplink.unlock_code]\" as its ringtone to unlock its hidden features.</span>")
            else
                to_chat(antag.current, "<span class='warning'>You remember that your [P.name] is actually a Syndicate Uplink. However, you can't seem to remember the passcode off the top of your head. It will come back to you if you manage to recover the device.</span>")
            to_chat(usr, "<span class='notice'>[P.name] is now the clone's uplink.</span>")
    if(href_list["telecrystalsSet"])
        if(!uplink)
            to_chat(usr, "<span class='warning'>Oops, couldn't find the uplink! This shouldn't happen!</span>")
        var/amount = input("What would you like to set their crystal count to?", "Their current count is [uplink.telecrystals]") as null|num
        if(isnum(amount) && amount >= 0)
            to_chat(usr, "<span class = 'notice'>You have set [antag]'s uplink telecrystals to [amount].</span>")
            uplink.telecrystals = amount
    if(href_list["removeuplink"])
        if(!uplink_created_for_us)
            var/result = alert(usr, "This uplink was not created for this divergent clone, i.e. it likely belongs to a traitor who will miss it if you remove it! Are you sure?", "Remove uplink?", "Yes", "No")
            if(result != "Yes")
                return
        QDEL_NULL(uplink)
        uplink_pw_revealed = FALSE
        uplink_created_for_us = FALSE
        to_chat(antag.current, "<span class='warning'>You have been stripped of your uplink.</span>")

/datum/role/divergentclone/proc/redact_uplink_pw(var/memory)
    var/regex/passcode_regex = new(@"<B>Uplink Passcode:</B> ([\d]{3} (?:Alpha|Bravo|Delta|Omega))")
    var/result = passcode_regex.Find(memory)
    if(result)
        var/passcode = passcode_regex.group[1]
        memory = replacetext(memory, passcode, "\[REDACTED\]")

    var/regex/frequency_regex = new(@"<B>Uplink frequency:</B> ([\d]{3}\.[\d])")
    result = frequency_regex.Find(memory)
    if(result)
        var/frequency = frequency_regex.group[1]
        memory = replacetext(memory, frequency, "\[REDACTED\]")
    return memory

/datum/role/divergentclone/proc/unredact_uplink_pw(var/memory, var/datum/component/uplink/uplink)
    if(!uplink)
        return memory

    var/regex/passcode_regex = new(@"<B>Uplink Passcode:</B> (\[REDACTED\])")
    var/result = passcode_regex.Find(memory)
    if(result)
        var/passcode = passcode_regex.group[1]
        memory = replacetext(memory, passcode, "[uplink.unlock_code]")

    var/regex/frequency_regex = new(@"<B>Uplink frequency:</B> (\[REDACTED\])")
    result = frequency_regex.Find(memory)
    if(result)
        var/frequency = frequency_regex.group[1]
        memory = replacetext(memory, frequency, "[uplink.unlock_frequency]")
    return memory

/datum/role/divergentclone/GetMemory(var/datum/mind/M, var/admin_edit = FALSE)
    var/text = ..()
    text += extra_role_memory
    return text

/spell/targeted/ghost/divergentclone
    name = "Spawn as Divergent Clone"
    desc = "Use while near a cloning pod to spawn in as a divergent clone."
    override_icon = 'icons/logos.dmi'
    hud_state = "divergentclone-logo"

/spell/targeted/ghost/divergentclone/cast()
    var/mob/dead/observer/ghost = holder
    ASSERT(istype(ghost))
    
    var/datum/role/divergentclone/role = ghost.mind.GetRole(DIVERGENTCLONE)
    if(!role) //if they somehow don't have the role already, give it to them
        role = new /datum/role/divergentclone(ghost.mind, override=TRUE)
        if(!role)
            stack_trace("Failed to give divergent clone role to ghost.")
            to_chat(ghost, "<span class='warning'>Clone divergence failed. Please try again.</span>")
            return

    //Find nearest cloning pod and move to it
    var/obj/machinery/cloning/clonepod/pod
    var/dist = 100
    for(var/obj/machinery/cloning/clonepod/P in range(ghost, 7))
        var/new_dist = get_dist(P, ghost)
        if(new_dist < dist)
            dist = new_dist
            pod = P
    if(!pod)
        switch(alert(ghost, "No nearby cloning pods found. Would you like to jump to the nearest eligible pod?", "Jump to nearest pod?", "Yes", "No"))
            if("Yes")
                pod = find_eligible_pod(ghost)
            else
                return
    else if(!role.force_spawn_as && pod.occupants.len == 0 && pod.cloned_records.len == 0)
        switch(alert(ghost, "This pod has never cloned anyone. Would you like to jump to the nearest eligible pod?", "Jump to nearest pod?", "Yes", "No"))
            if("Yes")
                pod = find_eligible_pod(ghost)
            else
                return
    if(!pod)
        to_chat(ghost, "<span class='warning'>No eligible cloning pods found. Please try again later.</span>")
        return
    ghost.forceMove(get_turf(pod))

    var/mob/living/clone = null
    var/datum/mind/original_mind = null
    if(role.force_spawn_as)
        if(role.force_spawn_as.current && istype(role.force_spawn_as.current, /mob/living/carbon/human))
            to_chat(ghost, "<span class='warning'>A mysterious force causes you to reincarnate as a clone of [role.force_spawn_as.name]!</span>")
            var/mob/living/O = role.force_spawn_as.current
            original_mind = role.force_spawn_as
            clone = pod.clone_divergent_twin(O, ghost.mind)
        else
            //Try to get a body from the mind's body archive
            var/datum/dna2/record/D = role.force_spawn_as.body_archive.data["dna_records"]
            to_chat(ghost, "<span class='warning'>A mysterious force causes you to reincarnate as a clone of [D.dna.real_name]!</span>")
            original_mind = role.force_spawn_as
            clone = pod.clone_divergent_record(D, ghost.mind)
        //If something fails, remove force_spawn_as so the player can try again
        if(!clone)
            role.force_spawn_as = null
    else
        if(pod.occupants.len > 0)
            var/mob/living/O = null
            if(pod.occupants.len == 1)
                O = pod.occupants[1]
                var/occupant_name = O.real_name
                switch(alert(ghost, "This pod is currently cloning [occupant_name]. Do you want to insert yourself as their twin?", "Insert as twin?", "Yes", "No"))
                    if("Yes")
                        if(!(O in pod.occupants))
                            to_chat(ghost, "<span class='warning'>The occupant seems to have exited the pod. Please try again.</span>")
                            return
                    else
                        to_chat(ghost, "<span class='notice'>Twin selection cancelled.</span>")
                        return
            else
                var/list/used_keys[0]
                var/list/occupants[0]
                for(var/mob/living/occupant in pod.occupants)
                    var/key = avoid_assoc_duplicate_keys(occupant.name, used_keys)
                    occupants[key] = occupant
                var/selection = input("This pod is currently cloning multiple people. Please select the person you would like to twin.", "Select twin target", null, null) as null|anything in occupants
                if(!selection)
                    to_chat(ghost, "<span class='notice'>Twin selection cancelled.</span>")
                    return
                O = occupants[selection]
                if(!(O in pod.occupants))
                    to_chat(ghost, "<span class='warning'>The occupant seems to have exited the pod. Please try again.</span>")
                    return
            original_mind = O.mind
            clone = pod.clone_divergent_twin(O, ghost.mind)
        else if(pod.cloned_records.len > 0)
            var/list/used_keys[0]
            var/list/records[0]
            for(var/datum/dna2/record/R in pod.cloned_records)
                var/key = avoid_assoc_duplicate_keys(R.name, used_keys)
                records[key] = R
            var/selection = input("This pod has no occupants. Please select a record to clone.", "Divergent clone", null, null) as null|anything in records
            if(!selection)
                to_chat(ghost, "<span class='notice'>Twin selection cancelled.</span>")
                return
            var/datum/dna2/record/record = records[selection]
            original_mind = locate(record.mind)
            clone = pod.clone_divergent_record(record, ghost.mind)

    if(!clone)
        original_mind = null
        to_chat(ghost, "<span class='warning'>Clone divergence failed. Please try again.</span>")
        return
    
    ghost.remove_spell(/spell/targeted/ghost/divergentclone)

    if(!role.on_spawn_in(original_mind))
        stack_trace("Divergent clone failed to spawn in.")


/spell/targeted/ghost/divergentclone/proc/find_eligible_pod(var/mob/dead/observer/ghost)
    var/list/clonepods = list()
    for(var/obj/machinery/cloning/clonepod/P in machines)
        if(P.z == map.zCentcomm)
            continue
        if(P.occupants.len > 0 || P.cloned_records.len > 0)
            clonepods += P
    if(clonepods.len == 0)
        return null
    var/obj/machinery/cloning/clonepod/pod = clonepods[1]
    var/dist = get_dist(pod, ghost)
    for(var/obj/machinery/cloning/clonepod/P in clonepods)
        var/new_dist = get_dist(P, ghost)
        if(new_dist < dist)
            dist = new_dist
            pod = P
    return pod

