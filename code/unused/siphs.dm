/obj/machinery/atmoalter/siphs/New()
	..()
	gas = new /datum/gas_mixture()

	return

/obj/machinery/atmoalter/siphs/proc/releaseall()
	t_status = 1
	t_per = max_valve
	return

/obj/machinery/atmoalter/siphs/proc/reset(valve, auto)
	if(c_status!=0)
		return

	if (valve < 0)
		t_per =  -valve
		t_status = 1
	else
		if (valve > 0)
			t_per = valve
			t_status = 2
		else
			t_status = 3
	if (auto)
		t_status = 4
	setstate()
	return

/obj/machinery/atmoalter/siphs/proc/release(amount, flag)
	/*
	var/T = loc
	if (!( istype(T, /turf) ))
		return
	if (locate(/obj/move, T))
		T = locate(/obj/move, T)
	if (!( amount ))
		return
	if (!( flag ))
		amount = min(amount, max_valve)
	gas.turf_add(T, amount)
	return
	*/ //TODO: FIX

/obj/machinery/atmoalter/siphs/proc/siphon(amount, flag)
	/*
	var/T = loc
	if (!( istype(T, /turf) ))
		return
	if (locate(/obj/move, T))
		T = locate(/obj/move, T)
	if (!( amount ))
		return
	if (!( flag ))
		amount = min(amount, 900000.0)
	gas.turf_take(T, amount)
	return
	*/ //TODO: FIX

/obj/machinery/atmoalter/siphs/proc/setstate()


	if(stat & NOPOWER)
		icon_state = "siphon:0"
		return

	if (holding)
		icon_state = "siphon:T"
	else
		if (t_status != 3)
			icon_state = "siphon:1"
		else
			icon_state = "siphon:0"
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/New()
	/*
	..()
	if(!empty)
		gas.oxygen = 2.73E7
		gas.n2 = 1.027E8
	return
	*/ //TODO: FIX

/obj/machinery/atmoalter/siphs/fullairsiphon/port/reset(valve, auto)

	if (valve < 0)
		t_per =  -valve
		t_status = 1
	else
		if (valve > 0)
			t_per = valve
			t_status = 2
		else
			t_status = 3
	if (auto)
		t_status = 4
	setstate()
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/attackby(W as obj, user as mob)

	if (istype(W, /obj/item/weapon/screwdriver))
		if (c_status)
			anchored = 1
			c_status = 0
		else
			if (locate(/obj/machinery/connector, loc))
				anchored = 1
				c_status = 3
	else
		if (istype(W, /obj/item/weapon/wrench))
			alterable = !( alterable )
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/setstate()


	if(stat & NOPOWER)
		icon_state = "vent-p"
		return

	if (t_status == 4)
		icon_state = "vent2"
	else
		if (t_status == 3)
			icon_state = "vent0"
		else
			icon_state = "vent1"
	return

/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/reset(valve, auto)

	if (auto)
		t_status = 4
	return

/obj/machinery/atmoalter/siphs/scrubbers/process()
	/*
	if(stat & NOPOWER) return

	if(gas.temperature >= 3000)
		melt()

	if (t_status != 3)
		var/turf/T = loc
		if (istype(T, /turf))
			if (locate(/obj/move, T))
				T = locate(/obj/move, T)
			if (T.firelevel < 900000.0)
				gas.turf_add_all_oxy(T)

		else
			T = null
		switch(t_status)
			if(1.0)
				if( !portable() ) use_power(50, ENVIRON)
				if (holding)
					var/t1 = gas.total_moles()
					var/t2 = t1
					var/t = t_per
					if (t_per > t2)
						t = t2
					holding.gas.transfer_from(gas, t)
				else
					if (T)
						var/t1 = gas.total_moles()
						var/t2 = t1
						var/t = t_per
						if (t_per > t2)
							t = t2
						gas.turf_add(T, t)
			if(2.0)
				if( !portable() ) use_power(50, ENVIRON)
				if (holding)
					var/t1 = gas.total_moles()
					var/t2 = maximum - t1
					var/t = t_per
					if (t_per > t2)
						t = t2
					gas.transfer_from(holding.gas, t)
				else
					if (T)
						var/t1 = gas.total_moles()
						var/t2 = maximum - t1
						var/t = t_per
						if (t > t2)
							t = t2
						gas.turf_take(T, t)
			if(4.0)
				if( !portable() ) use_power(50, ENVIRON)
				if (T)
					if (T.firelevel > 900000.0)
						f_time = world.time + 400
					else
						if (world.time > f_time)
							gas.extract_toxs(T)
							if( !portable() ) use_power(150, ENVIRON)
							var/contain = gas.total_moles()
							if (contain > 1.3E8)
								gas.turf_add(T, 1.3E8 - contain)

	setstate()
	updateDialog()
	return
	*/ //TODO: FIX

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/setstate()

	if(stat & NOPOWER)
		icon_state = "vent-p"
		return

	if (t_status == 4)
		icon_state = "vent2"
	else
		if (t_status == 3)
			icon_state = "vent0"
		else
			icon_state = "vent1"
	return

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/attackby(W as obj, user as mob)

	if (istype(W, /obj/item/weapon/screwdriver))
		if (c_status)
			anchored = 1
			c_status = 0
		else
			if (locate(/obj/machinery/connector, loc))
				anchored = 1
				c_status = 3
	else
		if (istype(W, /obj/item/weapon/wrench))
			alterable = !( alterable )
	return

