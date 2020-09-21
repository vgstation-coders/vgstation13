/obj/item/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	var/block=0
	var/datum/dna2/record/buf=null
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/uses = 1
	var/nofail = 0
	var/is_bullet = 0
	var/inuse = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype=0
	var/value=0

/obj/item/dnainjector/New()
	. = ..()

	if(ticker)
		initialize()

/obj/item/dnainjector/initialize()
	if(datatype && block)
		buf=new
		buf.dna=new
		buf.types = datatype
		buf.dna.ResetSE()
		//testing("[name]: DNA2 SE blocks prior to SetValue: [english_list(buf.dna.SE)]")
		SetValue(src.value)
		//testing("[name]: DNA2 SE blocks after SetValue: [english_list(buf.dna.SE)]")

/obj/item/dnainjector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/dnainjector/proc/GetRealBlock(var/selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/dnainjector/proc/GetState(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/dnainjector/proc/SetState(var/on, var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/dnainjector/proc/GetValue(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/dnainjector/proc/SetValue(var/val,var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/dnainjector/proc/inject(mob/M as mob, mob/user as mob)
	if(ismanifested(M))
		to_chat(M, "<span class='warning'> Apparently it didn't work.</span>")
		if(M != user)
			to_chat(user, "<span class='warning'> Apparently it didn't work.</span>")
	else if(istype(M, /mob/living/carbon/slime/pygmy))
		var/mob/living/carbon/slime/S = M
		var/mob/living/carbon/human/slime/H = new (S.loc)
		if(S.mind)
			S.mind.transfer_to(H)
		else
			H.key = S.key
		S.transferImplantsTo(H)
		S.transferBorers(H)
		qdel(S)
		var/i
		while(!i)
			var/randomname = H.species.makeName()
			if(findname(randomname))
				continue
			else
				H.real_name = randomname
				i++
		uses--
	else
		if(istype(M,/mob/living))
			var/mob/living/L = M
			L.apply_radiation(rand(1,10), RAD_INTERNAL)

		if(!(M_NOCLONE in M.mutations)) // prevents drained people from having their DNA changed
			// UI in syringe.
			if(buf.types & DNA2_BUF_UI)
				if(!block) //isolated block?
					M.UpdateAppearance(buf.dna.UI.Copy())
					if (buf.types & DNA2_BUF_UE) //unique enzymes? yes
						M.real_name = buf.dna.real_name
						M.flavor_text = buf.dna.flavor_text
						M.name = buf.dna.real_name
					uses--
				else
					M.dna.SetUIValue(block,src.GetValue())
					M.UpdateAppearance()
					uses--
			if(buf.types & DNA2_BUF_SE)
				if(!block) //isolated block?
					M.dna.SE = buf.dna.SE.Copy()
					M.dna.UpdateSE()
				else
					M.dna.SetSEValue(block,src.GetValue())
				spawn() //domutcheck can include monkeyization which is long and stops the proc until it's done, this fixes it
					domutcheck(M, null, nofail)
				uses--
				//if(prob(5))
					//trigger_side_effect(M)

		if(buf.types & DNA2_BUF_SE)
			if(block)// Isolated injector
				if (GetState() && block == MONKEYBLOCK && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] (MONKEY)")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] <span class='warning'>(MONKEY)</span>")
				else
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name]")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name]")
			else
				if (GetState(MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] <span class='warning'>(MONKEY)</span>")
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (MONKEY)")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (MONKEY)")
				else
					log_attack("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
					log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")

	spawn(0)//this prevents the collapse of space-time continuum
		if(user)
			user.drop_from_inventory(src)
		if(!uses)
			qdel(src)
	return uses

/obj/item/dnainjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_attack("[user.name] ([user.ckey]) used the [name] to inject [M.name] ([M.ckey])")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(inuse)
		return 0

	user.visible_message("<span class='danger'>\The [user] is trying to inject \the [M] with \the [src]!</span>")

	inuse = 1
	if(!do_after(user, M, 5 SECONDS))
		inuse = 0 //If you've got a better idea on how to not repeat this twice I'd like to hear it
		return
	inuse = 0

	M.visible_message("<span class='danger'>\The [M] has been injected with \the [src] by \the [user].</span>")
	if (!istype(M, /mob/living/carbon/human) && !istype(M, /mob/living/carbon/monkey) && !istype(M, /mob/living/carbon/slime/pygmy))
		to_chat(user, "<span class='warning'>Apparently, the DNA injector didn't work...</span>")
		return

	inject(M, user)

/obj/item/dnainjector/nofail
	nofail = MUTCHK_FORCED

/obj/item/dnainjector/nofail/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/hulkmut/initialize()
	block = HULKBLOCK
	..()

/obj/item/dnainjector/nofail/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antihulk/initialize()
	block = HULKBLOCK
	..()

/obj/item/dnainjector/nofail/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 8

/obj/item/dnainjector/nofail/xraymut/initialize()
	block = XRAYBLOCK
	..()

/obj/item/dnainjector/nofail/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 8

/obj/item/dnainjector/nofail/antixray/initialize()
	block = XRAYBLOCK
	..()

/obj/item/dnainjector/nofail/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 10

/obj/item/dnainjector/nofail/firemut/initialize()
	block = FIREBLOCK
	..()

/obj/item/dnainjector/nofail/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 10

/obj/item/dnainjector/nofail/antifire/initialize()
	block = FIREBLOCK
	..()

/obj/item/dnainjector/nofail/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12

/obj/item/dnainjector/nofail/telemut/initialize()
	block = TELEBLOCK
	..()

/obj/item/dnainjector/nofail/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12

/obj/item/dnainjector/nofail/antitele/initialize()
	block = TELEBLOCK
	..()

/obj/item/dnainjector/nofail/nobreath
	name = "DNA-Injector (No Breath)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/nobreath/initialize()
	block = NOBREATHBLOCK
	..()

/obj/item/dnainjector/nofail/antinobreath
	name = "DNA-Injector (Anti-No Breath)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antinobreath/initialize()
	block = NOBREATHBLOCK
	..()

/obj/item/dnainjector/nofail/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/remoteview/initialize()
	block = REMOTEVIEWBLOCK
	..()

/obj/item/dnainjector/nofail/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Quit staring."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antiremoteview/initialize()
	block = REMOTEVIEWBLOCK
	..()

/obj/item/dnainjector/nofail/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/regenerate/initialize()
	block = REGENERATEBLOCK
	..()

/obj/item/dnainjector/nofail/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antiregenerate/initialize()
	block = REGENERATEBLOCK
	..()

/obj/item/dnainjector/nofail/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/runfast/initialize()
	block = INCREASERUNBLOCK
	..()

/obj/item/dnainjector/nofail/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antirunfast/initialize()
	block = INCREASERUNBLOCK
	..()

/obj/item/dnainjector/nofail/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/morph/initialize()
	block = MORPHBLOCK
	..()

/obj/item/dnainjector/nofail/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antimorph/initialize()
	block = MORPHBLOCK
	..()

/obj/item/dnainjector/nofail/cold
	name = "DNA-Injector (Cold)"
	desc = "Feels a bit chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/cold/initialize()
	block = COLDBLOCK
	..()

/obj/item/dnainjector/nofail/anticold
	name = "DNA-Injector (Anti-Cold)"
	desc = "Feels room-temperature."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/anticold/initialize()
	block = COLDBLOCK
	..()

/obj/item/dnainjector/nofail/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/noprints/initialize()
	block = NOPRINTSBLOCK
	..()

/obj/item/dnainjector/nofail/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antinoprints/initialize()
	block = NOPRINTSBLOCK
	..()

/obj/item/dnainjector/nofail/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/insulation/initialize()
	block = SHOCKIMMUNITYBLOCK
	..()

/obj/item/dnainjector/nofail/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antiinsulation/initialize()
	block = SHOCKIMMUNITYBLOCK
	..()

/obj/item/dnainjector/nofail/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/midgit/initialize()
	block = SMALLSIZEBLOCK
	..()

/obj/item/dnainjector/nofail/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antimidgit/initialize()
	block = SMALLSIZEBLOCK
	..()

/obj/item/dnainjector/nofail/sober
	name = "DNA-Injector (Sober)"
	desc = "Makes you not fun."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/sober/initialize()
	block = SOBERBLOCK
	..()

/obj/item/dnainjector/nofail/antisober
	name = "DNA-Injector (Anti-Sober)"
	desc = "Makes you fun as hell."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antisober/initialize()
	block = SOBERBLOCK
	..()

/obj/item/dnainjector/nofail/psychic_resist
	name = "DNA-Injector (Psychic Resist)"
	desc = "Not today, mind hippies."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/psychic_resist/initialize()
	block = PSYRESISTBLOCK
	..()


/obj/item/dnainjector/nofail/antipsychic_resist
	name = "DNA-Injector (Anti-Psychic Resist)"
	desc = "Im thinking about furry porn 24/7. Come at me, faggots."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antipsychic_resist/initialize()
	block = PSYRESISTBLOCK
	..()

/*/obj/item/dnainjector/nofail/darkcloak
	name = "DNA-Injector (Dark Cloak)"
	desc = "BLEH BLEH, I AM HERE TO SUCK YOUR BLOOD!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
/obj/item/dnainjector/nofail/darkcloak/New()
	block = SHADOWBLOCK
	..()

/obj/item/dnainjector/nofail/antidarkcloak
	name = "DNA-Injector (Anti-Dark Cloak)"
	desc = "THE LIGHT, IT BUUURNS!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antidarkcloak/New()
	block = SHADOWBLOCK
	..()
*/
/obj/item/dnainjector/nofail/chameleon
	name = "DNA-Injector (Chameleon)"
	desc = "You cant see me."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/chameleon/initialize()
	block = CHAMELEONBLOCK
	..()

/obj/item/dnainjector/nofail/antichameleon
	name = "DNA-Injector (Anti-Chameleon)"
	desc = "OH GOD EVERYONE CAN SEE ME!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antichameleon/initialize()
	block = CHAMELEONBLOCK
	..()

/obj/item/dnainjector/nofail/cryo
	name = "DNA-Injector (Cryokinesis)"
	desc = "Its about to get chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/cryo/initialize()
	block = CRYOBLOCK
	..()


/obj/item/dnainjector/nofail/anticryo
	name = "DNA-Injector (Anti-Cryokinesis)"
	desc = "Fuck, its hot in here!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/anticryo/initialize()
	block = CRYOBLOCK
	..()

/obj/item/dnainjector/nofail/mattereater
	name = "DNA-Injector (Matter Eater)"
	desc = "OM NOM NOM."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/mattereater/initialize()
	block = EATBLOCK
	..()

/obj/item/dnainjector/nofail/antimattereater
	name = "DNA-Injector (Anti-Matter Eater)"
	desc = "Oh god I'm gonna puke."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antimattereater/initialize()
	block = EATBLOCK
	..()

/obj/item/dnainjector/nofail/jumpy
	name = "DNA-Injector (Jumpy)"
	desc = "WEEEEEEEEEEEE!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/jumpy/initialize()
	block = JUMPBLOCK
	..()

/obj/item/dnainjector/nofail/antijumpy
	name = "DNA-Injector (Anti-Jumpy)"
	desc = "Awwe.."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antijumpy/initialize()
	block = JUMPBLOCK
	..()

/obj/item/dnainjector/nofail/polymorph
	name = "DNA-Injector (Polymorph)"
	desc = "A clone of myself? Now neither of us will be virgins!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/polymorph/initialize()
	block = POLYMORPHBLOCK
	..()

/obj/item/dnainjector/nofail/antipolymorph
	name = "DNA-Injector (Anti-Polymorph)"
	desc = "Damn, friendzoned by my own clone."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antipolymorph/initialize()
	block = POLYMORPHBLOCK
	..()

/obj/item/dnainjector/nofail/empath
	name = "DNA-Injector (Empathic Thought)"
	desc = "What will I have for dinner?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/empath/initialize()
	block = EMPATHBLOCK
	..()

/obj/item/dnainjector/nofail/antiempath
	name = "DNA-Injector (Anti-Empathic Thought)"
	desc = "Damn tin foil hats."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antiempath/initialize()
	block = EMPATHBLOCK
	..()

/obj/item/dnainjector/nofail/superfart
	name = "DNA-Injector (Super Fart)"
	desc = "Really?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/superfart/initialize()
	block = SUPERFARTBLOCK
	..()

/obj/item/dnainjector/nofail/antisuperfart
	name = "DNA-Injector (Anti-Super Fart)"
	desc = "No, really!?"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antisuperfart/initialize()
	block = SUPERFARTBLOCK
	..()

/////////////////////////////////////
/obj/item/dnainjector/nofail/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 1

/obj/item/dnainjector/nofail/antiglasses/initialize()
	block = GLASSESBLOCK
	..()

/obj/item/dnainjector/nofail/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 1

/obj/item/dnainjector/nofail/glassesmut/initialize()
	block = GLASSESBLOCK
	..()

/obj/item/dnainjector/nofail/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 3

/obj/item/dnainjector/nofail/epimut/initialize()
	block = HEADACHEBLOCK
	..()

/obj/item/dnainjector/nofail/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 3

/obj/item/dnainjector/nofail/antiepi/initialize()
	block = HEADACHEBLOCK
	..()

/obj/item/dnainjector/nofail/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 5

/obj/item/dnainjector/nofail/anticough/initialize()
	block = COUGHBLOCK
	..()

/obj/item/dnainjector/nofail/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 5

/obj/item/dnainjector/nofail/coughmut/initialize()
	block = COUGHBLOCK
	..()

/obj/item/dnainjector/nofail/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 6

/obj/item/dnainjector/nofail/clumsymut/initialize()
	block = CLUMSYBLOCK
	..()

/obj/item/dnainjector/nofail/anticlumsy
	name = "DNA-Injector (Anti-Clumsy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 6

/obj/item/dnainjector/nofail/anticlumsy/initialize()
	block = CLUMSYBLOCK
	..()

/obj/item/dnainjector/nofail/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 7

/obj/item/dnainjector/nofail/antitour/initialize()
	block = TWITCHBLOCK
	..()

/obj/item/dnainjector/nofail/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 7

/obj/item/dnainjector/nofail/tourmut/initialize()
	block = TWITCHBLOCK
	..()

/obj/item/dnainjector/nofail/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 9

/obj/item/dnainjector/nofail/stuttmut/initialize()
	block = NERVOUSBLOCK
	..()

/obj/item/dnainjector/nofail/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 9

/obj/item/dnainjector/nofail/antistutt/initialize()
	block = NERVOUSBLOCK
	..()

/obj/item/dnainjector/nofail/veganmut
	name = "DNA-Injector (Vegan)"
	desc = "Makes you vegan."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11

/obj/item/dnainjector/nofail/veganmut/initialize()
	block = VEGANBLOCK
	..()

/obj/item/dnainjector/nofail/antivegan
	name = "DNA-Injector (Anti-Vegan)"
	desc = "Allows you to enjoy meat and animal products again."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11

/obj/item/dnainjector/nofail/asthmamut
	name = "DNA-Injector (Asthma)"
	desc = "Makes you asthmatic."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11

/obj/item/dnainjector/nofail/asthmamut/initialize()
	block = ASTHMABLOCK
	..()

/obj/item/dnainjector/nofail/antiasthma
	name = "DNA-Injector (Anti-Asthma)"
	desc = "Allows you to breathe normally again."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/dnainjector/nofail/antiblind/initialize()
	block = VEGANBLOCK
	..()

/obj/item/dnainjector/nofail/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11

/obj/item/dnainjector/nofail/blindmut/initialize()
	block = BLINDBLOCK
	..()

/obj/item/dnainjector/nofail/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11

/obj/item/dnainjector/nofail/antiblind/initialize()
	block = BLINDBLOCK
	..()

/obj/item/dnainjector/nofail/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 13

/obj/item/dnainjector/nofail/deafmut/initialize()
	block = DEAFBLOCK
	..()

/obj/item/dnainjector/nofail/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 13

/obj/item/dnainjector/nofail/antideaf/initialize()
	block = DEAFBLOCK
	..()

/obj/item/dnainjector/nofail/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/hallucination/initialize()
	block = HALLUCINATIONBLOCK
	..()

/obj/item/dnainjector/nofail/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antihallucination/initialize()
	block = HALLUCINATIONBLOCK
	..()

/obj/item/dnainjector/nofail/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/h2m/initialize()
	block = MONKEYBLOCK
	..()

/obj/item/dnainjector/nofail/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/m2h/initialize()
	block = MONKEYBLOCK
	..()


/obj/item/dnainjector/nofail/mute
	name = "DNA-Injector (Mute)"
	desc = "Hell."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/mute/initialize()
	block = MUTEBLOCK
	..()

/obj/item/dnainjector/nofail/antimute
	name = "DNA-Injector (Anti-Mute)"
	desc = "Shut up."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antimute/initialize()
	block = MUTEBLOCK
	..()

/obj/item/dnainjector/nofail/radioactive
	name = "DNA-Injector (Radioactive)"
	desc = "Welcome to the new age."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/radioactive/initialize()
	block = RADBLOCK
	..()

/obj/item/dnainjector/nofail/antiradioactive
	name = "DNA-Injector (Anti-Radioactive)"
	desc = "All systems go."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antiradioactive/initialize()
	block = RADBLOCK
	..()

/obj/item/dnainjector/nofail/fat
	name = "DNA-Injector (Fat)"
	desc = "Gives you big bones."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/fat/initialize()
	block = FATBLOCK
	..()

/obj/item/dnainjector/nofail/antifat
	name = "DNA-Injector (Anti-Fat)"
	desc = "Feeds you subway."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antifat/initialize()
	block = FATBLOCK
	..()


/obj/item/dnainjector/nofail/chav
	name = "DNA-Injector (Chav)"
	desc = "Makes you a real arsehole."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/chav/initialize()
	block = CHAVBLOCK
	..()

/obj/item/dnainjector/nofail/antichav
	name = "DNA-Injector (Anti-Chav)"
	desc = "Put it back, I liked you better that way."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antichav/initialize()
	block = CHAVBLOCK
	..()

/obj/item/dnainjector/nofail/sweedish
	name = "DNA-Injector (Sweedish)"
	desc = "BORK! BORK! BORK!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/sweedish/initialize()
	block = SWEDEBLOCK
	..()

/obj/item/dnainjector/nofail/antisweedish
	name = "DNA-Injector (Anti-Sweedish)"
	desc = "You're no fun."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antisweedish/initialize()
	block = SWEDEBLOCK
	..()

/obj/item/dnainjector/nofail/unintelligable
	name = "DNA-Injector (Unintelligable)"
	desc = "At?wh"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/unintelligable/initialize()
	block = SCRAMBLEBLOCK
	..()

/obj/item/dnainjector/nofail/antiunintelligable
	name = "DNA-Injector (Anti-Unintelligable)"
	desc = "What?"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antiunintelligable/initialize()
	block = SCRAMBLEBLOCK
	..()

/obj/item/dnainjector/nofail/strong
	name = "DNA-Injector (Strong)"
	desc = "HEY BRO, WANNA HIT THE GYM?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/strong/initialize()
	block = STRONGBLOCK
	..()

/obj/item/dnainjector/nofail/antistrong
	name = "DNA-Injector (Anti-Strong)"
	desc = "Spot me!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antistrong/initialize()
	block = STRONGBLOCK
	..()

/obj/item/dnainjector/nofail/horns
	name = "DNA-Injector (Horns)"
	desc = "Feelin' horny?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/horns/initialize()
	block = HORNSBLOCK
	..()

/obj/item/dnainjector/nofail/antihorns
	name = "DNA-Injector (Anti-Horns)"
	desc = "Right, lets just watch Law & Order."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antihorns/initialize()
	block = HORNSBLOCK
	..()

/obj/item/dnainjector/nofail/immolate
	name = "DNA-Injector (Immolate)"
	desc = "We didn't start the fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/immolate/initialize()
	block = IMMOLATEBLOCK
	..()

/obj/item/dnainjector/nofail/antiimmolate
	name = "DNA-Injector (Anti-Immolate)"
	desc = "It was always burnin' since the world was turnin'"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antiimmolate/initialize()
	block = IMMOLATEBLOCK
	..()

/obj/item/dnainjector/nofail/melt
	name = "DNA-Injector (Dissolve)"
	desc = "Win the game."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/melt/initialize()
	block = MELTBLOCK
	..()

/obj/item/dnainjector/nofail/antimelt
	name = "DNA-Injector (Dissolve)"
	desc = "You just lost the game."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antimelt/initialize()
	block = MELTBLOCK
	..()

/obj/item/dnainjector/nofail/smile
	name = "DNA-Injector (Smile)"
	desc = ":)"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/smile/initialize()
	block = SMILEBLOCK
	..()

/obj/item/dnainjector/nofail/antismile
	name = "DNA-Injector (Anti-Smile)"
	desc = ":("
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antismile/initialize()
	block = SMILEBLOCK
	..()

/obj/item/dnainjector/nofail/elvis
	name = "DNA-Injector (Elvis)"
	desc = "Tell the folks back home this is the promised land calling"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/elvis/initialize()
	block = ELVISBLOCK
	..()

/obj/item/dnainjector/nofail/antielvis
	name = "DNA-Injector (Anti-Elvis)"
	desc = "And the poor boy is on the line."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antielvis/initialize()
	block = ELVISBLOCK
	..()

/obj/item/dnainjector/nofail/loud
	name = "DNA-Injector (Loud)"
	desc = "CAPS LOCK IS CRUISE CONRTOL FOR COOL!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/loud/initialize()
	block = LOUDBLOCK
	..()

/obj/item/dnainjector/nofail/antiloud
	name = "DNA-Injector (Anti-Loud)"
	desc = "EVEN WITH CRUISE CONTROL, YOU STILL HAVE TO STEER!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antiloud/initialize()
	block = LOUDBLOCK
	..()

/obj/item/dnainjector/nofail/whisper
	name = "DNA-Injector (Quiet)"
	desc = "Shhh..."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/whisper/initialize()
	block = WHISPERBLOCK
	..()

/obj/item/dnainjector/nofail/antiwhisper
	name = "DNA-Injector (Anti-Quiet)"
	desc = "WOOOO HOOOO!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antiwhisper/initialize()
	block = WHISPERBLOCK
	..()

/obj/item/dnainjector/nofail/dizzy
	name = "DNA-Injector (Dizzy)"
	desc = "Touch fuzzy,"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/dizzy/initialize()
	block = DIZZYBLOCK
	..()

/obj/item/dnainjector/nofail/antidizzy
	name = "DNA-Injector (Anti-Dizzy)"
	desc = "Get dizzy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antidizzy/initialize()
	block = DIZZYBLOCK
	..()

/obj/item/dnainjector/nofail/sans
	name = "DNA-Injector (Wacky)"
	desc = "<span class='sans'>#wow #woah</span>"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/dnainjector/nofail/sans/initialize()
	block = SANSBLOCK
	..()

/obj/item/dnainjector/nofail/antisans
	name = "DNA-Injector (Anti-Wacky)"
	desc = "Worst font."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/dnainjector/nofail/antisans/initialize()
	block = SANSBLOCK
	..()

/obj/item/dnainjector/nofail/farsightmut
	name = "DNA-Injector (Farsight)"
	desc = "This will allow you to focus your eyes better."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/dnainjector/nofail/farsightmut/initialize()
	block = FARSIGHTBLOCK
	..()

/obj/item/dnainjector/nofail/antifarsight
	name = "DNA-Injector (Anti-Farsight)"
	desc = "No fun allowed"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/dnainjector/nofail/antifarsight/initialize()
	block = FARSIGHTBLOCK
	..()

/obj/item/dnainjector/nofail/remotesay
	name = "DNA-Injector (Remote Say)"
	desc = "Share it with the world."
	datatype = DNA2_BUF_SE
	value = 0xFFF

/obj/item/dnainjector/nofail/remotesay/initialize()
	block = REMOTETALKBLOCK
	..()

/obj/item/dnainjector/nofail/antiremotesay
	name = "DNA-Injector (Remote Say)"
	desc = "Keep it to yourself."
	datatype = DNA2_BUF_SE
	value = 0x001

/obj/item/dnainjector/nofail/antiremotesay/initialize()
	block = REMOTETALKBLOCK
	..()

/obj/item/dnainjector/nofail/randompower/New(newloc)
    var/type = pick(/obj/item/dnainjector/nofail/hulkmut,
        /obj/item/dnainjector/nofail/xraymut,
        /obj/item/dnainjector/nofail/firemut,
        /obj/item/dnainjector/nofail/telemut,
        /obj/item/dnainjector/nofail/nobreath,
        /obj/item/dnainjector/nofail/remoteview,
        /obj/item/dnainjector/nofail/regenerate,
        /obj/item/dnainjector/nofail/runfast,
        /obj/item/dnainjector/nofail/morph,
        /obj/item/dnainjector/nofail/cold,
        /obj/item/dnainjector/nofail/noprints,
        /obj/item/dnainjector/nofail/insulation,
        /obj/item/dnainjector/nofail/midgit,
        /obj/item/dnainjector/nofail/sober,
        /obj/item/dnainjector/nofail/psychic_resist,
        /obj/item/dnainjector/nofail/chameleon,
        /obj/item/dnainjector/nofail/cryo,
        /obj/item/dnainjector/nofail/mattereater,
        /obj/item/dnainjector/nofail/jumpy,
        /obj/item/dnainjector/nofail/polymorph,
        /obj/item/dnainjector/nofail/empath,
        /obj/item/dnainjector/nofail/superfart,
        /obj/item/dnainjector/nofail/epimut,
        /obj/item/dnainjector/nofail/strong,
        /obj/item/dnainjector/nofail/immolate,
        /obj/item/dnainjector/nofail/melt,
        /obj/item/dnainjector/nofail/farsightmut,
        /obj/item/dnainjector/nofail/remotesay)
    new type(loc)
    qdel(src)
