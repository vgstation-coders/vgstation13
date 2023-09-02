/datum/component/cooktop

/datum/component/cooktop/initialize()
	if(!isobj(parent))
		return FALSE
	parent.register_event(/event/attackhand, src, nameof(src::on_attackhand()))
	parent.register_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.register_event(/event/examined, src, nameof(src::on_examine()))
	return TRUE

/datum/component/cooktop/Destroy()
	parent.unregister_event(/event/attackhand, src, nameof(src::on_attackhand()))
	parent.unregister_event(/event/attackby, src, nameof(src::on_attackby()))
	parent.unregister_event(/event/examined, src, nameof(src::on_examine()))
	..()

/datum/component/cooktop/proc/on_attackhand(mob/user, atom/target)
	var/obj/P = parent
	if(P.cookvessel && ismob(user))
		if(user.put_in_active_hand(P.cookvessel))
			P.cookvessel.cook_stop()
			P.cookvessel = null
			P.on_cook_stop()
			P.render_cookvessel()

/datum/component/cooktop/proc/on_attackby(mob/attacker, obj/item/item)
	var/obj/P = parent
	if(P.cookvessel)
		to_chat(attacker, "<span class='notice'>\A [P.cookvessel] is already there.</span>")
	else if(item.is_cookvessel && P.can_receive_cookvessel())
		attacker.drop_item(item, parent)
		P.cookvessel = item
		P.cookvessel.cook_start()
		P.on_cook_start()
		P.render_cookvessel()

/datum/component/cooktop/proc/on_examine(mob/user)
	var/obj/P = parent
	if(P.cookvessel)
		var/vesseltext = "There's \a [P.cookvessel] on it"
		if(get_dist(user, P) <= 3)
			if(P.cookvessel.contains_anything())
				vesseltext += ", containing:<br>[P.cookvessel.build_list_of_contents()]"
			else
				vesseltext += ", which is empty."
		else
			vesseltext += "."
		to_chat(user, "<span class='notice'>[vesseltext]</span>")
