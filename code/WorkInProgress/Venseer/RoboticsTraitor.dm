//TODO LIST
//*Make my own sprites

/*
* Description: This .dm adds the following robotics traitor items: cyborg camera bugs, cyborg control boards and the syndicate reciever
* Cyborg Camera Bugs: You can attach them to any silicon lifeform (AI, Cyborgs, pAI). It will allow you to see the user's screen almost one to one.
* If the user has some kind of special vision (security hud for exemple), you will not have access to that.
* Cyborg Control Boards: To use, you install this instead of a MMI when making a robot. It will create a cyborg as normal, but without a player to control it.
* With the syndicate reciever, you can control the cyborg like any other player would, selecting a module, able to change your name, communicate with the AI.
* At the same time, you are linked to the cyborg consoles. So they can lock you down, and self-destruct you
* Syndicate Reciever: Imagine a controller with a screen and a keyboard, you can see the borgs you put the cameras on, or control your own borg.
*
* Other things:
* Syndieborg: Just a borg that has the Cyborg Control Board. I made this so I could overwrite the login message, it doesn't make sense to have the player recieve the
* law messages any time he connects to the borg. So it now displays a message about how to log off from the borg.
* Frequency: Every object in this list has a frequency. You can make your own frequency by editing the variables. They all default to 'syndicate'.
* What it means is, only boards on the syndicate frequency can communicate with syndicate recievers. You can have your own 'network', if you could say so.
* Active: Just a 0 or 1 flag to state if the object (Camera or Control board) is online. Setting it to 0 will not instantly disconnect the player from the camera or borg though.
* It is just a flag for when making the list. It updates when the mob with the camera, or board, dies.
* Logoff Procedure: A small procedure made for the syndieborgs. It disconnects the player from the borg, allowing them to simply come back to their original body. Nice and easy.
* 'Fuck Up Procs': It's the verifiers when the user, who is controlling or watching the camera, gets fucked up
* (controller removed from his hands, downed, pushed, stunned, monkified, or anything that can disable him). It stops the user from viewing the camera,
* or controlling the borg as soon as the code allowed me to. You still get a small grace moment (around a second) when dealing with the control boards because the process() method
* has a timeout before it is called again.
* Global Lists: Two lists, one for cameras, other for boards. Easy to understand. They just contain all active cameras/boards. When a borg dies, it is removed from there.
* Attack Message Supression: Just overwritten methods to remove the "YOU FUCKING ATTACK THE TARGET WITH YOUR SECRET CAMERA".
*/

var/global/list/syndicate_roboticist_cameras = list(); //list of all the cameras
var/global/list/syndicate_roboticist_control_board = list(); //list of all control boards

/*
    START CAMERA BUGS SECTION
*/
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
  var/frequency = "syndicate"
  var/active = 0
  var/mob/camera_target

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
/*
    END CAMERA BUGS SECTION
*/


/*
    START CONTROL BOARD SECTION
*/
/obj/item/device/syndicate_cyborg_control_board
  name = "Suspicious Looking Circuit Board"
  desc = "A suspiciously looking circuit board with red and black colors. It seems it has connectors shaped like a Man-Machine Interface and an antenna."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_SMALL
  flags = FPRINT | NOBLUDGEON
  var/frequency = "syndicate"
  var/active = 0
  var/mob/living/silicon/cyborg
  var/inUse
  var/controller = null

/obj/item/device/syndicate_cyborg_control_board/afterattack(atom/target, mob/user as mob, proximity_flag)
  if(!istype(target, /obj/item/robot_parts/robot_suit))
    return
  var/obj/item/robot_parts/robot_suit/robot_suit = target
  var/turf/T = get_turf(robot_suit)
  if(robot_suit.check_completion())
    if(!istype(T,/turf))
      to_chat(user, "<span class='warning'>You can't put the motherboard in, the frame has to be standing on the ground to be perfectly precise.</span>")
      return

    var/mob/living/silicon/robot/mind_control_robot/robot = new /mob/living/silicon/robot/mind_control_robot(get_turf(target), unfinished = 1)
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
    robot.mmi = src
    robot.verbs += /mob/living/silicon/robot/mind_control_robot/proc/Exit_robot
    src.cyborg = robot
    src.active = 1
    syndicate_roboticist_control_board += src
    feedback_inc("cyborg_birth",1)
    qdel(robot_suit)
    robot.emagged = 1
    user.drop_item(src, robot)

  else
    to_chat(user, "<span class='notice'>This robot does not seem to be done. You need all parts to inser the remote control body.</span>")

/*
    END CONTROL BOARD SECTION
*/

/*
    START RECIEVER SECTION
*/
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
  var/mob/living/carbon/user_body
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
    if ( src.loc != user || user.canmove == 0 || (user.active_hand != 1 && user.active_hand != 2) || user.held_items.Find(src) == 0 || user.blinded || !src.current_board || !src.current_board.active || src.current_board.cyborg.isDead() || user.monkeyizing && user)
      src.current_board.inUse = null
      src.current_board.controller = null
      user.ckey = src.user_ckey
      src.user_body = null
      src.user_ckey = null
      src.active = 0
      src.current_board = null
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
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_devices)
  if (!target)
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in devices)
    if (camera.camera_target.name + " (Camera)" == target && !camera.camera_target.isDead())
      target = camera
      break
  for(var/obj/item/device/syndicate_cyborg_control_board/board in devices)
    if (board.cyborg.name + " (Control Board)" == target && !board.cyborg.isDead())
      target = board
      break
  if(user.stat) return
  if(target && istype(target, /obj/item/device/syndicate_cyborg_camera_bug/))
    active = 1
    user.client.eye = target
    user.set_machine(src)
    src.current_camera = target
  if(target && istype(target, /obj/item/device/syndicate_cyborg_control_board/))
    var/obj/item/device/syndicate_cyborg_control_board/target_board = target
    if(target_board.inUse)
      to_chat(user, "<span class='warning'>This signal is already in use.</span>")
      return
    active = 1
    target_board.inUse = 1
    target_board.controller = src
    user_ckey = user.client.ckey
    user_body = user.client.mob
    src.current_board = target_board
    src.current_board.cyborg.ckey = user.client.ckey
  if(!target)
    user.unset_machine()
    return

/obj/item/device/syndicate_reciever/check_eye(var/mob/user as mob)
  if ( src.loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current_camera || !current_camera.active || current_camera.camera_target.isDead())
    src.active = 0
    user.unset_machine()
    user.reset_view(user)
    src.current_camera = null
    return null
  user.reset_view(current_camera)
  return 1

/*
    END RECIEVER SECTION
*/

/*
    START CYBORG OVERWRITTE SECTION
*/
/mob/living/silicon/robot/mind_control_robot

/mob/living/silicon/robot/mind_control_robot/show_laws()
  return

/mob/living/silicon/robot/mind_control_robot/Login()
  ..()
  to_chat(src, "<b>You can disconnect from the borg by using the logoff function on the Robot Commands tab.</b>")
  return

/mob/living/silicon/robot/mind_control_robot/proc/Exit_robot()
  set category = "Robot Commands"
  set name = "Logoff"
  var/obj/item/device/syndicate_cyborg_control_board/board = src.mmi
  var/obj/item/device/syndicate_reciever/syndie_controller = board.controller
  syndie_controller.user_body.ckey = syndie_controller.user_ckey
  syndie_controller.active = 0
  syndie_controller.current_board = null
  board.controller = null
  board.inUse = 0

/*
    END CYBORG OVERWRITTE SECTION
*/

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
