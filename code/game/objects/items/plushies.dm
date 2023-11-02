/*
 * Plushies are toys that can be hugged to synthesize some paracetamol, providing an alternative to hugging humans for incels.
 * They can also have the stuffing removed and replaced with a grenade to create an explosive surprise for the next person to hug the plushie.
 * They might also make a sound when interacted with.
 */

/obj/item/toy/plushie
	icon = 'icons/obj/plushie.dmi'
	var/stuffed = TRUE //stuffing has to be removed before a grenade can be inserted
	var/obj/item/weapon/grenade/grenade //the grenade, if the plush contains one
	var/interact_sound = ''
	var/hug_sound = 'sound/weapons/thudswoosh.ogg'


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
	desc = "A stuffed toy that quite realistically depicts the long-extinct king penguin."
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
	icon_state = ratvar

/obj/item/toy/plushie/nukie
	name = "plush operative"
	desc = "A stuffed toy that resembles a syndicate nuclear operative, manufactured by the Donk Corporation."
	icon_state = nukie

/obj/item/toy/plushie/orca
	name = "plush orca"
	desc = "A large stuffed toy in the shape of the long-extinct killer whale."
	icon_state = orca

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
	name = "Alice fumo"
	desc = "The doll magician depicted as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "alice"

/obj/item/toy/plushie/fumo/cirno
	name = "Cirno fumo"
	desc = "The strongest fumo-brand doll. It has a smug expression on its face."
	icon_state = "cirno"

/obj/item/toy/plushie/fumo/marisa
	name = "Marisa fumo"
	desc = "An ordinary magician doll that you shouldn't trust with your valuables. It has a smug expression on its face."
	icon_state = "marisa"

/obj/item/toy/plushie/fumo/mokou
	name = "Mokou fumo"
	desc = "The immortal immortalized as a stuffed doll. It has a deadpan expression on its face."
	icon_state = "mokou"

/obj/item/toy/plushie/fumo/patchouli
	name = "Patchouli fumo"
	desc = "The librarian witch depicted as a stuffed doll. It has a grumpy expression on its face."
	icon_state = "patchouli"

/obj/item/toy/plushie/fumo/reimu
	name = "Reimu fumo"
	desc = "The shrine maiden of paradise. It has a deadpan expression on its face."
	icon_state = "reimu"

/obj/item/toy/plushie/fumo/remilia
	name = "Remilia fumo"
	desc = "The Scarlet Devil depicted as a stuffed doll. It has a smug expression on its face."
	icon_state = "remilia"

/obj/item/toy/plushie/fumo/sakuya
	name = "Sakuya fumo"
	desc = "A perfect and elegant maid doll. It has a grumpy expression on its face."
	icon_state = "sakuya"

/obj/item/toy/plushie/fumo/yukari
	name = "Yukari fumo"
	desc = "An elusive and enigmatic stuffed doll. It has a smug expression on its face."
	icon_state = "yukari"
