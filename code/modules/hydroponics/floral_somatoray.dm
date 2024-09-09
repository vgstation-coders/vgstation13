
/obj/item/floral_somatoray
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "floral_somatoray"
	item_state = "floramut"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=3"
	mech_flags = null // So it can be scanned by the Device Analyser
	var/mode = 1
	var/list/genes = list(
		GENE_PHYTOCHEMISTRY		=	"#81FFEB",
		GENE_MORPHOLOGY			=	"#FF81AA",
		GENE_BIOLUMINESCENCE	=	"#81B4FF",
		GENE_ECOLOGY			=	"#FFB781",
		GENE_ECOPHYSIOLOGY		=	"#9781FF",
		GENE_METABOLISM			=	"#E9FF81",
		GENE_DEVELOPMENT		=	"#F681FF",
		GENE_XENOPHYSIOLOGY		=	"#8AFF81",
		)
	var/isSomatoraying = FALSE
	var/charge_speed = 10//how many ticks do you have to stand before the radiation comes out

	var/image/mode_color
	var/image/mode_glint
	var/atom/movable/overlay/charging_ray


/obj/item/floral_somatoray/New()
	..()
	mode_color = image(icon, src, "floral_somatoray-modecolor")
	mode_glint = image(icon, src, "floral_somatoray-modeglint")
	mode_glint.blend_mode = BLEND_ADD
	update_icon()

/obj/item/floral_somatoray/attack_self(var/mob/living/user)
	//loops through all genes
	if (emagged)
		mode = rand(1, length(genes))
		to_chat(user, "<span class='warning'>You try to change \the [src]'s mode but it doesn't seem to cooperate.</span>")
	else
		mode = mode % length(genes) + 1
		to_chat(user, "<span class='warning'>\The [src] is now set to modify [genes[mode]] traits.</span>")
	update_icon()
	playsound(user, 'sound/weapons/egun_toggle_noammo.ogg', 50, 1)
	flick("floral_somatoray-modechange", src)

/obj/item/floral_somatoray/update_icon()
	overlays.len = 0
	var/current_gene = genes[mode]
	mode_color.color = genes[current_gene]
	overlays += mode_color
	overlays += mode_glint
	if (emagged)
		overlays += "floral_somatoray-emagged"

/obj/item/floral_somatoray/pickup(var/mob/user)
	user.register_event(/event/after_move, src, /obj/item/floral_somatoray/proc/ray_moved)

/obj/item/floral_somatoray/dropped(var/mob/user)
	user.unregister_event(/event/after_move, src, /obj/item/floral_somatoray/proc/ray_moved)
	cancel_ray()

/obj/item/floral_somatoray/proc/ray_moved()
	var/turf/T = get_turf(src)
	if (charging_ray && (T != charging_ray.loc))
		cancel_ray()

/obj/item/floral_somatoray/proc/cancel_ray()
	isSomatoraying = FALSE
	QDEL_NULL(charging_ray)

/obj/item/floral_somatoray/attackby(var/obj/item/weapon/W, var/mob/user)
	if(isEmag(W) || issolder(W))
		if (emagged && issolder(W))
			to_chat(user, "<span class='warning'>You repair the safety limit of the [src.name]!</span>")
			desc = initial(desc)
			emagged = FALSE
			update_icon()
		else
			emag_act(user)

/obj/item/floral_somatoray/emag_act(mob/user)
	if (emagged)
		to_chat(user, "The safeties are already de-activated.")
	else
		emagged = TRUE
		to_chat(user, "<span class='warning'>You short out the safety limit of the [src.name]!</span>")
		desc += " It seems to have it's safety features de-activated."
		playsound(user, 'sound/effects/sparks4.ogg', 50, 1)
		update_icon()
	

/obj/item/floral_somatoray/attack(var/mob/living/M, var/mob/living/user, var/def_zone, var/originator=null)
	return

