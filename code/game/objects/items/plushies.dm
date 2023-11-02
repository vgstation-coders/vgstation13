/*
 * Plushies are toys that can be hugged to synthesize some paracetamol, providing an alternative to hugging humans for incels.
 * They can also have the stuffing removed and replaced with a grenade to create an explosive surprise for the next person to hug the plushie.
 * They might also make a sound when interacted with.
 */

/obj/item/toy/plushie
	icon = 'icons/obj/plushie.dmi'
	var/stuffed = TRUE //stuffing has to be removed before a grenade can be inserted
	var/obj/item/weapon/grenade/grenade //the grenade, if the plush contains one
	attack_verb = list("whomps", "bumps", "baps")
	var/interact_sound
	var/hug_sound = 'sound/weapons/thudswoosh.ogg'
	autoignition_temperature = AUTOIGNITION_FABRIC

/obj/item/toy/plushie/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>\The [user] is smothering \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/toy/plushie/examine(mob/user)
	..()
	if(!stuffed && !grenade)
		to_chat(user, "It looks like its stuffing has been removed.")

/obj/item/toy/plushie/attack_self(mob/living/user)
	. = ..()
	if(stuffed || grenade)
		if(interact_sound)
			playsound(src, interact_sound, 50, 1, -1)
		user.visible_message("<span class='notice'>\The [user] plays with \the [src].</span>", "<span class='notice'>You play with \the [src].</span>")
		if(grenade && !grenade.active)
			log_game("[user] activated a hidden grenade ([grenade]) inside [src].")
			grenade.activate(user)
	else
		to_chat(user, "<span class='notice'>Without its stuffing, \the [src] is all limp and boring to play with.</span>")

/obj/item/toy/plushie/attack(mob/living/M as mob, mob/living/user as mob)
	if(user.a_intent != I_HELP)
		return ..()
	if(hug_sound)
		playsound(src, hug_sound, 50, 1, -1)
	if(stuffed || grenade)
		src.visible_message("<span class='notice'>\The [src] gives \the [M] a [pick("hug", "warm embrace")].</span>")
		if(M.reagents)
			if(M == user)
				if(!M.has_reagent_in_blood(PARACETAMOL))
					M.reagents.add_reagent(PARACETAMOL, 1)
			else
				M.reagents.add_reagent(PARACETAMOL, 1)
	else
		src.visible_message("<span class='notice'>\The [src] gives \the [M] a limp hug.</span>")
	if(grenade && !grenade.active)
		log_game("[user] activated a hidden grenade ([grenade]) inside [src] by making it hug [M].")
		grenade.activate(user)

/obj/item/toy/plushie/attackby(var/obj/O, mob/living/user)
	if(O.sharpness_flags & SHARP_BLADE)
		if(!grenade)
			if(!stuffed)
				to_chat(user, "<span class='warning'>\The [src] has already had its stuffing removed.</span>")
				return
			user.visible_message("<span class='notice'>\The [user] tears out the stuffing from \the [src]!</span>", "<span class='notice'>You rip the stuffing out of \the [src].</span>")
			stuffed = FALSE
			//rags work well enough as stuffing
			new /obj/item/weapon/reagent_containers/glass/rag(get_turf(src))
			add_fingerprint(user)
		else
			to_chat(user, "<span class='notice'>You remove \the [grenade] from \the [src].</span>")
			user.put_in_hands(grenade)
			add_fingerprint(user)
			grenade.add_fingerprint(user)
		return 1
	if(istype(O, /obj/item/weapon/grenade))
		if(stuffed)
			to_chat(user, "<span class='warning'>You need to remove the stuffing first!</span>")
			return
		if(grenade)
			to_chat(user, "<span class='warning'>\The [src] already contains a grenade!</span>")
			return
		if(user.drop_item(O, src))
			user.visible_message("<span class='notice'>\The [user] inserts \the [O] into \the [src].</span>", "<span class='notice'>You insert \the [O] into \the [src].</span>")
			grenade = O
			add_fingerprint(user)
			grenade.add_fingerprint(user)
			log_game("[user] inserted a grenade ([O]) into [src].")
			return 1
	if(istype(O, /obj/item/weapon/reagent_containers/glass/rag))
		if(stuffed)
			to_chat(user, "<span class='notice'>\The [src] is already adequately stuffed.</span>")
			return
		if(user.drop_item(O, src))
			user.visible_message("<span class='notice'>\The [user] stuffs \the [O] into \the [src].</span>", "<span class='notice'>You stuff \the [O] into \the [src].</span>")
			qdel(O)
			stuffed = TRUE
			return 1
	return ..()


/obj/item/toy/plushie/bee
	name = "plush bee"
	desc = "A stuffed toy that resembles a bee."
	icon_state = "bee"

/obj/item/toy/plushie/bumbler
	name = "plush bumblebee"
	desc = "A stuffed toy in the shape of a huge, adorable bumblebee."
	icon_state = "bumbler"

/obj/item/toy/plushie/bunny
	name = "plush bunny"
	desc = "A stuffed toy in the shape of a rabbit."
	icon_state = "bunny"

