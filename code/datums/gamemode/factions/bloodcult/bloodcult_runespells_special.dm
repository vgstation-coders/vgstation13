
// Rune Spells that aren't listed when the player tries to draw a guided rune.




////////////////////////////////////////////////////////////////////
//																  //
//							SUMMON TOME							  //
//																  //
////////////////////////////////////////////////////////////////////
//Reason: Redundant with paraphernalia. No harm in keeping the rune somewhat usable until another use is found for that word combination.

/datum/rune_spell/summontome
	secret = TRUE
	name = "Summon Tome"
	desc = "Bring forth an arcane tome filled with Nar-Sie's knowledge."
	desc_talisman = "Turns into an arcane tome upon use."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/hell
	cost_invoke = 4
	page = ""

/datum/rune_spell/summontome/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		spell_holder.visible_message("<span class='rose'>The rune's symbols merge into each others, and an Arcane Tome takes form in their place</span>")
		var/turf/T = get_turf(spell_holder)
		var/obj/item/weapon/tome/AT = new (T)
		anim(target = AT, a_icon = 'icons/effects/effects.dmi', flick_anim = "tome_spawn")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/summontome/cast_talisman()//The talisman simply turns into a tome.
	var/turf/T = get_turf(spell_holder)
	var/obj/item/weapon/tome/AT = new (T)
	if (spell_holder == activator.get_active_hand())
		activator.drop_item(spell_holder, T)
		activator.put_in_active_hand(AT)
	else//are we using the talisman from a tome?
		activator.put_in_hands(AT)
	flick("tome_spawn",AT)
	qdel(src)


////////////////////////////////////////////////////////////////////
//																  //
//								STREAM							  //
//																  //
////////////////////////////////////////////////////////////////////
//Reason: we don't want a new cultist player to use this rune by accident, better leave it to savvy ones

/datum/rune_spell/stream
	secret = TRUE
	name = "Stream"
	desc = "Start or stop streaming on Spess.TV."
	desc_talisman = "Start or stop streaming on Spess.TV."
	invocation = "L'k' c'mm'nt 'n' s'bscr'b! P'g ch'mp! Kappah!"
	word1 = /datum/rune_word/other
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/self
	page = "This rune lets you start (or stop) streaming on Spess.TV so that you can let your audience watch and cheer for you while you slay infidels in the name of Nar-sie. #Sponsored"

/datum/rune_spell/stream/cast()
	var/datum/role/streamer/streamer = activator.mind.GetRole(STREAMER)
	if(!streamer)
		streamer = new /datum/role/streamer
		streamer.team = ESPORTS_CULTISTS
		if(!streamer.AssignToRole(activator.mind, 1))
			streamer.Drop()
			return
		streamer.OnPostSetup()
		streamer.Greet(GREET_DEFAULT)
		streamer.AnnounceObjectives()
	streamer.team = ESPORTS_CULTISTS
	if(!streamer.camera)
		streamer.set_camera(new /obj/machinery/camera/arena/spesstv(activator))
	streamer.toggle_streaming()
	qdel(src)

/*
Hall of fame of previous deprecated runes, might redesign later, noting their old word combinations there so I can easily retrieve them later.

MANIFEST GHOST: Blood 	See 	Travel
SACRIFICE: 		Hell 	Blood 	Join
DRAIN BLOOD: 	Travel 	Blood 	Self
BLOOD BOIL: 	Destroy See 	Blood
TEAR REALITY:	Hell 	Join 	Self

*/