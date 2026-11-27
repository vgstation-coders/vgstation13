// Admin verb for the WIP behavior tree port: render a mob's tree on demand.

/client/proc/view_behavior_tree()
	set name = "View Behavior Tree"
	set category = "Debug"
	set desc = "Renders a mob's behavior tree with live node status."

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/target = src.mob
	if(!target || !target.ai_controller)
		target = input(src.mob, "Choose a mob with an AI controller", "View Behavior Tree") as null|mob in view(src.mob)
	if(!target || !target.ai_controller)
		to_chat(src, "<span class='warning'>That mob has no behavior tree controller.</span>")
		return

	var/datum/bt_viewer/viewer = new(target.ai_controller)
	var/html = viewer.get_html()
	qdel(viewer)
	usr << browse(HTML_SKELETON(html), "window=bt_viewer;size=900x600")
