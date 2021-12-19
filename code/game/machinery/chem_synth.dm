/obj/machinery/chem_synth
	name = "\improper Chemical Synthesizer"
	desc = "!"
	icon = 'icons/obj/candymachine.dmi'
	icon_state = "sweetmachine"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK | SCREWTOGGLE | CROWDESTROY | EJECTNOTDEL
	use_power = 0
	var/scanEfficient = 0
	var/manipEfficient = 0
	var/obj/item/weapon/reagent_containers/glass/heldBeaker = null
	var/datum/reagents/ =
	var/list/chemsKnown = list()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_synth,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

/obj/machinery/chem_synth/New()
	..()
	RefreshParts()
	create_reagents(1)

/obj/machinery/chem_synth/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(heldBeaker)
			to_chat(user, "<span class='warning'>There already is \a [container] loaded in the machine.</span>")
			return
		if(user.drop_item(I, src))
			heldBeaker = I
	if(istype(I, /obj/item/device/chem_sampler))
		var/obj/item/device/chem_sampler/CS = I
		if(CS.heldChem)
			//delete the chem or whatever
