var/global/list/syndicate_roboticist_cameras = list(); //list of all the cameras
var/global/list/syndicate_roboticist_control_board = list(); //list of all control boards

//TODO LIST
//*Make my own sprites
//Check blungeon bug on camera_bug


/obj/item/device/syndicate_cyborg_camera_bug
  name = "Cyborg Camera Bug"
  desc = "A tiny weird looking device with a few wires sticking out and a small antenna."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_TINY
  item_state = ""
  throw_speed = 4
  throw_range = 20
  flags = NOBLUDGEON | FPRINT
  var/frequency = "syndicate" //in case someone wants to make a custom list of cameras
  var/active = 0 // check if the camera is online
  var/mob/camera_target //target that is stuck to

/obj/item/device/syndicate_cyborg_camera_bug/afterattack(atom/target, mob/user, proximity_flag)
  if (proximity_flag != 1)
    to_chat(user, "<span class='warning'>You are too far away to use this.</span>")
    return
  if(!istype(target, /mob/living/silicon/))
    to_chat(user, "<span class='warning'>You can only apply this to cyborgs.</span>")
    return
  if(istype(target, /mob/living/silicon/ai))
    to_chat(user, "<span class='warning'>You can not install this on an AI core.</span>")
    return
  if(istype(target, /mob/living/silicon/) && !istype(target, /mob/living/silicon/ai))
    user.drop_item(src, target)
    to_chat(user, "<span class='notice'>You install \the [src] on \the [target.name]'s surface.</span>")
    active = 1
    camera_target = target
    syndicate_roboticist_cameras += src
    return

/obj/item/device/syndicate_cyborg_control_board
  name = "Suspicious Looking Circuit Board"
  desc = "A suspiciously looking circuit board with red and black colors. It seems it has connectors shaped like a Man-Machine Interface and an antenna."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_SMALL
  flags = FPRINT | NOBLUDGEON
  var/frequency = "syndicate" //in case someone wants to make a custom list of remote borgs
  var/active = 0 // check if the board is online
  var/mob/living/silicon/cyborg //robot that is under the control of this board

/obj/item/device/syndicate_cyborg_control_board/afterattack(atom/target, mob/user as mob, proximity_flag)
  if(!istype(target, /obj/item/robot_parts/robot_suit))
    return
  var/obj/item/robot_parts/robot_suit/robot_suit = target
  var/turf/T = get_turf(robot_suit)
  if(robot_suit.check_completion()) //if robot suit is completed
    if(!istype(T,/turf))
      to_chat(user, "<span class='warning'>You can't put the motherboard in, the frame has to be standing on the ground to be perfectly precise.</span>")
      return

    //Code below creates a robot without a mind. A robot in standby mode
    var/mob/living/silicon/robot/robot = new /mob/living/silicon/robot(get_turf(target), unfinished = 1)
    robot.invisibility = 0
    robot.custom_name = robot_suit.created_name
    robot.updatename("Default")
    robot.job = "Cyborg"
    robot.cell = robot_suit.chest.cell
    robot.cell.loc = robot
    if(robot.cell)
      var/datum/robot_component/cell_component = robot.components["power cell"]
      cell_component.wrapped = robot.cell
      cell_component.installed = 1
    src.cyborg = robot //set the robot to the board
    src.active = 1 //set the board as active
    syndicate_roboticist_control_board += src //add board on list
    feedback_inc("cyborg_birth",1)
    qdel(robot_suit)
    //Setup Cyborg
    robot.scrambledcodes = 1
    robot.emagged = 1
    robot.connected_ai = null
    robot.laws = null
    //End setup
    user.drop_item(src, robot)

  else
    to_chat(user, "<span class='notice'>This robot does not seem to be done. You need all parts to inser the remote control body.</span>")

/obj/item/device/syndicate_reciever
  name = "Remote Cyborg Reciver"
  desc = "A weird looking device, with two thumbsticks, a set of buttons, a screen and a speaker."
  icon_state = "handtv"
  flags = FPRINT
  w_class = W_CLASS_TINY
  var/obj/item/device/syndicate_cyborg_camera_bug/current_camera
  var/obj/item/device/syndicate_cyborg_control_board/current_board
  var/frequency = "syndicate"
  var/user_ckey = ""
  var/user_body
  var/active = 0

