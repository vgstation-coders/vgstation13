//NEVER USE THIS IT SUX	-PETETHEGOAT //Nah it's finally good over a decade later. -Deity Link

var/global/list/cached_icons = list()
var/global/list/paint_types = subtypesof(/datum/reagent/paint)

/obj/item/weapon/reagent_containers/glass/metal_bucket
	name = "metal bucket"
	desc = "Can be used to store and carry reagents."
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "paint_bucket"
	item_state = "paint_bucket"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	melt_temperature = MELTPOINT_STEEL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,25,30,50,100,150)
	volume = 150
	flags = FPRINT | OPENCONTAINER
	//wearable with the same stats as regular buckets
	species_fit = list(INSECT_SHAPED)
	armor = list(melee = 8, bullet = 3, laser = 3, energy = 0, bomb = 1, bio = 1, rad = 0)
	slot_flags = SLOT_HEAD
	controlled_splash = TRUE

	var/icon/spots
	var/last_pigments = ""
	var/name_base = "metal bucket"
	var/icon_lid = "paint_cover"
//-------------------------------------------------------------------------------------------------

/obj/item/weapon/reagent_containers/glass/metal_bucket/paint
	name = "paint bucket"
	desc = "A bucket for storing acrylic paint."
	name_base = "paint bucket"

//-------------------------------------------------------------------------------------------------

/obj/item/weapon/reagent_containers/glass/metal_bucket/New()
	..()
	spots = icon(icon,"paint_spots")

/obj/item/weapon/reagent_containers/glass/metal_bucket/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is taking \his hand and eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/reagent_containers/glass/metal_bucket/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/metal_bucket/splash_special()
	if (prob(50))
		add_spots()

