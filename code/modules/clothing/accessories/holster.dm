/obj/item/clothing/accessory/holster/
	name = "holster"
	icon_state = "holster"
	_color = "holster"
	origin_tech = Tc_COMBAT + "=2"
	var/obj/item/holstered = null
	accessory_exclusion = HOLSTER
	w_type = RECYK_BIOLOGICAL //leather
	flammable = TRUE
	on_armory_manifest = TRUE
	var/holster_verb_name = "Holster"

/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/weapon/gun/W)
	return

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		to_chat(user, "<span class='warning'>There is already \a [holstered] holstered here!</span>")
		return

	if (!can_holster(I))
		to_chat(user, "<span class='warning'>\The [I] won't fit in the [src]!</span>")
		return

	if(user.attack_delayer.blocked())
		return

	if(user.drop_item(I, src, failmsg = TRUE))
		holstered = I
		holstered.add_fingerprint(user)
		user.visible_message("<span class='notice'>[user] holsters \the [holstered].</span>", "<span class='notice'>You holster \the [holstered].</span>")
		update_icon()
		return 1

/obj/item/clothing/accessory/holster/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(user.stat || user.resting)
		to_chat(user, "<span class='warning'>You can't hold \the [holstered] like this!</span>")
		return

	if(user.put_in_active_hand(holstered) || user.put_in_inactive_hand(holstered))
		unholster_message(user)
		holstered.add_fingerprint(user)
		holstered = null
		update_icon()
	else
		to_chat(user, "<span class='warning'>You need an empty hand to draw \the [holstered]!</span>")

/obj/item/clothing/accessory/holster/proc/unholster_message(user)
	return

/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	var/obj/item/clothing/accessory/holster/H = null
	if(istype(src, /obj/item/clothing/accessory/holster))
		H = src
	else if(istype(src, /obj/item/clothing/))
		var/obj/item/clothing/S = src
		if (S.accessories.len)
			H = locate() in S.accessories

	if(!H)
		to_chat(usr, "<span class='warning'>Something is very wrong.</span>")
		return

	if(!H.holstered)
		var/obj/item/W = usr.get_active_hand()
		if(istype(W))
			H.holster(W, usr)
	else
		H.unholster(usr)

/obj/item/clothing/accessory/holster/attack_hand(mob/user as mob)
	if(holstered && src.loc == user)
		return unholster(user)
	..(user)

/obj/item/clothing/accessory/holster/on_accessory_interact(mob/user, delayed)
	if (holstered && !delayed)
		unholster(user)
		return 1
	return ..()