/obj/item/toy/plushie/carp
	name = "plush carp"
	desc = "Can not be used as a distraction during a space carp attack."
	icon_state = "carp"

/obj/item/toy/plushie/cat
	name = "plush cat"
	desc = "Marginally less affectionate than an actual cat."
	icon_state = "cat"

/obj/item/toy/plushie/corgi
	name = "plush corgi"
	desc = "Perfect for the pet owner on a tight budget!"
	icon_state = "corgi"

/obj/item/toy/plushie/fancypenguin
	name = "plush penguin"
	desc = "A stuffed toy that quite realistically depicts the long-extinct gentoo penguin."
	icon_state = "fancypenguin"

/obj/item/toy/plushie/goat
	name = "plush goat"
	desc = "This little goat gives only the softest headbutts. Eheheheheh!"
	icon_state = "goat"

/obj/item/toy/plushie/kitten
	name = "plush kitten"
	desc = "An adorable ragdoll kitten."
	icon_state = "kitten"

/obj/item/toy/plushie/kitten/wizard
	name = "plush kitten"
	desc = "An adorable ragdoll kitten. This one must be a wizard's familiar."
	icon_state = "kitten_wizard"

/obj/item/toy/plushie/monkey
	name = "plush monkey"
	desc = "Much cuter and less smelly than a real monkey."
	icon_state = "monkey"

/obj/item/toy/plushie/narsie
	name = "plush Nar-Sie"
	desc = "A large plushie of the Geometer of Blood himself. More likely to cause nightmares than dispel them."
	icon_state = "narsie"

/obj/item/toy/plushie/ratvar
	name = "plush Ratvar"
	desc = "A large plushie of the Clockwork Justiciar himself. Though it contains no mechanism, you can hear a faint ticking sound from within."
	icon_state = "ratvar"

/obj/item/toy/plushie/nukie
	name = "plush operative"
	desc = "A stuffed toy that resembles a syndicate nuclear operative, manufactured by the Donk Corporation."
	icon_state = "nukie"

/obj/item/toy/plushie/orca
	name = "plush orca"
	desc = "A large stuffed toy in the shape of the long-extinct killer whale."
	icon_state = "orca"

/obj/item/toy/plushie/parrot
	name = "plush parrot"
	desc = "All the fun of a real parrot, without the obnoxious talking!"
	icon_state = "parrot"

/obj/item/toy/plushie/penguin
	name = "plush penguin"
	desc = "A stuffed toy that quite realistically depicts the modern space penguin."
	icon_state = "penguin"

/obj/item/toy/plushie/peacekeeper
	name = "plush peacekeeper"
	desc = "A large stuffed toy depicting a peacekeeper cyborg. In case of human harm, hug."
	icon_state = "peacekeeper"

/obj/item/toy/plushie/possum
	name = "plush possum"
	desc = "A stuffed toy depicting the only North American marsupial."
	icon_state = "possum"

/obj/item/toy/plushie/spacebear
	name = "plush space bear"
	desc = "A stuffed toy in the shape of a space bear. Much friendlier than the real thing."
	icon_state = "spacebear"

/obj/item/toy/plushie/teddy
	name = "teddy bear"
	desc = "An extra-large version of the classic stuffed bear."
	icon_state = "teddy"



/obj/item/toy/plushie/fumo/alice
	name = "\improper Alice fumo"
	desc = "The doll magician depicted as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "alice"

/obj/item/toy/plushie/fumo/cirno
	name = "\improper Cirno fumo"
	desc = "The strongest fumo-brand doll. It has a smug expression on its face."
	icon_state = "cirno"

/obj/item/toy/plushie/fumo/marisa
	name = "\improper Marisa fumo"
	desc = "An ordinary magician doll that you shouldn't trust with your valuables. It has a smug expression on its face."
	icon_state = "marisa"

/obj/item/toy/plushie/fumo/mokou
	name = "\improper Mokou fumo"
	desc = "The immortal immortalized as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "mokou"

/obj/item/toy/plushie/fumo/patchouli
	name = "\improper Patchouli fumo"
	desc = "The librarian witch depicted as a stuffed doll. It has a grumpy expression on its face."
	icon_state = "patchouli"

/obj/item/toy/plushie/fumo/reimu
	name = "\improper Reimu fumo"
	desc = "The shrine maiden of paradise. It has a deadpan expression on its face."
	icon_state = "reimu"

/obj/item/toy/plushie/fumo/remilia
	name = "\improper Remilia fumo"
	desc = "The Scarlet Devil depicted as a stuffed doll. It has a smug expression on its face."
	icon_state = "remilia"

/obj/item/toy/plushie/fumo/sakuya
	name = "\improper Sakuya fumo"
	desc = "A perfect and elegant maid doll. It has a grumpy expression on its face."
	icon_state = "sakuya"

/obj/item/toy/plushie/fumo/yukari
	name = "\improper Yukari fumo"
	desc = "An elusive and enigmatic stuffed doll. It has a smug expression on its face."
	icon_state = "yukari"
