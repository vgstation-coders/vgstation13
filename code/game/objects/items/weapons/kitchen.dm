/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Trays
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = W_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=1"
	attack_verb = list("attacks", "stabs", "pokes")

/obj/item/weapon/kitchen/utensil/New()
	. = ..()

	if (prob(60))
		src.pixel_y = rand(0, 4)

/*
 * Spoons
 */
/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"
	attack_verb = list("attacks", "pokes", "hits")
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/spoon/plastic
	name = "plastic spoon"
	desc = "Super dull action!"
	icon_state = "pspoon"
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Forks
 */
/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	sharpness = 0.6
	var/loaded_food_name
	var/image/loaded_food
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/fork/New()
	..()
	reagents = new(10)
	reagents.my_atom = src

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || !istype(user))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != LIMB_HEAD && M != user && !loaded_food)
		return ..()

	if (src.loaded_food)
		reagents.update_total()
		if(M == user)
			user.visible_message("<span class='notice'>[user] eats a delicious forkful of [loaded_food_name]!</span>")
		else
			user.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of [loaded_food_name]!</span>")
		reagents.reaction(M, INGEST)
		reagents.trans_to(M.reagents, reagents.total_volume)
		overlays -= loaded_food
		del(loaded_food)
		loaded_food_name = null
		return
	else
		if((M_CLUMSY in user.mutations) && prob(50))
			return eyestab(user,user)
		else
			return eyestab(M, user)

/obj/item/weapon/kitchen/utensil/fork/examine(mob/user)
	..()
	if(loaded_food)
		user.show_message("It has a forkful of [loaded_food_name] on it.")

/obj/item/weapon/kitchen/utensil/fork/proc/load_food(obj/item/weapon/reagent_containers/food/snacks/snack, mob/user)
	if(!snack || !user || !istype(snack) || !istype(user))
		return

	if(loaded_food)
		to_chat(user, "<span class='notice'>You already have food on \the [src].</span>")
		return

	if(snack.wrapped)
		to_chat(user, "<span class='notice'>You can't eat packaging!</span>")
		return

	if(snack.reagents.total_volume)
		loaded_food_name = snack.name
		var/icon/food_to_load = getFlatIcon(snack)
		food_to_load.Scale(16,16)
		loaded_food = image(food_to_load)
		loaded_food.pixel_x = 8 + src.pixel_x
		loaded_food.pixel_y = 15 + src.pixel_y
		src.overlays += loaded_food
		if(snack.reagents.total_volume > snack.bitesize)
			snack.reagents.trans_to(src, snack.bitesize)
		else
			snack.reagents.trans_to(src, snack.reagents.total_volume)
			snack.bitecount++
			snack.On_Consume(user)
	return 1

/obj/item/weapon/kitchen/utensil/fork/plastic
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Knives
 */
/obj/item/weapon/kitchen/utensil/knife
	name = "small knife"
	desc = "Can cut through any food."
	icon_state = "smallknife"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 10.0
	throwforce = 10.0
	sharpness = 1.2
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/kitchen/utensil/knife/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with the [src].</span>")
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/kitchen/utensil/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 2
	throwforce = 1
	sharpness = 0.8
	melt_temperature = MELTPOINT_PLASTIC

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchen/utensil/knife/large
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.5
	force = 10.0
	w_class = W_CLASS_MEDIUM
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 12000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1"
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/kitchen/utensil/knife/large/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You slice the handle off of \the [src].")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/metal_blade/I = new (get_turf(user))
				user.put_in_hands(I)
			else
				new /obj/item/weapon/metal_blade(get_turf(src.loc))
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")

/obj/item/weapon/kitchen/utensil/knife/large/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/large/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Butcher's cleaver
 */
