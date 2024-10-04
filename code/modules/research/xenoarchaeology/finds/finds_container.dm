/datum/finds
    var/datum/geosample/geologic_data
    var/excavation_level = 0
    var/list/finds = list()//no longer null to prevent those pesky runtime errors
    //	var/next_rock = 0
    var/archaeo_overlay
    var/excav_overlay
    var/datum/artifact_find/artifact_find
    var/datum/weakref/holder

/datum/finds/New(turf/T)
    ..()
    holder = makeweakref(T)

/datum/finds/proc/create_finds(datum/digsite/D)
    if(prob(50)) //Single find
        finds.Add(D.gen_find(rand(5,95)))
    else if(prob(75)) //Two finds
        finds.Add(D.gen_find(rand(5,45)))
        finds.Add(D.gen_find(rand(55,95)))
    else //Three finds!
        finds.Add(D.gen_find(rand(5,30)))
        finds.Add(D.gen_find(rand(35,75)))
        finds.Add(D.gen_find(rand(75,95)))

    update_archaeo_overlay()

/datum/finds/proc/handle_attackby(obj/item/weapon/W, mob/user)
    var/turf/T = holder.get()
    if(!istype(T))
        return
    if (istype(W, /obj/item/device/depth_scanner))
        var/obj/item/device/depth_scanner/C = W
        C.scan_atom(user, T)
        return TRUE

    if (istype(W, /obj/item/device/measuring_tape))
        var/obj/item/device/measuring_tape/P = W
        user.visible_message("<span class='notice'>[user] extends [P] towards [T].</span>","<span class='notice'>You extend [P] towards [T].</span>")
        to_chat(user, "<span class='notice'>[bicon(P)] [T] has been excavated to a depth of [excavation_level]cm.</span>")
        return TRUE
    return FALSE

/datum/finds/proc/exceed_depth(obj/item/weapon/pickaxe/P, mob/user, depresses_digsites = FALSE)
    . = FALSE
    if(!depresses_digsites && finds && finds.len)
        var/datum/find/top_find = finds[1]

        var/exc_diff = excavation_level + P.excavation_amount - top_find.excavation_required

        if (exc_diff > 0)
            // Digging too far, probably breaking the artifact.
            var/fail_message = "<b>[pick("There is a crunching noise","[P] collides with some different rock","Part of the rock face crumbles away","Something breaks under [P]")]</b>"
            to_chat(user, "<span class='rose'>[fail_message].</span>")
            . = TRUE

            var/destroy_prob = 50
            if (exc_diff > 5)
                destroy_prob = 95

            if (prob(destroy_prob))
                finds.Remove(top_find)
                if (prob(40))
                    artifact_debris()

            else
                excavate_find(5, top_find)

/datum/finds/proc/drill_find(obj/item/weapon/pickaxe/P, broke_find, depresses_digsites = FALSE)
    if(!depresses_digsites && finds && finds.len && !broke_find)
        var/datum/find/F = finds[1]
        if(round(excavation_level + P.excavation_amount) == F.excavation_required)
            excavate_find(100, F)

        else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
            excavate_find(0, F)

/datum/finds/proc/artifact_debris(var/severity = 0)
    var/turf/T = holder.get()
    if(!istype(T))
        return
    if(severity)
        var/obj/item/stack/S
        var/bigamount = rand(5,25)
        switch(rand(1,3))
            if(1)
                S = new /obj/item/stack/sheet/metal(T)
            if(2)
                S = new /obj/item/stack/sheet/plasteel(T)
            if(3)
                S = new /obj/item/stack/sheet/mineral/uranium(T)
        S.amount = bigamount
    else
        var/quantity = rand(1,3)
        switch(rand(1,5))
            if(1)
                var/obj/item/stack/rods/R = new(T)
                R.amount = rand(5,25)
            if(2)
                var/obj/item/stack/tile/metal/R = new(T)
                R.amount = rand(1,5)
            if(3)
                var/obj/item/stack/sheet/metal/M = new(T)
                M.amount = rand(1,5)
            if(4)
                for(var/i in 1 to quantity)
                    new /obj/item/weapon/shard(T)
            if(5)
                for(var/i in 1 to quantity)
                    new /obj/item/weapon/shard/plasma(T)

/datum/finds/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
    //with skill or luck, players can cleanly extract finds
    //otherwise, they come out inside a chunk of rock
    var/turf/T = holder.get()
    if(!istype(T))
        return
    var/obj/item/weapon/X
    if(prob_clean)
        X = F.create_find(T)
    else
        X = new /obj/item/weapon/strangerock(T, F)
        if(!geologic_data)
            geologic_data = new/datum/geosample(T)
        geologic_data.UpdateNearbyArtifactInfo(T)
        X:geologic_data = geologic_data

    finds.Remove(F)

/datum/finds/proc/update_excav_level(obj/item/weapon/pickaxe/P)
    var/turf/T = holder.get()
    if(!istype(T))
        return
    excavation_level += P.excavation_amount

    update_archaeo_overlay()

    var/update_excav_overlay = 0

    var/subtractions = 0
    while(excavation_level - 25*(subtractions + 1) >= 0 && subtractions < 3)
        subtractions++
    if(excavation_level - P.excavation_amount < subtractions * 25)
        update_excav_overlay = 1

    //update overlays displaying excavation level
    if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
        var/excav_quadrant = round(excavation_level / 25) + 1
        excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
        T.overlays += excav_overlay

/datum/finds/proc/update_archaeo_overlay()
    var/turf/T = holder.get()
    if(!istype(T))
        return
    if(!archaeo_overlay && finds && finds.len)
        //sometimes a find will be close enough to the surface to show
        var/datum/find/F = finds[1]
        if(F.excavation_required <= excavation_level + F.view_range)
            archaeo_overlay = "overlay_archaeo[rand(1,3)]"
            T.overlays += archaeo_overlay

/datum/finds/proc/spawn_boulder(mob/user,depresses_digsites = FALSE)
    var/turf/T = holder.get()
    if(!istype(T))
        return
    var/obj/structure/boulder/B
    . = TRUE
    if(!depresses_digsites)
        if(artifact_find)
            if(excavation_level > 0)

                B = new /obj/structure/boulder(T)
                B.geological_data = geologic_data

                B.artifact_find = artifact_find
                B.investigation_log(I_ARTIFACT, "|| [artifact_find.artifact_find_type] - [artifact_find.artifact_id] found by [key_name(user)].")
                . = FALSE

            else
                artifact_debris(1)

        else if(!excavation_level > 0 && prob(15))
            B = new /obj/structure/boulder(T)
            B.geological_data = geologic_data

        
/datum/finds/proc/large_artifact_fail()
    var/turf/T = holder.get()
    if(!istype(T))
        return
    //destroyed artifacts have weird, unpleasant effects
	//make sure to destroy them before changing the turf though
	if(artifact_find)
		var/datum/artifact_postmortem_data/destroyed = new(null, FALSE, TRUE)
		destroyed.artifact_id = artifact_find.artifact_id
		destroyed.last_loc = T
		destroyed.artifact_type = artifact_find.artifact_find_type
		if (artifact_find.artifact_find_type == /obj/machinery/artifact)
			destroyed.primary_effect = "???"
			destroyed.secondary_effect = "???"
		razed_large_artifacts[artifact_find.artifact_id] += destroyed
		ArtifactRepercussion(T, usr, "", "[artifact_find.artifact_find_type]")