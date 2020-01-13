/obj/item/weapon/reagent_containers/borghypo
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	flags = FPRINT
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 // time it takes for shots to recharge (in seconds)

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list(TRICORDRAZINE, INAPROVALINE, SPACEACILLIN)
	//var/list/reagent_ids = list(DEXALIN, KELOTANE, BICARIDINE, ANTI_TOXIN, INAPROVALINE, SPACEACILLIN)

/obj/item/weapon/reagent_containers/borghypo/New(loc)
	..(loc)
	qdel(reagents)
	reagents = null

	for(var/reagent in reagent_ids)
		var/datum/reagents/reagents = new(volume)
		reagents.my_atom = src
		reagents.add_reagent(reagent, volume)
		reagent_list += reagents

	processing_objects += src

/obj/item/weapon/reagent_containers/borghypo/Destroy()
	for(var/datum/reagents/reagents in reagent_list)
		qdel(reagents)

	reagent_list = null

	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	if(++charge_tick < recharge_time)
		return 0

	charge_tick = 0

	if(isrobot(loc))
		var/mob/living/silicon/robot/robot = loc

		if(robot && robot.cell)
			var/datum/reagents/reagents = reagent_list[mode]

			if(reagents.total_volume < reagents.maximum_volume) // don't recharge reagents and drain power if the storage is full
				robot.cell.use(charge_cost) // take power from borg
				reagents.add_reagent(reagent_ids[mode], 5) // and fill hypo with reagent.

	return 1


/obj/item/weapon/reagent_containers/borghypo/attack(mob/M as mob, mob/user as mob)
	var/datum/reagents/reagents = reagent_list[mode]

	if(!reagents.total_volume)
		to_chat(user, "<span class='notice'>The injector is empty.</span>")
		return

	if(!ismob(M))
		return

	if(issilicon(M))
		return

	user.do_attack_animation(M, src)
	user.visible_message(\
		"<span class='warning'>[user] injects [M] with [src].</span>",\
		"<span class='info'>You inject [M] with with [src].<span>")
	to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
	reagents.reaction(M, INGEST)

	if(M.reagents)
		var/transferred = reagents.trans_to(M, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>[transferred] units injected. [reagents.total_volume] units remaining.</span>")
		add_logs(user, M, "injected [transferred]u [reagent_ids[mode]] with \the [src]", admin = (user.ckey && M.ckey)) //We don't care about monkeymen, right?

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user as mob)
	playsound(src, 'sound/effects/pop.ogg', 50, 0) // change the mode

	if(++mode > reagent_list.len)
		mode = 1

	charge_tick = 0 // prevents wasted chems/cell charge if you're cycling through modes.

	to_chat(user, "<span class='notice'>Synthesizer is now producing '[reagent_ids[mode]]'.</span>")

/obj/item/weapon/reagent_containers/borghypo/examine(mob/user)
	..()
	var/contents_count = 0
	for(var/datum/reagents/reagents in reagent_list)
		to_chat(user, "<span class='info'>It currently has [reagents.total_volume] units of [reagent_ids[++contents_count]] stored.</span>")
	to_chat(user, "<span class='info'>It's currently producing '[reagent_ids[mode]]'.</span>")

/obj/item/weapon/reagent_containers/borghypo/upgraded
	name = "upgraded cyborg hypospray"
	desc = "An upgraded hypospray with more potent chemicals and a larger storage capacity."
	reagent_ids = list(DOCTORSDELIGHT, DEXALINP, SPACEACILLIN, CHARCOAL)
	volume = 50
	recharge_time = 3 // time it takes for shots to recharge (in seconds)

/obj/item/weapon/reagent_containers/borghypo/peace
	name = "peace hypospray"
	desc = "A tranquilizer synthesizer and injection system. These drugs are capable of inducing a state of relaxation, or euphoria."
	reagent_ids = list(STOXIN,CRYPTOBIOLIN,CHILLWAX)
	volume = 5
	recharge_time = 20

/obj/item/weapon/reagent_containers/borghypo/peace/hacked
	desc = "Everything's peaceful in death!"
	icon_state = "borghypo_s"
	reagent_ids = list(CYANIDE)
	volume = 10
	recharge_time = 10

/obj/item/weapon/reagent_containers/borghypo/biofoam
	name = "biofoam hypospray"
	icon_state = "biofoam1"
	reagent_ids = list(BIOFOAM)
	volume = 15
	recharge_time = 30

/obj/item/weapon/reagent_containers/borghypo/biofoam/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "biofoam1"
	else
		icon_state = "biofoam0"

/obj/item/weapon/reagent_containers/borghypo/crisis
	name = "crisis hypospray"
	desc = "A syndicate-exclusive emergency hypospray filled with potent stimulants and painkillers."
	icon_state = "borghypo_s"
	reagent_ids = list(TRICORDRAZINE, INAPROVALINE, COCAINE, OXYCODONE, TRAMADOL)
	volume = 10
	amount_per_transfer_from_this = 10