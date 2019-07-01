#define PAGE_FOREWORD		0
#define PAGE_LORE1			101

var/list/arcane_tomes = list()

///////////////////////////////////////ARCANE TOME////////////////////////////////////////////////
/obj/item/weapon/tome
	name = "arcane tome"
	desc = "A dark, dusty tome with frayed edges and a sinister cover. Its surface is hard and cold to the touch."
	icon = 'icons/obj/cult.dmi'
	icon_state ="tome"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "tome"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	slot_flags = SLOT_BELT
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
		var/datum/rune_spell/blood_cult/instance = subtype
		if (initial(instance.Act_restriction) <= veil_thickness)
			dat += "<a href='byond://?src=\ref[src];page=[i]'><label> \Roman[i] </label> <li>  [initial(instance.name)] </li></a>"
			if (i == current_page)
				var/datum/runeword/word1 = initial(instance.word1)
				var/datum/runeword/word2 = initial(instance.word2)
				var/datum/runeword/word3 = initial(instance.word3)
				page_data = {"<div align="center"><b>\Roman[i]<br>[initial(instance.name)]</b><br><i>[initial(word1.english)], [initial(word2.english)], [word3 ? "[initial(word3.english)]" : "<any>"]</i></div><br>"}
				page_data += initial(instance.page)
		else
			dat += "<label> \Roman[i] </label> <li>  __________ </li>"
		i++

	dat += {"<a href='byond://?src=\ref[src];page=[PAGE_LORE1]'><label> * </label> <li>  about this tome and our goal </li></a>
			</ul></div>
			<div class="column">      <div align="left">      <b><ul>"}

	for (var/obj/item/weapon/talisman/T in talismans)
		dat += {"<label> * </label><li>  <a style="color:#AE250F" href='byond://?src=\ref[src];talisman=\ref[T]'>[T.talisman_name()][(T.uses > 1) ? " [T.uses] uses" : ""]</a> <a style="color:#AE250F" href='byond://?src=\ref[src];remove=\ref[T]'>(x)</a> </li>"}

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
	if(!usr.held_items.Find(src))
		return
	if(href_list["page"])
		current_page = text2num(href_list["page"])
		flick("tome-flick",src)
		playsound(usr, "pageturn", 50, 1, -5)

	if(href_list["talisman"])
		var/obj/item/weapon/talisman/T = locate(href_list["talisman"])
		if(!talismans.Find(T))
			return
		T.trigger(usr)

	if(href_list["remove"])
		var/obj/item/weapon/talisman/T = locate(href_list["remove"])
		if(!talismans.Find(T))
			return
		talismans.Remove(T)
		usr.put_in_hands(T)

	usr << browse_rsc('icons/tomebg.png', "tomebg.png")
	usr << browse(tome_text(), "window=arcanetome;size=537x375")

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
		usr << browse(tome_text(), "window=arcanetome;size=537x375")

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
			playsound(user, "pageturn", 50, 1, -5)
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
			playsound(user, "pageturn", 50, 1, -3)
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
					usr << browse(tome_text(), "window=arcanetome;size=537x375")
		else
			to_chat(user, "<span class='warning'>This tome cannot contain any more talismans. Use or remove some first.</span>")

/obj/item/weapon/tome/AltClick(var/mob/user)
	var/list/choices = list()
	var/datum/rune_spell/blood_cult/instance
	var/list/choice_to_talisman = list()
	var/image/talisman_image
	for(var/obj/item/weapon/talisman/T in talismans)
		talisman_image = new(T)
		instance = T.spell_type
		choices += list(list(T, talisman_image, initial(instance.desc_talisman), T.talisman_name()))
		choice_to_talisman[initial(instance.name)] = T

	if (state == TOME_CLOSED)
		icon_state = "tome-open"
		item_state = "tome-open"
		flick("tome-flickopen",src)
		playsound(user, "pageturn", 50, 1, -5)
		state = TOME_OPEN
	var/choice = show_radial_menu(user,loc,choices,'icons/obj/cult_radial3.dmi', "radial-cult2")
	if(!choice_to_talisman[choice])
		return
	var/obj/item/weapon/talisman/chosen_talisman = choice_to_talisman[choice]
	if(!usr.held_items.Find(src))
		return
	if (state == TOME_OPEN)
		icon_state = "tome"
		item_state = "tome"
		flick("tome-stun",src)
		state = TOME_CLOSED
	talismans.Remove(chosen_talisman)
	usr.put_in_hands(chosen_talisman)

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
	var/blood_text = ""
	var/obj/effect/rune/attuned_rune = null
	var/spell_type = null
	var/uses = 1

/obj/item/weapon/talisman/New()
	..()
	pixel_x=0
	pixel_y=0

/obj/item/weapon/talisman/proc/talisman_name()
	var/datum/rune_spell/blood_cult/instance = spell_type
	if (blood_text)
		return "\[blood message\]"
	if (instance)
		return initial(instance.name)
	else
		return "\[blank\]"

/obj/item/weapon/talisman/examine(var/mob/user)
	..()
	if (blood_text)
		user << browse_rsc(file("goon/browserassets/css/fonts/youmurdererbb_reg.otf"))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text=#612014>[blood_text]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
		return

	if (!spell_type)
		to_chat(user, "<span class='info'>This one however seems pretty unremarkable.</span>")
		return

	var/datum/rune_spell/blood_cult/instance = spell_type

	if (iscultist(user) || isobserver(user))
		if (attuned_rune)
			to_chat(user, "<span class='info'>This one was attuned to a <b>[initial(instance.name)]</b> rune. [initial(instance.desc_talisman)]</span>")
		else
			to_chat(user, "<span class='info'>This one was imbued with a <b>[initial(instance.name)]</b> rune. [initial(instance.desc_talisman)]</span>")
		if (uses > 1)
			to_chat(user, "<span class='info'>Its powers can be used [uses] more times.</span>")
	else
		to_chat(user, "<span class='info'>This one was some arcane drawings on it. You cannot read them.</span>")

/obj/item/weapon/talisman/attack_self(var/mob/living/user)
	if (blood_text)
		user << browse_rsc(file("goon/browserassets/css/fonts/youmurdererbb_reg.otf"))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text=#612014>[blood_text]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
		onclose(user, "[name]")
		return

	if (iscultist(user))
		trigger(user)

/obj/item/weapon/talisman/attack(var/mob/living/target, var/mob/living/user)
	if(iscultist(user) && spell_type)
		var/datum/rune_spell/blood_cult/instance = spell_type
		if (initial(instance.touch_cast))
			new spell_type(user, src, "touch", target)
			qdel(src)
			return
	..()

/obj/item/weapon/talisman/proc/trigger(var/mob/user)
	if (!user)
		return

	if (blood_text)
		user << browse_rsc(file("goon/browserassets/css/fonts/youmurdererbb_reg.otf"))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text=#612014>[blood_text]</BODY></HTML>", "window=[name]")
		onclose(user, "[name]")
		return

	if (!spell_type)
		if (!(src in user.held_items))//triggering an empty rune from a tome removes it.
			if (istype(loc, /obj/item/weapon/tome))
				var/obj/item/weapon/tome/T = loc
				T.talismans.Remove(src)
				user << browse_rsc('icons/tomebg.png', "tomebg.png")
				user << browse(T.tome_text(), "window=arcanetome;size=537x375")
				user.put_in_hands(src)
		return

	if (attuned_rune)
		if (attuned_rune.loc)
			attuned_rune.trigger(user,1)
		else//darn, the rune got destroyed one way or another
			attuned_rune = null
			to_chat(user, "<span class='warning'>The talisman disappears into dust. The rune it was attuned to appears to no longer exist.</span>")
	else
		new spell_type(user, src)

	uses--
	if (uses > 0)
		return

	if (istype(loc,/obj/item/weapon/tome))
		var/obj/item/weapon/tome/T = loc
		T.talismans.Remove(src)
	qdel(src)

/obj/item/weapon/talisman/proc/imbue(var/mob/user, var/obj/effect/rune/blood_cult/R)
	if (!user || !R)
		return

	if (blood_text)
		to_chat(user, "<span class='warning'>Cannot imbue a talisman that has been written on.</span>")
		return

	var/datum/rune_spell/blood_cult/spell = get_rune_spell(user,null,"examine",R.word1, R.word2, R.word3)
	if(initial(spell.talisman_absorb) == RUNE_CANNOT)//placing a talisman on a Conjure Talisman rune to try and fax it
		user.drop_item(src)
		src.forceMove(get_turf(R))
		R.attack_hand(user)
	else
		if (attuned_rune)
			to_chat(user, "<span class='warning'>\The [src] is already linked to a rune.</span>")
			return
		if (attuned_rune)
			to_chat(user, "<span class='warning'>\The [src] is already imbued with the power of a rune.</span>")
			return

		if (!spell)
			to_chat(user, "<span class='warning'>There is no power in those runes. \The [src] isn't reacting to it.</span>")
			return

		if (initial(spell.Act_restriction) > veil_thickness)
			to_chat(user, "<span class='danger'>The veil is still too thick for \the [src] to draw power from this rune.</span>")
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
		uses = initial(spell.talisman_uses)

		var/talisman_interaction = initial(spell.talisman_absorb)
		var/datum/rune_spell/blood_cult/active_spell = R.active_spell
		if(!istype(R))
			return
		if (active_spell)//some runes may change their interaction type dynamically (ie: Path Exit runes)
			talisman_interaction = active_spell.talisman_absorb
			if (istype(active_spell,/datum/rune_spell/blood_cult/portalentrance))
				var/datum/rune_spell/blood_cult/portalentrance/entrance = active_spell
				if (entrance.network)
					word_pulse(global_runesets["blood_cult"].words[entrance.network])
			else if (istype(active_spell,/datum/rune_spell/blood_cult/portalexit))
				var/datum/rune_spell/blood_cult/portalentrance/exit = active_spell
				if (exit.network)
					word_pulse(global_runesets["blood_cult"].words[exit.network])

		switch(talisman_interaction)
			if (RUNE_CAN_ATTUNE)
				playsound(src, 'sound/effects/talisman_attune.ogg', 50, 0, -5)
				to_chat(user, "<span class='notice'>\The [src] can now remotely trigger the [initial(spell.name)] rune.</span>")
				attuned_rune = R
			if (RUNE_CAN_IMBUE)
				playsound(src, 'sound/effects/talisman_imbue.ogg', 50, 0, -5)
				to_chat(user, "<span class='notice'>\The [src] absorbs the power of the [initial(spell.name)] rune.</span>")
				qdel(R)
			if (RUNE_CANNOT)//like, that shouldn't even be possible because of the earlier if() check, but just in case.
				message_admins("Error! ([key_name(user)]) managed to imbue a Conjure Talisman rune. That shouldn't be possible!")
				return

/obj/item/weapon/talisman/proc/word_pulse(var/datum/runeword/W)
	var/image/I1 = image(icon,"talisman-[W.icon_state]a")
	animate(I1, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5, loop = -1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	overlays += I1
	var/image/I2 = image(icon,"talisman-[W.icon_state]")
	animate(I2, color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5, loop = -1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	overlays += I2

/obj/item/weapon/talisman/attackby(var/obj/item/weapon/P, var/mob/user)
	..()
	if(P.is_hot())
		ashify_item(user)
		return 1

///////////////////////////////////////CULT BLADE////////////////////////////////////////////////

/obj/item/weapon/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie. It features a nice round socket at the base of its obsidian blade."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = FPRINT
	w_class = W_CLASS_LARGE
	force = 30
	throwforce = 10
	sharpness = 1.35
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	hitsound = "sound/weapons/bladeslice.ogg"
	var/checkcult = 1

/obj/item/weapon/melee/cultblade/cultify()
	return

/obj/item/weapon/melee/cultblade/attack(var/mob/living/target, var/mob/living/carbon/human/user)
	if(!checkcult)
		return ..()
	if (iscultist(user))
		if (ishuman(target) && target.resting)
			var/obj/structure/cult/altar/altar = locate() in target.loc
			if (altar)
				altar.attackby(src,user)
				return
			else
				return ..()
		else
			return ..()
	else
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels \the [src] from [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()

/obj/item/weapon/melee/cultblade/pickup(var/mob/living/user)
	if(checkcult && !iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.</span>")
		user.Dizzy(120)

/obj/item/weapon/melee/cultblade/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/talisman) || istype(I,/obj/item/weapon/paper))
		I.ashify_item(user)
		return 1
	if(istype(I,/obj/item/device/soulstone/gem))
		if (user.get_inactive_hand() != src)
			to_chat(user,"<span class='warning'>You must hold \the [src] in your hand to properly place \the [I] in its socket.</span>")
			return 1
		var/turf/T = get_turf(user)
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		user.drop_item(src,T)
		var/obj/item/weapon/melee/soulblade/SB = new (T)
		if (fingerprints)
			SB.fingerprints = fingerprints.Copy()
		spawn(1)
			user.put_in_active_hand(SB)
		for(var/mob/living/simple_animal/shade/A in I)
			A.forceMove(SB)
			SB.shade = A
			A.give_blade_powers()
			break
		SB.update_icon()
		qdel(I)
		qdel(src)
		return 1
	if(istype(I,/obj/item/device/soulstone))
		to_chat(user,"<span class='warning'>\The [I] doesn't fit in \the [src]'s socket.</span>")
		return 1
	..()

/obj/item/weapon/melee/cultblade/nocult
	name = "broken cult blade"
	desc = "What remains of an arcane weapon wielded by the followers of Nar-Sie. In this state, it can be held mostly without risks."
	icon_state = "cultblade-broken"
	item_state = "cultblade-broken"
	checkcult = 0
	force = 15

/obj/item/weapon/melee/cultblade/nocult/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/talisman) || istype(I,/obj/item/weapon/paper))
		return 1
	if(istype(I,/obj/item/device/soulstone/gem))
		to_chat(user,"<span class='warning'>The [src]'s damage doesn't allow it to hold \a [I] any longer.</span>")
		return 1
	..()

///////////////////////////////////////SOUL BLADE////////////////////////////////////////////////

/obj/item/weapon/melee/soulblade
	name = "soul blade"
	desc = "An obsidian blade fitted with a soul gem, giving it soul catching propertiess."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	icon_state = "soulblade"
	item_state = "soulblade"
	flags = FPRINT
	w_class = W_CLASS_LARGE
	force = 30//30 brute, plus 5 burn
	throwforce = 20
	sharpness = 1.35
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	hitsound = "sound/weapons/bladeslice.ogg"
	var/mob/living/simple_animal/shade/shade = null
	var/blood = 0
	var/maxregenblood = 8//the maximum amount of blood you can regen by waiting around.
	var/maxblood = 100
	var/movespeed = 2//smaller = faster
	health = 40
	var/maxHealth = 40

/obj/item/weapon/melee/soulblade/Destroy()
	var/turf/T = get_turf(src)
	if (istype(loc, /obj/item/projectile))
		qdel(loc)
	if (shade)
		shade.remove_blade_powers()
		if (T)
			shade.forceMove(T)
			shade.status_flags &= ~GODMODE
			shade.canmove = 1
			shade.cancel_camera()
			var/datum/control/C = shade.control_object[src]
			if(C)
				C.break_control()
				qdel(C)
		else
			qdel(shade)
	if (T)
		var/obj/item/weapon/melee/cultblade/nocult/B = new (T)
		B.Move(get_step_rand(T))
		if (fingerprints)
			B.fingerprints = fingerprints.Copy()
		new /obj/item/device/soulstone(T)
	shade = null
	..()

/obj/item/weapon/melee/soulblade/examine(var/mob/user)
	..()
	if (iscultist(user))
		to_chat(user, "<span class='info'>blade blood: [blood]%</span>")
		to_chat(user, "<span class='info'>blade health: [round((health/maxHealth)*100)]%</span>")


/obj/item/weapon/melee/soulblade/cultify()
	return


/obj/item/weapon/melee/soulblade/attack_self(var/mob/user)
	var/choices = list(
		list("Give Blood", "radial_giveblood", "Transfer some of your blood to \the [src] to repair it and refuel its blood level, or you could just slash someone."),
		list("Remove Gem", "radial_removegem", "Remove the soul gem from the blade."),
		)

	if (!iscultist(user))
		choices = list(
			list("Remove Gem", "radial_removegem", "Remove the soul gem from \the [src]."),
			)

	var/task = show_radial_menu(user,user,choices,'icons/obj/cult_radial.dmi',"radial-cult")//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	if (user.get_active_hand() != src)
		to_chat(user,"<span class='warning'>You must hold \the [src] in your active hand.</span>")
		return
	switch (task)
		if ("Give Blood")
			var/data = use_available_blood(user, 10)
			if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
				blood = min(maxblood,blood+20)//reminder that the blade cannot give blood back to their wielder, so this should prevent some exploits
				health = min(maxHealth,health+10)
		if ("Remove Gem")
			var/turf/T = get_turf(user)
			playsound(T, 'sound/items/Deconstruct.ogg', 50, 0, -3)
			user.drop_item(src,T)
			var/obj/item/weapon/melee/cultblade/CB = new (T)
			var/obj/item/device/soulstone/gem/SG = new (T)
			if (fingerprints)
				CB.fingerprints = fingerprints.Copy()
			user.put_in_active_hand(CB)
			user.put_in_inactive_hand(SG)
			if (shade)
				shade.forceMove(SG)
				shade.remove_blade_powers()
				SG.icon_state = "soulstone2"
				SG.item_state = "shard-soulstone2"
				SG.name = "Soul Stone: [shade.real_name]"
				shade = null
			loc = null//so we won't drop a broken blade and shard
			qdel(src)


/obj/item/weapon/melee/soulblade/attack(var/mob/living/target, var/mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels \the [src] from \the [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()
		return
	if (ishuman(target) && target.resting)
		var/obj/structure/cult/altar/altar = locate() in target.loc
		if (altar)
			altar.attackby(src,user)
			return
	..()
	if (!shade && istype(target, /mob/living/carbon))
		transfer_soul("VICTIM", target, user,1)
		update_icon()

/obj/item/weapon/melee/soulblade/afterattack(var/atom/A, var/mob/living/user, var/proximity_flag, var/click_parameters)
	if(proximity_flag)
		return
	if (user.is_pacified(VIOLENCE_SILENT,A,src))
		return

	if (blood >= 5)
		blood = max(0,blood-5)
		var/turf/starting = get_turf(user)
		var/turf/target = get_turf(A)
		var/obj/item/projectile/bloodslash/BS = new (starting)
		BS.firer = user
		BS.original = A
		BS.target = target
		BS.current = starting
		BS.starting = starting
		BS.yo = target.y - starting.y
		BS.xo = target.x - starting.x
		user.delayNextAttack(4)
		if(user.zone_sel)
			BS.def_zone = user.zone_sel.selecting
		else
			BS.def_zone = LIMB_CHEST
		BS.OnFired()
		playsound(starting, 'sound/effects/forge.ogg', 100, 1)
		BS.process()

/obj/item/weapon/melee/soulblade/on_attack(var/atom/attacked, var/mob/user)
	..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		M.take_organ_damage(0,5)
		playsound(loc, 'sound/weapons/welderattack.ogg', 50, 1)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.stat != DEAD)
				if (C.take_blood(null,10))
					blood = min(100,blood+10)
					to_chat(user, "<span class='warning'>You steal some of their blood!</span>")
			else
				if (C.take_blood(null,5))//same cost as spin, basically negates the cost, but doesn't let you farm corpses. It lets you make a mess out of them however.
					blood = min(100,blood+5)
					to_chat(user, "<span class='warning'>You steal a bit of their blood, but not much.</span>")

			if (shade && shade.hud_used && shade.gui_icons && shade.gui_icons.soulblade_bloodbar)
				var/matrix/MAT = matrix()
				MAT.Scale(1,blood/maxblood)
				var/total_offset = (60 + (100*(blood/maxblood))) * PIXEL_MULTIPLIER
				shade.hud_used.mymob.gui_icons.soulblade_bloodbar.transform = MAT
				shade.hud_used.mymob.gui_icons.soulblade_bloodbar.screen_loc = "WEST,CENTER-[8-round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE]"
				shade.hud_used.mymob.gui_icons.soulblade_coverLEFT.maptext = "[blood]"


/obj/item/weapon/melee/soulblade/pickup(var/mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.</span>")
		user.Dizzy(120)

/obj/item/weapon/melee/soulblade/dropped(var/mob/user)
	..()
	update_icon()

/obj/item/weapon/melee/soulblade/update_icon()
	overlays.len = 0
	animate(src, pixel_y = -16 * PIXEL_MULTIPLIER, time = 3, easing = SINE_EASING)
	shade = locate() in src
	if (shade)
		plane = HUD_PLANE//let's keep going and see where this takes us
		layer = ABOVE_HUD_LAYER
		item_state = "soulblade-full"
		icon_state = "soulblade-full"
		animate(src, pixel_y = -8 * PIXEL_MULTIPLIER , time = 7, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -12 * PIXEL_MULTIPLIER, time = 7, loop = -1, easing = SINE_EASING)
	else
		if (!ismob(loc))
			plane = initial(plane)
			layer = initial(layer)
		item_state = "soulblade"
		icon_state = "soulblade"

	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/C = loc
		C.update_inv_hands()


/obj/item/weapon/melee/soulblade/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	var/turf/starting = get_turf(src)
	var/turf/target = get_turf(targ)
	var/turf/second_target = target
	var/obj/item/projectile/soulbullet/SB = new (starting)
	SB.original = target
	SB.target = target
	SB.current = starting
	SB.starting = starting
	SB.secondary_target = second_target
	SB.yo = target.y - starting.y
	SB.xo = target.x - starting.x
	SB.shade = shade
	SB.blade = src
	src.forceMove(SB)
	SB.OnFired()
	SB.process()

/obj/item/weapon/melee/soulblade/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(40)
		if (3)
			takeDamage(20)

/obj/item/weapon/melee/soulblade/proc/takeDamage(var/damage)
	if (!damage)
		return
	health -= damage
	if (shade && shade.hud_used)
		shade.regular_hud_updates()
	if (health <= 0)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		qdel(src)
	else
		playsound(loc, 'sound/items/trayhit1.ogg', 70, 1)

/obj/item/weapon/melee/soulblade/Cross(var/atom/movable/mover, var/turf/target, var/height=1.5, var/air_group = 0)
	if(istype(mover, /obj/item/projectile))
		if (prob(60))
			return 0
	return ..()

/obj/item/weapon/melee/soulblade/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/talisman) || istype(I,/obj/item/weapon/paper))
		I.ashify_item(user)
		return 1
	user.delayNextAttack(8)
	if (user.is_pacified(VIOLENCE_DEFAULT,src))
		return
	if(I.force)
		var/damage = I.force
		if (I.damtype == HALLOSS)
			damage = 0
		takeDamage(damage)
		user.visible_message("<span class='danger'>\The [src] has been attacked with \the [I] by \the [user]. </span>")

/obj/item/weapon/melee/soulblade/hitby(var/atom/movable/AM)
	. = ..()
	if(.)
		return

	visible_message("<span class='warning'>\The [src] was hit by \the [AM].</span>", 1)
	if (isobj(AM))
		var/obj/O = AM
		takeDamage(O.throwforce)

/obj/item/weapon/melee/soulblade/bullet_act(var/obj/item/projectile/P)
	..()
	takeDamage(P.damage)

///////////////////////////////////////BLOOD DAGGER////////////////////////////////////////////////

/obj/item/weapon/melee/blood_dagger
	name = "blood dagger"
	icon = 'icons/obj/cult.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "blood_dagger"
	item_state = "blood_dagger"
	desc = "A knife-shaped hunk of solidified blood."
	siemens_coefficient = 0.2
	sharpness = 1.5
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	force = 15.0
	w_class = W_CLASS_GIANT//don't want it stored anywhere
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/mob/originator = null
	var/stacks = 0
	var/absorbed = 0

/obj/item/weapon/melee/blood_dagger/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/forge_over.ogg', 100, 0, -2)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.basecolor = color
			S.update_icon()
	..()

/obj/item/weapon/melee/blood_dagger/dropped(var/mob/user)
	..()
	qdel(src)

/obj/item/weapon/melee/blood_dagger/attack(var/mob/living/target, var/mob/living/carbon/human/user)
	if(target == user)
		if (stacks < 5 && user.take_blood(null,5))
			stacks++
			playsound(user, 'sound/weapons/bladeslice.ogg', 30, 0, -2)
			to_chat(user, "<span class='warning'>\The [src] takes a bit of your blood.</span>")
		return
	..()
/obj/item/weapon/melee/blood_dagger/attack_hand(var/mob/living/user)
	if(!ismob(loc))
		qdel(src)
		return
	..()

/obj/item/weapon/melee/blood_dagger/attack_self(var/mob/user)
	if (ishuman(user) && iscultist(user))
		var/mob/living/carbon/human/H = user
		var/datum/reagent/blood/B = get_blood(H.vessel)
		if (B && !(H.species.flags & NO_BLOOD))
			to_chat(user, "<span class='notice'>You sheath \the [src] back inside your body[stacks ? ", along with the stolen blood" : ""].</span>")
			H.vessel.add_reagent(BLOOD, 5 + stacks * 5)
			H.vessel.update_total()
		else
			to_chat(user, "<span class='notice'>You sheath \the [src] inside your body, but the blood fails to find vessels to occupy.</span>")
		absorbed = 1
		playsound(H, 'sound/weapons/bloodyslice.ogg', 30, 0, -2)
		qdel(src)

/obj/item/weapon/melee/blood_dagger/pre_throw()
	absorbed = 1

/obj/item/weapon/melee/blood_dagger/throw_at(var/atom/targ, var/range, var/speed, var/override = 1, var/fly_speed = 0)
	var/turf/starting = get_turf(src)
	var/turf/target = get_turf(targ)
	var/obj/item/projectile/blooddagger/BD = new (starting)
	BD.original = target
	BD.target = target
	BD.current = starting
	BD.starting = starting
	BD.yo = target.y - starting.y
	BD.xo = target.x - starting.x
	BD.stacks = stacks
	BD.damage = 5 + stacks * 5
	BD.icon_state = icon_state
	BD.color = color
	BD.firer = originator
	BD.OnFired()
	BD.process()
	qdel(src)

/obj/item/weapon/melee/blood_dagger/on_attack(var/atom/attacked, var/mob/user)
	..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			var/datum/reagent/B = C.take_blood(null,5)
			if (B)
				if (stacks < 5)
					stacks++
					to_chat(user, "<span class='warning'>\The [src] steals a bit of their blood.</span>")
				else if (!locate(/obj/effect/decal/cleanable/blood/splatter) in get_turf(C))
					blood_splatter(C,B,1)//no room in the dagger? let's splatter their stolen blood on the floor.

///////////////////////////////////////SOULSTONE////////////////////////////////////////////////
/obj/item/device/soulstone/gem
	name = "Soul Gem"
	desc = "A freshly cut stone which appears to hold the same soul catching properties as shards of the Soul Stone. This one however is cut to perfection."
	icon = 'icons/obj/cult.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shards.dmi', "right_hand" = 'icons/mob/in-hand/right/shards.dmi')

/obj/item/device/soulstone/gem/throw_impact(var/atom/hit_atom, var/speed, var/mob/user)
	..()
	var/obj/item/device/soulstone/S = new(loc)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(S)
		S.icon_state = "soulstone2"
		S.item_state = "shard-soulstone2"
	playsound(S, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	qdel(src)

///////////////////////////////////////CULT HOOD////////////////////////////////////////////////

/obj/item/clothing/head/culthood
	name = "cult hood"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags = FPRINT|HIDEHAIRCOMPLETELY
	armor = list(melee = 30, bullet = 10, laser = 10,energy = 5, bomb = 10, bio = 25, rad = 0)
	body_parts_covered = EARS|HEAD
	siemens_coefficient = 0
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/culthood/get_cult_power()
	return 20

/obj/item/clothing/head/culthood/cultify()
	return

///////////////////////////////////////CULT SHOES////////////////////////////////////////////////

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "cult"
	item_state = "cult"
	_color = "cult"
	siemens_coefficient = 0.7
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/cult/get_cult_power()
	return 10

/obj/item/clothing/shoes/cult/cultify()
	return

///////////////////////////////////////CULT ROBES////////////////////////////////////////////////

/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags = FPRINT
	allowed = list(/obj/item/weapon/melee/cultblade,/obj/item/weapon/melee/soulblade,/obj/item/weapon/tome,/obj/item/weapon/talisman,/obj/item/weapon/blood_tesseract)
	armor = list(melee = 50, bullet = 30, laser = 30,energy = 20, bomb = 25, bio = 25, rad = 0)
	siemens_coefficient = 0
	species_fit = list(VOX_SHAPED)
	clothing_flags = ONESIZEFITSALL

/obj/item/clothing/suit/cultrobes/get_cult_power()
	return 50

/obj/item/clothing/suit/cultrobes/cultify()
	return

///////////////////////////////////////CULT BACKPACK (TROPHY RACK)////////////////////////////////////////////////

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity. It has room on it for trophies of macabre descript."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "cultpack_0skull"
	item_state = "cultpack"
	var/skulls = 0

/obj/item/weapon/storage/backpack/cultpack/attack_self(var/mob/user)
	..()
	for(var/i = 1 to skulls)
		new/obj/item/weapon/skull(get_turf(src))
	update_icon(user)

/obj/item/weapon/storage/backpack/cultpack/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/weapon/skull) && (skulls < 3))
		user.u_equip(W,1)
		qdel(W)
		skulls++
		update_icon(user)
		to_chat(user,"<span class='warning'>You plant \the [W] on \the [src].</span>")
		return
	. = ..()

