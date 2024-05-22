/proc/gibs(atom/location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor)		//CARN MARKER
	new /obj/effect/gibspawner/generic(location,virus2,MobDNA,fleshcolor,bloodcolor)

/proc/mgibs(atom/location, var/list/virus2, var/datum/dna/MobDNA)
	new /obj/effect/gibspawner/genericmothership(location,virus2,MobDNA)

/proc/hgibs(atom/location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/human(location,virus2,MobDNA,fleshcolor,bloodcolor, spread_radius)

/proc/xgibs(atom/location, var/list/virus2)
	new /obj/effect/gibspawner/xeno(location,virus2)

/proc/robogibs(atom/location, var/list/virus2)
	new /obj/effect/gibspawner/robot(location,virus2)
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//The following procs were thought to be used in correlation with the amount of blood available, example:
//a loop in [bloodpack.dm] that spawns      _______________________________________
//1 blood splatter per 60u of blood     >>>|this means that 6drips = 1splatter    |
//and 1 blood drip per 10u                |same behaviour as proc/blood_splatter|
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Apparently no one has ever needed to do a blood mess, so I didn't bother making a generic proc.
////////////////////////////////////////////////////////////////////////////////////////////////////////
/proc/bloodmess_splatter(atom/location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/blood(location, virus2, MobDNA, fleshcolor, bloodcolor, spread_radius)

/proc/bloodmess_drip(atom/location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	new /obj/effect/gibspawner/blood_drip(location, virus2, MobDNA, fleshcolor, bloodcolor, spread_radius)

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists
	var/fleshcolor = DEFAULT_FLESH
	var/bloodcolor = DEFAULT_BLOOD
	var/list/virus2
	var/datum/dna/MobDNA
	var/spread_radius

/obj/effect/gibspawner/New(location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	..()

	if(virus2)
		src.virus2 = virus2.Copy()
	if(MobDNA)
		src.MobDNA = MobDNA
	if(fleshcolor)
		src.fleshcolor = fleshcolor
	if(bloodcolor)
		src.bloodcolor = bloodcolor
	if(spread_radius)
		src.spread_radius = spread_radius

	if(loc?.type != /obj/machinery/atmospherics/unary/cryo_cell)
		Gib(get_turf(loc))
	else
		register_event(/event/after_move, src, nameof(src::gib_out_cryo()))

/obj/effect/gibspawner/proc/gib_out_cryo()
	if(loc?.type != /obj/machinery/atmospherics/unary/cryo_cell)
		unregister_event(/event/after_move, src, nameof(src::gib_out_cryo()))
		Gib(get_turf(loc))

/obj/effect/gibspawner/proc/Gib(atom/location)
	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		to_chat(world, "<span class='warning'>Gib list length mismatch!</span>")
		return

	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		spark(location, 2)

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]

				gib = spawngib(gibType,location,fleshcolor,bloodcolor,virus2,MobDNA)

				var/list/directions = gibdirections[i]
				if(gib && directions.len)
					gib.streak(directions, spread_radius)

	qdel(src)

//spawning a single gib
/proc/spawngib(var/gibType,
				var/location,
				var/fleshcolor=DEFAULT_FLESH,
				var/bloodcolor=DEFAULT_BLOOD,
				var/list/virus2 = list(),
				var/datum/dna/MobDNA = null)
	var/obj/effect/decal/cleanable/blood/gibs/gib = new gibType(location)

	if(!istype(gib, /obj/effect/decal/cleanable))
		return gib

	if(bloodcolor)
		gib.basecolor = bloodcolor
	if(virus2?.len)
		gib.virus2 = filter_disease_by_spread(virus_copylist(virus2),required = SPREAD_BLOOD)
	if(MobDNA)
		gib.blood_DNA = list()
		gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.b_type

	if(!istype(gib))
		return gib

	if(fleshcolor)
		gib.fleshcolor = fleshcolor
	gib.update_icon()
	return gib
