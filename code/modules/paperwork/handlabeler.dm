/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "labeler0"
	origin_tech = Tc_MATERIALS + "=1"
	var/label = null
	var/chars_left = 250 //Like in an actual label maker, uses an amount per character rather than per label.
	var/mode = 0	//off or on.

/obj/item/weapon/hand_labeler/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return

	if(!mode)	//if it's off, give up.
		return
	if(target == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!chars_left)
		to_chat(user, "<span class='notice'>Out of label.</span>")
		return

	if(!label || !length(label))
		to_chat(user, "<span class='notice'>No text set.</span>")
		return

	if(length(target.name) + min(length(label) + 2, chars_left) > 64)
		to_chat(user, "<span class='notice'>Label too big.</span>")
		return
	if(ishuman(target))
		to_chat(user, "<span class='notice'>You can't label humans.</span>")
		return
	if(issilicon(target))
		to_chat(user, "<span class='notice'>You can't label cyborgs.</span>")
		return

	if(user.a_intent == I_HURT && target.min_harm_label)
		user.visible_message("<span class='warning'>[user] labels [target] as [label]... with malicious intent!</span>", \
							 "<span class='warning'>You label [target] as [label]... with malicious intent!</span>") //OK this is total shit but I don't want to add TOO many vars to /atom
		target.harm_labeled = min(length(label) + 2, chars_left)
		target.harm_label_update()
	else
		user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
							 "<span class='notice'>You label [target] as [label].</span>")

	target.set_labeled(label)

	chars_left = max(chars_left - (length(label) + 2),0)

	if(!chars_left)
		to_chat(user, "<span class='notice'>The labeler is empty.</span>")
		mode = 0
		icon_state = "labeler_e"
		return
	if(chars_left < length(label) + 2)
		to_chat(user, "<span class='notice'>The labeler is almost empty.</span>")
		label = copytext(label,1,min(chars_left, length(label) + 1))

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	if(!chars_left)
		to_chat(user, "<span class='notice'>It's empty.</span>")
		return
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,min(MAX_NAME_LEN,chars_left))
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")

/obj/item/weapon/hand_labeler/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/label_roll))
		if(mode)
			to_chat(user, "<span class='notice'>Turn it off first.</span>")
			return
		var/obj/item/device/label_roll/LR = O
		var/holder = chars_left //I hate having to do this.
		chars_left = LR.left
		if(holder)
			LR.left = holder
			to_chat(user, "<span class='notice'>You switch the label rolls.</span>")
		else
			qdel(LR)
			LR = null
			to_chat(user, "<span class='notice'>You replace the label roll.</span>")
			icon_state = "labeler0"

/obj/item/weapon/hand_labeler/attack_hand(mob/user) //Shamelessly stolen from stack.dm.
	if (!mode && user.get_inactive_hand() == src)
		var/obj/item/device/label_roll/LR = new(user, amount=chars_left)
		user.put_in_hands(LR)
		to_chat(user, "<span class='notice'>You remove the label roll.</span>")
		chars_left = 0
		icon_state = "labeler_e"
	else
		..()

/obj/item/weapon/hand_labeler/examine(mob/user) //Shamelessly stolen from the paper bin.
	..()
	if(chars_left)
		to_chat(user, "<span class='info'>There " + (chars_left > 1 ? "are [chars_left] letters" : "is one letter") + " worth of label on the roll.</span>")
	else
		to_chat(user, "<span class='info'>The label roll is all used up.</span>")

/obj/item/device/label_roll
	name = "label roll"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "label_cart" //Placeholder image; recolored police tape
	w_class = W_CLASS_TINY
	var/left = 250

/obj/item/device/label_roll/New(var/loc, var/amount=null)
	..()
	if(amount)
		left = amount

/obj/item/device/label_roll/examine(mob/user) //Shamelessly stolen from above.
	..()
	if(left)
		to_chat(user, "<span class='info'>There " + (left > 1 ? "are [left] letters" : "is one letter") + " worth of label on the roll.</span>")
	else
		to_chat(user, "<span class='warning'>Something has fucked up and this item should have deleted itself. Throw it away for IMMERSION.</span>")

/*
 * ATOM PROCS
 */

/atom/proc/set_labeled(var/label, var/start_text = " (", var/end_text = ")")
	if(labeled)
		remove_label()
	labeled = "[start_text][label][end_text]"
	name = "[name][labeled]"
	new/atom/proc/remove_label_verb(src)

/atom/proc/remove_label_verb()
	set name = "Remove label"
	set src in view(1)
	set category = "Object"
	if(usr.incapacitated())
		return
	remove_label()
	to_chat(usr, "<span class='notice'>You remove the label.</span>")

/atom/proc/remove_label()
	name = replacetext(name, labeled, "")
	labeled = null
	if(harm_labeled)
		harm_labeled = 0
		harm_label_update()
	verbs -= /atom/proc/remove_label_verb

/atom/proc/harm_label_update()
	return //To be assigned (or not, in most cases) on a per-item basis.

// Not really sure where to put this. This is a verb that lets you add a tiny label to the item without consuming label rolls or anything.
// Used for pen-labeling pill bottles, beakers and whatnot.
/atom/proc/set_tiny_label(var/mob/user, var/start_text = " (", var/end_text = ")")
	var/tmp_label = sanitize(input(user, "Enter a label for \the [src]","Label",copytext(labeled, length(start_text), length(labeled)-length(end_text))) as text|null)
	if (!Adjacent(user) || user.incapacitated() || !tmp_label || !length(tmp_label))
		return FALSE
	if(length(tmp_label) > 16)
		to_chat(user, "<span class='warning'>The label can be at most 16 characters long.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
	set_labeled(tmp_label, start_text, end_text)
	return TRUE
