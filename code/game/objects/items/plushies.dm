/*
 * Plushies are toys that can be hugged to synthesize some paracetamol, providing an alternative to hugging humans for incels.
 * They can also have the stuffing removed and replaced with a grenade to create an explosive surprise for the next person to hug the plushie.
 * They might also make a sound when interacted with.
 */

/obj/item/toy/plushie
	icon = 'icons/obj/plushie.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/plushie.dmi', "right_hand" = 'icons/mob/in-hand/right/plushie.dmi')
	var/stuffed = TRUE //stuffing has to be removed before a grenade can be inserted
	var/obj/item/weapon/grenade/grenade //the grenade, if the plush contains one
	attack_verb = list("whomps", "bumps", "baps")
	var/list/interact_sounds = list()//plays when the plushie is interacted with (attack_self etc.)
	var/list/hug_sounds = list('sound/weapons/thudswoosh.ogg') //plays when the plushie hugs someone
	var/death_sound //sound to play when the plushie is destroyed, e.g. in an explosion
	autoignition_temperature = AUTOIGNITION_FABRIC
	var/list/hug_reagents //= list(PARACETAMOL)

/obj/item/toy/plushie/Destroy()
	if(grenade)
		qdel(grenade)
	return ..()

/obj/item/toy/plushie/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>\The [user] is smothering \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/toy/plushie/kick_act(mob/living/carbon/human/H, var/no_default_sound = FALSE)
	if(!no_default_sound && interact_sounds.len)
		playsound(loc, pick(interact_sounds), 30, 1, -1)
	. = ..()

/obj/item/toy/plushie/examine(mob/user)
	..()
	if(!stuffed && !grenade)
		to_chat(user, "It looks like its stuffing has been removed.")

/obj/item/toy/plushie/ex_act(severity)
	switch(severity)
		if(2.0)
			if(prob(25))
				return
		if(3.0)
			if(prob(50))
				return
	playsound(src, death_sound, 50, 0)
	qdel(src)
	return

/obj/item/toy/plushie/attack_self(mob/living/user)
	. = ..()
	if(stuffed || grenade)
		if(interact_sounds.len)
			var/interact_sound = pick(interact_sounds)
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
	if(hug_sounds.len)
		var/hug_sound = pick(hug_sounds)
		playsound(src, hug_sound, 50, 1, -1)
	if(stuffed || grenade)
		src.visible_message("<span class='notice'>\The [src] gives \the [M] a [pick("hug", "warm embrace")].</span>")
		if(hug_reagents.len && M.reagents)
			for(var/R in hug_reagents)
				if(!M.has_reagent_in_blood(R))
					M.reagents.add_reagent(R, 1)
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


/obj/item/toy/plushie/bumbler
	name = "plush bumblebee"
	desc = "A stuffed toy in the shape of a big, adorable bumblebee."
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
	interact_sounds = list("sound/voice/catmeow.ogg")

/obj/item/toy/plushie/chicken
	name = "plush chicken"
	desc = "A very soft and plushy chicken. Cluck!"
	icon_state = "chicken"
	interact_sounds = list("sound/voice/chicken.ogg")

/obj/item/toy/plushie/corgi
	name = "plush corgi"
	desc = "Perfect for the pet owner on a tight budget!"
	icon_state = "corgi"
	interact_sounds = list("sound/voice/corgibark.ogg")

/obj/item/toy/plushie/fancypenguin
	name = "plush penguin"
	desc = "A stuffed toy that quite realistically depicts the long-extinct gentoo penguin."
	icon_state = "fancypenguin"

/obj/item/toy/plushie/goat
	name = "plush goat"
	desc = "This little goat gives only the softest headbutts. Eheheheheh!"
	icon_state = "goat"
	interact_sounds = list("sound/voice/goat.ogg")

/obj/item/toy/plushie/kitten
	name = "plush kitten"
	desc = "An adorable ragdoll kitten."
	icon_state = "kitten"

/obj/item/toy/plushie/kitten/wizard
	name = "plush kitten"
	desc = "An adorable ragdoll kitten. This one must be a wizard's familiar."
	icon_state = "kitten_wizard"

