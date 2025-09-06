/obj/item/mecha_parts/component/coupler
	name = "mecha module coupler"
	desc = "A standard issue module coupler. Allows fast, relatively hands-free switching of equipment."
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "board"
	w_class = W_CLASS_GIANT
	origin_tech = Tc_POWERSTORAGE + "=1;" + Tc_ENGINEERING + "=1"
	component_type = MECH_COUPLER
	emp_resistance = 2
	integrity_danger_mod = 0.4
	max_integrity = 100
	step_delay = 20
	relative_size = 10
	internal_damage_flag = null
	broken_icon = "board_broken"
	var/quick_attach = TRUE
	var/welded = FALSE

/obj/item/mecha_parts/component/coupler/detach()
	.=..()
	if(welded)
		src.damage_part(1000) // it breaks
		visible_message(src, "<span class='danger'>The melted connector breaks apart when you pry it out!</span>")
	return

/obj/item/mecha_parts/component/coupler/attackby(obj/item/W as obj, mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "<span class='warning'>You start melting the [src]'s locking release..</span>")
		if(WT.do_weld(user, src, 5 SECONDS, 0))
			to_chat(user, "<span class='warning'>You permanently weld shut the locking release.</span>")
			if(!welded)
				welded = TRUE // Somehow, this permanently locks it. Removing the component allows you to detact gear, but not attach it.
			else
				to_chat(user, "<span class='warning'>The electronic locking components have been fused, you can't repair this!</span>")
				return

/obj/item/mecha_parts/component/coupler/durable
	name = "mecha manual module coupler"
	desc = "A hefty mechanical coupler that trades usability  for durability. It lacks a magnetic system, requiring hands-on work."
	emp_resistance = 4
	integrity_danger_mod = 0.2
	max_integrity = 200
	relative_size = 10
	quick_attach = FALSE

/obj/item/mecha_parts/component/coupler/durable/attackby(obj/item/W as obj, mob/user as mob)
	return
