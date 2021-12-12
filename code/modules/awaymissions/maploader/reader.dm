///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////

/**
 * Returns a list with two numbers. First number is the map's width. Second number is the map's height.
 */
var/list/map_dimension_cache = list()

/dmm_suite/get_map_dimensions(var/dmm_file as file)
	var/quote = ascii2text(34)
	var/tfile = file2text(dmm_file)
	var/hash = md5(tfile)

	if(map_dimension_cache.Find(hash))
		return map_dimension_cache[hash]

	var/tfile_len = length(tfile)
	var/lpos = 1 // the models definition index

	var/key_len = length(copytext(tfile,2,findtext(tfile,quote,2,0)))//the length of the model key (e.g "aa" or "aba")
	if(!key_len)
		key_len = 1

	//proceed line by line to find the map layout
	//Another way to do this would be to search for this string: (1,1,1) = {" , but if some joker varedited that into the map it would break bigly
	for(lpos=1; lpos<tfile_len; lpos=findtext(tfile,"\n",lpos,0)+1)
		var/tline = copytext(tfile,lpos,findtext(tfile,"\n",lpos,0))
		if(copytext(tline,1,2) != quote)//we reached the map "layout"
			break

	var/zpos = findtext(tfile, "\n(1,1,", lpos, 0)
	var/zgrid = copytext(tfile, findtext(tfile, quote+"\n", zpos, 0)+2, findtext(tfile,"\n"+quote, zpos, 0)+1) //copy the whole map grid
	var/x_depth = length(copytext(zgrid, 1, findtext(zgrid, "\n", 2, 0))) //Length of an encoded line (like "aaaaaaaaAAAAAAAAAAAA")
	var/map_width = x_depth / key_len //Divide length of the encoded line by the length of the key to get the map's width
	var/map_height= length(zgrid) / (x_depth+1) //x_depth + 1 because we're counting the '\n' characters in z_depth

	var/return_list = list(map_width, map_height)
	map_dimension_cache[hash] = return_list

	return return_list

/**
 * Construct the model map and control the loading process
 *
 * WORKING :
 *
 * 1) Makes an associative mapping of model_keys with model
 *		e.g aa = /turf/unsimulated/wall{icon_state = "rock"}
 * 2) Read the map line by line, parsing the result (using parse_grid)
 *
 * RETURNS :
 *
 * A list of all atoms created
 *
 */
