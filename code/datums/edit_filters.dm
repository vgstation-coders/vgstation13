
	//		https://www.byond.com/docs/ref/info.html#/{notes}/filters

/proc/get_next_filter_entry_name(var/atom/A, var/filter_type)
	var/entry_name = "[filter_type]_0"
	var/entry_count = 0
	for (var/filter_entry in A.filters)
		var/F_name = filter_entry:name//I don't think we can typecast filters but F:name works properly here.
		if (F_name == entry_name)
			entry_count++
			entry_name = "[filter_type]_[entry_count]"

	return entry_name


/client/proc/add_filter(var/atom/A)
	var/filter_setups = list(
		"Alpha Mask" = "alpha",
		"Angular Blur" = "angular_blur",
		"Bloom" = "bloom",
		"Gaussian Blur" = "blur",
		"Color Matrix" = "color",
		"Displacement Map" = "displace",
		"Drop Shadow" = "drop_shadow",
		"Layering (composite)" = "layer",
		"Motion Blur" = "motion_blur",
		"Outline" = "outline",
		"Radial Blur" = "radial_blur",
		"Rays" = "rays",
		"Ripple" = "ripple",
		"Wave" = "wave",
		)

	var/filter_name = input(usr, "Select a new filter", "New Filter Effect", null) as null|anything in filter_setups

	if (!filter_name)
		return

	var/filter = filter_setups[filter_name]

	switch(filter)
		////////////////////////////////////////////////////////////////////
		//																  //
