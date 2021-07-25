
/datum/mind_ui/adminbus
	uniqueID = "Adminbus"
	sub_uis_to_spawn = list(
		/datum/mind_ui/adminbus_top_panel,
		/datum/mind_ui/adminbus_left_panel,
		/datum/mind_ui/adminbus_bottom_panel,
		)


/datum/mind_ui/adminbus_top_panel
	uniqueID = "Adminbus Top Panel"
	y = "TOP"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/top_panel,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		)

/datum/mind_ui/adminbus_left_panel
	uniqueID = "Adminbus Left Panel"
	x = "LEFT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/left_panel,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		)

/datum/mind_ui/adminbus_bottom_panel
	uniqueID = "Adminbus Bottom Panel"
	y = "BOTTOM"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bottom_panel,
		/obj/abstract/mind_ui_element/hoverable/test_close,
		/obj/abstract/mind_ui_element/hoverable/test_hello,
		)

