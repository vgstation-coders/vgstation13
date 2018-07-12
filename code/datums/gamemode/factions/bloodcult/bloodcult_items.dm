#define PAGE_FOREWORD		0
#define PAGE_LORE1			101

var/list/arcane_tomes = list()

///////////////////////////////////////ARCANE TOME////////////////////////////////////////////////
/obj/item/weapon/tome
	name = "arcane tome"
	desc = "A dark, dusty tome with frayed edges and a sinister looking cover. It's surface is hard and cold to the touch."
	icon = 'icons/obj/cult.dmi'
	icon_state ="tome"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "tome"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	var/state = TOME_CLOSED
	var/can_flick = 1
	var/list/talismans = list()
	var/current_page = PAGE_FOREWORD

/obj/item/weapon/tome/New()
	..()
	arcane_tomes.Add(src)

/obj/item/weapon/tome/Destroy()
	arcane_tomes.Remove(src)
	for(var/obj/O in talismans)
		talismans.Remove(O)
		qdel(O)
	talismans = list()
	..()



/obj/item/weapon/tome/proc/tome_text()
	var/page_data = null
	var/dat = {"<title>arcane tome</title><body style="color:#5C1D12" background="tomebg.png">

			<style>
				label {display: inline-block; width: 50px;text-align: right;float: left;margin: 0 0 0 -45px;}
				ul {list-style-type: none;}
				li:before {content: "-";padding-left: 4px;}
				a {text-decoration: none; color:#5C1D12}
				.column {float: left; width: 250px; padding: 0px; height: 300px;}
				.row:after {content: ""; display: table; clear: both;}
			</style>

			<div class="row">
			<div class="column">
			<div align="center" style="margin: 0 0 0 -10px;"><div style="font-size:20px"><b>The scriptures of <font color=#AE250F>Nar-Sie</b></font></div>The Geometer of Blood</div>
			<ul>
			<a href='byond://?src=\ref[src];page=[PAGE_FOREWORD]'><label> * </label> <li> Foreword</a> </li>"}

	var i = 1
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance = subtype
		if (initial(instance.Act_restriction) <= 1000)//TODO: SET TO CURRENT CULT FACTION ACT
			dat += "<a href='byond://?src=\ref[src];page=[i]'><label> \Roman[i] </label> <li>  [initial(instance.name)] </li></a>"
			if (i == current_page)
				var/datum/cultword/word1 = initial(instance.word1)
				var/datum/cultword/word2 = initial(instance.word2)
				var/datum/cultword/word3 = initial(instance.word3)
				page_data = {"<div align="center"><b>\Roman[i]<br>[initial(instance.name)]</b><br><i>[initial(word1.english)], [initial(word2.english)], [word3 ? "[initial(word3.english)]" : "<any>"]</i></div><br>"}
				page_data += initial(instance.page)
		else
			dat += "<label> \Roman[i] </label> <li>  __________ </li>"
		i++

	dat += {"<a href='byond://?src=\ref[src];page=[PAGE_LORE1]'><label> * </label> <li>  about this tome and our goal </li></a>
			</ul></div>
			<div class="column">      <div align="left">      <b><ul>"}

	for (var/obj/item/weapon/talisman/T in talismans)
		var/datum/rune_spell/instance = T.spell_type
		dat += {"<label> * </label><li>  <a style="color:#AE250F" href='byond://?src=\ref[src];talisman=\ref[T]'>[initial(instance.name)]</a> <a style="color:#AE250F" href='byond://?src=\ref[src];remove=\ref[T]'>(x)</a> </li>"}

	dat += {"</ul></b></div><div style="margin: 0px 20px;" align="justify">"}

	if (page_data)
		dat += page_data
	else
		dat += page_special()

	dat += {"</div></div></div></body>"}

	return dat

/obj/item/weapon/tome/proc/page_special()
	var/dat = null
	switch (current_page)
		if (PAGE_FOREWORD)
			dat = {"<div align="center"><b>Foreword</b></div><br>
				This tome in your hands is both a guide to the ways of the devotes to Nar-Sie, and a tool to help them performing the cult's rituals.
				Inside are gathered notes on the various rituals, which you can read to study their use, and learn their runes. You don't have to learn
				the runes by heart however, as keeping this tome open allows you to immediately remember them when tracing words. Additional pieces of lore
				are available in the latter pages, aiming to satisfy the curiosity of the assiduous cultists.
				"}
		if (PAGE_LORE1)
			dat = {"<div align="center"><b>About this tome and our goal</b></div><br>
				This tome was written under the guidance of Nar-Sie, by devotes who have left behind their flesh enveloppes and taken residence in the realm of the Geometer of Blood.
				Our goal is to help our kin in the physical world, that is you, achieve the Tear Reality ritual, so that you can all join us and bring along lots of value, in other words blood.
				This goal has been achieved countless times before by different beings in different place, and this tome has been updated thanks to the knowledge of those who joined us.
				"}
	return dat

/obj/item/weapon/tome/Topic(href, href_list)
	if (..())
		return

	if(href_list["page"])
		current_page = text2num(href_list["page"])
		flick("tome-flick",src)

	if(href_list["talisman"])
		var/obj/item/weapon/talisman/T = locate(href_list["talisman"])
		T.trigger(usr)

	if(href_list["remove"])
		var/obj/item/weapon/talisman/T = locate(href_list["remove"])
		talismans.Remove(T)
		usr.put_in_hands(T)

	usr << browse_rsc('icons/tomebg.png', "tomebg.png")
	usr << browse(tome_text(), "window=arcanetome;size=512x375")

/obj/item/weapon/tome/attack(var/mob/living/M, var/mob/living/user)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!iscarbon(M))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!istype(M))
		return

	if(iscultist(M))//don't want to harm our team mates using tomes
		return

	..()
	M.take_organ_damage(0,10)
	to_chat(M, "<span class='warning'>You feel a searing heat inside of you!</span>")

/obj/item/weapon/tome/attack_hand(var/mob/living/user)
	if(!iscultist(user) && state == TOME_OPEN)
		user.take_organ_damage(0,10)
		to_chat(user, "<span class='warning'>As you reach to pick up \the [src], you feel a searing heat inside of you!</span>")
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0,0,0)
		user.Knockdown(5)
		user.Stun(5)
		icon_state = "tome"
		item_state = "tome"
		flick("tome-stun",src)
		state = TOME_CLOSED
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()
		return
	..()

/obj/item/weapon/tome/pickup(var/mob/user)
	if(iscultist(user) && state == TOME_OPEN)
		usr << browse_rsc('icons/tomebg.png', "tomebg.png")
		usr << browse(tome_text(), "window=arcanetome;size=512x375")

/obj/item/weapon/tome/dropped(var/mob/user)
	usr << browse(null, "window=arcanetome")

/obj/item/weapon/tome/attack_self(var/mob/living/user)
	if(!iscultist(user))//Too dumb to live.
		user.take_organ_damage(0,10)
		to_chat(user, "<span class='warning'>You try to peek inside \the [src], only to feel a discharge of energy and a searing heat inside of you!</span>")
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0,0,0)
		user.Knockdown(5)
		user.Stun(5)
		if (state == TOME_OPEN)
			icon_state = "tome"
			item_state = "tome"
			flick("tome-stun",src)
			state = TOME_CLOSED
		else
			flick("tome-stun2",src)
		return
	else
		if (state == TOME_CLOSED)
			icon_state = "tome-open"
			item_state = "tome-open"
			flick("tome-flickopen",src)
			state = TOME_OPEN
			usr << browse_rsc('icons/tomebg.png', "tomebg.png")
			usr << browse(tome_text(), "window=arcanetome;size=537x375")
		else
			icon_state = "tome"
			item_state = "tome"
			flick("tome-flickclose",src)
			state = TOME_CLOSED
			usr << browse(null, "window=arcanetome")

		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()

//absolutely no use except letting cultists know that you're here.
/obj/item/weapon/tome/attack_ghost(var/mob/dead/observer/user)
	if (state == TOME_OPEN && can_flick)
		if (Adjacent(user))
			to_chat(user, "You flick a page.")
			flick("tome-flick",src)
			can_flick = 0
			spawn(5)
				can_flick = 1
		else
			to_chat(user, "<span class='warning'>You need to get closer to interact with the pages.</span>")

/obj/item/weapon/tome/attackby(var/obj/item/I, var/mob/user)
	if (..())
		return
	if (istype(I, /obj/item/weapon/talisman))
		if (talismans.len < MAX_TALISMAN_PER_TOME)
			if(user.drop_item(I))
				talismans.Add(I)
				I.forceMove(src)
				to_chat(user, "<span class='notice'>You slip \the [I] into \the [src].</span>")
				if (state == TOME_OPEN)
					usr << browse_rsc('icons/tomebg.png', "tomebg.png")
					usr << browse(tome_text(), "window=arcanetome;size=512x375")
		else
			to_chat(user, "<span class='warning'>This tome cannot contain any more talismans. Use or remove some first.</span>")

#undef PAGE_FOREWORD
#undef PAGE_LORE1

///////////////////////////////////////TALISMAN////////////////////////////////////////////////

/obj/item/weapon/talisman
	name = "talisman"
	desc = "A tattered parchment. You feel a dark energy emanating from it."
	gender = NEUTER
	icon = 'icons/obj/cult.dmi'
	icon_state = "talisman"
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	layer = ABOVE_DOOR_LAYER
	pressure_resistance = 1
	attack_verb = list("slaps")
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1
	var/obj/effect/rune/attuned_rune = null
	var/spell_type = null

/obj/item/weapon/talisman/New()
	..()
	pixel_x=0
	pixel_y=0

/obj/item/weapon/talisman/examine(var/mob/user)
	..()
	if (!spell_type)
		to_chat(user, "<span class='info'>This one however seems pretty unremarkable.</span>")
		return

	var/datum/rune_spell/instance = spell_type

	if (iscultist(user) || isobserver(user))
		if (attuned_rune)
			to_chat(user, "<span class='info'>This one was attuned to a <b>[initial(instance.name)]</b> rune.</span>")
		else
			to_chat(user, "<span class='info'>This one was imbued with a <b>[initial(instance.name)]</b> rune.</span>")
	else
		to_chat(user, "<span class='info'>This one was some arcane drawings on it. You cannot read them.</span>")

/obj/item/weapon/talisman/attack_self(var/mob/living/user)
	if (iscultist(user))
		trigger(user)

/obj/item/weapon/talisman/proc/trigger(var/mob/user)
	if (!user) return

	if (!spell_type)
		if (src != user.get_active_hand())
			user.put_in_hands(src)//removing from a tome
		return

	if (attuned_rune)
		attuned_rune.trigger(user)
	else
		new spell_type(user, src)

	if (istype(loc,/obj/item/weapon/tome))
		var/obj/item/weapon/tome/T = loc
		T.talismans.Remove(src)
	qdel(src)

/obj/item/weapon/talisman/proc/imbue(var/mob/user, var/obj/effect/rune/R)
	if (!user || !R) return

	var/datum/rune_spell/spell = get_rune_spell(user,null,"examine",R.word1, R.word2, R.word3)
	if(initial(spell.talisman_absorb) == 2)
		user.drop_item(src)
		src.forceMove(get_turf(R))
		R.attack_hand(user)
	else
		if (attuned_rune)
			to_chat(user, "<span class='warning'>This [src] is already linked to a rune.</span>")
			return
		if (attuned_rune)
			to_chat(user, "<span class='warning'>This talisman is already imbued with the power of a rune.</span>")
			return

		if (!spell)
			to_chat(user, "<span class='warning'>There is no power in those runes. The talisman isn't reacting to it.</span>")
			return

		if (initial(spell.Act_restriction) > 1000)//TODO: SET TO CURRENT CULT FACTION ACT
			to_chat(user, "<span class='danger'>The veil is still too thick for a talisman to draw power from this rune.</span>")
			return

		//blood markings
		overlays += image(icon,"talisman-[R.word1.icon_state]a")
		overlays += image(icon,"talisman-[R.word2.icon_state]a")
		overlays += image(icon,"talisman-[R.word3.icon_state]a")
		//black markings
		overlays += image(icon,"talisman-[R.word1.icon_state]")
		overlays += image(icon,"talisman-[R.word2.icon_state]")
		overlays += image(icon,"talisman-[R.word3.icon_state]")

		spell_type = spell
		switch(initial(spell.talisman_absorb))
			if (0)
				user.playsound_local(src, 'sound/effects/talisman_attune.ogg', 50, 0, 0, 0, 0)
				to_chat(user, "<span class='notice'>The talisman can now remotely trigger the [initial(spell.name)] rune.</span>")
				attuned_rune = R
			if (1)
				user.playsound_local(src, 'sound/effects/talisman_imbue.ogg', 50, 0, 0, 0, 0)
				to_chat(user, "<span class='notice'>The talisman absorbs the power of the [initial(spell.name)] rune.</span>")
				qdel(R)
			if (2)
				message_admins("Error! Some bloke managed to imbue a Conjure Talisman rune. That shouldn't be possible!")
				return


/obj/item/weapon/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = FPRINT
	w_class = W_CLASS_LARGE
	force = 30
	throwforce = 10
	sharpness = 1.35
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/checkcult = 1

/obj/item/weapon/melee/cultblade/nocult
	checkcult = 0
	force = 15

/obj/item/weapon/melee/cultblade/cultify()
	return

/obj/item/weapon/melee/cultblade/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(!checkcult || iscultist(user))
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		return ..()
	else
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels the sword from [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()


/obj/item/weapon/melee/cultblade/pickup(mob/living/user as mob)
	if(checkcult && !iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to rid yourself of this blade quickly.</span>")
		user.Dizzy(120)


/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags = FPRINT
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 0
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/culthood/cultify()
	return

/obj/item/clothing/head/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags = FPRINT
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/cultrobes/cultify()
	return

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	item_state = "magusred"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0


/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie"
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armor bristling with spikes. It looks space proof."
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = NO_SLOWDOWN
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0


/obj/item/weapon/bloodcult_pamphlet
	name = "cult of Nar-Sie pamphlet"
	desc = "Looks like a page torn from a tome. One glimpse at it surely can't hurt you."
	icon = 'icons/obj/cult.dmi'
	icon_state ="pamphlet"
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	layer = ABOVE_DOOR_LAYER
	pressure_resistance = 1
	attack_verb = list("slaps")
	autoignition_temperature = AUTOIGNITION_PAPER
	fire_fuel = 1

/*
/obj/item/weapon/bloodcult_pamphlet/attack_self(var/mob/user)
	initialize_cultwords()
	var/datum/faction/bloodcult/cult = find_active_faction(BLOODCULT)
	if (cult)
		cult.HandleRecruitedMind(user.mind)
	user.add_spell(new /spell/cult/trace_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	user.add_spell(new /spell/cult/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
*/