/obj/item/clothing/accessory/holster/attackby(obj/item/W as obj, mob/user as mob)
	return holster(W, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	if (holstered)
		holstered.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	..(user)
	if (holstered)
		to_chat(user, "A [holstered.name] is holstered here.")
	else
		to_chat(user, "It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S)
	..()
	//We're making a new verb, see http://www.byond.com/forum/?post=238593
	if(attached_to)
		attached_to.verbs += new/obj/item/clothing/accessory/holster/verb/holster_verb(attached_to,holster_verb_name)

/obj/item/clothing/accessory/holster/on_removed(mob/user as mob)
	//Yes, we're calling "new" when removing a verb. I blame verbs entirely for this shit. See: http://www.byond.com/forum/?post=80230
	if(attached_to)
		attached_to.verbs -= new/obj/item/clothing/accessory/holster/verb/holster_verb(attached_to,holster_verb_name)
	..()

//
// Handguns
//
/obj/item/clothing/accessory/holster/handgun
	name = "shoulder holster"
	desc = "A handgun holster that clips to a suit. Perfect for concealed carry."
	holster_verb_name = "Holster (Handgun)"

/obj/item/clothing/accessory/holster/handgun/can_holster(obj/item/weapon/W)
	if(!isgun(W) && !isbanana(W) && !istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana))
		return
	return W.isHandgun()

/obj/item/clothing/accessory/holster/handgun/unholster_message(mob/user)
	if(user.a_intent == I_HURT)
		user.visible_message("<span class='warning'>[user] draws \the [holstered], ready to shoot!</span></span>", \
		"<span class='warning'>You draw \the [holstered], ready to shoot!</span>")
	else
		user.visible_message("<span class='notice'>[user] draws \the [holstered], pointing it at the ground.</span>", \
		"<span class='notice'>You draw \the [holstered], pointing it at the ground.</span>")

/obj/item/clothing/accessory/holster/handgun/wornout
	desc = "A worn-out handgun holster. Perfect for concealed carry."

/obj/item/clothing/accessory/holster/handgun/biogenerator
	desc = "A leather handgun holster. It smells faintly of potato."

/obj/item/clothing/accessory/holster/handgun/waist
	name = "waistband holster"
	desc = "A handgun holster that clips to a suit. Made of expensive leather."
	_color = "holster_low"

/obj/item/clothing/accessory/holster/handgun/preloaded
	var/gun_type

/obj/item/clothing/accessory/holster/handgun/preloaded/New()
	..()
	if(!holstered)
		holstered = new gun_type(src)
		update_icon()

/obj/item/clothing/accessory/holster/handgun/preloaded/mateba
	gun_type = /obj/item/weapon/gun/projectile/mateba

/obj/item/clothing/accessory/holster/handgun/preloaded/NTUSP
	gun_type = /obj/item/weapon/gun/projectile/NTUSP

/obj/item/clothing/accessory/holster/handgun/preloaded/NTUSP/fancy
	gun_type = /obj/item/weapon/gun/projectile/NTUSP/fancy

/obj/item/clothing/accessory/holster/handgun/preloaded/glock
	gun_type = /obj/item/weapon/gun/projectile/glock

/obj/item/clothing/accessory/holster/handgun/preloaded/glock/fancy
	gun_type = /obj/item/weapon/gun/projectile/glock/fancy

//
// Knives
//
/obj/item/clothing/accessory/holster/knife
	name = "knife holster"
	desc = "A holster that takes knives. The possibilities are endless."
	holster_verb_name = "Holster (Knife)"

/obj/item/clothing/accessory/holster/knife/can_holster(obj/item/weapon/W)
	if(!istype(W))
		return
	if(istype(W, /obj/item/weapon/kitchen/utensil/knife/large/butch))
		return
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = W
		if(S.active == 0)
			return 1

	return is_type_in_list(W, list(\
		/obj/item/weapon/kitchen/utensil, \
		/obj/item/tool/screwdriver, \
		/obj/item/tool/solder, \
		/obj/item/tool/wirecutters, \
		/obj/item/weapon/pen, \
		/obj/item/tool/scalpel, \
		/obj/item/weapon/minihoe, \
		/obj/item/weapon/hatchet, \
		/obj/item/weapon/pickaxe/shovel/spade, \
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana, \
		/obj/item/weapon/bikehorn, \
		/obj/item/weapon/gun/projectile/banana
		)) //honk

/obj/item/clothing/accessory/holster/knife/unholster_message(mob/user)
	user.visible_message("<span class='warning'>[user] pulls \a [holstered] from its holster!</span>", \
	"<span class='warning'>You draw your [holstered.name]!</span>")

/obj/item/clothing/accessory/holster/knife/boot
	desc = "A knife holster that can be attached to any pair of boots."
	item_state = "bootknife"
	icon_state = "bootknife"
	_color = "bootknife"

/obj/item/clothing/accessory/holster/knife/boot/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/shoes)

/obj/item/clothing/accessory/holster/knife/boot/update_icon()
	if(holstered)
		if(holstered.icon_state in list("skinningknife", "tacknife", "knife", "smallknife", "fork", "pen", "scalpel", "banana", "bike_horn", "sword0"))
			icon_state = "[initial(icon_state)]_[holstered.icon_state]"
			_color = "[initial(_color)]_[holstered.icon_state]"
		else
			icon_state = "[initial(icon_state)]_knife"
			_color = "[initial(_color)]_knife"
	else
		icon_state = "[initial(icon_state)]_empty"
		_color = "[initial(_color)]_empty"
	..()

/obj/item/clothing/accessory/holster/knife/boot/preloaded
	var/knife_type

/obj/item/clothing/accessory/holster/knife/boot/preloaded/New()
	..()
	if(!holstered)
		holstered = new knife_type(src)
		update_icon()

/obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical
	knife_type = /obj/item/weapon/kitchen/utensil/knife/tactical

/obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning
	knife_type = /obj/item/weapon/kitchen/utensil/knife/skinning

/obj/item/clothing/accessory/holster/knife/boot/preloaded/energysword
	knife_type = /obj/item/weapon/melee/energy/sword