/obj/item/toy/plushie/ladybug
	name = "plush ladybug"
	desc = "A stuffed toy in the shape of a big, adorable ladybug."
	icon_state = "ladybug"

/obj/item/toy/plushie/monkey
	name = "plush monkey"
	desc = "Much cuter and less smelly than a real monkey."
	icon_state = "monkey"

/obj/item/toy/plushie/narsie
	name = "plush Nar-Sie"
	desc = "A large plushie of the Geometer of Blood himself. More likely to cause nightmares than dispel them."
	icon_state = "narsie"

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

/obj/item/toy/plushie/ratvar
	name = "plush Ratvar"
	desc = "A large plushie of the Clockwork Justiciar himself. Though it contains no mechanism, you can hear a faint ticking sound from within."
	icon_state = "ratvar"

/obj/item/toy/plushie/roach
	name = "plush roach"
	desc = "It is friend-shaped."
	icon_state = "roach"

/obj/item/toy/plushie/spacebear
	name = "plush space bear"
	desc = "A stuffed toy in the shape of a space bear. Much friendlier than the real thing."
	icon_state = "spacebear"

/obj/item/toy/plushie/teddy
	name = "teddy bear"
	desc = "An extra-large version of the classic stuffed bear."
	icon_state = "teddy"

//This one is only available with a pomfcoin
/obj/item/toy/plushie/chicken/pomf
	name = "plush Pomf the Chicken"
	desc = "An extremely soft and plushy chicken. Cluck!"
	icon_state = "chicken_pomf"
	hug_reagents = list(DOCTORSDELIGHT)

/obj/item/toy/plushie/sylveon
	name = "plush Sylveon"
	desc = "This special edition Sylveon plushie was never officially released to the public."
	icon_state = "sylveon"

/*
 * Fumos
 */

/obj/item/toy/plushie/fumo/atmostech
	name = "\improper fumo atmospheric technician"
	desc = "A stuffed doll depicting the person who fixes and causes plasmafloods."
	icon_state = "atmosfumo"

/obj/item/toy/plushie/fumo/assistant
	name = "\improper fumo assistant"
	desc = "This greyshirt doll is complete with insulated gloves, gas mask and toolbelt."
	icon_state = "assistantfumo"

/obj/item/toy/plushie/fumo/borg
	name = "\improper fumo cyborg"
	desc = "A stuffed doll depicting a station cyborg."
	icon_state = "borgfumo"

/obj/item/toy/plushie/fumo/chef
	name = "\improper fumo chef"
	desc = "A stuffed doll depicting a chef. It has a deadpan expression on its face."
	icon_state = "cheffumo"

/obj/item/toy/plushie/fumo/clown
	name = "\improper fumo clown"
	desc = "Made of real clown fabric, this plushie contains an authentic honk. It has a deadpan expression on its face."
	icon_state = "clownfumo"
	interact_sounds = list("sound/effects/clownstep1.ogg", "sound/effects/clownstep2.ogg")
	hug_sounds = list("sound/items/bikehorn.ogg")

/obj/item/toy/plushie/fumo/clown/clownette
	name = "\improper fumo clownette"
	desc = "A female clown doll that will not accept your appeals. It has a smug expression on its face."
	icon_state = "clownette"

/obj/item/toy/plushie/fumo/clown/kick_act(mob/living/carbon/human/H)
	playsound(loc, "sound/items/bikehorn.ogg", 30, 1, -1)
	. = ..()

/obj/item/toy/plushie/fumo/captain
	name = "\improper fumo captain"
	desc = "A fumo-style doll depicting the captain. It has a deadpan expression on its face."
	icon_state = "capfumo"

/obj/item/toy/plushie/fumo/engi
	name = "\improper fumo engineer"
	desc = "A stuffed doll depicting the person who contains and looses the singularity."
	icon_state = "engifumo"

/obj/item/toy/plushie/fumo/librarian
	name = "\improper fumo librarian"
	desc = "A stuffed doll depicting a nerdy librarian. It has a deadpan expression on its face."
	icon_state = "libfumo"