/obj/item/device/syndicate_reciever/New()
  processing_objects.Add(src)

/obj/item/device/syndicate_reciever/Destroy()
  processing_objects.Remove(src)

/obj/item/device/syndicate_reciever/process()
  if(src.active == 0 || !(src.current_board))
    return
  else
    var/mob/living/carbon/user = src.user_body
    if ( src.loc != user || user.canmove == 0 || (user.active_hand != 1 && user.active_hand != 2) || user.held_items.Find(src) == 0 || user.blinded || !current_board || !current_board.active || current_board.cyborg.isDead() || user.monkeyizing && user)
      user.ckey = src.user_ckey
      src.user_body = null
      src.user_ckey = null
      src.active = 0
      return
    else
      return


/obj/item/device/syndicate_reciever/attack_self(mob/user as mob)
  var/list/devices = list()
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in syndicate_roboticist_cameras)
    if(camera.camera_target.isDead())
      camera.active = 0
      syndicate_roboticist_cameras -= camera
    if(camera.frequency == frequency && camera.active == 1)
      devices += camera
  for(var/obj/item/device/syndicate_cyborg_control_board/board in syndicate_roboticist_control_board)
    if(board.cyborg.isDead())
      board.active = 0
      syndicate_roboticist_control_board -= board
    if(board.frequency == frequency && board.active == 1)
      devices += board
  if(!devices.len)
    to_chat(user, "<span class='warning'>No signals detected.</span>")
    return

  var/list/friendly_devices = new/list()

  for (var/obj/device in devices)
    if(istype(device, /obj/item/device/syndicate_cyborg_control_board/))
      var/obj/item/device/syndicate_cyborg_control_board/controlboard = device
      friendly_devices.Add(controlboard.cyborg.name + " (Control Board)")
    if(istype(device, /obj/item/device/syndicate_cyborg_camera_bug/))
      var/obj/item/device/syndicate_cyborg_camera_bug/camerabug = device
      friendly_devices.Add(camerabug.camera_target.name + " (Camera)")
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_devices) //give list of devices
  if (!target) // if not chosen, cancel the the remote view in cameras, code below cleans machine from user and reset it view back to character
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in devices)
    if (camera.camera_target.name + " (Camera)" == target && !camera.camera_target.isDead())
      target = camera // Set target as selected camera
      break
  for(var/obj/item/device/syndicate_cyborg_control_board/board in devices)
    if (board.cyborg.name + " (Control Board)" == target && !board.cyborg.isDead())
      target = board // Set target as selected board
      break
  if(user.stat) return
  if(target && istype(target, /obj/item/device/syndicate_cyborg_camera_bug/))
    active = 1
    user.client.eye = target  // set user's eyes to the camera
    user.set_machine(src) //>without this client.eye resets every moment
    src.current_camera = target // add current selected camera to TV for reference
  if(target && istype(target, /obj/item/device/syndicate_cyborg_control_board/))
    active = 1
    user_ckey = user.client.ckey
    user_body = user.client.mob //set user body to machine
    src.current_board = target
    user.client.mob = src.current_board.cyborg  // control the robot
  if(!target)
    user.unset_machine() // clean machine from user, rest of cleaning is done by the game
    return

//check if the user is fucked up or the camera target ended up dead
/obj/item/device/syndicate_reciever/check_eye(var/mob/user as mob)
  if ( src.loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current_camera || !current_camera.active || current_camera.camera_target.isDead())
    src.active = 0
    user.unset_machine() //clean machine for user
    user.reset_view(user) // reset view back to character
    src.current_camera = null // clean source so TV won't work atuomatically on changing hands
    return null
  user.reset_view(current_camera)
  return 1


//START REMOVE ATTACK MESSAGES//
/obj/item/device/syndicate_cyborg_camera_bug/attack(mob/M as mob, mob/user as mob, def_zone)
  return

/obj/item/device/syndicate_cyborg_camera_bug/attackby(obj/item/I as obj, mob/user as mob)
	return

/obj/item/device/syndicate_cyborg_control_board/attack(mob/M as mob, mob/user as mob, def_zone)
  return

/obj/item/device/syndicate_cyborg_control_board/attackby(obj/item/I as obj, mob/user as mob)
	return
//END REMOVE ATTACK MESSAGES//
