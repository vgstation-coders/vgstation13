var/list/opposite_dirs = list(SOUTH,NORTH,null,WEST,null,null,null,EAST)

/client
	var/tmp
		mloop = 0
		move_dir = 0 //keep track of the direction the player is currently trying to move in.
		true_dir = 0
		keypresses = 0
		CAN_MOVE_DIAGONALLY = 0

	//rebind your interface so that your north/south/east/west keypresses are bound to:
	//keydown: MoveKey [Direction] 1
	//keyup: MoveKey [Direction] 0
	//Directions:
	//NORTH = 1
	//SOUTH = 2
	//EAST = 4
	//WEST = 8

/client/verb/MoveKey(Dir as num,State as num)
	set hidden = 1
	set instant = 1
	//if we are currently not moving at the start of this function call, set a flag for later
	if(!move_dir)
		. = 1
	//get the opposite direction
	var/opposite = opposite_dirs[Dir]
	if(State)
		//turn on the bitflags
		move_dir |= Dir
		keypresses |= Dir
		//make sure that conflicting directions result in the newest one being dominant.
		if(opposite&keypresses)
			move_dir &= ~opposite

	else
		//turn off the bitflags
		move_dir &= ~Dir
		keypresses &= ~Dir

		//restore non-dominant directional keypress
		if(opposite&keypresses)
			move_dir |= opposite

		else
			move_dir |= keypresses

	if(CAN_MOVE_DIAGONALLY)
		true_dir = move_dir
	else
		true_dir = move_dir^(move_dir&move_dir-1)

	//if earlier flag was set, and we now are going to be moving
	if(.&&true_dir)
		move_loop()

/client/North()
/client/South()
/client/East()
/client/West()

/client/proc/move_loop()
	set waitfor = 0
	if(src.mloop) return
	mloop = 1
	src.Move(mob.loc,true_dir)
	while(src.true_dir)
		sleep(world.tick_lag)
		if(src.true_dir)
			src.Move(mob.loc,true_dir)
	mloop = 0

