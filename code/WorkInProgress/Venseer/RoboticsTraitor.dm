var/global/list/syndicate_roboticist_cameras = list(); //list of all the cameras
var/global/list/syndicate_roboticist_control_board = list(); //list of all control boards

//TODO LIST
//*Check MMI.dm, ROBOT_PARTS.dm and BORER.dm for making borg controlling boards
//*Check https://github.com/ComicIronic/vgstation13.git Neural branch.
//*Make my own sprites
//Check blungeon bug on camera_bug
//test this shit, been three days since I code w/o test


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
  if(istype(target, /mob/living/silicon/) && !istype(target, /mob/living/silicon/ai))
    user.drop_item(src, target)
    to_chat(user, "<span class='notice'>You install \the [src] on \the [target.name]'s surface.</span>")
    active = 1
    camera_target = target
    syndicate_roboticist_cameras += src
    return 1
  if(!istype(target, /mob/living/silicon/))
    to_chat(user, "<span class='warning'>You can only apply this to cyborgs.</span>")
    return 0
  if(istype(target, /mob/living/silicon/ai))
    to_chat(user, "<span class='warning'>You can not install this on an AI core.</span>")
    return 0

/obj/item/device/syndicate_reciver
  name = "Remote Cyborg Reciver"
  desc = "A weird looking device, with two thumbsticks, a set of buttons, a screen and a speaker."
  icon_state = "handtv"
  w_class = W_CLASS_TINY
  var/obj/item/device/syndicate_cyborg_camera_bug/current_camera
  var/frequency = "syndicate"

/obj/item/device/syndicate_reciver/attack_self(mob/user as mob)
  var/list/devices = list()
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in syndicate_roboticist_cameras)
    if(camera.camera_target.isDead())
      camera.active = 0
      syndicate_roboticist_devices -= camera
      if(camera.frequency == frequency)
        devices += camera
  for(var/obj/item/device/syndicate_cyborg_control_board/board in syndicate_roboticist_control_board)
    if(board.cyborg.isDead())
      board.active = 0
      syndicate_roboticist_control_board -= board
      if(board.frequency == frequency)
        devices += board
  if(!devices.len)
    to_chat(user, "<span class='warning'>No signals detected.</span>")
    return

  var/list/friendly_devices = new/list()

  for (var/obj/device in devices)
    if(istype(device, obj/item/device/syndicate_cyborg_control_board/))
      var/obj/item/device/syndicate_cyborg_control_board/controlboard = device
      friendly_devices.Add(controlboard.cyborg.name + "(Control Board)")
    if(istype(device, obj/item/device/syndicate_cyborg_camera_bug/))
      var/obj/item/device/syndicate_cyborg_camera_bug/camerabug = device
      friendly_devices.Add(camerabug.camera_target.name + "(Camera Bug)")
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_devices) //give list of devices
  if (!target) // if not chosen, cancel the the remote view in cameras, code below cleans machine from user and reset it view back to character
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in devices)
    if (camera.camera_target.name + "(Camera Bug)" == target)
      target = camera // Set target as selected camera
      break
  if(user.stat) return
  if(target && istype(target, obj/item/device/syndicate_cyborg_camera_bug/))
    user.client.eye = target  // set user's eyes to the camera
    user.set_machine(src) //>without this client.eye resets every moment
    src.current_camera = target // add current selected camera to TV for reference
  else
    user.unset_machine() // clean machine from user, rest of cleaning is done by the game
    return

//check if the user is fucked up or the camera target ended up dead
/obj/item/device/syndicate_reciver/check_eye(var/mob/user as mob)
  if ( src.loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current_camera || !current_camera.active || current_camera.camera_target.isDead())
    user.unset_machine() //clean machine for user
    user.reset_view(user) // reset view back to character
    src.current_camera = null // clean source so TV won't work atuomatically on changing hands
    return null
  user.reset_view(current_camera) // why do I even have to do this, must be fucking heavy on the server
  return 1


/obj/item/device/syndicate_cyborg_control_board
  name = "Suspicious Looking Circuit Board"
  desc = "A suspiciously looking circuit board with red and black colors. It seems it has connectors shaped like a Man-Machine Interface and an antenna."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_SMALL
  flags = FPRINT
  var/frequency = "syndicate" //in case someone wants to make a custom list of remote borgs
  var/active = 0 // check if the board is online
  var/mob/living/silicon/cyborg //robot that is under the control of this board

/obj/item/device/syndicate_cyborg_control_board/attackby(var/obj/item/object as obj, var/mob/user as mob)
  if(!istype(object, /obj/item/robot_parts/robot_suit))
    return
  var/obj/item/robot_parts/robot_suit/robot_suit = object
  var/turf/T = get_turf(object)
  if(robot_suit.check_completion()) //if robot suit is completed
    if(!istype(T,/turf))
      to_chat(user, "<span class='warning'>You can't put the motherboard in, the frame has to be standing on the ground to be perfectly precise.</span>")
      return

    //Code below creates a robot without a mind. A robot in standby mode
    var/mob/living/silicon/robot/robot = new /mob/living/silicon/robot(get_turf(T), unfinished = 1)
    robot.invisibility = 0
    robot.custom_name = created_name
    robot.updatename("Default")
    robot.job = "Cyborg"
    robot.cell = chest.cell
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

  else
    to_chat(user, "<span class='notice'>This robot does not seem to be ready for remote control.</span>")
