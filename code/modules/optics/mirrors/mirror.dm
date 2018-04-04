var/global/list/obj/machinery/mirror/mirror_list = list()
/obj/machinery/mirror
	name = "mirror"
	desc = "Looks too expensive and sciencey to mount above your bathroom sink."

	icon='icons/obj/machines/optical/beamsplitter.dmi'
	icon_state="mirror" // For alignment when mapping
	var/base_state = "base"
	var/mirror_state = "mirror"

	var/nsplits=1

	use_power = 0
	anchored = 0
	density = 1

	var/list/emitted_beams[4] // directions

	machine_flags = WRENCHMOVE | SCREWTOGGLE | CROWDESTROY

	var/list/powerchange_hooks=list()

/obj/machinery/mirror/New()
	..()
	mirror_list += src
	icon_state = base_state
	overlays += mirror_state // TODO: break on BROKEN
	component_parts = list(
		new /obj/item/stack/sheet/glass/rglass(src,5),
	)

/obj/machinery/mirror/proc/get_deflections(var/in_dir)
	if(dir in list(EAST, WEST))
		//testing("[src]: Detected orientation: \\, in_dir=[dir2text(in_dir)], dir=[dir2text(dir)]")
		switch(in_dir) // \\ orientation
			if(NORTH)
				return list(EAST)
			if(SOUTH)
				return list(WEST)
			if(EAST)
				return list(NORTH)
			if(WEST)
				return list(SOUTH)
	else
		//testing("[src]: Detected orientation: /, in_dir=[dir2text(in_dir)], dir=[dir2text(dir)]")
		switch(in_dir) // / orientation
			if(NORTH)
				return list(WEST)
			if(SOUTH)
				return list(EAST)
			if(EAST)
				return list(SOUTH)
			if(WEST)
				return list(NORTH)

/obj/machinery/mirror/Destroy()
	kill_all_beams()
	mirror_list -= src
	..()

// Replace machine frame with mirror frame.
/obj/machinery/mirror/dropFrame()
	var/obj/structure/mirror_frame/MF = new (src.loc)
	MF.anchored=anchored

/obj/machinery/mirror/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, -90)
	kill_all_beams()
	update_beams()
	return 1

/obj/machinery/mirror/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	kill_all_beams()
	update_beams()
	return 1

/obj/machinery/mirror/wrenchAnchor(var/mob/user)
	. = ..()
	if(!.)
		return

	if(beams && beams.len)
		kill_all_beams()
	update_beams()

/obj/machinery/mirror/beam_connect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		powerchange_hooks[B]=B.power_change.Add(src,"on_power_change")
		update_beams()

/obj/machinery/mirror/beam_disconnect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		B.power_change.Remove(powerchange_hooks[B])
		powerchange_hooks.Remove(B)
		update_beams()

// When beam power changes
/obj/machinery/mirror/proc/on_power_change(var/list/args)
	//Don't care about args, just update beam.
	update_beams()

/obj/machinery/mirror/proc/kill_all_beams()
	for(var/i=1;i<=4;i++)
		if(i > emitted_beams.len)
			break
		var/obj/effect/beam/beam = emitted_beams[i]
		qdel(beam)
		emitted_beams[i]=null
		beam=null
	emitted_beams.len = 4