/dmm_suite/load_map(var/dmm_file as file, var/z_offset as num, var/x_offset as num, var/y_offset as num, var/datum/map_element/map_element as null, var/rotate as num, var/overwrite as num)
	if((rotate % 90) != 0) //If not divisible by 90, make it
		rotate += (rotate % 90)

	if(!z_offset)//what z_level we are creating the map on
		z_offset = world.maxz+1

	//If this is true, the lag is reduced at the cost of slower loading speed, and tiny atmos leaks during loading
	var/remove_lag
	if(map_element.load_at_once)
		remove_lag = FALSE
	else if(ticker && ticker.current_state > GAME_STATE_PREGAME)
		//Lag doesn't matter before the game
		remove_lag = TRUE

	var/list/spawned_atoms = list()

	var/quote = ascii2text(34)
	var/tfile = file2text(dmm_file)//the map file we're creating
	var/tfile_len = length(tfile)
	var/lpos = 1 // the models definition index

	///////////////////////////////////////////////////////////////////////////////////////
	//first let's map model keys (e.g "aa") to their contents (e.g /turf/space{variables})
	///////////////////////////////////////////////////////////////////////////////////////
	var/list/grid_models = list()
	var/key_len = length(copytext(tfile,2,findtext(tfile,quote,2,0)))//the length of the model key (e.g "aa" or "aba")
	if(!key_len)
		key_len = 1

	//proceed line by line
	for(lpos=1; lpos<tfile_len; lpos=findtext(tfile,"\n",lpos,0)+1)
		var/tline = copytext(tfile,lpos,findtext(tfile,"\n",lpos,0))
		if(copytext(tline,1,2) != quote)//we reached the map "layout"
			break
		var/model_key = copytext(tline,2,2+key_len)
		var/model_contents = copytext(tline,findtext(tfile,"=")+3,length(tline))
		grid_models[model_key] = model_contents
		if (remove_lag)
			CHECK_TICK
		else
			sleep(-1)

	///////////////////////////////////////////////////////////////////////////////////////
	//now let's fill the map with turf and objects using the constructed model map
	///////////////////////////////////////////////////////////////////////////////////////

	//position of the currently processed square
	var/zcrd=-1
	var/ycrd=x_offset
	var/xcrd=y_offset
	var/ycrd_rotate=x_offset
	var/xcrd_rotate=y_offset
	var/ycrd_flip=x_offset
	var/xcrd_flip=y_offset
	var/ycrd_flip_rotate=y_offset
	var/xcrd_flip_rotate=x_offset

	for(var/zpos=findtext(tfile,"\n(1,1,",lpos,0);zpos!=0;zpos=findtext(tfile,"\n(1,1,",zpos+1,0))	//in case there's several maps to load

		zcrd++
		if(zcrd+z_offset > world.maxz)
			world.maxz = zcrd+z_offset
			map.addZLevel(new /datum/zLevel/away, world.maxz) //create a new z_level if needed

		var/zgrid = copytext(tfile,findtext(tfile,quote+"\n",zpos,0)+2,findtext(tfile,"\n"+quote,zpos,0)+1) //copy the whole map grid
		var/z_depth = length(zgrid) //Length of the whole block (with multiple lines in them)

		//if exceeding the world max x or y, increase it
		var/x_depth = length(copytext(zgrid,1,findtext(zgrid,"\n",2,0))) //This is the length of an encoded line (like "aaaaaaaaBBBBaaaaccccaaa")
		var/y_depth = z_depth / (x_depth+1) //x_depth + 1 because we're counting the '\n' characters in z_depth
		var/map_width = x_depth / key_len //To get the map's width, divide the length of the line by the length of the key

		var/x_check = rotate == 0 || rotate == 180 ? map_width + x_offset : y_depth + y_offset
		var/y_check = rotate == 0 || rotate == 180 ? y_depth + y_offset : map_width + x_offset
		if(world.maxx < x_check)
			if(!map.can_enlarge)
				WARNING("Cancelled load of [map_element] due to map bounds.")
				return list()
			world.maxx = x_check
			WARNING("Loading [map_element] enlarged the map. New max x = [world.maxx]")

		if(world.maxy < y_check)
			if(!map.can_enlarge)
				WARNING("Cancelled load of [map_element] due to map bounds.")
				return list()
			world.maxy = y_check
			WARNING("Loading [map_element] enlarged the map. New max y = [world.maxy]")

		//then proceed it line by line, starting from top
		ycrd = y_offset + y_depth
		ycrd_rotate = x_offset + map_width
		ycrd_flip = y_offset + 1
		ycrd_flip_rotate = x_offset + 1

		for(var/gpos=1;gpos!=0;gpos=findtext(zgrid,"\n",gpos,0)+1)
			var/grid_line = copytext(zgrid,gpos,findtext(zgrid,"\n",gpos,0))

			//fill the current square using the model map
			xcrd=x_offset
			xcrd_rotate=y_offset
			xcrd_flip=x_offset + map_width + 1
			xcrd_flip_rotate=y_offset + map_width + 1
			for(var/mpos=1;mpos<=x_depth;mpos+=key_len)
				xcrd++
				xcrd_rotate++
				xcrd_flip--
				xcrd_flip_rotate--
				var/model_key = copytext(grid_line,mpos,mpos+key_len)
				switch(rotate)
					if(0)
						spawned_atoms |= parse_grid(grid_models[model_key],xcrd,ycrd,zcrd+z_offset,rotate,overwrite)
					if(90)
						spawned_atoms |= parse_grid(grid_models[model_key],ycrd_rotate,xcrd_flip_rotate,zcrd+z_offset,rotate,overwrite)
					if(180)
						spawned_atoms |= parse_grid(grid_models[model_key],xcrd_flip,ycrd_flip,zcrd+z_offset,rotate,overwrite)
					if(270)
						spawned_atoms |= parse_grid(grid_models[model_key],ycrd_flip_rotate,xcrd_rotate,zcrd+z_offset,rotate,overwrite)
				if (remove_lag)
					CHECK_TICK
			if(map_element)
				map_element.width = xcrd - x_offset

			//reached end of current map
			if(gpos+x_depth+1>z_depth)
				break

			ycrd--
			ycrd_rotate--
			ycrd_flip++
			ycrd_flip_rotate++

			if(remove_lag)
				CHECK_TICK
			else
				sleep(-1)

		if(map_element)
			map_element.height = y_depth

			if(!map_element.location)
				//Set location to the lower left corner, if it hasn't already been set
				map_element.location = locate(x_offset + 1, y_offset + 1, z_offset)

		//reached End Of File
		if(findtext(tfile,quote+"}",zpos,0)+2==tfile_len)
			break
		sleep(-1)

	return spawned_atoms

