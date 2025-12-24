var/list/obj/machinery/prism/prism_list = list()
/obj/machinery/prism
	name = "Prism"
	desc = "A simple device that combines emitter beams."

	icon='icons/obj/machines/optical/prism.dmi'
	icon_state="prism_off"

	use_power = MACHINE_POWER_USE_NONE
	anchored = 0
	density = 1
	verb_rotates = TRUE
	alt_click_rotates = TRUE

	var/obj/effect/beam/emitter/beam

	machine_flags = WRENCHMOVE | SCREWTOGGLE | CROWDESTROY

/obj/machinery/prism/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/prism
	)
	prism_list += src

/obj/machinery/prism/Destroy()
	QDEL_NULL(beam)
	prism_list -= src
	..()

/obj/machinery/prism/proc/check_rotation()
	for(var/obj/effect/beam/emitter/B in beams)
		to_chat(world, "[src] \ref[src] found [get_dir(src, B)] its dir is [dir]")
		if(get_dir(src, B) != dir)
			return 1

/obj/machinery/prism/change_dir(new_dir, changer)
	. = ..()
	QDEL_NULL(beam)
	update_beams()

/obj/machinery/prism/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(beams && beams.len)
		update_beams()

/obj/machinery/prism/beam_connect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		B.register_event(/event/beam_power_change, src, nameof(src::on_power_change()))
		update_beams(B)

/obj/machinery/prism/beam_disconnect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		B.unregister_event(/event/beam_power_change, src, nameof(src::on_power_change()))
		update_beams(B)

// When beam power changes
/obj/machinery/prism/proc/on_power_change(obj/effect/beam/beam)
	update_beams()

/obj/machinery/prism/proc/update_beams(var/obj/effect/beam/emitter/touching_beam)
	overlays.len = 0
	underlays.len = 0
	kill_moody_light_all()
	//testing("Beam count: [beams.len]")
	if(get_dir(src, touching_beam) == dir)
		return 0 //Make no change for beams touching us on our emission side.
	if(!beams)
		if(loc || !gcDestroyed)
			beams = list()
		else
			return
	if(beams.len>0 && anchored)
		var/newbeam=0
		if(!beam)
			beam = new /obj/effect/beam/emitter(loc)
			beam.dir=dir
			newbeam=1
		beam.power=0
		var/list/spawners = list(src)
		for(var/obj/effect/beam/emitter/B in beams)
			if(get_dir(src, B) == dir)
				continue
			if(B.HasSource(src))
				warning("Ignoring beam [B] due to recursion.")
				continue // Prevent infinite loops.
			// Don't process beams firing into our emission side.

			spawners |= B.sources
			beam.power += B.power

			/// Propogate anti-recursion info
			if(beam.steps<B.steps+1)
				beam.steps=B.steps+1

			var/beamdir=get_dir(B.loc,src)
			overlays += image(icon=icon,icon_state="beam_arrow",dir=beamdir)
			update_moody_light_index("beam_arrow_[beamdir]",'icons/lighting/moody_lights.dmi', "overlay_beam_arrow", moody_color = "#66ffff", dir_override = beamdir)

			var/indir = turn(beamdir, 180)
			underlays += B.get_machine_underlay(indir)
			update_moody_light_index("inbeam_dir[indir]",'icons/lighting/moody_lights.dmi', "overlay_emitter_beam_underlay_short", moody_color = "#66ffff", dir_override = indir)

		if(newbeam)
			beam.emit(spawn_by=spawners)
		else
			beam.set_power(beam.power)
		icon_state = "prism_on"
		update_moody_light_index("base",'icons/lighting/moody_lights.dmi', "overlay_prism", moody_color = "#66ffff")
		underlays += beam.get_machine_underlay(dir)
		update_moody_light_index("outbeam_dir[dir]",'icons/lighting/moody_lights.dmi', "overlay_emitter_beam_underlay_short", moody_color = "#66ffff", dir_override = dir)
	else
		icon_state = "prism_off"
		if (beam)
			qdel(beam)
			beam=null
