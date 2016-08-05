//IDs go anti-clockwise, from bottom left

/obj/item/device/remote/four_button
	name = "four-button remote"
	icon_state = "remote_4b"

/obj/item/device/remote/four_button/New()
	..()
	controller = new/datum/context_click/remote_control/four_button(src)

/datum/context_click/remote_control/four_button
	buttons = list("4B1" = null,
					"4B2" = null,
					"4B3" = null,
					"4B4" = null)

	removable_buttons = list("4B1", "4B2", "4B3", "4B4")

/datum/context_click/remote_control/four_button/return_clicked_id(x_pos, y_pos)
	switch(y_pos)
		if(8 to 24)
			switch(x_pos)
				if(16 to 32)
					return "4B1"
				if(33 to 50)
					return "4B2"
		if(26 to 42)
			switch(x_pos)
				if(16 to 32)
					return "4B4"
				if(33 to 50)
					return "4B3"

/datum/context_click/remote_control/four_button/get_icon_type(button_id)
	return "4bq" //the q is for quad, for the square shape

/datum/context_click/remote_control/four_button/get_pixel_displacement(button_id)
	var/x_dis = 0
	var/y_dis = 0
	switch(button_id)
		if("4B1", "4B4")
			x_dis = -10
		if("4B2", "4B3")
			x_dis = 8

	switch(button_id)
		if("4B1", "4B2")
			y_dis = -18

	return list("pixel_x" = x_dis, "pixel_y" = y_dis)