/obj/item/toy/plushie/fumo/mime
	name = "\improper fumo mime"
	desc = "..."
	icon_state = "mimefumo"

/obj/item/toy/plushie/fumo/miner
	name = "\improper fumo miner"
	desc = "The station's richest crew member depicted as a doll."
	icon_state = "minerfumo"

/obj/item/toy/plushie/fumo/nukeop
	name = "\improper fumo nuclear operative"
	desc = "A menacing doll in a blood-red hardsuit that should be kept away from the nuclear authentication disk. The label says it's manufactured by the Donk Corporation."
	icon_state = "nukefumo"

/obj/item/toy/plushie/fumo/nurse
	name = "\improper fumo nurse"
	desc = "A stuffed doll depicting a nurse. It has a smug expression on its face."
	icon_state = "nursefumo"

/obj/item/toy/plushie/fumo/plasmaman
	name = "\improper fumo plasmaman"
	desc = "A stuffed doll depicting a plasmaman. The face is thankfully not visible."
	icon_state = "plasmafumo"

/obj/item/toy/plushie/fumo/scientist
	name = "\improper fumo scientist"
	desc = "A doll depicting a slime person scientist. It has a deadpan expression on its face."
	icon_state = "scifumo"

/obj/item/toy/plushie/fumo/secofficer
	name = "\improper fumo security officer"
	desc = "A female security officer depicted as a stuffed doll. It has a grumpy expression on its face."
	icon_state = "secfumo"

/obj/item/toy/plushie/fumo/vox
	name = "\improper fumo vox"
	desc = "A fumo-style doll depicting a vox trader in their trademark space suit. The label has several spelling mistakes on it."
	icon_state = "voxfumo"

/obj/item/toy/plushie/fumo/wizard
	name = "\improper fumo wizard"
	desc = "A stuffed doll depicting a space wizard. It has a smug expression on its face."
	icon_state = "wizfumo"

//Touhous
/obj/item/toy/plushie/fumo/touhou
	death_sound = 'sound/effects/pichuun.ogg'

/obj/item/toy/plushie/fumo/touhou/alice
	name = "\improper fumo Alice"
	desc = "The doll magician depicted as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "alice"

/obj/item/toy/plushie/fumo/touhou/cirno
	name = "\improper fumo Cirno"
	desc = "The strongest fumo-brand doll. It has a smug expression on its face."
	icon_state = "cirno"

/obj/item/toy/plushie/fumo/touhou/marisa
	name = "\improper fumo Marisa"
	desc = "An ordinary magician doll that you shouldn't trust with your valuables. It has a smug expression on its face."
	icon_state = "marisa"

/obj/item/toy/plushie/fumo/touhou/mokou
	name = "\improper fumo Mokou"
	desc = "The immortal immortalized as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "mokou"

/obj/item/toy/plushie/fumo/touhou/nitori
	name = "\improper fumo Nitori"
	desc = "A stuffed doll depicting an aquatic engineer. It has a smug expression on its face."
	icon_state = "nitori"

/obj/item/toy/plushie/fumo/touhou/patchouli
	name = "\improper fumo Patchouli"
	desc = "The librarian witch depicted as a stuffed doll. It has a grumpy expression on its face."
	icon_state = "patchouli"

/obj/item/toy/plushie/fumo/touhou/reimu
	name = "\improper fumo Reimu"
	desc = "The shrine maiden of paradise. It has a deadpan expression on its face."
	icon_state = "reimu"

/obj/item/toy/plushie/fumo/touhou/remilia
	name = "\improper fumo Remilia"
	desc = "The Scarlet Devil depicted as a stuffed doll. It has a smug expression on its face."
	icon_state = "remilia"

/obj/item/toy/plushie/fumo/touhou/sakuya
	name = "\improper fumo Sakuya"
	desc = "A perfect and elegant maid doll. It has a grumpy expression on its face."
	icon_state = "sakuya"

/obj/item/toy/plushie/fumo/touhou/yukari
	name = "\improper fumo Yukari"
	desc = "An elusive and enigmatic stuffed doll. It has a smug expression on its face."
	icon_state = "yukari"