//////////							ALPHA MASK							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("alpha")
			var/mask_icon = null
			var/mask_target = null

			var/mask_x = input(usr, "Choose the horizontal offset of the mask", "New Filter Effect (Alpha Mask)", 0) as null|num
			if (mask_x == null)
				return

			var/mask_y = input(usr, "Choose the vertical offset of the mask", "New Filter Effect (Alpha Mask)", 0) as null|num
			if (mask_y == null)
				return

			var/choice = alert("Use icon or render_target as mask?", "New Filter Effect (Alpha Mask)", "icon", "render_target")
			if (choice == "icon")
				mask_icon = input(usr, "Choose the icon to use as a mask", "New Filter Effect (Alpha Mask)", null) as null|icon
				if (mask_icon == null)
					return
			else
				mask_target = input(usr, "Choose the render_target to use as a mask", "New Filter Effect (Alpha Mask)", "") as null|text
				if (mask_target == null)
					return

			var/available_mask_flags = list(
				"MASK_INVERSE" = MASK_INVERSE,
				"MASK_SWAP" = MASK_SWAP,
				"MASK_SWAP | MASK_INVERSE" = (MASK_SWAP | MASK_INVERSE),
				"none (default)" = 0
				)

			var/mask_flag = input(usr, "Choose any flags to add or none", "New Filter Effect (Alpha Mask)", "none (default)") as null|anything in available_mask_flags
			if (mask_flag == null)
				return

			var/added_flag = available_mask_flags[mask_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			if (choice == "icon")
				A.filters += filter(type="alpha", name=entry_name, x=mask_x, y=mask_y, icon=mask_icon, flags=added_flag)
			else
				A.filters += filter(type="alpha", name=entry_name, x=mask_x, y=mask_y, render_source=mask_target, flags=added_flag)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							ANGULAR BLUR						  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("angular_blur")
			var/blur_x = input(usr, "Choose the horizontal center of effect, in pixels, relative to image center", "New Filter Effect (Angular Blur)", 0) as null|num
			if (blur_x == null)
				return

			var/blur_y = input(usr, "Choose the vertical center of effect, in pixels, relative to image center", "New Filter Effect (Angular Blur)", 0) as null|num
			if (blur_y == null)
				return

			var/blur_size = input(usr, "Choose the amount of blur", "New Filter Effect (Angular Blur)", 1) as null|num
			if (blur_size == null)
				return

			var/blur_offset = input(usr, "Choose the pixel radius before blurring occurs ", "New Filter Effect (Angular Blur)", 0) as null|num
			if (blur_offset == null)
				return

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="angular_blur", name=entry_name, x=blur_x, y=blur_y, size=blur_size, offset=blur_offset)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							  BLOOM								  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("bloom")
			var/bloom_threshold = input(usr, "Choose the color threshold for bloom", "New Filter Effect (Bloom)", null) as null|color
			if (bloom_threshold == null)
				return

			var/bloom_size = input(usr, "Choose the blur radius of bloom effect (please avoid going above 6!)", "New Filter Effect (Bloom)", 1) as null|num
			if (bloom_size == null)
				return

			var/bloom_offset = input(usr, "Choose the growth/outline radius of bloom effect before blur", "New Filter Effect (Bloom)", 0) as null|num
			if (bloom_size == null)
				return

			var/bloom_alpha = input(usr, "Choose the opacity of effect", "New Filter Effect (Bloom)", 255) as null|num
			if (bloom_size == null)
				return

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="bloom", name=entry_name, threshold=bloom_threshold, size=bloom_size, offset=bloom_offset, alpha=bloom_alpha)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							GAUSSIAN BLUR						  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("blur")
			var/blur_size = input(usr, "Choose the amount of blur (please avoid going above 6!)", "New Filter Effect (Gaussian Blur)", null) as null|num
			if (blur_size == null)
				return
			//hopefully I won't have to add extra failsafes to deal with badmins setting blur size to 99999 or something like that

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="blur", name=entry_name, size=blur_size)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							COLOR MATRIX							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("color")
			var/color_matrix = get_color_matrix()

			var/available_color_spaces = list(
				"FILTER_COLOR_RGB (default)" = FILTER_COLOR_RGB,
				"FILTER_COLOR_HSV" = FILTER_COLOR_HSV,
				"FILTER_COLOR_HSL" = FILTER_COLOR_HSL,
				"FILTER_COLOR_HCY" = FILTER_COLOR_HCY,
				)

			var/color_space = input(usr, "Choose the color space", "New Filter Effect (Color Matrix)", null) as null|anything in available_color_spaces
			if (color_space == null)
				return

			var/color_filter = available_color_spaces[color_space]

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="color", name=entry_name, color=color_matrix, space=color_filter)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							DISPLACEMENT MAP					  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("displace")
			var/displace_icon = null
			var/displace_target = null

			var/displace_x = input(usr, "Choose the horizontal offset of the map", "New Filter Effect (Displacement Map)", 0) as null|num
			if (displace_x == null)
				return

			var/displace_y = input(usr, "Choose the vertical offset of the map", "New Filter Effect (Displacement Map)", 0) as null|num
			if (displace_y == null)
				return

			var/displace_size = input(usr, "Choose the maximum distortion, in pixels ", "New Filter Effect (Displacement Map)", 0) as null|num
			if (displace_size == null)
				return

			var/choice = alert("Use icon or render_target as displacement map?", "New Filter Effect (Displacement Map)", "icon", "render_target")
			if (choice == "icon")
				displace_icon = input(usr, "Choose the icon to use as a displacement map", "New Filter Effect (Displacement Map)", null) as null|icon
				if (displace_icon == null)
					return
			else
				displace_target = input(usr, "Choose the render_target to use as a displacement map", "New Filter Effect (Displacement Map)", "") as null|text
				if (displace_target == null)
					return


			var/available_map_flags = list(
				"FILTER_OVERLAY" = FILTER_OVERLAY,
				"none (default)" = 0
				)

			var/mask_flag = input(usr, "Choose any flags to add or none", "New Filter Effect (Displacement Map)", "none (default)") as null|anything in available_map_flags
			if (mask_flag == null)
				return

			var/added_flag = available_map_flags[mask_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			if (choice == "icon")
				A.filters += filter(type="displace", name=entry_name, x=displace_x, y=displace_y, size=displace_size, icon=displace_icon, flags=added_flag)
			else
				A.filters += filter(type="displace", name=entry_name, x=displace_x, y=displace_y, size=displace_size, render_source=displace_target, flags=added_flag)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							DROP SHADOW							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("drop_shadow")
			var/shadow_x = input(usr, "Choose the shadow's horizontal offset", "New Filter Effect (Drop Shadow)", 1) as null|num
			if (shadow_x == null)
				return

			var/shadow_y = input(usr, "Choose the shadow's vertical offset", "New Filter Effect (Drop Shadow)", -1) as null|num
			if (shadow_y == null)
				return

			var/shadow_blur = input(usr, "Choose the blur amount (negative values create inset shadows)", "New Filter Effect (Drop Shadow)", 1) as null|num
			if (shadow_blur == null)
				return

			var/shadow_offset = input(usr, "Choose the size increase before blur ", "New Filter Effect (Drop Shadow)", 0) as null|num
			if (shadow_offset == null)
				return

			var/shadow_color = input(usr, "Choose the shadow's color", "New Filter Effect (Drop Shadow)", null) as null|color
			if (shadow_color == null)
				return

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="drop_shadow", name=entry_name, x=shadow_x, y=shadow_y, size=shadow_blur, offset=shadow_offset, color=shadow_color)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							LAYERING							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("layer")
			var/layer_icon = null
			var/layer_target = null

			var/layer_x = input(usr, "Choose the horizontal offset of second image", "New Filter Effect (Layering)", 0) as null|num
			if (layer_x == null)
				return

			var/layer_y = input(usr, "Choose the vertical offset of second image", "New Filter Effect (Layering)", 0) as null|num
			if (layer_y == null)
				return

			var/choice = alert("Use icon or render_target as second image?", "New Filter Effect (Layering)", "same icon", "other icon (load file)", "render_target")
			switch(choice)
				if ("same icon")
					layer_icon = icon(A.icon, A.icon_state)
				if ("other icon (load file)")
					layer_icon = input(usr, "Choose the icon to use as a second image", "New Filter Effect (Layering)", null) as null|icon
					if (layer_icon == null)
						return
				if ("render_target")
					layer_target = input(usr, "Choose the render_target to use as a second image", "New Filter Effect (Layering)", "") as null|text
					if (layer_target == null)
						return

			var/available_map_flags = list(
				"FILTER_OVERLAY (default)" = FILTER_OVERLAY,
				"FILTER_UNDERLAY" = FILTER_UNDERLAY
				)

			var/mask_flag = input(usr, "Choose any flags to add or none", "New Filter Effect (Layering)", "FILTER_OVERLAY (default)") as null|anything in available_map_flags
			if (mask_flag == null)
				return

			var/added_flag = available_map_flags[mask_flag]

			var/color_layer = null

			var/choice_color = alert("Apply a color or color matrix to the second image?", "New Filter Effect (Layering)", "color", "color_matrix", "none")
			switch (choice_color)
				if ("color")
					color_layer = input(usr, "Choose the color to apply to the second image", "New Filter Effect (Layering)", null) as null|color
					if (color_layer == null)
						return
				if ("color_matrix")
					color_layer = get_color_matrix()

			var/transform_layer = matrix()

			if (alert(src,"Apply a transform to the second image?", "New Filter Effect (Layering)", "Yes", "No") == "Yes")

				while (transform_layer != null)
					transform_layer = modify_matrix_menu(transform_layer)
					if (transform_layer == null)
						return
					if(alert(src,"Modify matrix further?", "New Filter Effect (Layering)","Yes","No") == "No")
						break

			var/available_blend_modes = list(
				"BLEND_DEFAULT (default)" = BLEND_DEFAULT,
				"BLEND_OVERLAY" = BLEND_OVERLAY,
				"BLEND_ADD" = BLEND_ADD,
				"BLEND_SUBTRACT" = BLEND_SUBTRACT,
				"BLEND_MULTIPLY" = BLEND_MULTIPLY,
				"BLEND_INSET_OVERLAY" = BLEND_INSET_OVERLAY,
				)

			var/blend_choice = input(usr, "Choose a blend mode for the second image", "New Filter Effect (Layering)", "BLEND_DEFAULT (default)") as null|anything in available_blend_modes
			if (blend_choice == null)
				return

			var/layer_blend = available_blend_modes[blend_choice]

			var/entry_name = get_next_filter_entry_name(A, filter)

			if (choice == "render_target")
				A.filters += filter(type="layer", name=entry_name, x=layer_x, y=layer_y, render_source=layer_target, flags=added_flag, color=color_layer, transform=transform_layer, blend_mode=layer_blend)
			else
				A.filters += filter(type="layer", name=entry_name, x=layer_x, y=layer_y, icon=layer_icon, flags=added_flag, color=color_layer, transform=transform_layer, blend_mode=layer_blend)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							MOTION BLUR							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("motion_blur")
			var/motion_x = input(usr, "Choose the blur vector on the X axis", "New Filter Effect (Motion Blur)", 0) as null|num
			if (motion_x == null)
				return

			var/motion_y = input(usr, "Choose the blur vector on the Y axis", "New Filter Effect (Motion Blur)", 0) as null|num
			if (motion_y == null)
				return

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="motion_blur", name=entry_name, x=motion_x, y=motion_y)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							OUTLINE								  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("outline")
			var/outline_size = input(usr, "Choose the width in pixels", "New Filter Effect (Outline)", 1) as null|num
			if (outline_size == null)
				return

			var/outline_color = input(usr, "Choose the outline color", "New Filter Effect (Outline)", null) as null|color
			if (outline_color == null)
				return

			var/available_outline_flags = list(
				"OUTLINE_SHARP" = OUTLINE_SHARP,
				"OUTLINE_SQUARE" = OUTLINE_SQUARE,
				"none (default)" = 0
				)

			var/outline_flag = input(usr, "Choose any flags to add or none", "New Filter Effect (Outline)", "none (default)") as null|anything in available_outline_flags
			if (outline_flag == null)
				return

			var/added_flag = available_outline_flags[outline_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="outline", name=entry_name, size=outline_size , color=outline_color, flags=added_flag)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							RADIAL BLUR							  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("radial_blur")
			var/blur_x = input(usr, "Choose the horizontal center of effect, in pixels, relative to image center", "New Filter Effect (Radial Blur)", 0) as null|num
			if (blur_x == null)
				return

			var/blur_y = input(usr, "Choose the vertical center of effect, in pixels, relative to image center", "New Filter Effect (Radial Blur)", 0) as null|num
			if (blur_y == null)
				return

			var/blur_size = input(usr, "Choose the amount of blur per pixel of distance", "New Filter Effect (Radial Blur)", 0.01) as null|num
			if (blur_size == null)
				return

			var/blur_offset = input(usr, "Choose the pixel radius before blurring occurs ", "New Filter Effect (Radial Blur)", 0) as null|num
			if (blur_offset == null)
				return

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="radial_blur", name=entry_name, x=blur_x, y=blur_y, size=blur_size, offset=blur_offset)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							RAYS								  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("rays")
			var/rays_x = input(usr, "Choose the horizontal center of ray center, relative to image center", "New Filter Effect (Rays)", 0) as null|num
			if (rays_x == null)
				return

			var/rays_y = input(usr, "Choose the vertical center of ray center, relative to image center", "New Filter Effect (Rays)", 0) as null|num
			if (rays_y == null)
				return

			var/rays_size = input(usr, "Choose the maximum length of rays", "New Filter Effect (Rays)", 16) as null|num
			if (rays_size == null)
				return

			var/rays_color = input(usr, "Choose the rays' color", "New Filter Effect (Rays)", null) as null|color
			if (rays_color == null)
				return

			var/rays_offset = input(usr, "Choose the \"time\" offset of rays", "New Filter Effect (Rays)", 0) as null|num
			if (rays_offset == null)
				return

			var/rays_density = input(usr, "Choose the ray density. Higher values mean more, narrower rays. Must be integer.", "New Filter Effect (Rays)", 10) as null|num
			if (rays_density == null)
				return

			var/rays_threshold = input(usr, "Choose the low-end cutoff for ray strength (can be 0 to 1)", "New Filter Effect (Rays)", 0.5) as null|num
			if (rays_threshold == null)
				return

			var/rays_factor = input(usr, "Choose how much ray strength is related to ray length (can be 0 to 1)", "New Filter Effect (Rays)", 0) as null|num
			if (rays_factor == null)
				return

			var/available_map_flags = list(
				"0 (rays replace the existing image)" = 0,,
				"FILTER_OVERLAY" = FILTER_OVERLAY,
				"FILTER_UNDERLAY" = FILTER_UNDERLAY,
				"FILTER_OVERLAY | FILTER_UNDERLAY (default)" = (FILTER_OVERLAY | FILTER_UNDERLAY),
				)

			var/mask_flag = input(usr, "Choose any flags to add or none", "New Filter Effect (Rays)", "FILTER_OVERLAY | FILTER_UNDERLAY (default)") as null|anything in available_map_flags
			if (mask_flag == null)
				return

			var/added_flag = available_map_flags[mask_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="rays", name=entry_name, x=rays_x, y=rays_y, size=rays_size, color=rays_color, offset=rays_offset, density=rays_density, threshold=rays_threshold, factor=rays_factor, flags=added_flag)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							RIPPLE								  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("ripple")
			var/ripple_x = input(usr, "Choose the horizontal center of the ripple center, relative to image center", "New Filter Effect (Ripple)", 0) as null|num
			if (ripple_x == null)
				return

			var/ripple_y = input(usr, "Choose the vertical center of the ripple center, in pixels, relative to image center", "New Filter Effect (Ripple)", 0) as null|num
			if (ripple_y == null)
				return

			var/ripple_size = input(usr, "Choose the maximum distortion in pixels", "New Filter Effect (Ripple)", 1) as null|num
			if (ripple_size == null)
				return

			var/ripple_repeat = input(usr, "Choose the wave period, in pixels", "New Filter Effect (Ripple)", 2) as null|num
			if (ripple_repeat == null)
				return

			var/ripple_radius = input(usr, "Choose the outer radius of ripple, in pixels ", "New Filter Effect (Ripple)", 0) as null|num
			if (ripple_radius == null)
				return

			var/ripple_falloff = input(usr, "Choose how quickly ripples lose strength away from the outer edge", "New Filter Effect (Ripple)", 1) as null|num
			if (ripple_falloff == null)
				return

			var/available_map_flags = list(
				"0 (default)" = 0,
				"WAVE_BOUNDED " = WAVE_BOUNDED,
				)

			var/mask_flag = input(usr, "Choose any flags to add", "New Filter Effect (Ripple)", "0 (default)") as null|anything in available_map_flags
			if (mask_flag == null)
				return

			var/added_flag = available_map_flags[mask_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="ripple", name=entry_name, x=ripple_x, y=ripple_y, size=ripple_size, repeat=ripple_repeat, radius=ripple_radius, falloff=ripple_falloff, flags=added_flag)

		////////////////////////////////////////////////////////////////////
		//																  //
