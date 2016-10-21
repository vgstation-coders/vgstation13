var/list/opposite_dirs = list(SOUTH,NORTH,null,WEST,null,null,null,EAST)

/client
	var/tmp
		mloop = 0
		move_dir = 0 //keep track of the direction the player is currently trying to move in.
		keypresses = 0

	//rebind your interface so that your north/south/east/west keypresses are bound to:
	//keydown: MoveKey [Direction] 1
	//keyup: MoveKey [Direction] 0
	//Directions:
	//NORTH = 1
	//SOUTH = 2
	//EAST = 4
	//WEST = 8

//#define ALLOW_DIAGONAL_MOVEMENT
/client/verb/MoveKey(Dir as num,State as num)
	set hidden = 1
	set instant = 1
	//if we are currently not moving at the start of this function call, set a flag for later
	if(!move_dir)
		. = 1
#ifdef ALLOW_DIAGONAL_MOVEMENT
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
#else
	if(State)
		move_dir = Dir
	else
		move_dir &= ~Dir
#endif
	//if earlier flag was set, and we now are going to be moving
	if(.&&move_dir)
		move_loop()

/client/North()
/client/South()
/client/East()
/client/West()

/client/proc/move_loop()
	set waitfor = 0
	if(src.mloop) return
	mloop = 1
	src.Move(mob.loc,move_dir)
	while(src.move_dir)
		sleep(world.tick_lag)
		if(src.move_dir)
			src.Move(mob.loc,move_dir)
	mloop = 0