/obj/item/weapon/storage/backpack/cultpack/update_icon(var/mob/living/carbon/user)
	icon_state = "cultpack_[skulls]skull"
	item_state = "cultpack"
	if(istype(user))
		user.update_inv_back()

/obj/item/weapon/storage/backpack/cultpack/get_cult_power()
	return 30

/obj/item/weapon/storage/backpack/cultpack/cultify()
	return


///////////////////////////////////////CULT HELMET////////////////////////////////////////////////


/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "culthelmet"
	item_state = "culthelmet"
	armor = list(melee = 60, bullet = 50, laser = 50,energy = 15, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0
	species_fit = list(VOX_SHAPED, UNDEAD_SHAPED)
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE


/obj/item/clothing/head/helmet/space/cult/get_cult_power()
	return 30

/obj/item/clothing/head/helmet/space/cult/cultify()
	return

///////////////////////////////////////CULT ARMOR////////////////////////////////////////////////

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	desc = "A bulky suit of armor bristling with spikes. It looks space proof."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "cultarmor"
	item_state = "cultarmor"
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/melee/soulblade,/obj/item/weapon/tank,/obj/item/weapon/tome,/obj/item/weapon/talisman,/obj/item/weapon/blood_tesseract)
	slowdown = HARDSUIT_SLOWDOWN_MED
	armor = list(melee = 60, bullet = 50, laser = 50,energy = 15, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0
	species_fit = list(VOX_SHAPED, UNDEAD_SHAPED)
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN|ONESIZEFITSALL
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/cult/get_cult_power()
	return 60

/obj/item/clothing/suit/space/cult/cultify()
	return



///////////////////////////////////////I'LL HAVE TO DEAL WITH THIS STUFF LATER////////////////////////////////////////////////

/obj/item/clothing/head/culthood/old
	icon_state = "culthood_old"
	item_state = "culthood_old"
	species_fit = list()

/obj/item/clothing/suit/cultrobes/old
	icon_state = "cultrobes_old"
	item_state = "cultrobes_old"
	species_fit = list()

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm."
	flags = FPRINT
	body_parts_covered = FULL_HEAD|BEARD
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes."
	icon_state = "magusred"
	item_state = "magusred"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	siemens_coefficient = 0

	
///////////////////////////////////////DEBUG ITEMS////////////////////////////////////////////////
//Pamphlet: turns you into a cultist
/obj/item/weapon/bloodcult_pamphlet
	name = "cult of Nar-Sie pamphlet"
	desc = "Looks like a page torn from one of those cultist tomes. It is titled \"Ten reasons why Nar-Sie can improve your life!\""
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

/obj/item/weapon/bloodcult_pamphlet/attack_self(var/mob/user)
	var/datum/role/cultist/newCultist = new
	newCultist.AssignToRole(user.mind,1)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
		cult.OnPostSetup()
	cult.HandleRecruitedRole(newCultist)
	newCultist.OnPostSetup()
	newCultist.Greet(GREET_PAMPHLET)

//Jaunter: creates a pylon on spawn, lets you teleport to it on use
/obj/item/weapon/bloodcult_jaunter
	name = "test jaunter"
	desc = ""
	icon = 'icons/obj/wizard.dmi'
	icon_state ="soulstone"
	var/obj/structure/bloodcult_jaunt_target/target = null

/obj/item/weapon/bloodcult_jaunter/New()
	..()
	target = new(loc)

/obj/item/weapon/bloodcult_jaunter/attack_self(var/mob/user)
	new /obj/effect/bloodcult_jaunt(get_turf(src),user,get_turf(target))

/obj/structure/bloodcult_jaunt_target
	name = "test target"
	desc = ""
	icon = 'icons/obj/cult.dmi'
	icon_state ="pylon"
	anchored = 1
	density = 0

///////////////////////////////////////CULT BOX////////////////////////////////////////////////

/obj/item/weapon/storage/cult
	name = "coffer"
	desc = "A gloomy-looking storage chest"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "cult"
	item_state = "syringe_kit"
	starting_materials = list(MAT_IRON = 3750)
	w_type=RECYK_METAL

///////////////////////////////////////CULT GLASS////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/cult
	name = "tempting goblet"
	desc = "An obsidian cup in the shape of a skull. Used by the followers of Nar-Sie to collect the blood of their sacrifices."
	icon_state = "cult"
	item_state = "cult"
	isGlass = 0
	amount_per_transfer_from_this = 10
	volume = 60
	force = 5
	throwforce = 7
	
/obj/item/weapon/reagent_containers/food/drinks/cult/examine(var/mob/user)
	..()
	if (iscultist(user))
		if(issilicon(user))
			to_chat(user, "<span class='info'>Drinking blood from this cup will always safely replenish the vessels of cultists, regardless of blood type. It's a shame you're a robot.</span>")
		else
			to_chat(user, "<span class='info'>Drinking blood from this cup will always safely replenish your own vessels, regardless of blood types. The opposite is true to non-cultists. Throwing this cup at them may force them to swallow some of its content if their face isn't covered.</span>")
	else if (get_blood(reagents))
		to_chat(user, "<span class='sinister'>Its contents look delicious though. Surely a sip won't hurt...</span>")

/obj/item/weapon/reagent_containers/food/drinks/cult/on_reagent_change()
	..()
	overlays.len = 0
	if (reagents.reagent_list.len > 0)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "cult")
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/food/drinks/cult/throw_impact(var/atom/hit_atom)
	if(reagents.total_volume)
		if (ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(!(H.species.chem_flags & NO_DRINK) && !(H.get_body_part_coverage(MOUTH)))
				H.visible_message("<span class='warning'>Some of \the [src]'s content spills into \the [H]'s mouth.</span>","<span class='danger'>Some of \the [src]'s content spills into your mouth.</span>")
				reagents.reaction(H, INGEST)
				reagents.trans_to(H, gulp_size)
	transfer(get_turf(hit_atom), null, splashable_units = -1)

///////////////////////////////////////BLOOD TESSERACT////////////////////////////////////////////////

/obj/item/weapon/blood_tesseract
	name = "blood tesseract"
	desc = "A small totem. Cultists use them as anchors from the other side of the veil to quickly swap gear."
	gender = NEUTER
	icon = 'icons/obj/cult.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/cultstuff.dmi', "right_hand" = 'icons/mob/in-hand/right/cultstuff.dmi')
	icon_state = "tesseract"
	item_state = "tesseract"
	throwforce = 2
	w_class = W_CLASS_TINY
	layer = ABOVE_DOOR_LAYER

	var/discarded_types = list(
		/obj/item/clothing/head/culthood,
		/obj/item/clothing/shoes/cult,
		/obj/item/clothing/suit/cultrobes,
		)

	var/list/stored_gear = list()

	var/obj/item/weapon/talisman/remaining = null