/obj/item/weapon/kitchen/utensil/knife/large/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	hitsound = "sound/weapons/rapidslice.ogg"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1.2
	force = 15.0
	w_class = W_CLASS_SMALL
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 12000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1"
	attack_verb = list("cleaves", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
	name = "meat cleaver"
	icon_state = "mcleaver"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	force = 25.0
	throwforce = 15.0

/obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver/throw_impact(atom/hit_atom)
	if(istype(hit_atom, /mob/living) && prob(85))
		var/mob/living/L = hit_atom
		L.Stun(5)
		L.Weaken(5)
	return ..()

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	hitsound = "sound/weapons/smash.ogg"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = W_CLASS_MEDIUM
	autoignition_temperature=AUTOIGNITION_WOOD
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "whacks") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_organ_damage(10)
		user.Paralyse(2)
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	var/t = user:zone_sel.selecting
	if (t == LIMB_HEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				user.visible_message("<span class='danger'><B>[H] has been knocked unconscious!</B>", "<span class='warning'>You knock [H] unconscious!</span></span>")
				return
			else
				H.visible_message("<span class='warning'>[user] tried to knock [H] unconscious!</span>", "<span class='warning'>[user] tried to knock you unconscious!</span>")
				H.eye_blurry += 3
	return ..()

/*
 * Trays - Agouri
 */
/obj/item/weapon/tray
	name = "tray"
	icon = 'icons/obj/food.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 10.0
	force = 5 //look at us, we don't even use this var in our attack because we're so snowflake!
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	siemens_coefficient = 1
	starting_materials = list(MAT_IRON = 3000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	var/list/carrying = list() // List of things on the tray. - Doohl
	var/max_carry = 10 // w_class = W_CLASS_TINY -- takes up 1
					   // w_class = W_CLASS_SMALL -- takes up 3
					   // w_class = W_CLASS_MEDIUM -- takes up 5
	var/cooldown = 0	//shield bash cooldown. based on world.time

/obj/item/weapon/tray/Destroy()
	for(var/atom/thing in carrying)
		qdel(thing)
	carrying = null
	..()

/obj/item/weapon/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	// Drop all the things. All of them.
	send_items_flying()

	if((M_CLUMSY in user.mutations) && prob(50))              //What if he's a clown?
		to_chat(M, "<span class='warning'>You accidentally slam yourself with the [src]!</span>")
		M.Weaken(1)
		user.take_organ_damage(2)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(user.zone_sel.selecting == ("eyes" || LIMB_HEAD))) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(prob(15))
			M.Weaken(3)
			M.take_organ_damage(3)
		else
			M.take_organ_damage(5)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return




	if(istype(M, /mob/living/carbon/human) && H.check_body_part_coverage(EYES))
		to_chat(H, "<span class='warning'>You get slammed in the face with the tray, against your mask!</span>")
		if(prob(33))
			src.add_blood(H)
			if (H.wear_mask)
				H.wear_mask.add_blood(H)
			if (H.head)
				H.head.add_blood(H)
			if (H.glasses && prob(33))
				H.glasses.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))     //Addin' blood! At least on the floor and item :v
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_organ_damage(3)
			return
		else
			M.take_organ_damage(5)
			return

	else //No eye or head protection, tough luck!
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray!</span>")
		if(prob(33))
			src.add_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		if(prob(30))
			M.Stun(rand(2,4))
			M.take_organ_damage(4)
			return
		else
			M.take_organ_damage(8)
			if(prob(30))
				M.Weaken(2)
				return
			return
/*
===============~~~~~================================~~~~~====================
=																			=
=  Code for trays carrying things. By Doohl for Doohl erryday Doohl Doohl~  =
=																			=
===============~~~~~================================~~~~~====================
*/
/obj/item/proc/get_trayweight() //calculates weight for the purpose of trays, 0 if too big
	if(w_class > W_CLASS_MEDIUM)
		return 0
	if(w_class == W_CLASS_TINY)
		return 1
	if(w_class == W_CLASS_SMALL)
		return 3
	if(w_class == W_CLASS_MEDIUM)
		return 5

/obj/item/weapon/tray/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/kitchen/rollingpin)) //shield bash
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
			return
	if(!user.candrop)
		return
	var/weight = W.get_trayweight()
	if(!weight)
		to_chat(user, "<span class='warning'>\The [W] is too heavy!</span>")
		return
	if(weight + calc_carry() > max_carry)
		to_chat(user, "<span class='warning'>The tray is carrying too much!</span>")
		return
	if( W == src || W.anchored || is_type_in_list(W, list(/obj/item/clothing/under, /obj/item/clothing/suit, /obj/item/projectile, /obj/item/weapon/tray, /obj/item/weapon/holder/) ) )
		to_chat(user, "<span class='warning'>This doesn't seem like a good idea.</span>")
		return
	if(user.drop_item(W, user.loc))
		W.loc = src
		carrying.Add(W)
		var/list/params_list = params2list(params)
		if(params_list.len)
			var/icon/clicked = new/icon(icon, icon_state, dir)
			var/clamp_x = clicked.Width() / 2
			var/clamp_y = clicked.Height() / 2
			W.pixel_x = Clamp(text2num(params_list["icon-x"]) - clamp_x, -clamp_x, clamp_x)
			W.pixel_y = Clamp(text2num(params_list["icon-y"]) - clamp_y, -clamp_y, clamp_y)
		var/image/image = image(icon = null)
		image.appearance = W.appearance
		image.layer = W.layer + 30
		image.plane = FLOAT_PLANE

		overlays += image
	else
		..()