/obj/item/floral_somatoray/afterattack(var/atom/target, var/mob/user, var/proximity_flag, var/click_parameters)
	//First let's check if we can even fire at all at the target
	if(isSomatoraying)
		return
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	if ((T.z != U.z)||(get_dist(user,target) > world.view))
		to_chat(user, "<span class='warning'>The [target] is too far, the radiation would dissipate before it reaches it.</span>")
		return
	if((target != user) && ((!isturf(target) && !isturf(target.loc)) || !test_reach(T,target,PASSTABLE|PASSGLASS|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER|PASSRAILING)))
		to_chat(user, "<span class='warning'>You can't aim at \the [target] from here.</span>")
		return
	var/current_gene = genes[mode]
	playsound(user,'sound/weapons/wave_reversed_and_longer.ogg', 15)

	var/firing_angle
	//Charging Ray Effect
	isSomatoraying = TRUE
	if (T!=U)
		charging_ray = anim(target = user, a_icon = 'icons/effects/96x96.dmi', a_icon_state = "floral_somatoray",sleeptime = charge_speed, offX = -32, offY = -32, alph = 50,plane = ABOVE_LIGHTING_PLANE)
		if (emagged)
			charging_ray.icon += genes[pick(genes)]
		else
			charging_ray.icon += genes[current_gene]
		animate(charging_ray, alpha = 100, time = 10)
		var/disty = U.y - T.y
		var/distx = U.x - T.x
		if(!disty)
			if(distx >= 0)
				firing_angle = 90
			else
				firing_angle = 270
		else
			firing_angle = arctan(distx/disty)
			if(disty < 0)
				firing_angle += 180
			else if(distx < 0)
				firing_angle += 360
		var/matrix/M = matrix()
		charging_ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),firing_angle)

	if(!do_after(user,U,charge_speed))
		cancel_ray()
		return
	if(!isSomatoraying)
		return
	cancel_ray()

	playsound(user,'sound/weapons/wave.ogg', 30)

	var/atom/actual_target
	if (target && (U == get_turf(target)))//target didn't move
		if (T == U)
			actual_target = target
		else
			actual_target = get_reach(T,target,PASSTABLE|PASSGLASS|PASSGRILLE|PASSRAILING)//something might still get caught in-between
	if (!actual_target)
		actual_target = get_reach(T,U,PASSTABLE|PASSGLASS|PASSGRILLE|PASSRAILING)//target moved away, let's try to hit something still

	//Firing Ray Effect
	if (T!=actual_target && T!=actual_target.loc)
		var/colo
		if (emagged)
			colo = genes[pick(genes)]
		else
			colo = genes[current_gene]
		var/atom/movable/overlay/firing_ray = anim(target = user, a_icon = 'icons/effects/96x96.dmi', flick_anim = "floral_somatoray_hit",sleeptime = 5, offX = -32, offY = -32, col = colo, alph = 150,plane = ABOVE_LIGHTING_PLANE)
		var/disty = actual_target.y - T.y
		var/distx = actual_target.x - T.x
		var/matrix/M = matrix()
		firing_ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),firing_angle)

	//custom tracker effect
	spawn()
		var/matrix/N = matrix()
		for(var/i = 0;i < 3;i++)
			var/obj/effect/tracker/Tr = new (T)
			Tr.target = actual_target
			Tr.plane = ABOVE_LIGHTING_PLANE
			Tr.icon = 'icons/obj/hydroponics/hydro_tools.dmi'
			if (emagged)
				Tr.icon += genes[pick(genes)]
			else
				Tr.icon += genes[current_gene]
			Tr.icon_state = "floral_somatoray_ray"
			Tr.transform = turn(N,firing_angle)
			Tr.refresh = 0.5
			Tr.alpha = 100
			sleep(1)

	//Now to finally deal with the hit target
	if (istype(actual_target,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = actual_target
		if (emagged)
			for(var/gene in genes)
				if(prob(50))
					tray.mutate(gene)
		else
			if(prob(50))
				tray.mutate((genes[mode]))
	else if(ishuman(actual_target))
		var/mob/living/carbon/human/H = actual_target
		if((H.species.flags & IS_PLANT))
			if (emagged)
				H.apply_radiation((rand(10,30)),RAD_EXTERNAL)
				H.Knockdown(5)
				H.Stun(5)
				user.show_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", 1, "<span class='warning'>You hear the crunching of leaves.</span>", 2)
			else if(H.nutrition < 500)
				H.nutrition += 30//should probably be different effects depending on the selected genes
				to_chat(H, "<span class='notice'>The radiation stimulates your cells and you feel well nourrished.</span>")
		else
			if (emagged)
				to_chat(H, "<span class='warning'>The radiation beam singes you!</span>")
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					H.adjustFireLoss(rand(3, 10))
					randmutg(H)
					domutcheck(H,null)
			else
				to_chat(H, "<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else if(istype(target, /obj/machinery/apiary))
		var/obj/machinery/apiary/A = actual_target
		if (A.queen_bees_inside || A.worker_bees_inside)
			if (emagged)
				A.angry_swarm()
				to_chat(user, "<span class='danger'>The radiation agitates the bees!/span>")
			else
				switch(genes[mode])
					if (GENE_DEVELOPMENT)
						if(!A.yieldmod)
							A.yieldmod += 1
							to_chat(user, "<span class='notice'>The radiation stimulates the bees' productivity.</span>")
						else if (prob(1/(A.yieldmod * A.yieldmod) *100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
							A.yieldmod += 1
							to_chat(user, "<span class='notice'>The radiation stimulates the bees' productivity further...</span>")
					if (GENE_MORPHOLOGY)
						A.damage = round(rand(0,3))//0, 1, or 2 brute damage per stings...per bee in a swarm
						to_chat(user, "<span class='notice'>The radiation seems to alter the bees' morphology.</span>")
					else
						to_chat(user, "<span class='warning'>The radiation appears to have no discernable effect on the bees.</span>")
		else
			to_chat(user, "<span class='notice'>There are no bees inside \the [A]. The radiation appears ineffective.</span>")
