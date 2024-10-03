/datum/finds
    var/datum/geosample/geologic_data
    var/excavation_level = 0
    var/list/finds = list()//no longer null to prevent those pesky runtime errors
    //	var/next_rock = 0
    var/archaeo_overlay = ""
    var/excav_overlay = ""
    var/datum/artifact_find/artifact_find
    var/turf/holder

/datum/finds/New(turf/T)
    ..()
    holder = T

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

    //sometimes a find will be close enough to the surface to show
    var/datum/find/F = finds[1]

    if(F.excavation_required <= F.view_range)
        archaeo_overlay = "overlay_archaeo[rand(1,3)]"
        holder.overlays += archaeo_overlay

/datum/finds/proc/exceed_depth(obj/item/weapon/pickaxe/P, mob/user)
    . = FALSE
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

/datum/finds/proc/drill_find(obj/item/weapon/pickaxe/P, broke_find)
    if(!P.depresses_digsites && finds && finds.len && !broke_find)
        var/datum/find/F = finds[1]
        if(round(excavation_level + P.excavation_amount) == F.excavation_required)
            excavate_find(100, F)

        else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
            excavate_find(0, F)

/datum/finds/proc/artifact_debris(var/severity = 0)
	if(severity)
		switch(rand(1,3))
			if(1)
				var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal((holder))
				M.amount = rand(5,25)
			if(2)
				var/obj/item/stack/sheet/plasteel/R = new(holder)
				R.amount = rand(5,25)
			if(3)
				var/obj/item/stack/sheet/mineral/uranium/R = new(holder)
				R.amount = rand(5,25)
	else
		switch(rand(1,5))
			if(1)
				var/obj/item/stack/rods/R = new(holder)
				R.amount = rand(5,25)
			if(2)
				var/obj/item/stack/tile/metal/R = new(holder)
				R.amount = rand(1,5)
			if(3)
				var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal((holder))
				M.amount = rand(1,5)
			if(4)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard(holder.loc)
			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new /obj/item/weapon/shard/plasma(holder.loc)

/datum/finds/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
	//with skill or luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/X
	if(prob_clean)
		X = F.create_find(holder)
	else
		X = new /obj/item/weapon/strangerock(holder, F)
		if(!geologic_data)
			geologic_data = new/datum/geosample(holder)
		geologic_data.UpdateNearbyArtifactInfo(holder)
		X:geologic_data = geologic_data

	finds.Remove(F)

/datum/finds/proc/update_excav_level(obj/item/weapon/pickaxe/P)
    excavation_level += P.excavation_amount

    if(!archaeo_overlay && finds && finds.len)
        var/datum/find/F = finds[1]
        if(F.excavation_required <= excavation_level + F.view_range)
            archaeo_overlay = "overlay_archaeo[rand(1,3)]"
            holder.overlays += archaeo_overlay

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
        holder.overlays += excav_overlay

/datum/finds/proc/spawn_boulder(obj/item/weapon/pickaxe/P,mob/user)
    var/obj/structure/boulder/B
    . = TRUE
    if(!P.depresses_digsites && artifact_find)
        if(excavation_level > 0)

            B = new /obj/structure/boulder(holder)
            B.geological_data = geologic_data

            B.artifact_find = artifact_find
            B.investigation_log(I_ARTIFACT, "|| [artifact_find.artifact_find_type] - [artifact_find.artifact_id] found by [key_name(user)].")
            . = FALSE

        else
            artifact_debris(1)

    else if(!P.depresses_digsites && excavation_level > 0 && prob(15))
        B = new /obj/structure/boulder(holder)
        B.geological_data = geologic_data

        
/datum/finds/proc/large_artifact_fail()
    //destroyed artifacts have weird, unpleasant effects
	//make sure to destroy them before changing the turf though
	if(artifact_find)
		var/datum/artifact_postmortem_data/destroyed = new(null, FALSE, TRUE)
		destroyed.artifact_id = artifact_find.artifact_id
		destroyed.last_loc = holder
		destroyed.artifact_type = artifact_find.artifact_find_type
		if (artifact_find.artifact_find_type == /obj/machinery/artifact)
			destroyed.primary_effect = "???"
			destroyed.secondary_effect = "???"
		razed_large_artifacts[artifact_find.artifact_id] += destroyed
		ArtifactRepercussion(holder, usr, "", "[artifact_find.artifact_find_type]")