/**
 * Fill a given tile with its area/turf/objects/mobs
 * Variable model is one full map line (e.g /turf/unsimulated/wall{icon_state = "rock"},/area/mine/explored)
 *
 * WORKING :
 *
 * 1) Read the model string, member by member (delimiter is ',')
 *
 * 2) Get the path of the atom and store it into a list
 *
 * 3) a) Check if the member has variables (text within '{' and '}')
 *
 * 3) b) Construct an associative list with found variables, if any (the atom index in members is the same as its variables in members_attributes)
 *
 * 4) Instanciates the atom with its variables
 *
 * RETURNS :
 *
 * A list with all spawned atoms
 *
 */
/dmm_suite/proc/parse_grid(var/model as text,var/xcrd as num,var/ycrd as num,var/zcrd as num,var/rotate as num,var/overwrite as num)
	/*Method parse_grid()
	- Accepts a text string containing a comma separated list of type paths of the
		same construction as those contained in a .dmm file, and instantiates them.
	*/

	var/list/members = list()//will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
	var/list/members_attributes = list()//will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())

	var/list/spawned_atoms = list()

	/////////////////////////////////////////////////////////
	//Constructing members and corresponding variables lists
	////////////////////////////////////////////////////////

	var/index=1
	var/old_position = 1
	var/dpos

	do
		//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/explored)
		dpos= find_next_delimiter_position(model,old_position,",","{","}")//find next delimiter (comma here) that's not within {...}

		var/full_def = copytext(model,old_position,dpos)//full definition, e.g : /obj/foo/bar{variables=derp}
		var/atom_def = text2path(copytext(full_def,1,findtext(full_def,"{")))//path definition, e.g /obj/foo/bar
		members.Add(atom_def)
		old_position = dpos + 1

		//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
		var/list/fields = list()

		var/variables_start = findtext(full_def,"{")
		if(variables_start)//if there's any variable
			full_def = copytext(full_def,variables_start+1,length(full_def))//removing the last '}'
			fields = readlist(full_def,";")

		//then fill the members_attributes list with the corresponding variables
		members_attributes.len++
		members_attributes[index++] = fields

		sleep(-1)
	while(dpos != 0)


	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile

	//first instance the /area and remove it from the members list
	index = members.len
	var/atom/instance
	_preloader.setup(members_attributes[index])//preloader for assigning  set variables on atom creation

	//Locate the area object
	instance = locate(members[index])

	if(!isspace(instance)) //Space is the default area and contains every loaded turf by default
		instance.contents.Add(locate(xcrd,ycrd,zcrd))
		spawned_atoms.Add(instance)

	if(use_preloader && instance)
		_preloader.load(instance)

	//The areas list doesn't contain areas without objects by default
	//We have to add it manually
	if(!areas.Find(instance))
		var/area/A = instance

		if(istype(A))
			areas.Add(instance)
			A.addSorted()


	members.Remove(members[index])

	//then instance the /turf and, if multiple tiles are presents, simulates the DMM underlays piling effect (only the last turf is spawned, other ones are drawn as underlays)

	var/first_turf_index = 1
	while(!ispath(members[first_turf_index],/turf)) //find first /turf object in members
		first_turf_index++

	var/last_turf_index = first_turf_index
	while(last_turf_index+1 <= members.len && ispath(members[last_turf_index + 1], /turf))
		last_turf_index++

	//instanciate the last /turf
	var/turf/T = instance_atom(members[last_turf_index],members_attributes[last_turf_index],xcrd,ycrd,zcrd,rotate)

	if(first_turf_index != last_turf_index) //More than one turf is present - go from the lowest turf to the turf before the last one
		var/turf_index = first_turf_index
		while(turf_index < last_turf_index)
			var/turf/underlying_turf = members[turf_index]
			var/image/new_underlay = image(icon = null) //Because just image() doesn't work, and neither does image(appearance=...)

			new_underlay.appearance = initial(underlying_turf.appearance)
			T.underlays.Add(new_underlay)
			turf_index++

	spawned_atoms.Add(T)

	//finally instance all remainings objects/mobs
	if(overwrite)
		var/turf/T_old = locate(xcrd,ycrd,zcrd)
		for(var/atom/thing in T_old)
			qdel(T_old)
	for(index=1,index < first_turf_index,index++)
		var/atom/new_atom = instance_atom(members[index],members_attributes[index],xcrd,ycrd,zcrd,rotate)
		spawned_atoms.Add(new_atom)

	return spawned_atoms

