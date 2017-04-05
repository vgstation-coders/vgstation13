/proc/gibs(atom/location, var/list/viruses, var/datum/dna/MobDNA)		//CARN MARKER
	new /obj/effect/gibspawner/generic(get_turf(location),viruses,MobDNA)

/proc/hgibs(atom/location, var/list/viruses, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/human(get_turf(location),viruses,MobDNA,fleshcolor,bloodcolor, spread_radius)

/proc/xgibs(atom/location, var/list/viruses)
	new /obj/effect/gibspawner/xeno(get_turf(location),viruses)

/proc/robogibs(atom/location, var/list/viruses)
	new /obj/effect/gibspawner/robot(get_turf(location),viruses)
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//The following procs were thought to be used in correlation with the amount of blood available, example:
//a loop in [bloodpack.dm] that spawns      _______________________________________
//1 blood splatter per 60u of blood     >>>|this means that 6drips = 1splatter    |
//and 1 blood drip per 10u                |same behaviour as proc/blood_splatter|
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Apparently no one has ever needed to do a blood mess, so I didn't bother making a generic proc.
////////////////////////////////////////////////////////////////////////////////////////////////////////
/proc/bloodmess_splatter(atom/location, var/list/viruses, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/blood(get_turf(location), viruses, MobDNA, fleshcolor, bloodcolor, spread_radius)

/proc/bloodmess_drip(atom/location, var/list/viruses, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/blood_drip(get_turf(location), viruses, MobDNA, fleshcolor, bloodcolor, spread_radius)

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists
	var/fleshcolor //Used for gibbed humans.
	var/bloodcolor //Used for gibbed humans.

/obj/effect/gibspawner/New(location, var/list/viruses, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	..()

	if(fleshcolor)
		src.fleshcolor = fleshcolor
	if(bloodcolor)
		src.bloodcolor = bloodcolor

	if(istype(loc,/turf)) //basically if a badmin spawns it
		Gib(loc,viruses,MobDNA,spread_radius)

/obj/effect/gibspawner/proc/Gib(atom/location, var/list/viruses = list(), var/datum/dna/MobDNA = null, spread_radius)
	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		to_chat(world, "<span class='warning'>Gib list length mismatch!</span>")
		return

	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]
				gib = getFromPool(gibType,location)//new gibType(location)
				gib.New(location)

				// Apply human species colouration to masks.
				if(fleshcolor)
					gib.fleshcolor = fleshcolor
				if(bloodcolor)
					gib.basecolor = bloodcolor

				gib.update_icon()

				if(viruses)
					gib.virus2 |= virus_copylist(viruses)

				gib.blood_DNA = list()
				if(MobDNA)
					gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.b_type
				else if(istype(src, /obj/effect/gibspawner/xeno))
					gib.blood_DNA["UNKNOWN DNA"] = "X*"
				else if(istype(src, /obj/effect/gibspawner/human)) // Probably a monkey
					gib.blood_DNA["Non-human DNA"] = "A+"
				var/list/directions = gibdirections[i]
				if(directions.len)
					gib.streak(directions, spread_radius)

	qdel(src)
