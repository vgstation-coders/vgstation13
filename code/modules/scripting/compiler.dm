/datum/n_Compiler
	var/datum/n_Interpreter/interpreter
	var/ready = 1 // 1 if ready to run code
	var/interptype = /datum/n_Interpreter

	/* -- Set ourselves to Garbage Collect -- */

/datum/n_Compiler/proc/GC()
	if(interpreter)
		interpreter.GC()


	/* -- Compile a raw block of text -- */

/datum/n_Compiler/proc/Compile(code as message)
	var/datum/n_scriptOptions/nS_Options/options		= new()
	var/datum/n_Scanner/nS_Scanner/scanner				= new(code, options)
	var/list/tokens										= scanner.Scan()
	var/datum/n_Parser/nS_Parser/parser					= new(tokens, options)
	var/datum/node/BlockDefinition/GlobalBlock/program	= parser.Parse()

	var/list/returnerrors = list()

	returnerrors += scanner.errors
	returnerrors += parser.errors

	if(returnerrors.len)
		return returnerrors

	interpreter 		= new interptype(program)
	interpreter.persist	= 1
	interpreter.Compiler= src

	return returnerrors

/* -- Execute the compiled code -- */

/datum/n_Compiler/proc/Run(var/datum/signal/signal)
	if(!ready)
		return

	if(!interpreter)
		return

	SetVars(signal)
	SetProcs(signal)

	// Run the compiled code
	interpreter.Run()

/datum/n_Compiler/proc/SetProcs(var/datum/signal/signal)
	// Set up the script procs

	/*
		-> Delay code for a given amount of deciseconds
				@format: sleep(time)

				@param time: 		time to sleep in deciseconds (1/10th second)
	*/
	interpreter.SetProc("sleep",		/proc/delay)

	/*
		-> Replaces a string with another string
				@format: replace(string, substring, replacestring)

				@param string: 			the string to search for substrings (best used with $content$ constant)
				@param substring: 		the substring to search for
				@param replacestring: 	the string to replace the substring with

	*/
	interpreter.SetProc("replace",		/proc/n_replacetext)

	/*
		-> Locates an element/substring inside of a list or string
				@format: find(haystack, needle, start = 1, end = 0)

				@param haystack:	the container to search
				@param needle:		the element to search for
				@param start:		the position to start in
				@param end:			the position to end in

	*/
	interpreter.SetProc("find",			/proc/smartfind)

	/*
		-> Finds the length of a string or list
				@format: length(container)

				@param container: the list or container to measure

	*/
	interpreter.SetProc("length",		/proc/smartlength)

	/* -- Clone functions, carried from default BYOND procs --- */

	// vector namespace
	interpreter.SetProc("vector",		/proc/n_list)
	interpreter.SetProc("at",			/proc/n_listpos)
	interpreter.SetProc("copy",			/proc/n_listcopy)
	interpreter.SetProc("push_back",	/proc/n_listadd)
	interpreter.SetProc("remove",		/proc/n_listremove)
	interpreter.SetProc("cut",			/proc/n_listcut)
	interpreter.SetProc("swap",			/proc/n_listswap)
	interpreter.SetProc("insert",		/proc/n_listinsert)

	interpreter.SetProc("pick",			/proc/n_pick)
	interpreter.SetProc("prob",			/proc/prob_chance)
	interpreter.SetProc("substr",		/proc/docopytext)

	interpreter.SetProc("shuffle",		/proc/shuffle)
	interpreter.SetProc("uniquevector",	/proc/uniquelist)

	interpreter.SetProc("text2vector",	/proc/n_splittext)
	interpreter.SetProc("text2vectorEx",/proc/splittextEx)
	interpreter.SetProc("vector2text",	/proc/vg_jointext)

	// Strings
	interpreter.SetProc("lower",		/proc/n_lower)
	interpreter.SetProc("upper",		/proc/n_upper)
	interpreter.SetProc("explode",		/proc/string_explode)
	interpreter.SetProc("repeat",		/proc/n_repeat)
	interpreter.SetProc("reverse",		/proc/reverse_text)
	interpreter.SetProc("tonum",		/proc/n_str2num)
	interpreter.SetProc("capitalize",	/proc/capitalize)
	//interpreter.SetProc("replacetextEx",/proc/n_replacetextEx)

	// Numbers
	interpreter.SetProc("tostring",		/proc/n_num2str)
	interpreter.SetProc("sqrt",			/proc/n_sqrt)
	interpreter.SetProc("abs",			/proc/n_abs)
	interpreter.SetProc("floor",		/proc/Floor)
	interpreter.SetProc("ceil",			/proc/Ceiling)
	interpreter.SetProc("round",		/proc/n_round)
	interpreter.SetProc("clamp",		/proc/n_clamp)
	interpreter.SetProc("inrange",		/proc/IsInRange)
	interpreter.SetProc("rand",			/proc/rand_chance)
	interpreter.SetProc("arctan",		/proc/Atan2)
	interpreter.SetProc("lcm",			/proc/Lcm)
	interpreter.SetProc("gcd",			/proc/Gcd)
	interpreter.SetProc("mean",			/proc/Mean)
	interpreter.SetProc("root",			/proc/Root)
	interpreter.SetProc("sin",			/proc/n_sin)
	interpreter.SetProc("cos",			/proc/n_cos)
	interpreter.SetProc("arcsin",		/proc/n_asin)
	interpreter.SetProc("arccos",		/proc/n_acos)
	interpreter.SetProc("tan",			/proc/Tan)
	interpreter.SetProc("csc",			/proc/Csc)
	interpreter.SetProc("cot",			/proc/Cot)
	interpreter.SetProc("sec",			/proc/Sec)
	interpreter.SetProc("todegrees",	/proc/ToDegrees)
	interpreter.SetProc("toradians",	/proc/ToRadians)
	interpreter.SetProc("lerp",			/proc/mix)
	interpreter.SetProc("max",			/proc/n_max)
	interpreter.SetProc("min",			/proc/n_min)

	// End of Donkie~

	// Time
	interpreter.SetProc("time",			/proc/time)
	interpreter.SetProc("timestamp",	/proc/timestamp)

/datum/n_Compiler/proc/SetVars(var/datum/signal/signal)
	interpreter.SetVar("TAU",	 	TAU)			// value of tau
	interpreter.SetVar("PI",	 	PI)				// value of pi
	interpreter.SetVar("E",		 	E)				// value of e
	interpreter.SetVar("SQURT2", 	Sqrt2)			// value of the square root of 2
	interpreter.SetVar("FALSE", 	0)				// boolean shortcut to 0
	interpreter.SetVar("false", 	0)				// boolean shortcut to 0
	interpreter.SetVar("TRUE",		1)				// boolean shortcut to 1
	interpreter.SetVar("true",		1)				// boolean shortcut to 1

	interpreter.SetVar("NORTH", 	NORTH)			// NORTH (1)
	interpreter.SetVar("SOUTH", 	SOUTH)			// SOUTH (2)
	interpreter.SetVar("EAST",	 	EAST)			// EAST  (4)
	interpreter.SetVar("WEST",	 	WEST)			// WEST  (8)