////////////////
//Helpers procs
////////////////

//Instance an atom at (x,y,z) and gives it the variables in attributes
/dmm_suite/proc/instance_atom(var/path,var/list/attributes, var/x, var/y, var/z, var/rotate)
	if(!path)
		return
	var/atom/instance
	_preloader.setup(attributes, path)

	if(ispath(path, /turf)) //Turfs use ChangeTurf
		var/turf/oldTurf = locate(x,y,z)
		if(path != oldTurf.type)
			instance = oldTurf.ChangeTurf(path, allow = 1)
	else
		instance = new path (locate(x,y,z))//first preloader pass

	// Stolen from shuttlecode but very good to reuse here
	if(rotate && instance)
		instance.shuttle_rotate(rotate)

	if(use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
		_preloader.load(instance)

	return instance

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/proc/trim_text(var/what as text,var/trim_quotes=0)
	while(length(what) && (findtext(what," ",1,2)))
		what=copytext(what,2,0)
	while(length(what) && (findtext(what," ",length(what),0)))
		what=copytext(what,1,length(what))
	if(trim_quotes)
		while(length(what) && (findtext(what,quote,1,2)))
			what=copytext(what,2,0)
		while(length(what) && (findtext(what,quote,length(what),0)))
			what=copytext(what,1,length(what))
	return what

//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/proc/find_next_delimiter_position(var/text as text,var/initial_position as num, var/delimiter=",",var/opening_escape=quote,var/closing_escape=quote)
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter


//build a list from variables in text form (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
//return the filled list
/proc/readlist(var/text as text,var/delimiter=",")


	var/list/to_return = list()

	var/position
	var/old_position = 1

	do
		//find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter)

		//check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		var/equal_position = findtext(text,"=",old_position, position)

		var/trim_left = trim_text(copytext(text,old_position,(equal_position ? equal_position : position)),1)//the name of the variable, must trim quotes to build a BYOND compliant associatives list
		old_position = position + 1

		if(equal_position)//associative var, so do the association
			var/trim_right = trim_text(copytext(text,equal_position+1,position))//the content of the variable

			//Check for string
			if(findtext(trim_right,quote,1,2))
				trim_right = copytext(trim_right,2,findtext(trim_right,quote,3,0))

			//Check for number
			else if(isnum(text2num(trim_right)))
				trim_right = text2num(trim_right)

			//Check for null
			else if(trim_right == "null")
				trim_right = null

			//Check for list
			else if(copytext(trim_right,1,5) == "list")
				trim_right = readlist(copytext(trim_right,6,length(trim_right)))

			//Check for file
			else if(copytext(trim_right,1,2) == "'")
				trim_right = file(copytext(trim_right,2,length(trim_right)))

			to_return[trim_left] = trim_right

		else//simple var
			to_return[trim_left] = null

	while(position != 0)

	return to_return

//simulates the DM multiple turfs on one tile underlaying
/dmm_suite/proc/add_underlying_turf(var/turf/placed,var/turf/underturf, var/list/turfs_underlays)
	if(underturf.density)
		placed.setDensity(TRUE)
	if(underturf.opacity)
		placed.opacity = 1
	placed.underlays += turfs_underlays

/atom/New()

	//atom creation method that preloads variables at creation
	if(use_preloader && (src.type == _preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		_preloader.load(src)

	. = ..()

//////////////////
//Preloader datum
//////////////////

//global datum that will preload variables on atoms instanciation
var/global/dmm_suite/preloader/_preloader = new
var/use_preloader = FALSE

/dmm_suite/preloader
	parent_type = /datum
	var/list/attributes
	var/target_path

/dmm_suite/preloader/proc/setup(list/the_attributes, path)
	if(!the_attributes.len)
		return
	use_preloader = TRUE
	attributes = the_attributes
	target_path = path

/dmm_suite/preloader/proc/load(atom/what)
	use_preloader = FALSE
	var/list/local_attributes = attributes
	var/list/what_vars = what.vars
	for(var/attribute in local_attributes)
		what_vars[attribute] = local_attributes[attribute]