//manipulating the bucket causes it to spill some of its paint on itself, getting dirtier and dirtier
/obj/item/weapon/reagent_containers/glass/metal_bucket/pickup(var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/metal_bucket/dropped(var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/metal_bucket/attackby(var/obj/item/I, var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/metal_bucket/throw_at(atom/target, range, speed)
	..()
	add_spots(2)

/obj/item/weapon/reagent_containers/glass/metal_bucket/equipped(var/mob/M, var/slot)
	..()
	if(slot == slot_head)
		if(reagents.total_volume)
			reagents.splashplosion(0)//splashing ourselves and everything on our tile with
			visible_message("<span class='warning'>The bucket's content spills on \the [M].</span>")

/obj/item/weapon/reagent_containers/glass/metal_bucket/dissolvable()
	var/mob/living/carbon/human/H = get_holder_of_type(src,/mob/living/carbon/human)
	if(H && src == H.head)
		return 0
	return ..()

/obj/item/weapon/reagent_containers/glass/metal_bucket/throw_impact(var/atom/hit_atom, var/speed, var/mob/user)
	if (!(flags & OPENCONTAINER))
		return
	var/pigment_rgb = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (pigment_rgb)
		var/mix_alpha = mix_alpha_from_reagents(reagents.reagent_list)
		var/turf/T = get_turf(hit_atom)
		var/datum/reagent/B = get_blood(reagents)
		var/list/bucket_blood_data = list()
		if (B)
			bucket_blood_data = list(B.data["blood_DNA"] = B.data["blood_type"])
		var/has_nanopaint = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if (R.paint_light == PAINTLIGHT_FULL)
				has_nanopaint = TRUE
		T.apply_paint_stroke(pigment_rgb, mix_alpha, SOUTH, "splatter", bucket_blood_data, has_nanopaint)
		T.paint_overlay.wet(pigment_rgb,20 SECONDS,2)
		reagents.remove_any(5)
		playsound(T, 'sound/effects/slosh.ogg', 25, 1)


/obj/item/weapon/reagent_containers/glass/metal_bucket/container_splash_sub(var/datum/reagents/reagents, var/atom/target, var/amount, var/mob/user = null)
	var/spot_color = mix_color_from_reagents(reagents.reagent_list, TRUE)
	. = ..()
	if (. != -1 && spot_color)
		add_spots(3, spot_color)

/obj/item/weapon/reagent_containers/glass/metal_bucket/update_icon()
	..()

	overlays.len = 0
	overlays += spots

	if (last_pigments)
		var/image/I = image(icon, src, "paint_pigments")
		I.color = last_pigments
		overlays += I
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "paint_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "paint_pigments")
		paintleft.color = last_pigments
		paintright.color = last_pigments
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
		//dynamic hat overlay
		var/image/painthead = image('icons/mob/head.dmi', src, "paint_pigments")
		painthead.color = last_pigments
		dynamic_overlay["[HEAD_LAYER]"] = painthead
	else
		dynamic_overlay = list()

	if (reagents && reagents.total_volume)
		var/image/I = image(icon, src, "paint_inside")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		I.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += I

	if (!(flags & OPENCONTAINER))
		overlays += icon_lid



/obj/item/weapon/reagent_containers/glass/metal_bucket/on_reagent_change()
	var/new_pigments = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (new_pigments)
		if (last_pigments != new_pigments)
			name = "[name_base] ([get_paint_name(new_pigments)])"
			last_pigments = new_pigments
	else
		name = name_base
	update_icon()

/obj/item/weapon/reagent_containers/glass/metal_bucket/clean_act(var/cleanliness)
	..()
	if (cleanliness >= CLEANLINESS_BLEACH)
		spots = icon(icon,"paint_spots")
		last_pigments = ""
		on_reagent_change()

/obj/item/weapon/reagent_containers/glass/metal_bucket/proc/add_spots(var/spots_to_add = 1, var/color_override)
	if (!(flags & OPENCONTAINER))
		return
	if (!spots)
		spots = icon('icons/obj/painting_items.dmi',"paint_spots")
	var/spot_color = color_override
	if (!spot_color)
		spot_color = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (spot_color)
		for (var/i = 1 to spots_to_add)
			var/icon/I = icon('icons/obj/painting_items.dmi', "paint_spots[rand(1,4)]")
			I.Blend(spot_color, ICON_MULTIPLY)
			spots.Blend(I, ICON_OVERLAY)
		update_icon()

/obj/item/weapon/reagent_containers/glass/metal_bucket/proc/get_paint_name(var/_paint_name)
	var/paint_name = copytext(_paint_name,1,8)//removing alpha channel just in case
	var/upper_name = uppertext(paint_name)
	if (upper_name in colors_all)
		return colors_all[upper_name]
	else
		return "[upper_name]"


//-------------------------------------------------------------------------------------------------

//Acrylic Paints
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled
	last_pigments = "#FFFFFF"
	var/paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/New(turf/loc, var/p_color)
	..()
	if (p_color)
		paint_color = p_color
	reagents.add_reagent(ACRYLIC, volume, list("color" = paint_color))

/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/red
	paint_color	= "#D52127"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/yellow
	paint_color	= "#FCED23"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/blue
	paint_color	= "#2357BC"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/orange
	paint_color	= "#F6851E"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/green
	paint_color	= "#07B151"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/violet
	paint_color	= "#733B97"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/vermilion
	paint_color	= "#F36621"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/amber
	paint_color	= "#FBB40F"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/magenta
	paint_color	= "#AF3A94"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/indigo
	paint_color	= "#4C489B"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/turquoise
	paint_color	= "#2FBBB3"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/chartreuse
	paint_color	= "#8CC640"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/black
	paint_color	= "#111111"
/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/white
	paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/metal_bucket/paint/filled/random/New(turf/loc, var/p_color)
	paint_color = pick(colors_all)
	..(loc, paint_color)

//-------------------------------------------------------------------------------------------------

//Nano Paints
/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint
	name = "nano-paint bucket"
	desc = "A bucket for storing paint composed of luminous nanomachines."
	icon_state = "nano_bucket"
	item_state = "nano_bucket"
	name_base = "nano-paint bucket"
	icon_lid = "nano_cover"

/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled
	last_pigments = "#FFFFFF"
	var/paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/New(turf/loc, var/p_color)
	..()
	if (p_color)
		paint_color = p_color
	reagents.add_reagent(NANOPAINT, volume, list("color" = paint_color))

/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/red
	paint_color	= "#FF0000"
/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/green
	paint_color	= "#00FF00"
/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/blue
	paint_color	= "#0000FF"
/obj/item/weapon/reagent_containers/glass/metal_bucket/nanopaint/filled/vantablack
	paint_color	= "#000000"