/obj/machinery/atmoalter/siphs/scrubbers/air_filter/reset(valve, auto)

	if (auto)
		t_status = 4
	setstate()
	return

/obj/machinery/atmoalter/siphs/scrubbers/port/setstate()

	if(stat & NOPOWER)
		icon_state = "scrubber:0"
		return

	if (holding)
		icon_state = "scrubber:T"
	else
		if (t_status != 3)
			icon_state = "scrubber:1"
		else
			icon_state = "scrubber:0"
	return

/obj/machinery/atmoalter/siphs/scrubbers/port/reset(valve, auto)

	if (valve < 0)
		t_per =  -valve
		t_status = 1
	else
		if (valve > 0)
			t_per = valve
			t_status = 2
		else
			t_status = 3
	if (auto)
		t_status = 4
	setstate()
	return

//true if the siphon is portable (therfore no power needed)

/obj/machinery/proc/portable()
	return istype(src, /obj/machinery/atmoalter/siphs/fullairsiphon/port) || istype(src, /obj/machinery/atmoalter/siphs/scrubbers/port)

/obj/machinery/atmoalter/siphs/power_change()

	if( portable() )
		return

	if(!powered(ENVIRON))
		spawn(rand(0,15))
			stat |= NOPOWER
			setstate()
	else
		stat &= ~NOPOWER
		setstate()


/obj/machinery/atmoalter/siphs/process()
	/*
//	var/dbg = (suffix=="d") && Debug

	if(stat & NOPOWER) return

	if (t_status != 3)
		var/turf/T = loc
		if (istype(T, /turf))
			if (locate(/obj/move, T))
				T = locate(/obj/move, T)
		else
			T = null
		switch(t_status)
			if(1.0)
				if( !portable() ) use_power(50, ENVIRON)
				if (holding)
					var/t1 = gas.total_moles()
					var/t2 = t1
					var/t = t_per
					if (t_per > t2)
						t = t2
					holding.gas.transfer_from(gas, t)
				else
					if (T)
						var/t1 = gas.total_moles()
						var/t2 = t1
						var/t = t_per
						if (t_per > t2)
							t = t2
						gas.turf_add(T, t)
			if(2.0)
				if( !portable() ) use_power(50, ENVIRON)
				if (holding)
					var/t1 = gas.total_moles()
					var/t2 = maximum - t1
					var/t = t_per
					if (t_per > t2)
						t = t2
					gas.transfer_from(holding.gas, t)
				else
					if (T)
						var/t1 = gas.total_moles()
						var/t2 = maximum - t1
						var/t = t_per
						if (t > t2)
							t = t2
						//var/g = gas.total_moles()
						//if(dbg) world.log << "VP0 : [t] from turf: [gas.total_moles()]"
						//if(dbg) Air()

						gas.turf_take(T, t)
						//if(dbg) world.log << "VP1 : now [gas.total_moles()]"

						//if(dbg) world.log << "[gas.total_moles()-g] ([t]) from turf to siph"

						//if(dbg) Air()
			if(4.0)
				if( !portable() )
					use_power(50, ENVIRON)

				if (T)
					if (T.firelevel > 900000.0)
						f_time = world.time + 300
					else
						if (world.time > f_time)
							var/difference = CELLSTANDARD - (T.oxygen + T.n2)
							if (difference > 0)
								var/t1 = gas.total_moles()
								if (difference > t1)
									difference = t1
								gas.turf_add(T, difference)

	updateDialog()

	setstate()
	return
	*/ //TODO: FIX

