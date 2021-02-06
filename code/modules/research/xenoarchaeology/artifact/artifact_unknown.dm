var/list/excavated_large_artifacts = list()
var/list/destroyed_large_artifacts = list()
var/list/razed_large_artifacts = list()//destroyed while still inside a rock wall/boulder

/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano00"
	var/prefix = "ano"
	var/numsuffix = 0
	var/image/fx_image
	density = 1
	var/datum/artifact_effect/primary_effect
	var/datum/artifact_effect/secondary_effect
	var/being_used = 0
	var/contained = 0
	var/artifact_id = ""
	anchored = 0
	layer = ABOVE_OBJ_LAYER
	var/event/on_attackby
	var/event/on_explode
	var/event/on_projectile
	var/event/on_beam
	var/analyzed = 0 //set to 1 after having been analyzed successfully
	var/safe_delete = FALSE

/obj/machinery/artifact/New(location, find_id, generate_effect = 1)
	..()
	if(find_id)
		artifact_id = find_id
	else
		artifact_id = generate_artifact_id()

	excavated_large_artifacts[artifact_id] = src

	on_attackby = new(owner = src)
	on_explode = new(owner = src)
	on_projectile = new(owner = src)
	on_beam = new(owner = src)
	//event arguement list format (user, "context", item)

	if(generate_effect)
		//setup primary effect
		var/effecttype = pick(typesof(/datum/artifact_effect) - /datum/artifact_effect)
		primary_effect = new effecttype(src, 1) //pass the 1 so that the effect knows to generate a trigger
		primary_effect.artifact_id = "[artifact_id]a"
		spawn(1)	//delay logging so if admin tools override/other fuckery occurs the logs still end up correct
			src.investigation_log(I_ARTIFACT, "|| spawned with a primary effect [primary_effect.artifact_id]: [primary_effect] || range: [primary_effect.effectrange] || charge time: [primary_effect.chargelevelmax] || trigger: [primary_effect.trigger].")

		//75% chance to have a secondary effect
		if(prob(75))
			effecttype = pick(typesof(/datum/artifact_effect) - /datum/artifact_effect)
			secondary_effect = new effecttype(src, 1, FALSE)
			secondary_effect.artifact_id = "[artifact_id]b"
			spawn(1)
				if(secondary_effect)	//incase admin tools or something deleted the secondary
					src.investigation_log(I_ARTIFACT, "|| spawned with a secondary effect [secondary_effect.artifact_id]: [secondary_effect] || range: [secondary_effect.effectrange] || charge time: [secondary_effect.chargelevelmax] || trigger: [secondary_effect.trigger].")
					if(prob(75) && secondary_effect.effect != ARTIFACT_EFFECT_TOUCH)
						src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id] starts triggered by default.")
						secondary_effect.ToggleActivate(2)

		generate_icon()

/obj/machinery/artifact/proc/generate_icon()
	prefix = pick(primary_effect.valid_style_types)
	numsuffix = pick(rand(1,all_artifact_style_effect_types[prefix]))

	if(prefix in goon_style_effect_types)
		icon = 'goon/icons/obj/artifacts.dmi'
		if(prefix != ARTIFACT_STYLE_RELIQUARY)
			fx_image = image(icon, "[prefix][numsuffix]fx")
			fx_image.color = rgb(rand(0,255),rand(0,255),rand(0,255))
	else
		if(numsuffix == 7 || numsuffix == 8)
			name = "large crystal"
			desc = pick("It shines faintly as it catches the light.",\
			"It appears to have a faint inner glow.",\
			"It seems to draw you inward as you look it at.",\
			"Something twinkles faintly as you look at it.",\
			"It's mesmerizing to behold.")
		else if(numsuffix == 9)
			name = "alien computer"
			desc = "It is covered in strange markings."
		else if(numsuffix == 10)
			desc = "A large alien device, there appear to be some kind of vents in the side."
		else if(numsuffix == 11)
			name = "sealed alien pod"
			desc = "A strange alien device."

	update_icon()

/obj/machinery/artifact/update_icon()
	overlays.len = 0
	var/fx_suffix = ""

	if(icon == 'icons/obj/xenoarchaeology.dmi')		//If its not a goon artifact:
		if(primary_effect.activated)				// If its active, suffix is 1, otherwise its 0
			fx_suffix = 1
		else
			fx_suffix = 0
	else if(primary_effect.activated)
		if(fx_image)
			fx_suffix = ""
			overlays += fx_image
		else
			fx_suffix = "fx"					//If we're a goon-style artifact and we don't have an fx image, then we're our own fx!
	else
		fx_suffix = ""						//If its an non-active goon artifact, fx suffix is always empty.

	icon_state = "[prefix][numsuffix][fx_suffix]"