//////////							WAVE								  ///////////////////////////////////////////////////////////
		//																  //
		////////////////////////////////////////////////////////////////////
		if ("wave")
			var/wave_x = input(usr, "Choose the horizontal center of effect, in pixels, relative to image center", "New Filter Effect (Wave)", 0) as null|num
			if (wave_x == null)
				return

			var/wave_y = input(usr, "Choose the vertical center of effect, in pixels, relative to image center", "New Filter Effect (Wave)", 0) as null|num
			if (wave_y == null)
				return

			var/wave_size = input(usr, "Choose the maximum distortion in pixels", "New Filter Effect (Wave)", 1) as null|num
			if (wave_size == null)
				return

			var/wave_offset = input(usr, "Choose the phase of wave ", "New Filter Effect (Wave)", 0) as null|num
			if (wave_offset == null)
				return

			var/available_map_flags = list(
				"0 (default)" = 0,
				"WAVE_SIDEWAYS " = WAVE_SIDEWAYS,
				"WAVE_BOUNDED " = WAVE_BOUNDED,
				)

			var/mask_flag = input(usr, "Choose any flags to add", "New Filter Effect (Wave)", "0 (default)") as null|anything in available_map_flags
			if (mask_flag == null)
				return

			var/added_flag = available_map_flags[mask_flag]

			var/entry_name = get_next_filter_entry_name(A, filter)

			A.filters += filter(type="wave", name=entry_name, x=wave_x, y=wave_y, size=wave_size, offset=wave_offset, flags=added_flag)

	return filter_name


/client/proc/remove_filter(var/atom/A)
	to_chat(world, "remove_filter")
	var/filter_list = list()

	for (var/F in A.filters)
		var/F_name = F:name//I don't think we can typecast filters but F:name works properly here.
		filter_list[F_name] = F
		to_chat(world, "found filter [F] with name [F_name]")

	var/filter = input(usr, "Choose which filter to remove", "Removing Filter Effect", null) as null|anything in filter_list

	if (!filter)
		return

	A.filters -= filter

	return filter
