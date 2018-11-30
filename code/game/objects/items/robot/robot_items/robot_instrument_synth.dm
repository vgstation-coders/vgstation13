//Cyborg Instrument Synth. Remember to always play REMOVE KEBAB on malf rounds.
/obj/item/device/instrument/instrument_synth
	name = "instrument synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon = 'icons/obj/device.dmi'
	icon_state = "soundsynth"
	item_state = "radio"
	instrumentId = "piano"
	instrumentExt = "ogg"
	var/static/list/insTypes = list("accordion" = "mid", "bikehorn" = "ogg", "glockenspiel" = "mid", "guitar" = "ogg", "harmonica" = "mid", "piano" = "ogg", "recorder" = "mid", "saxophone" = "mid", "trombone" = "mid", "violin" = "mid", "xylophone" = "mid", "drum" = "mid")
	actions_types = list(/datum/action/item_action/synthswitch, /datum/action/item_action/instrument)

/obj/item/device/instrument/instrument_synth/proc/changeInstrument(name = "piano")
	song.instrumentDir = name
	song.instrumentExt = insTypes[name]

/datum/action/item_action/synthswitch
	name = "Change Synthesizer Instrument"
	desc = "Change the type of instrument your synthesizer is playing as."

/datum/action/item_action/synthswitch/Trigger()
	if(istype(target, /obj/item/device/instrument/instrument_synth))
		var/obj/item/device/instrument/instrument_synth/synth = target
		var/chosen = input("Choose the type of instrument you want to use", "Instrument Selection", "piano") as null|anything in synth.insTypes
		if(!synth.insTypes[chosen])
			return
		return synth.changeInstrument(chosen)
	return ..()

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/datum/action/item_action/instrument/Trigger()
	if(istype(target, /obj/item/device/instrument))
		var/obj/item/device/instrument/I = target
		I.interact(usr)
		return
	return ..()