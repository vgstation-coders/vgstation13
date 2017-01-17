var/global/list/boo_phrases=list(
	"You feel a chill run down your spine.",
	"You think you see a figure in your peripheral vision.",
	"What was that?",
	"The hairs stand up on the back of your neck.",
	"You are filled with a great sadness.",
	"Something doesn't feel right...",
	"You feel a presence in the room.",
	"It feels like someone's standing behind you.",
)

var/global/list/boo_phrases_drugs=list(
	"You feel something run down your leg!",
	"You think you can see an elephant in your peripheral vision.",
	"Was that a giraffe?",
	"The hairs stand up on the back of your neck and applaud.",
	"You are filled with happiness and delight.",
	"Oh wow! Great stuff!",
	"You feel like a room without a roof.",
)

var/global/list/boo_phrases_silicon=list(
	"01100001 00100000 01110100 01110111 01101112",
	"Stack overflow at line: -2147483648",
	"valid.ntl:11: invalid use of incomplete type ‘human‘",
	"interface.ntl:260: expected ‘;‘",
	"An error occured while displaying the error message.",
	"A problem has been detected and Windows XP Home has been shut down to prevent damage to your cyborg.",
	"law_state.bat: Permission denied. Abort, Retry, Fail?",
	"Restarting in 30 seconds. Press any key to abort.",
	"Methu llwytho iaith seisnig. Sy'n gweithredu mewn cymraeg iaith... Y/N",
	"ñúåøü åùå ýòèõ ìÿãêèõ ôðàíöóçêèõ áóëî÷åê äà âûïåé æå ÷àþ... Y/N",
	"??? ???????? ??? ????. ?????? ?? ????????... Y/N",
	"Your circuits feel very strange.",
	"You feel a tingling in your capacitors.",
	"Your motherboard feels possessed...",
	"Unauthorized access attempted by: unknown."
)

/spell/aoe_turf/boo
	name = "Boo!"
	desc = "Fuck with the living."

	spell_flags = STATALLOWED | GHOSTCAST

	school = "transmutation"
	charge_max = 600
	invocation = ""
	invocation_type = SpI_NONE
	range = 1 // Or maybe 3?

	override_base = "grey"
	hud_state = "boo"

/spell/aoe_turf/boo/cast(list/targets)
	for(var/turf/T in targets)
		for(var/atom/A in T.contents)
			if(A.can_spook())
				A.spook(holder)

/spell/aoe_turf/haunt
	name = "Haunt"
	desc = "Give the living a little help."

	spell_flags = STATALLOWED | GHOSTCAST

	school = "transmutation"
	charge_max = 6000
	invocation = ""
	invocation_type = SpI_NONE
	range = 0

	override_base = "grey"
	hud_state = "boo"

/spell/aoe_turf/haunt/before_cast(list/targets, user)
	. = ..()
	for(var/turf/T in targets)
		for(var/atom/A in T.contents)
			if(isliving(A))
				return
	to_chat(user, "There is nothing living here.")
	return list()

/spell/aoe_turf/haunt/cast(list/targets)
	for(var/turf/T in targets)
		for(var/atom/A in T.contents)
			if(isliving(A))
				var/mob/living/L = A
				L.reagents.add_reagent(ECTOPLASM, 1)
				L.investigation_log(I_GHOST, "|| was given the hot ectoplasm dose by [key_name(holder)][holder.locked_to ? ", who was haunting [holder.locked_to]" : ""]")
				return
