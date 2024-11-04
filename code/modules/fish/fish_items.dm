/obj/item/weapon/fishtools/fish_egg_scoop
	name = "fish egg scoop"
	desc = "A small scoop to collect fish eggs with."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "egg_scoop"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/fishtools/fish_net
	name = "fish net"
	desc = "A tiny net to capture fish with. It's a death sentence!"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "net"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/fishtools/fish_net/suicide_act(var/mob/living/user)			//"A tiny net is a death sentence: it's a net and it's tiny!" https://www.youtube.com/watch?v=FCI9Y4VGCVw
	visible_message("<span class='warning'>\The [user] places \the [src] on top of \his head, \his fingers tangled in the netting! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/fishtools/fish_food
	name = "fish food can"
	desc = "A small can of Carp's Choice brand fish flakes. The label shows a smiling Space Carp."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish_food"
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/fishtools/fish_tank_brush
	name = "aquarium brush"
	desc = "A brush for cleaning the inside of aquariums. Contains a built-in odor neutralizer."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "brush"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	attack_verb = list("scrubbed", "brushed", "scraped")

/obj/item/weapon/fishtools/fish_tank_brush/suicide_act(var/mob/living/user)
	visible_message("<span class='warning'>\The [user] is vigorously scrubbing \himself raw with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/fishtools/fishtank_helper
	name = "aquarium automation module"
	desc = "A module that automates cleaning of aquariums."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	w_class = W_CLASS_SMALL

/obj/item/weapon/reagent_containers/food/snacks/feederfish
	name = "feeder fish"
	desc = "A tiny feeder fish. Sure doesn't look very filling..."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "feederfish"
	filling_color = "#FF1C1C"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/feederfish/New()
	..()
	reagents.add_reagent(NUTRIMENT, 1)

/obj/item/weapon/fish
	name = "fish"
	desc = "A generic fish."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish"
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")
	hitsound = 'sound/effects/snap.ogg'
	var/meat_type

/obj/item/weapon/fish/shrimp
	name = "shrimp"
	desc = "Raw shrimp."
	icon = 'icons/obj/seafood.dmi'
	icon_state = "shrimp_raw"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/shrimp

/obj/item/weapon/fish/glofish
	name = "glofish"
	desc = "A small bio-luminescent fish. Not very bright, but at least it's pretty!"
	icon_state = "glofish"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/glofishmeat

/obj/item/weapon/fish/glofish/New()
	..()
	set_light(2,1,"#99FF66")

/obj/item/weapon/fish/electric_eel
	name = "electric eel"
	desc = "An eel capable of producing a mild electric shock. Luckily it's rather weak out of water."
	icon_state = "electric_eel"

/obj/item/weapon/fish/shark
	name = "shark"
	desc = "Warning: Keep away from tornadoes."
	icon_state = "shark"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3

/obj/item/weapon/fish/shark/attackby(var/obj/item/O, var/mob/user)
	if(O.is_wirecutter(user))
		to_chat(user, "You rip out the teeth of \the [src]!")
		new /obj/item/weapon/fish/toothless_shark(get_turf(src))
		new /obj/item/stack/teeth/shark(get_turf(src), 10)
		qdel(src)
		return
	..()

/obj/item/weapon/fish/toothless_shark
	name = "toothless shark"
	desc = "Looks like someone ripped it's teeth out!"
	icon_state = "shark"
	hitsound = 'sound/effects/snap.ogg'

/obj/item/stack/teeth/shark
	name = "shark teeth"
	desc = "A number of teeth, supposedly from a shark."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "teeth"
	force = 2.0
	throwforce = 5.0
	materials = list()

/obj/item/stack/teeth/shark/New()
	src.pixel_x = rand(-5,5)
	src.pixel_y = rand(-5,5)

/obj/item/weapon/fish/catfish
	name = "catfish"
	desc = "Apparently, catfish don't purr like you might have expected them to. Such a confusing name!"
	icon_state = "catfish"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/catfishmeat

/obj/item/weapon/fish/goldfish
	name = "goldfish"
	desc = "A goldfish, just like the one you never won at the county fair."
	icon_state = "goldfish"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/goldfishmeat

/obj/item/weapon/fish/salmon
	name = "salmon"
	desc = "The second-favorite food of Space Bears, right behind crew members."
	icon_state = "salmon"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/salmonmeat

/*/obj/item/weapon/fish/babycarp
	name = "baby space carp"
	desc = "Substantially smaller than the space carp lurking outside the hull, but still unsettling."
	icon_state = "babycarp"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3*/

/*/obj/item/weapon/fish/babycarp/attackby(var/obj/item/O, var/mob/user)
	if(is_sharp(O))
		to_chat(user, "You carefully clean and gut \the [src.name].")
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(get_turf(src)) //just one fillet; this is a baby, afterall.
		qdel(src)
		return
	..()   removed because we already have babycarp */

/obj/item/weapon/fish/clownfish
	name = "clownfish"
	desc = "Even underwater, you cannot escape HONKing."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "clownfish"
	meat_type = /obj/item/weapon/bananapeel/clownfish

/obj/item/weapon/bananapeel/clownfish
	name = "clownfish"
	desc = "Even underwater, you cannot escape HONKing."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "clownfish"
	throwforce = 1
	force = 1
	hitsound = 'sound/items/bikehorn.ogg'
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")

/obj/item/weapon/fish/attackby(var/obj/item/O, var/mob/user)
	if(meat_type && O.sharpness_flags & SHARP_BLADE)
		to_chat(user, "You carefully clean and gut \the [src].")
		new meat_type(get_turf(src))
		qdel(src)
		return TRUE
	..()

/obj/item/weapon/fish/lobster
	name = "lobster"
	desc = "The cousin of the crab, genetically modified to be unable to snap at anyone. Its innate anger and hatred is kept intact."
	icon_state = "lobster"
	icon = 'icons/obj/fish_items.dmi'

/obj/item/weapon/fish/lobster/attackby(var/obj/item/O, var/mob/user) // extracting tail and claw meat from a sea cockroach
	if(O.is_wirecutter(user))
		to_chat(user, "<span class='notice'>You crack open the shell of \the [src] and pull out the claw meat while separating the tail!")
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail(get_turf(src))
		qdel(src)
		return
	if(O.is_sharp(user))
		to_chat(user, "<span class='notice'>You crack open the shell of \the [src] and pull out the claw meat while separating the tail!")
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/raw_lobster_tail/attackby(var/obj/item/O, var/mob/user) // extracting the meat from the tail, just makes normal lobster meat
	if(O.is_wirecutter(user))
		to_chat(user, "<span class='notice'>You crack open the remains of the shell from \the [src] and pull out the meat!")
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		qdel(src)
		return
	if(O.is_sharp(user))
		to_chat(user, "<span class='notice'>You crack open the remains of the shell from \the [src] and pull out the meat!")
		new /obj/item/weapon/reagent_containers/food/snacks/raw_lobster_meat(get_turf(src))
		qdel(src)
		return
	..()


/obj/item/weapon/steamed_lobster_simple_uncracked // a cooked lobster without its shell cracked
	name = "Steamed Lobster"
	desc = "A steamed lobster. You can almost hear its screams. Its shell isn't cracked open yet."
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_simple"

/obj/item/weapon/steamed_lobster_simple_uncracked/attackby(var/obj/item/O, var/mob/user) // cracking the shell of a steamed lobstroso, simple version
	if(O.is_wirecutter(user))
		to_chat(user, "<span class='notice'>You crack open the shell of \the [src]!")
		new /obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_simple(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/weapon/steamed_lobster_deluxe_uncracked // a cooked lobster without its shell cracked, deluxe edition
	name = "Steamed Lobster"
	desc = "A steamed lobster, served with a side of melted butter and a slice of lemon. You can still feel its hatred. Its shell isn't cracked open yet." //if anyones got a better desc im all ears
	icon = 'icons/obj/food.dmi'
	icon_state = "lobster_steamed_deluxe"

/obj/item/weapon/steamed_lobster_deluxe_uncracked/attackby(var/obj/item/O, var/mob/user) // cracking the shell of a steamed lobstroso
	if(O.is_wirecutter(user))
		to_chat(user, "<span class='notice'>You crack open the shell of \the [src]!")
		new /obj/item/weapon/reagent_containers/food/snacks/steamed_lobster_deluxe(get_turf(src))
		qdel(src)
		return
	..()

