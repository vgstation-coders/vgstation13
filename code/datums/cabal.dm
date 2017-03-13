/datum/action/call_cabal
	name = "Call to Tchernobog"
	button_icon_state = "highfive"
	var/cooldown = 0
	var/cooldowndelay = 15 SECONDS
	var/list/calls = list( "sound/cabal/crudox_cruo.ogg",
                           "sound/cabal/cruo_stragana_malactose.ogg",
                           "sound/cabal/gera_shay_cruo.ogg",
                           "sound/cabal/gera_shay_cruoto.ogg",
                           "sound/cabal/in_marana_domus_bhaava_crunatus.ogg",
                           "sound/cabal/madermaxen_fervuxun.ogg",
                           "sound/cabal/maranax_pallex.ogg",
                           "sound/cabal/peroshay_bibox_mallax.ogg",
                           "sound/cabal/vorox_esco_maranaeat.ogg",
                            )
							
/datum/action/call_cabal/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "You do not wish to anger the Dreaming God with the praise from someone as weak as yourself.")
		return
	if(istype(owner.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(owner, "You can not praise the Dreaming God while wearing [owner.wear_mask].")
		return
	var/mob/living/carbon/human/H = owner
	if(istype(H) && (H.miming || H.silent))
		to_chat(owner, "You can not praise the Dreaming God while silenced.")
		return
	if(cooldown > world.time)
		to_chat(owner, "You do not wish to anger the Dreaming God with incessant mortal praise.")
		return
	var/soundfile = pick(calls)
	playsound(get_turf(owner), soundfile, 50, 0)
	owner.visible_message("<span class='sinister'>[owner] calls to Tchernobog!</span>","<span class='notice'>You call to Tchernobog!</span>")
	cooldown = world.time + cooldowndelay
