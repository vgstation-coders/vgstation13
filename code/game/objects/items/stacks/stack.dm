#define CORRECT_STACK_NAME(stack) ((stack.irregular_plural && stack.amount > 1) ? stack.irregular_plural : "[stack.singular_name]")

/* Stack type objects!
 * Contains:
 * 		Stacks
 *		Recipe datum
 */

/*
 * Stacks
 */
/obj/item/stack
	gender = PLURAL
	origin_tech = Tc_MATERIALS + "=1"
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/irregular_plural //"Teeth", for example. Without this, you'd see "There are 30 tooths in the stack."
	var/amount = 1
	var/perunit = 3750
	var/max_amount //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/redeemed = 0 // For selling minerals to central command via supply shuttle.
	var/restock_amount = 0 //For borg chargers restocking.

/obj/item/stack/New(var/loc, var/amount=null)
	..()
	if (amount)
		src.amount=amount
	update_materials()
	//forceMove(loc) // So that Crossed gets called, so that stacks can be merged

/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	src.forceMove(null)
	..()

/obj/item/stack/examine(mob/user)
	..()
	var/be = "are"
	if(amount == 1)
		be = "is"

	to_chat(user, "<span class='info'>There [be] [src.amount] [CORRECT_STACK_NAME(src)][amount == 1 ? " in" : "s in"] the stack.</span>")

/obj/item/stack/attack_self(mob/user as mob)
	list_recipes(user)

