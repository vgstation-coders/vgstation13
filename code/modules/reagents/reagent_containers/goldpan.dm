// gold pans. not nescicarily made of gold.
// used to sift useful materials from sand.

#define WATER_USED_PER_SAND 2

var/global/goldpan_drop_weights = alist(
	/obj/item/stack/ore/iron = 10,
	/obj/item/stack/ore/silver = 5,
	/obj/item/stack/ore/gold = 4,
	/obj/item/stack/ore/uranium = 4,
	)

/obj/item/weapon/reagent_containers/glass/goldpan
	name = "gold pan"
	desc = "separates valuable minerals from fine rock using water."
	w_class = W_CLASS_SMALL
	volume = 20
	icon = 'icons/obj/chemical.dmi'
	icon_state = "goldpan"
	item_state = "goldpan"
	health=null
	breakable_flags=0
	var/pantime=4.0 SECONDS
	var/panning=FALSE
	var/heldsand=0
	var/maxsand=10

/obj/item/weapon/reagent_containers/glass/goldpan/New()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/goldpan/is_open_container()
	return TRUE

/obj/item/weapon/reagent_containers/glass/goldpan/fits_in_iv_drip()
	return FALSE
	
/obj/item/weapon/reagent_containers/glass/goldpan/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/S=I
		var/tadd=min(maxsand-heldsand,S.amount)
		S.use(tadd)
		heldsand+=tadd
		if(tadd)
			to_chat(user,"<span class='notice'>You add [tadd] clumps of [S] to \the [src].</span>")
		else
			to_chat(user,"<span class='notice'>\The [src] cannot fit any more [S]!</span>")
		return TRUE
	return ..()

/obj/item/weapon/reagent_containers/glass/goldpan/examine(var/mob/user)
	.=..()
	if(heldsand>0.5*maxsand)
		to_chat(user,"<span class='notice'>It's mostly filled with sand.</span>")
	else if(heldsand)
		to_chat(user,"<span class='notice'>There is some sand in it.</span>")
	else
		to_chat(user,"<span class='notice'>There is no sand in it.</span>")

/obj/item/weapon/reagent_containers/glass/goldpan/attack_self(var/mob/living/user)
	if(!panning)
		if(!heldsand)
			to_chat(user,"<span class='notice'>There's no sand to pan with!</span>")
			return FALSE
		if(reagents.total_volume<WATER_USED_PER_SAND)
			to_chat(user,"<span class='notice'>There's no water to pan with!</span>")
			return FALSE
		panning=TRUE
		to_chat(user,"<span class='notice'>You sift \the [src] around.</span>")
		var/foundstuff=FALSE
		if(do_after(user,src,pantime))
			while(heldsand && reagents.total_volume>=WATER_USED_PER_SAND)
				if(0.87055<user.lucky_prob_rand()) //12.9% chance at base, made it so there's a roughly 50% chance of 5 sand dropping a single ore.
					var/path=pickweight(goldpan_drop_weights)
					var/atom/A=new path(src.loc.loc,1)
					to_chat(user,"<span class='notice'>\A [A] falls out of suspension...</span>")
					foundstuff=TRUE
				heldsand--
				reagents.remove_any(WATER_USED_PER_SAND)
		if(!foundstuff)
			to_chat(user,"<span class='notice'>The sand leaves nothing behind...</span>")
		panning=FALSE
		return TRUE


/obj/item/weapon/reagent_containers/glass/goldpan/wood
	name = "wooden gold pan"
	icon_state = "goldpan_w"
	w_type=RECYK_WOOD
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD*3)

/obj/item/weapon/reagent_containers/glass/goldpan/metal
	name = "metal gold pan"
	icon_state = "goldpan_m"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL*3)
	w_type=RECYK_METAL

/obj/item/weapon/reagent_containers/glass/goldpan/plastic
	name = "plastic gold pan"
	w_type=RECYK_PLASTIC
	starting_materials = list(MAT_PLASTIC = CC_PER_SHEET_PLASTIC*3)

/obj/item/weapon/reagent_containers/glass/goldpan/gold
	name = "golden gold pan"
	desc = "For when you don't have enough gold already."
	icon_state = "goldpan_g"
	w_type=RECYK_METAL
	starting_materials = list(MAT_GOLD = CC_PER_SHEET_GOLD*3)

#undef WATER_USED_PER_SAND