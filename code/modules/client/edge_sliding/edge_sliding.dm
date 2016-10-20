#define TILE_HEIGHT 32
#define TILE_WIDTH 32
var/collider/slider/slider = new/collider/slider()

atom/movable
	var/can_slide = 1
	var/tmp/sliding = 0

/atom/movable/Move(atom/NewLoc,Dir=0,step_x=0,step_y=0)
	//call default action
	. = ..(NewLoc,Dir,step_x,step_y)
	if(!. && can_slide && !sliding)
		//if this mob is able to slide when colliding, and is currently not attempting to slide
		//mark that we are sliding
		sliding = 1
		//call to the global slider object to determine what direction our slide will happen in (if any)
		. = slider.slide(src,Dir,step_x,step_y)
		if(.)
			//if slider was able to slide, step us in the direction indicated
			. = step(src,.)
		//mark that we are no longer sliding
		sliding = 0

var
	list/__dirang = list(0,180,null,90,null,null,null,270)

//shortcut so you don't have to remember the list. Treat this like a proc.
#define Dir2Ang(d) (__dirang[(d)])

collider
	parent_type = /atom/movable
	slider
		density = 1
		var
			atom/movable/proxy
		proc
			slide(atom/movable/self,Dir=0,step_x=0,step_y=0)
				//might be a depth call, so store old data
				var/old_self = proxy
				var/old_bounds = src.bounds
				var/old_loc = src.loc
				var/old_sx = src.step_x
				var/old_sy = src.step_y

				proxy = self //used for advanced collision detection

				if(Dir & Dir - 1)
					//perform diagonal sliding
					src.bound_width = self.bound_width
					src.bound_height = self.bound_height

					//resize and relocate src to the correct position
					var/d = turn(Dir,-45)
					locate_corner(self,Dir)

					//test the first direction
					. = step(src,d,2)
					if(!.)
						//if failed, check the second (No need to move, already in position)
						d = turn(Dir,45)

						. = step(src,d,2)
						if(.)
							//return the slide direction
							. = d
					else
						//return the slide direction
						. = d
/*				else
					//perform linear sliding
					src.bound_width = self.bound_width/2
					src.bound_height = self.bound_height/2

					var/d = turn(Dir,-90)
					//move the bounding box to the correct corner
					locate_corner(self,Dir|d)

					//check if we can step
					. = step(src,Dir,2)
					if(!.)
						//if we can't step, try the opposite corner
						d = turn(Dir,90)
						locate_corner(self,Dir|d)

						//check if we can step
						. = step(src,Dir,2)
						if(.)
							//if successful, return the slide direction
							. = d
					else
						//if successful, return the slide direction
						. = d*/

				//restore old data
				src.proxy = old_self
				src.bounds = old_bounds
				src.step_x = old_sx
				src.step_y = old_sy
				src.loc = old_loc

			//this will position the slider over the calling mob in the correct position
			locate_corner(atom/movable/self,corner)
				//gather the directional components and get their angles
				var/d1 = corner & corner - 1
				var/d2 = Dir2Ang(corner ^ d1)
				d1 = Dir2Ang(d1)

				//set up the position based on the bounding coverage so that the slider is on the correct corner of the movable caller
				var/nx = (self.bound_width - src.bound_width) * max(sin(d1),0) + (self.x - 1) * TILE_WIDTH + self.step_x + self.bound_x
				var/ny = (self.bound_height - src.bound_height) * max(cos(d2),0) + (self.y - 1) * TILE_HEIGHT + self.step_y + self.bound_y

				//correct positioning
				src.step_x = nx % TILE_WIDTH
				src.step_y = ny % TILE_HEIGHT
				src.loc = locate(round(nx/TILE_WIDTH) + 1, round(ny/TILE_HEIGHT) + 1, self.z)

var
	list/opposite_dirs = list(SOUTH,NORTH,null,WEST,null,null,null,EAST)

client
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

	verb
		MoveKey(Dir as num,State as num)
			set hidden = 1
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

			//if earlier flag was set, and we now are going to be moving
			if(.&&move_dir)
				move_loop()

	North()
	South()
	East()
	West()

	proc
		move_loop()
			set waitfor = 0
			if(src.mloop) return
			mloop = 1
			src.Move(mob.loc,move_dir)
			while(src.move_dir)
				sleep(world.tick_lag)
				if(src.move_dir)
					src.Move(mob.loc,move_dir)
			mloop = 0