/obj/item/stack/proc/list_recipes(mob/user as mob, recipes_sublist)
	ASSERT(isnum(amount))
	if (!recipes)
		return
	if (!src || amount<=0)
		user << browse(null, "window=stack")
	user.set_machine(src) //for correct work of onclose
	var/list/recipe_list = recipes
	if (recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.amount)
	for(var/i=1;i<=recipe_list.len,i++)
		var/E = recipe_list[i]
		if (isnull(E))
			t1 += "<hr>"
			continue

		if (i>1 && !isnull(recipe_list[i-1]))
			t1+="<br>"

		if (istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E

			var/stack_name = (irregular_plural && srl.req_amount > 1) ? irregular_plural : "[singular_name]\s"
			if (src.amount >= srl.req_amount)
				t1 += "<a href='?src=\ref[src];sublist=[i]'>[srl.title] ([srl.req_amount] [stack_name])</a>"
			else
				t1 += "[srl.title] ([srl.req_amount] [stack_name]\s)<br>"

		if (istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(src.amount / R.req_amount)
			var/title as text
			var/can_build = 1
			can_build = can_build && (max_multiplier>0)
			/*
			if (R.one_per_turf)
				can_build = can_build && !(locate(R.result_type) in usr.loc)
			if (R.on_floor)
				can_build = can_build && istype(usr.loc, /turf/simulated/floor)
			*/
			if (R.res_amount>1)
				title+= "[R.res_amount]x [R.title]\s"
			else
				title+= "[R.title]"
			//title+= " ([R.req_amount] [src.singular_name]\s)"
			title+= " ([R.req_amount] [CORRECT_STACK_NAME(src)]"
			if(R.other_reqs.len)
				for(var/ii=1 to R.other_reqs.len)
					can_build = 0
					var/obj/looking_for = R.other_reqs[ii]
					var/req_amount
					if(ispath(looking_for, /obj/item/stack))
						var/obj/item/stack/S = new looking_for
						req_amount = R.other_reqs[looking_for]
						title +=  ", [req_amount] [CORRECT_STACK_NAME(S)]"
					else
						title += ", [initial(looking_for.name)] required in vicinity"
					if(ispath(user.get_inactive_hand(), looking_for))
						if(req_amount)
							var/obj/item/stack/S = user.get_inactive_hand()
							if(S.amount >= req_amount)
								can_build = 1
								continue
					if(!can_build)
						for(var/obj/I in range(get_turf(src),1))
							if(ispath(looking_for, I))
								if(req_amount) //It's of a stack/sheet subtype
									var/obj/item/stack/S = I
									if(S.amount >= req_amount)
										can_build = 1
										continue
								else
									can_build = 1
									continue
					break
			if (can_build)
				t1 += text("<A href='?src=\ref[src];sublist=[recipes_sublist];make=[i]'>[title]</A>)")
			else
				t1 += text("[]", title)
				continue
			if (R.max_res_amount>1 && max_multiplier>1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
				t1 += " |"
				var/list/multipliers = list(5,10,25)
				for (var/n in multipliers)
					if (max_multiplier>=n)
						t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
				if (!(max_multiplier in multipliers))
					t1 += " <A href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	t1 += "</TT></body></HTML>"
	user << browse(t1, "window=stack")
	onclose(user, "stack")
	return

/obj/item/stack/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return

	if (href_list["sublist"] && !href_list["make"])
		list_recipes(usr, text2num(href_list["sublist"]))

	if (href_list["make"])
		if (src.amount < 1)
			returnToPool(src) //Never should happen
		var/list/recipes_list = recipes
		if (href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier)
			multiplier = 1
		if (src.amount < R.req_amount*multiplier)
			if (R.res_amount*multiplier>1)
				to_chat(usr, "<span class='warning'>You haven't got enough [irregular_plural ? irregular_plural : "[singular_name]\s"] to build [R.res_amount*multiplier] [R.title]\s!</span>")
			else
				to_chat(usr, "<span class='warning'>You haven't got enough [irregular_plural ? irregular_plural : "[singular_name]\s"] to build \the [R.title]!</span>")
			return
		if (!R.can_build_here(usr, usr.loc))
			return
		if (R.time)
			if (!do_after(usr, get_turf(src), R.time))
				return
		if (src.amount < R.req_amount*multiplier)
			return
		var/list/stacks_to_consume = list()
		if(R.other_reqs.len)
			for(var/i=1 to R.other_reqs.len)
				var/looking_for = R.other_reqs[i]
				var/req_amount
				var/found = FALSE
				if(ispath(looking_for, /obj/item/stack))
					req_amount = R.other_reqs[looking_for]
				if(ispath(usr.get_inactive_hand(), looking_for))
					found = TRUE
					if(req_amount) //It's of a stack/sheet subtype
						var/obj/item/stack/S = usr.get_inactive_hand()
						if(S.amount < req_amount)
							found = FALSE
						else
							stacks_to_consume.Add(S)
							stacks_to_consume[S] = req_amount
						continue
				for(var/obj/I in range(get_turf(src),1))
					if(ispath(looking_for, I))
						found = TRUE
						if(req_amount) //It's of a stack/sheet subtype
							var/obj/item/stack/S = I
							if(S.amount < req_amount)
								found = FALSE
							else
								stacks_to_consume.Add(S)
								stacks_to_consume[S] = req_amount
				if(!found)
					return
		var/atom/O
		if(ispath(R.result_type, /obj/item/stack))
			O = drop_stack(R.result_type, usr.loc, (R.max_res_amount>1 ? R.res_amount*multiplier : 1), usr)
			var/obj/item/stack/S = O
			S.update_materials()
		else
			O = new R.result_type( usr.loc )

		O.dir = usr.dir
		if(R.start_unanchored)
			var/obj/A = O
			A.anchored = 0
		R.finish_building(usr, src, O)

		//if (R.max_res_amount>1)
		//	var/obj/item/stack/new_item = O
		//	new_item.amount = R.res_amount*multiplier
		//	//new_item.add_to_stacks(usr)

		src.use(R.req_amount*multiplier)
		for(var/obj/item/stack/S in stacks_to_consume)
			S.use(stacks_to_consume[S])
		if (src.amount<=0)
			var/oldsrc = src
			//src = null //dont kill proc after del()
			usr.before_take_item(oldsrc)
			returnToPool(oldsrc)
			if (istype(O,/obj/item))
				usr.put_in_hands(O)
		O.add_fingerprint(usr)
		//BubbleWrap - so newly formed boxes are empty //This is pretty shitcode but I'm not fixing it because even if sloth is a sin I am already going to hell anyways
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				qdel(I)
	if (src && usr.machine==src) //do not reopen closed window
		spawn( 0 )
			src.interact(usr)
			return
	return

/obj/item/stack/proc/use(var/amount)
	ASSERT(isnum(src.amount))

	if(src.amount>=amount)
		src.amount-=amount
		update_materials()
	else
		return 0
	. = 1
	if (src.amount<=0) //If the stack is empty after removing the required amount of items!
		if(usr)
			if(istype(usr,/mob/living/silicon/robot))
				var/mob/living/silicon/robot/R=usr
				if(R.module)
					R.module.modules -= src
				if(R.module_active == src)
					R.module_active = null
				if(R.module_state_1 == src)
					R.uneq_module(R.module_state_1)
					R.module_state_1 = null
					R.inv1.icon_state = "inv1"
				else if(R.module_state_2 == src)
					R.uneq_module(R.module_state_2)
					R.module_state_2 = null
					R.inv2.icon_state = "inv2"
				else if(R.module_state_3 == src)
					R.uneq_module(R.module_state_3)
					R.module_state_3 = null
					R.inv3.icon_state = "inv3"
			usr.before_take_item(src)
		spawn returnToPool(src)

/obj/item/stack/proc/add(var/amount)
	src.amount += amount
	update_materials()

/obj/item/stack/proc/set_amount(new_amount)
	amount = new_amount
	update_materials()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(src == S) //We need to check this because items can cross themselves for some fucked up reason
		return
	if(!can_stack_with(S))
		return
	var/transfer = min(amount, S.max_amount - S.amount)
	if(transfer <= 0)
		return
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer)
	S.add(transfer)

/obj/item/stack/proc/update_materials()
	if(amount && starting_materials)
		for(var/matID in starting_materials)
			materials.storage[matID] = max(0, starting_materials[matID]*amount)
	if(amount < 2)
		gender = NEUTER
	else
		gender = PLURAL

/obj/item/stack/proc/can_stack_with(obj/item/other_stack)
	if(ispath(other_stack))
		return (src.type == other_stack)

	return (src.type == other_stack.type)

/obj/item/stack/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		var/obj/item/stack/F = new src.type( user, amount=1)
		F.copy_evidences(src)
		user.put_in_hands(F)
		src.add_fingerprint(user)
		F.add_fingerprint(user)
		use(1)
		if (src && usr.machine==src)
			spawn(0) src.interact(usr)
	else
		..()
	return

/obj/item/stack/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0

	if (can_stack_with(target))
		var/obj/item/stack/S = target
		if (amount >= max_amount)
			to_chat(user, "\The [src] cannot hold anymore [CORRECT_STACK_NAME(src)].")
			return 1
		var/to_transfer as num
		if (user.get_inactive_hand()==S)
			to_transfer = 1
		else
			to_transfer = min(S.amount, max_amount-amount)
		add(to_transfer)
		to_chat(user, "You add [to_transfer] [((to_transfer > 1) && S.irregular_plural) ? S.irregular_plural : "[S.singular_name]\s"] to \the [src]. It now contains [amount] [CORRECT_STACK_NAME(src)].")
		if (S && user.machine==S)
			spawn(0) interact(user)
		S.use(to_transfer)
		if (src && user.machine==src)
			spawn(0) src.interact(user)
		update_icon()
		S.update_icon()
		return 1
	return ..()

//Ported from -tg-station/#10973, credit to MrPerson
/obj/item/stack/Crossed(obj/o)
	if(src != o && istype(o, src.type) && !o.throwing)
		merge(o)
	return ..()

/obj/item/stack/hitby(atom/movable/AM) //Doesn't seem to ever be called since stacks are not dense but whatever
	. = ..()
	if(.)
		return
	if(src != AM && istype(AM, src.type))
		merge(AM)

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/*
 drop_stack() helper proc

 Arguments:
   - new_stack_type = type of stack to spawn (for example /obj/item/stack/tile/light)
   - loc = where to spawn the stack
   - add_amount = how much items to create in the stack
   - user = non-essential, whom to send the messages to

 This proc sees if there are any stacks of the same type in *loc. If there are, and it's possible to add *amount items to them,
 add *amount items to them and return.
 If unable to add to any already existing stack, create a new instance of *new_stack_type

 Returns stack

 */

/proc/drop_stack(new_stack_type = /obj/item/stack, atom/loc, add_amount = 1, mob/user)
	for(var/obj/item/stack/S in loc)
		if(S.can_stack_with(new_stack_type))
			if(S.max_amount >= S.amount + add_amount)
				S.add(add_amount)
				if(user)
					to_chat(user, "<span class='info'>You add [add_amount] item\s to the stack. It now contains [S.amount] [CORRECT_STACK_NAME(S)].</span>")
				return S

	var/obj/item/stack/S = new new_stack_type(loc)
	S.amount = add_amount
	return S

/obj/item/stack/verb_pickup(mob/living/user)
	var/obj/item/I = user.get_active_hand()
	if(I && can_stack_with(I))
		I.preattack(src, user, 1)
		return
	return ..()

/obj/item/stack/restock()
	if(!restock_amount)
		return //Do not restock this stack type
	if(amount < max_amount)
		amount += restock_amount
	if(amount > max_amount)
		amount = max_amount

#undef CORRECT_STACK_NAME
