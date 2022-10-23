/datum/component/cooktop

/datum/component/cooktop/initialize()
	if(!isobj(parent))
		return FALSE
	parent.register_event(/event/attackhand, src, .proc/on_attackhand)
	parent.register_event(/event/attackby, src, .proc/on_attackby)
	parent.register_event(/event/examined, src, .proc/on_examine)
	return TRUE

/datum/component/cooktop/Destroy()
	parent.unregister_event(/event/attackhand, src, .proc/on_attackhand)
	parent.unregister_event(/event/attackby, src, .proc/on_attackby)
	parent.unregister_event(/event/examined, src, .proc/on_examine)
	..()

/datum/component/cooktop/proc/on_attackhand(mob/user, atom/target)
	var/obj/P = parent
	message_admins("DEBUG COOKTOP on_attackhand [P] | [P.cookingvessel] | [user] | [target]")
	if(P.cookingvessel)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.put_in_active_hand(P.cookingvessel)
			P.cookingvessel.cook_stop()
			P.cookingvessel = null
			P.on_cook_stop()
			P.render_cookvessel()

/datum/component/cooktop/proc/on_attackby(mob/attacker, obj/item/item)
	var/obj/P = parent
	message_admins("DEBUG COOKTOP on_attackby [P] | [P.cookingvessel] | [attacker] | [item]")
	if(P.cookingvessel)
		to_chat(attacker, "<span class='notice'>\A [P.cookingvessel] is already there.</span>")
	else if(item.is_cookingvessel && P.can_receive_cookvessel())
		attacker.drop_item(item, parent)
		P.cookingvessel = item
		P.cookingvessel.cook_start()
		P.on_cook_start()
		P.render_cookvessel()

/datum/component/cooktop/proc/on_examine(mob/user)
	var/obj/P = parent
	message_admins("DEBUG COOKTOP on_examine [P] | [P.cookingvessel] | [user]")
	if(P.cookingvessel)
		var/vesseltext = "There's \a [P.cookingvessel] on it"
		if(get_dist(user, P) <= 3)
			if(P.cookingvessel.contains_anything())
				vesseltext += ", containing:<br>[P.cookingvessel.build_list_of_contents()]"
			else
				vesseltext += ", which is empty."
		to_chat(user, "<span class='notice'>[vesseltext]</span>")