/obj/machinery/artifact/process()

	var/turf/L = loc
	if(isnull(L) || !istype(L)) 	// We're inside a container or on null turf, either way stop processing effects
		return

	if(primary_effect)
		primary_effect.trigger.CheckTrigger(src)	//check enviromental triggers
		if(!contained)								//"contained" is toggled by artifact extraction fields
			primary_effect.process()
	if(secondary_effect)
		secondary_effect.trigger.CheckTrigger(src)
		if(!contained)
			secondary_effect.process()

	if(pulledby)
		if(!Adjacent(pulledby)) //Not actually next to them
			if(pulledby.pulling == src)
				pulledby.stop_pulling()
			pulledby = null
		else if(pulledby.incapacitated()) //To prevent getting stuck stunned forever due to not being able to break the pull.
			if(pulledby.pulling == src)
				pulledby.stop_pulling()
			pulledby = null
		else
			Bumped(pulledby)

/obj/machinery/artifact/attack_hand(var/mob/user as mob)
	if(isobserver(user))
		to_chat(user, "<span class='rose'>Your ghostly hand goes right through!</span>")
		return
	if (get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You can't reach [src] from here.</span>")
		return
	if(ishuman(user) && user:gloves)
		to_chat(user, "<b>You touch [src]</b> with your gloved hands, [pick("but nothing of note happens","but nothing happens","but nothing interesting happens","but you notice nothing different","but nothing seems to have happened")].")
		return

	src.add_fingerprint(user)
	to_chat(user, "<b>You touch [src].</b>")
	lazy_invoke_event(/lazy_event/on_attackhand, list("user" = user, "target" = src))

/obj/machinery/artifact/attackby(obj/item/weapon/W as obj, mob/living/user as mob)

	..()
	user.delayNextAttack(8)
	user.do_attack_animation(src, W)
	if (W.hitsound)
		playsound(src, W.hitsound, 50, 1, -1)
	if (W.attack_verb)
		visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W].</span>")
	else
		visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>")
	on_attackby.Invoke(list(user, "MELEE", W))

/obj/machinery/artifact/Bumped(var/atom/A)
	if (istype(A,/obj))
		on_attackby.Invoke(list(usr, "THROW", A))
	else if (isliving(A))
		var/mob/living/L = A
		if (!ishuman(L) || !istype(L:gloves,/obj/item/clothing/gloves))
			if (prob(50))
				to_chat(L, "<b>You accidentally touch [src].<b>")
				lazy_invoke_event(/lazy_event/on_bumped, list("user" = L, "target" = src))
	..()

/obj/machinery/artifact/to_bump(var/atom/A)
	if (iscarbon(A))
		var/mob/living/L = A
		if (!ishuman(L) || !istype(L:gloves,/obj/item/clothing/gloves))
			if (prob(50))
				to_chat(L, "<b>\The [src] bumps into you.<b>")
				lazy_invoke_event(/lazy_event/on_bumped, list("user" = L, "target" = src))
	..()

/obj/machinery/artifact/bullet_act(var/obj/item/projectile/P)
	on_projectile.Invoke(list(P.firer, "PROJECTILE",P))
	return ..()

/obj/machinery/artifact/beam_connect(var/obj/effect/beam/B)
	..()
	on_beam.Invoke(list(B, "BEAMCONNECT"))

/obj/machinery/artifact/ex_act(severity)
	switch(severity)
		if(1.0)
			src.investigation_log(I_ARTIFACT, "|| blew up by EXPLOSION DAMAGE([severity]).")
			ArtifactRepercussion(src, null, "an explosion", "[type]")
			qdel(src)
		if(2.0)
			if (prob(50))
				src.investigation_log(I_ARTIFACT, "|| blew up by EXPLOSION DAMAGE([severity]).")
				ArtifactRepercussion(src, null, "an explosion", "[type]")
				qdel(src)
			else
				on_explode.Invoke(list("", "EXPLOSION"))
		if(3.0)
			on_explode.Invoke(list("", "EXPLOSION"))
	return

/obj/machinery/artifact/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if(primary_effect)
		primary_effect.UpdateMove()
	if(secondary_effect)
		secondary_effect.UpdateMove()

/obj/machinery/artifact/Destroy()
	new /datum/artifact_postmortem_data(src)

	qdel(primary_effect); primary_effect = null
	qdel(secondary_effect); secondary_effect = null
	qdel(on_attackby); on_attackby = null
	qdel(on_explode); on_explode = null
	qdel(on_projectile); on_projectile = null
	qdel(on_beam); on_beam = null
	..()

/proc/ArtifactRepercussion(var/atom/source, var/mob/mob_cause = null, var/other_cause = "", var/artifact_type = "")
	if (mob_cause)
		source.investigation_log(I_ARTIFACT, "|| [artifact_type] destroyed by [key_name(mob_cause)].")
	else
		source.investigation_log(I_ARTIFACT, "|| [artifact_type] destroyed[other_cause ? "because of [other_cause]." : ""]")
	for(var/mob/living/M in range(source, 200))
		M.playsound_local(M, 'sound/hallucinations/scary.ogg', 100, 0)
		to_chat(M, "<span class='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</b></span>")
		if(prob(50)) //pain
			flick("pain",M.pain)
			if(prob(50))
				M.adjustBruteLoss(5)
		else
			M.flash_eyes(visual = 1)
			if(prob(50))
				M.Stun(5)
		M.apply_radiation(25, RAD_EXTERNAL)

/obj/machinery/artifact/can_overload()
	return 0