/obj/item/weapon/blood_tesseract/Destroy()
	if (loc)
		var/turf/T = get_turf(src)
		for(var/slot in stored_gear)
			var/obj/item/I = stored_gear[slot]
			stored_gear.Remove(I)
			I.forceMove(T)
	if (remaining)
		qdel(remaining)
		remaining = null
	..()

/obj/item/weapon/blood_tesseract/throw_impact(atom/hit_atom)
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "tesseract_break", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
	qdel(src)

/obj/item/weapon/blood_tesseract/examine(var/mob/user)
	..()
	if (iscultist(user))
		to_chat(user, "<span class='info'>Press it in your hands to discard currently equiped cult clothing and re-equip your stored items.</span>")

/obj/item/weapon/blood_tesseract/attack_self(var/mob/living/user)
	if (iscultist(user))
		//Alright so we'll discard cult gear and equip the stuff stored inside.
		anim(target = user, a_icon = 'icons/effects/64x64.dmi', flick_anim = "rune_tesseract", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = LIGHTING_PLANE)
		user.u_equip(src)
		if (remaining)
			remaining.forceMove(get_turf(user))
			user.put_in_hands(remaining)
			remaining = null

		for(var/obj/item/I in user)
			if (is_type_in_list(I, discarded_types))
				user.u_equip(I)
				qdel(I)

		for(var/slot in stored_gear)
			var/nslot = text2num(slot)
			var/obj/item/stored_slot = stored_gear[slot]
			var/obj/item/user_slot = user.get_item_by_slot(nslot)
			if (!user_slot)
				user.equip_to_slot_or_drop(stored_slot,nslot)
			else
				if(istype(user_slot, /obj/item/weapon/storage))
					var/obj/item/weapon/storage/S = user_slot
					S.close(user)
				if (istype(user_slot,/obj/item/weapon/storage/backpack/cultpack))
					if (istype(stored_slot,/obj/item/weapon/storage/backpack))
						//swapping backpacks
						for(var/obj/item/I in user_slot)
							I.forceMove(stored_slot)
						user.u_equip(user_slot)
						qdel(user_slot)
						user.equip_to_slot_or_drop(stored_slot,nslot)
					else
						//free backpack
						var/obj/item/weapon/storage/backpack/B = new(user)
						for(var/obj/item/I in user_slot)
							I.forceMove(B)
						user.u_equip(user_slot)
						qdel(user_slot)
						user.equip_to_slot_or_drop(B,nslot)
						user.put_in_hands(stored_slot)
				else
					user.equip_to_slot_or_drop(stored_slot,nslot)
			stored_gear.Remove(slot)
		qdel(src)