/obj/item/weapon/tray/proc/calc_carry() 
	// calculate the weight of the items on the tray
	. = 0 // value to return

	for(var/obj/item/I in carrying)
		. += I.get_trayweight() || INFINITY
/* previous functionality of trays, 
/obj/item/weapon/tray/prepickup(mob/user)
	..()

	if(!isturf(loc))
		return

	for(var/obj/item/I in loc)
		if( I != src && !I.anchored && !is_type_in_list(I, list(/obj/item/clothing/under, /obj/item/clothing/suit, /obj/item/projectile, /obj/item/weapon/tray)) )
			var/add = 0
			if(I.w_class > W_CLASS_TINY)
				add = 1
			else if(I.w_class == W_CLASS_SMALL)
				add = 3
			else if(I.w_class > W_CLASS_MEDIUM)
				add = 5
			else
				continue
			if(calc_carry() + add >= max_carry)
				break

			I.loc = src
			carrying.Add(I)

			var/image/image = image(icon = null) //image(appearance = ...) doesn't work, and neither does image().
			image.appearance = I.appearance
			image.layer = I.layer + 30
			image.plane = FLOAT_PLANE

			overlays += image
			//overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)
*/
/obj/item/weapon/tray/dropped(mob/user)
	spawn() //because throwing drops items before setting their throwing var, and a lot of other zany bullshit
		if(throwing)
			return ..()
		//This is so monumentally bad that I have to leave it in as a comment
		/*var/mob/living/M
		for(M in src.loc) //to handle hand switching
			return*/
		if(isturf(loc))
			for(var/obj/structure/table/T in loc)
				remove_items()
				return ..()
			// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
			whoops()
		..()

/obj/item/weapon/tray/throw_impact(atom/hit_atom)
	if(isturf(hit_atom))
		whoops()
	..()

/obj/item/weapon/tray/proc/remove_items()
	overlays.len = 0
	for(var/obj/item/I in carrying)
		I.forceMove(get_turf(src))
		carrying.Remove(I)

/obj/item/weapon/tray/proc/send_items_flying()
	overlays.len = 0
	for(var/obj/item/I in carrying)
		I.forceMove(get_turf(src))
		carrying.Remove(I)
		spawn(rand(1,3))
			if(I && prob(75))
				step(I, pick(alldirs))

/obj/item/weapon/tray/proc/whoops()
	if(prob(50))
		playsound(src, 'sound/items/trayhit1.ogg', 35, 1)
	else
		playsound(src, 'sound/items/trayhit2.ogg', 35, 1)
	send_items_flying()




/////////////////////////////////////////////////////////////////////////////////////////
//Enough with the violent stuff, here's what happens if you try putting food on it
/////////////////////////////////////////////////////////////////////////////////////////////



/*/obj/item/weapon/tray/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if (W.icon_state == "forkloaded")
			to_chat(user, "<span class='warning'>You already have omelette on your fork.</span>")
			return
		W.icon = 'icons/obj/kitchen.dmi'
		W.icon_state = "forkloaded"
		to_chat(viewers(3,user), "[user] takes a piece of omelette with his fork!")
		reagents.remove_reagent(NUTRIMENT, 1)
		if (reagents.total_volume <= 0)
			del(src)*/


/*			if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_mask)
						H.wear_mask.add_blood(H)
					if (H.head)
						H.head.add_blood(H)
					if (H.glasses && prob(33))
						H.glasses.add_blood(H)
					if (istype(user, /mob/living/carbon/human))
						var/mob/living/carbon/human/user2 = user
						if (user2.gloves)
							user2.gloves.add_blood(H)
						else
							user2.add_blood(H)
						if (prob(15))
							if (user2.wear_suit)
								user2.wear_suit.add_blood(H)
							else if (user2.w_uniform)
								user2.w_uniform.add_blood(H)*/