/obj/machinery/atmoalter/siphs/attack_ai(user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/atmoalter/siphs/attack_paw(user as mob)

	return attack_hand(user)
	return

/obj/machinery/atmoalter/siphs/attack_hand(var/mob/user as mob)

	if(stat & NOPOWER) return

	if(portable() && istype(user, /mob/living/silicon/ai)) //AI can't use portable siphons
		return

	user.machine = src
	var/tt
	switch(t_status)
		if(1.0)
			tt = text("Releasing <A href='?src=\ref[];t=2'>Siphon</A> <A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(2.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> Siphoning <A href='?src=\ref[];t=3'>Stop</A>", src, src)
		if(3.0)
			tt = text("<A href='?src=\ref[];t=1'>Release</A> <A href='?src=\ref[];t=2'>Siphon</A> Stopped <A href='?src=\ref[];t=4'>Automatic</A>", src, src, src)
		else
			tt = "Automatic equalizers are on!"
	var/ct = null
	switch(c_status)
		if(1.0)
			ct = text("Releasing <A href='?src=\ref[];c=2'>Accept</A> <A href='?src=\ref[];c=3'>Stop</A>", src, src)
		if(2.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> Accepting <A href='?src=\ref[];c=3'>Stop</A>", src, src)
		if(3.0)
			ct = text("<A href='?src=\ref[];c=1'>Release</A> <A href='?src=\ref[];c=2'>Accept</A> Stopped", src, src)
		else
			ct = "Disconnected"
	var/at = null
	if (t_status == 4)
		at = text("Automatic On <A href='?src=\ref[];t=3'>Stop</A>", src)
	var/dat = text("<TT><B>Canister Valves</B> []<BR>\n\t<FONT color = 'blue'><B>Contains/Capacity</B> [] / []</FONT><BR>\n\tUpper Valve Status: [] []<BR>\n\t\t<A href='?src=\ref[];tp=-[]'>M</A> <A href='?src=\ref[];tp=-10000'>-</A> <A href='?src=\ref[];tp=-1000'>-</A> <A href='?src=\ref[];tp=-100'>-</A> <A href='?src=\ref[];tp=-1'>-</A> [] <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=100'>+</A> <A href='?src=\ref[];tp=1000'>+</A> <A href='?src=\ref[];tp=10000'>+</A> <A href='?src=\ref[];tp=[]'>M</A><BR>\n\tPipe Valve Status: []<BR>\n\t\t<A href='?src=\ref[];cp=-[]'>M</A> <A href='?src=\ref[];cp=-10000'>-</A> <A href='?src=\ref[];cp=-1000'>-</A> <A href='?src=\ref[];cp=-100'>-</A> <A href='?src=\ref[];cp=-1'>-</A> [] <A href='?src=\ref[];cp=1'>+</A> <A href='?src=\ref[];cp=100'>+</A> <A href='?src=\ref[];cp=1000'>+</A> <A href='?src=\ref[];cp=10000'>+</A> <A href='?src=\ref[];cp=[]'>M</A><BR>\n<BR>\n\n<A href='?src=\ref[];mach_close=siphon'>Close</A><BR>\n\t</TT>", (!( alterable ) ? "<B>Valves are locked. Unlock with wrench!</B>" : "You can lock this interface with a wrench."), num2text(gas.return_pressure(), 10), num2text(maximum, 10), (t_status == 4 ? text("[]", at) : text("[]", tt)), (holding ? text("<BR>(<A href='?src=\ref[];tank=1'>Tank ([]</A>)", src, holding.air_contents.return_pressure()) : null), src, num2text(max_valve, 7), src, src, src, src, t_per, src, src, src, src, src, num2text(max_valve, 7), ct, src, num2text(max_valve, 7), src, src, src, src, c_per, src, src, src, src, src, num2text(max_valve, 7), user)
	user << browse(dat, "window=siphon;size=600x300")
	onclose(user, "siphon")
	return

/obj/machinery/atmoalter/siphs/Topic(href, href_list)
	if(..()) return 1

	if (usr.stat || usr.restrained())
		return
	if ((!( alterable )) && (!istype(usr, /mob/living/silicon/ai)))
		return
	if (((get_dist(src, usr) <= 1 || usr.telekinesis == 1) && istype(loc, /turf)) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["c"])
			var/c = text2num(href_list["c"])
			switch(c)
				if(1.0)
					c_status = 1
				if(2.0)
					c_status = 2
				if(3.0)
					c_status = 3
				else
		else
			if (href_list["t"])
				var/t = text2num(href_list["t"])
				if (t_status == 0)
					return
				switch(t)
					if(1.0)
						t_status = 1
					if(2.0)
						t_status = 2
					if(3.0)
						t_status = 3
					if(4.0)
						t_status = 4
						f_time = 1
					else
			else
				if (href_list["tp"])
					var/tp = text2num(href_list["tp"])
					t_per += tp
					t_per = min(max(round(t_per), 0), max_valve)
				else
					if (href_list["cp"])
						var/cp = text2num(href_list["cp"])
						c_per += cp
						c_per = min(max(round(c_per), 0), max_valve)
					else
						if (href_list["tank"])
							var/cp = text2num(href_list["tank"])
							if (cp == 1)
								holding.loc = loc
								holding = null
								if (t_status == 2)
									t_status = 3
		updateUsrDialog()

		add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/atmoalter/siphs/attackby(var/obj/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/tank))
		if (holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		holding = T
	else
		if (istype(W, /obj/item/weapon/screwdriver))
			var/obj/machinery/connector/con = locate(/obj/machinery/connector, loc)
			if (c_status)
				anchored = 0
				c_status = 0
				user.show_message("<span class='notice'>You have disconnected the siphon.</span>")
				if(con)
					con.connected = null
			else
				if (con && !con.connected)
					anchored = 1
					c_status = 3
					user.show_message("<span class='notice'>You have connected the siphon.</span>")
					con.connected = src
				else
					user.show_message("<span class='notice'>There is nothing here to connect to the siphon.</span>")


		else
			if (istype(W, /obj/item/weapon/wrench))
				alterable = !( alterable )
				if (alterable)
					to_chat(user, "<span class='notice'>You unlock the interface!</span>")
				else
					to_chat(user, "<span class='notice'>You lock the interface!</span>")
	return


