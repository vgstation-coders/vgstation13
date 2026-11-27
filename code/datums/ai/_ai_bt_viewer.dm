// Behavior tree viewer for the WIP behavior tree port.
//
// Renders a controller's trees as indented text/HTML with live node markers. It
// reads the node state on demand (no per-tick logging): "*" means the leaf is
// running, "o" means idle, and ">" marks the active execution index.

/datum/bt_viewer
	var/datum/ai_controller/controller
	/// Plain text lines accumulated by render().
	var/list/lines = null
	/// HTML fragments accumulated by append_line().
	var/list/html_parts = null

/datum/bt_viewer/New(datum/ai_controller/new_controller)
	controller = new_controller
	return ..()

/// Renders the controller summary and every tree root into lines/html_parts.
/datum/bt_viewer/proc/render()
	lines = list()
	html_parts = list()
	if(!controller)
		append_line("No AI controller.")
		return

	var/mob/living/pawn = controller.pawn
	append_line("Controller: [controller.type]")
	append_line("Pawn: [pawn ? "[pawn] ([pawn.type])" : "none"]")
	append_line("Status: [controller.ai_status]   Movement: [controller.ai_movement ? controller.ai_movement.type : "none"]")
	append_line("Active index: [controller.active_execution_index]   Polling observers: [controller.polling_observers ? length(controller.polling_observers) : 0]")
	append_blackboard()
	append_line("")

	if(!controller.behavior_nodes || !length(controller.behavior_nodes))
		append_line("(no behavior tree built)")
		return
	for(var/datum/bt_node/root in controller.behavior_nodes)
		append_node(root, 0)

/// Appends one line to both renderings.
/datum/bt_viewer/proc/append_line(text)
	lines += text
	html_parts += "<div style='white-space: pre; font-family: Consolas, monospace;'>[html_encode(text)]</div>"

/// Appends the blackboard keys/values so target and pawn keys are visible.
/datum/bt_viewer/proc/append_blackboard()
	if(!controller.blackboard || !length(controller.blackboard))
		return
	append_line("Blackboard:")
	for(var/key in controller.blackboard)
		append_line("  [key] = [controller.blackboard[key]]")

/// Appends a node with its status marker and recurses into its children.
/datum/bt_viewer/proc/append_node(datum/bt_node/node, depth)
	var/indent = ""
	for(var/i in 1 to depth)
		indent += "  "
	var/active = controller && node.execution_index == controller.active_execution_index
	append_line("[indent][active ? ">" : " "][node.get_status_marker()] [node.type]#[node.execution_index][describe_node(node)]")
	var/list/children = node.get_children()
	if(children)
		for(var/datum/bt_node/child in children)
			append_node(child, depth + 1)

/// Adds a short summary of the interesting per-node config.
/datum/bt_viewer/proc/describe_node(datum/bt_node/node)
	if(istype(node, /datum/bt_node/decorator/pawn_health_below))
		var/datum/bt_node/decorator/pawn_health_below/health = node
		return " (health < [health.threshold])"
	if(istype(node, /datum/bt_node/ai_behavior/flee_target))
		var/datum/bt_node/ai_behavior/flee_target/flee = node
		return " (distance [flee.flee_distance], hold [flee.hold_while_target_alive])"
	if(istype(node, /datum/bt_node/ai_behavior/use_ability))
		var/datum/bt_node/ai_behavior/use_ability/ability = node
		return " (ability [ability.ability_type], [ability.min_distance]-[ability.max_distance])"
	if(istype(node, /datum/bt_node/ai_behavior/wander))
		var/datum/bt_node/ai_behavior/wander/wander = node
		return " (chance [wander.move_chance]%, cooldown [wander.cooldown])"
	return ""

/// Returns the plain-text rendering (tests and debug logs).
/datum/bt_viewer/proc/get_text()
	if(isnull(lines))
		render()
	return lines.Join("\n")

/// Returns the HTML body for the browser window.
/datum/bt_viewer/proc/get_html()
	if(isnull(lines))
		render()
	return html_parts.Join("")