/obj/machinery/mirror/proc/update_beams()
	overlays.len = 0

	var/list/beam_dirs[4] // dir = list(
                        //  type = power
                        // )

	var/i = 0 // Iteration index.

	// Initialize list.
	for(i=1;i<=4;i++)
		beam_dirs[i]=list()

	// For tracking recursion.
	var/list/spawners = list(src)

	//testing("Beam count: [beams.len]")
	if(beams && beams.len>0 && anchored)
		// Figure out what we're getting hit by.
		//var/BN=0
		for(var/obj/effect/beam/B in beams)
			//BN++
			//testing("Processing beam #[BN]")
			if(B.HasSource(src))
				warning("Ignoring beam [B] due to recursion.")
				continue // Prevent infinite loops.

			// For recursion protection
			spawners |= B.sources

			var/beamdir=get_dir(src,B)

			overlays += B.get_machine_underlay(beamdir)

			// Figure out how much power to emit in each direction
			var/list/deflections = get_deflections(beamdir)
			var/splitpower=1
			if(istype(B, /obj/effect/beam/emitter))
				var/obj/effect/beam/emitter/EB=B
				splitpower = round(EB.power/nsplits, 0.1) // Remember, round() is equivalent to other languages' floor().
			if(splitpower<0.1)
				continue
			for(i=1;i<=nsplits;i++)
				var/splitdir = deflections[i]
				var/diridx = cardinal.Find(splitdir)
				var/list/dirdata = beam_dirs[diridx]

				if(!(B.type in dirdata))
					dirdata[B.type] = splitpower
					//testing(" splitdir=[splitdir], splitpower=[splitpower]")
				else
					dirdata[B.type] = dirdata[B.type] + splitpower
					//testing(" splitdir=[splitdir], splitpower+=[splitpower]")
				beam_dirs[diridx]=dirdata


	// Ensure our emitted beams list is at the required length
	if(emitted_beams.len < 4)
		emitted_beams.len=4

	var/list/oldebs=emitted_beams.Copy()

	// Emit beams
	for(i=1;i<=4;i++)
		var/cdir = cardinal[i]
		var/list/dirdata = beam_dirs[i]
		var/delbeam=0
		var/obj/effect/beam/beam
		if(dirdata.len > 0)
			for(var/beamtype in dirdata)
				var/newbeam=0
				beam = emitted_beams[i]

				// If there's a beam and it's changed, nuke the existing beam.
				if (beam && beam.type != beamtype)
					qdel(beam)
					emitted_beams[i]=null
					beam=null

				// No beam?  Make one.
				if(!beam)
					beam = new beamtype(loc)
					emitted_beams[i]=beam
					beam.dir=cdir
					newbeam=1

				// Is it an emitter beam? Update its power.
				if(istype(beam, /obj/effect/beam/emitter))
					var/obj/effect/beam/emitter/EB=beam
					EB.power = dirdata[beamtype]

				overlays += beam.get_machine_underlay(cdir)

				if(newbeam)
					beam.emit(spawn_by=spawners)
				else if(istype(beam, /obj/effect/beam/emitter))
					var/obj/effect/beam/emitter/EB=beam
					EB.set_power(EB.power)
				break
		else // dirdata.len == 0
			delbeam=1

		// N3X15 Jan 11 2017: GC is deleting shit from the list or something, so we have to ensure size again.
		// Fix for #12077
		if(emitted_beams.len < 4)
			emitted_beams.len=4

		beam = emitted_beams[i] // Crashes here
		if(delbeam && beam)
			qdel(beam)
			emitted_beams[i]=null

	overlays += mirror_state

	// Ensure all beams have been cleaned up
	// Another 12077 fix.
	for(var/obj/effect/beam/B in oldebs)
		if(B && !(B in emitted_beams))
			// Ideally, I'd like to keep this warning to make Pomf bug Lummox,
			// but the spam would just piss everyone off.
			//testing("BUG: Beam \ref[B] is still around after getting deleted!")
			qdel(B)

/obj/machinery/mirror/bullet_act(var/obj/item/projectile/P, var/def_zone)
	if(!istype(P, /obj/item/projectile/beam))
		return
	if(P.damage < initial(P.damage)/4)  //Can only be reflected 5 times, let's say
		return
	var/list/deflections = get_deflections(get_dir(src,P))
	var/turf/T = get_turf(src)
	for(var/i=1 to nsplits)
		var/splitdir = deflections[i]
		var/turf/target = get_edge_target_turf(src, splitdir)
		var/obj/item/projectile/beam/B = new P.type
		B.original = target
		B.starting = T
		B.current = T
		B.forceMove(T)
		B.shot_from = P.shot_from
		B.yo = target.y - T.y
		B.xo = target.y - T.x
		B.OnFired()
		B.damage = P.damage/2
		spawn()
			B.process()