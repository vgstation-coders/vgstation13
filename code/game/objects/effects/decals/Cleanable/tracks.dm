// The idea is to have 4 bits for coming and 4 for going.
#define TRACKS_COMING_NORTH 1
#define TRACKS_COMING_SOUTH 2
#define TRACKS_COMING_EAST  4
#define TRACKS_COMING_WEST  8
#define TRACKS_GOING_NORTH  16
#define TRACKS_GOING_SOUTH  32
#define TRACKS_GOING_EAST   64
#define TRACKS_GOING_WEST   128

// 5 seconds
//#define TRACKS_CRUSTIFY_TIME   50

// color-dir-dry
//var/global/list/image/fluidtrack_cache=list()

/datum/fluidtrack
	var/direction=0
	var/basecolor=DEFAULT_BLOOD
	//var/wet=0
	var/fresh=1
	//var/crusty=0
	var/image/overlay

/datum/fluidtrack/New(_direction,_color)
	src.direction=_direction
	src.basecolor=_color
	//src.wet=_wet

// Footprints, tire trails...
/obj/effect/decal/cleanable/blood/tracks
	amount = 0
	random_icon_states = null
	var/dirs=0
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = ""
	var/coming_state="blood1"
	var/going_state="blood2"
	var/updatedtracks=0

	var/list/setdirs=list(
		"1"=0,
		"2"=0,
		"4"=0,
		"8"=0,
		"16"=0,
		"32"=0,
		"64"=0,
		"128"=0
	)

	/** DO NOT FUCKING REMOVE THIS. **/
	process()
		return PROCESS_KILL

	/**
	* Add tracks to an existing trail.
	*
	* @param DNA bloodDNA to add to collection.
	* @param comingdir Direction tracks come from, or 0.
	* @param goingdir Direction tracks are going to (or 0).
	* @param bloodcolor Color of the blood when wet.
	*/
/obj/effect/decal/cleanable/blood/tracks/resetVariables()
	..("setdirs")
	setdirs=list(
		"1"=0,
		"2"=0,
		"4"=0,
		"8"=0,
		"16"=0,
		"32"=0,
		"64"=0,
		"128"=0
	)

/obj/effect/decal/cleanable/blood/tracks/proc/AddTracks(var/list/DNA, var/comingdir, var/goingdir, var/bloodcolor=DEFAULT_BLOOD)
	var/updated=0
	// Shift our goingdir 4 spaces to the left so it's in the GOING bitblock.
	var/realgoing=goingdir<<4

	// When tracks will start to dry out
	//var/t=world.time + TRACKS_CRUSTIFY_TIME

	var/datum/fluidtrack/track

	for (var/b in cardinal)
		// COMING BIT
		// If setting
		if(comingdir&b)
			track=new /datum/fluidtrack(b,bloodcolor)
			if(!setdirs || !istype(setdirs, /list) || setdirs.len < 8 || isnull(setdirs["[b]"]))
				warning("[src] had a bad directional [b] or bad list [setdirs.len]")
				warning("Setdirs keys:")
				for(var/key in setdirs)
					warning(key)
				setdirs=list (
				"1"=0,
				"2"=0,
				"4"=0,
				"8"=0,
				"16"=0,
				"32"=0,
				"64"=0,
				"128"=0
				)
			setdirs["[b]"] = track
			updatedtracks |= b
			updated=1

		// GOING BIT (shift up 4)
		b=b<<4
		if(realgoing&b)
			track=new /datum/fluidtrack(b,bloodcolor)
			if(!setdirs || !istype(setdirs, /list) || setdirs.len < 8 || isnull(setdirs["[b]"]))
				warning("[src] had a bad directional [b] or bad list [setdirs.len]")
				warning("Setdirs keys:")
				for(var/key in setdirs)
					warning(key)
				setdirs=list (
				"1"=0,
				"2"=0,
				"4"=0,
				"8"=0,
				"16"=0,
				"32"=0,
				"64"=0,
				"128"=0
				)
			setdirs["[b]"] = track
			updatedtracks |= b
			updated=1

	dirs |= comingdir|realgoing
	if(istype(DNA,/list))
		blood_DNA |= DNA.Copy()
	if(updated)
		update_icon()

/obj/effect/decal/cleanable/blood/tracks/update_icon()
	var/truedir=0
	var/b=0
	for(var/_overlay in overlays) //For whatever reason we can't use a typed var in here
		var/image/overlay = _overlay
		b=overlay.dir
		if(overlay.icon_state==going_state)
			b=b<<4
		if(updatedtracks&b)
			overlays.Remove(overlay)
			//del(overlay)

	// We start with a blank canvas, otherwise some icon procs crash silently
	var/icon/flat = icon('icons/effects/fluidtracks.dmi')

	// Update ONLY the overlays that have changed.
	for(var/trackidx in setdirs)
		var/datum/fluidtrack/track = setdirs[trackidx]
		if(!track)
			continue
		if(!(updatedtracks&track.direction) && !track.fresh)
			continue
		var/state=coming_state
		truedir=track.direction
		if(truedir>15) // Check if we're in the GOING block
			state=going_state
			truedir=truedir>>4
		var/icon/add = icon('icons/effects/fluidtracks.dmi', state, truedir)
		add.SwapColor("#FFFFFF",track.basecolor)
		var/image/realadd = image(add,, state,, truedir)
		overlays += realadd
		if(track.basecolor == "#FF0000"||track.basecolor == DEFAULT_BLOOD) // no dirty dumb vox scum allowed
			plane = NOIR_BLOOD_PLANE
		else
			plane = ABOVE_TURF_PLANE
		track.fresh=0

	icon = flat
	updatedtracks=0 // Clear our memory of updated tracks.

/obj/effect/decal/cleanable/blood/tracks/footprints
	name = "wet footprints"
	desc = "Whoops..."
	coming_state = "human1"
	going_state  = "human2"
	amount = 0
	plane = NOIR_BLOOD_PLANE

/obj/effect/decal/cleanable/blood/tracks/footprints/vox
	coming_state = "claw1"
	going_state  = "claw2"

/obj/effect/decal/cleanable/blood/tracks/footprints/magboots
	coming_state = "magboots1"
	going_state  = "magboots2"

/obj/effect/decal/cleanable/blood/tracks/footprints/boots
	coming_state = "boots1"
	going_state  = "boots2"

/obj/effect/decal/cleanable/blood/tracks/footprints/clown //Fun Fact: This footprint is way longer than the regular one and thus is spaced differently, making it the only evenly-spaced footprint type.
	coming_state = "clown1"
	going_state  = "clown2"

/obj/effect/decal/cleanable/blood/tracks/footprints/catbeast
	coming_state = "catbeast1"
	going_state  = "catbeast2"

/obj/effect/decal/cleanable/blood/tracks/wheels
	name = "wet tracks"
	desc = "Whoops..."
	coming_state = "wheels"
	going_state  = ""
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	random_icon_states = null
	amount = 0

