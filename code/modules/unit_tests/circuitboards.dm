/datum/unit_test/circuitboards/start()
	for(var/cb_type in subtypesof(/obj/item/weapon/circuitboard))
		var/obj/item/weapon/circuitboard/instance = new cb_type

		var/req_components = instance.req_components
		for(var/component in req_components)
			if(!ispath(component))
				if(istext(component))
					fail("[cb_type] specified [component] as a text string")
				else
					fail("[cb_type] specified an invalid [component]")
			var/component_amount = req_components[component]
			if(!isnum(component_amount))
				fail("[cb_type] specified an invalid amount for the [component] component: [component_amount]")
			
		var/build_path = instance.build_path
		var/list/abstract_types = list(
			/obj/item/weapon/circuitboard/sorting_machine,
			/obj/item/weapon/circuitboard/telecomms,
		)
		if(cb_type in abstract_types)
			continue
		if(instance.board_type == OTHER)
			continue
		
		if(!ispath(build_path))
			if(istext(build_path))
				fail("[cb_type] specified build_path as a text string")
			else
				fail("[cb_type] specified an invalid build_path")
