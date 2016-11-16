/*
* MODULE: Syndicate R.C. (Syndicate Remote Cyborg)
* Description: This .dm adds the following robotics traitor items: cyborg camera bugs, cyborg control boards and the syndicate remote controller
* Cyborg Camera Bugs: You can attach them to any silicon lifeform (AI, Cyborgs, pAI). It will allow you to see the user's screen almost one to one.
* If the user has some kind of special vision (security hud for exemple), you will not have access to that.
* Cyborg Control Boards: To use, you install this instead of a MMI when making a robot. It will create a cyborg as normal, but without a player to control it.
* With the syndicate controller, you can control the cyborg like any other player would, selecting a module, able to change your name, communicate with the AI.
* At the same time, you are linked to the cyborg consoles. So they can lock you down, and self-destruct the robot
* Syndicate Controller: Imagine a controller with a screen and a keyboard, you can see the borgs you put the cameras on, or control your own borg.
*
* Other things:
* Syndieborg: Just a borg that has the Cyborg Control Board. I made this so I could overwrite the login message, it doesn't make sense to have the player recieve the
* law messages any time he connects to the borg. So it now displays a message about how to log off from the borg.
* Frequency: Every object in this list has a frequency. You can make your own frequency by editing the variables. They all default to 'syndicate'.
* What it means is, only boards on the syndicate frequency can communicate with syndicate controllers. You can have your own 'network', if you could say so.
* Active: Just a 0 or 1 flag to state if the object (Camera or Control board) is online. Setting it to 0 will not instantly disconnect the player from the camera or borg though.
* It is just a flag for when making the list. It updates when the mob with the camera, or board, dies.
* Logoff Procedure: A small procedure made for the syndieborgs. It disconnects the player from the borg, allowing them to simply come back to their original body. Nice and easy.
* 'Fuck Up Procs': It's the verifiers when the user, who is controlling or watching the camera, gets fucked up
* (controller removed from his hands, downed, pushed, stunned, monkified, or anything that can disable him). It stops the user from viewing the camera,
* or controlling the borg as soon as the code allowed me to. You still get a small grace moment (around a second) when dealing with the control boards because the process() method
* has a timeout before it is called again.
* Global Lists: Two lists, one for cameras, other for boards. Easy to understand. They just contain all active cameras/boards. When a borg dies, it is removed from there.
* Attack Message Supression: Just overwritten methods to remove the "YOU FUCKING ATTACK THE TARGET WITH YOUR SECRET CAMERA".
*
* Stuff in other .DMs (If removing this module, please, mind these notes)
* Added in robot.dm, attackby():
* A verification about the camera, so it will not cause sparks
* uplink_item.dm:
* Added the box of items on the uplink_item.dm so the roboticist can pick the bundle to build a remote cyborg
*
*/

var/list/rc_cameras = list()
var/list/rc_control_boards = list()

/*
    START REMOTE CYBORG CAMERA SECTION
*/
/obj/item/device/syndicate_remote_cyborg_camera
  name = "\improper R.C. Camera"
  desc = "A tiny camera with a small antenna sticking to its side. It is able to transmit a signal to anything that can accept it. Seems to blend well with complex machinery."
  icon = 'icons/obj/RemoteCyborg.dmi'
  icon_state = "flashing_camera"
  w_class = W_CLASS_TINY
  item_state = ""
  throw_speed = 4
  throw_range = 20
  flags = NOBLUDGEON | FPRINT
  var/frequency = "syndicate"
  var/active = 0
  var/mob/camera_target

/obj/item/device/syndicate_remote_cyborg_camera/afterattack(atom/target, mob/user, proximity_flag)
  if (!proximity_flag)
    to_chat(user, "<span class='warning'>You are too far away to use this.</span>")
    return
  if(!istype(target, /mob/living/silicon/))
    to_chat(user, "<span class='warning'>You can only apply this to cyborgs.</span>")
    return
  if(istype(target, /mob/living/silicon/ai))
    to_chat(user, "<span class='warning'>You can not install this on an AI core.</span>")
    return
  if(istype(target, /mob/living/silicon/))
    user.drop_item(src, target)
    to_chat(user, "<span class='notice'>You install \the [src] on \the [target.name]'s surface.</span>")
    active = 1
    camera_target = target
    rc_cameras += src
/*
    END REMOTE CYBORG CAMERA SECTION
*/


/*
    START CONTROL BOARD SECTION
*/
/obj/item/device/syndicate_remote_cyborg_control_board
  name = "\improper R.C. Circuit Board"
  desc = "An off-putting looking board. Instead of standard green and yellow, it is black with red circuits, there is a small antenna on the side."
  icon = 'icons/obj/RemoteCyborg.dmi'
  icon_state = "syndie_board_01"
  w_class = W_CLASS_SMALL
  flags = FPRINT | NOBLUDGEON
  var/frequency = "syndicate"
  var/active = 0
  var/mob/living/silicon/cyborg
  var/inUse
  var/controller = null

/obj/item/device/syndicate_remote_cyborg_control_board/afterattack(atom/target, mob/user, proximity_flag)
  if(!istype(target, /obj/item/robot_parts/robot_suit))
    return
  var/obj/item/robot_parts/robot_suit/robot_suit = target
  var/turf/T = get_turf(robot_suit)
  if(robot_suit.check_completion())
    if(!istype(T,/turf))
      to_chat(user, "<span class='warning'>You can't put the motherboard in, the frame has to be standing on the ground to be perfectly precise.</span>")
      return

    var/mob/living/silicon/robot/remote_control_robot/robot = new /mob/living/silicon/robot/remote_control_robot(get_turf(target), unfinished = 1)
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
    robot.verbs += /mob/living/silicon/robot/remote_control_robot/proc/Exit_robot
    cyborg = robot
    active = 1
    rc_control_boards += src
    qdel(robot_suit)
    user.drop_item(src, robot)

  else
    to_chat(user, "<span class='notice'>This robot does not seem to be done. You need all parts to be in place in order to insert the remote control board.</span>")

/*
    END CONTROL BOARD SECTION
*/

/*
    START CONTROLLER SECTION
*/
/obj/item/device/syndicate_controller
  name = "\improper R.C. Controller"
  desc = "A Remote Cyborg Controller."
  icon_state = "handtv"
  flags = FPRINT
  w_class = W_CLASS_TINY
  var/obj/item/device/syndicate_remote_cyborg_camera/current_camera
  var/obj/item/device/syndicate_remote_cyborg_control_board/current_board
  var/frequency = "syndicate"
  var/user_ckey = ""
  var/mob/living/carbon/user_body
  var/active = 0

/obj/item/device/syndicate_controller/New()
  processing_objects.Add(src)

/obj/item/device/syndicate_controller/Destroy()
  processing_objects.Remove(src)

/obj/item/device/syndicate_controller/process()
  if(active == 0 || !current_board)
    return
  else
    var/mob/living/carbon/user = user_body
    if ( !user || user.isDead() || loc != user || user.held_items.Find(src) == 0 || user.blinded || !current_board || !current_board.active || current_board.cyborg.isDead() || user.monkeyizing || user.z != current_board.cyborg.z)
      current_board.inUse = null
      current_board.controller = null
      user.ckey = user_ckey
      user_body = null
      user_ckey = null
      active = 0
      current_board = null

/obj/item/device/syndicate_controller/attack_self(mob/user)
  var/list/devices = list()
  for(var/obj/item/device/syndicate_remote_cyborg_camera/camera in rc_cameras)
    if(camera.camera_target.isDead())
      camera.active = 0
      rc_cameras -= camera
    if(camera.frequency == frequency && camera.active == 1 && camera.camera_target.z == user.z)
      devices += camera
  for(var/obj/item/device/syndicate_remote_cyborg_control_board/board in rc_control_boards)
    if(board.cyborg.isDead())
      board.active = 0
      rc_control_boards -= board
    if(board.frequency == frequency && board.active == 1  && board.cyborg.z == user.z)
      devices += board
  if(!devices.len)
    to_chat(user, "<span class='warning'>No signals detected.</span>")
    return

  var/list/friendly_devices = new/list()

  for (var/obj/device in devices)
    if(istype(device, /obj/item/device/syndicate_remote_cyborg_control_board/))
      var/obj/item/device/syndicate_remote_cyborg_control_board/controlboard = device
      friendly_devices.Add(controlboard.cyborg.name + " (Control Board)")
    if(istype(device, /obj/item/device/syndicate_remote_cyborg_camera/))
      var/obj/item/device/syndicate_remote_cyborg_camera/camerabug = device
      friendly_devices.Add(camerabug.camera_target.name + " (Camera)")
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_devices)
  if (!target)
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_remote_cyborg_camera/camera in devices)
    if (camera.camera_target.name + " (Camera)" == target && !camera.camera_target.isDead())
      target = camera
      break
  for(var/obj/item/device/syndicate_remote_cyborg_control_board/board in devices)
    if (board.cyborg.name + " (Control Board)" == target && !board.cyborg.isDead())
      target = board
      break
  if(user.incapacitated()) return
  if(target && istype(target, /obj/item/device/syndicate_remote_cyborg_camera/))
    active = 1
    user.client.eye = target
    user.set_machine(src)
    current_camera = target
  if(target && istype(target, /obj/item/device/syndicate_remote_cyborg_control_board/))
    var/obj/item/device/syndicate_remote_cyborg_control_board/target_board = target
    if(target_board.inUse)
      to_chat(user, "<span class='warning'>This signal is already in use.</span>")
      return
    active = 1
    target_board.inUse = 1
    target_board.controller = src
    user_ckey = user.client.ckey
    user_body = user.client.mob
    current_board = target_board
    current_board.cyborg.ckey = user.client.ckey
  if(!target)
    user.unset_machine()

/obj/item/device/syndicate_controller/OnMobDeath(var/mob/user)
  if(active == 1)
    user.ckey = user_ckey
    active = 0
    current_board.inUse = 0


/obj/item/device/syndicate_controller/check_eye(var/mob/user)
  if ( loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current_camera || !current_camera.active || current_camera.camera_target.isDead() || current_camera.camera_target.z != user.z)
    active = 0
    user.unset_machine()
    user.reset_view(user)
    current_camera = null
    return 0
  user.reset_view(current_camera)
  return 1

/*
    END CONTROLLER SECTION
*/

/*
    START CYBORG OVERWRITTE SECTION
*/
/mob/living/silicon/robot/remote_control_robot

/mob/living/silicon/robot/remote_control_robot/show_laws()
  return

/mob/living/silicon/robot/remote_control_robot/Login()
  ..()
  to_chat(src, "<b>You can disconnect from the borg by using the R.C. Logoff function on the Robot Commands tab.</b>")
  return

/mob/living/silicon/robot/remote_control_robot/proc/Exit_robot()
  set category = "Robot Commands"
  set name = "R.C. Logoff"
  var/obj/item/device/syndicate_remote_cyborg_control_board/board = mmi
  var/obj/item/device/syndicate_controller/syndie_controller = board.controller
  syndie_controller.user_body.ckey = syndie_controller.user_ckey
  syndie_controller.active = 0
  syndie_controller.current_board = null
  board.controller = null
  board.inUse = 0
  return

/*
    END CYBORG OVERWRITTE SECTION
*/

//START REMOVE ATTACK MESSAGES//
/obj/item/device/syndicate_remote_cyborg_camera/attack(mob/M, mob/user, def_zone)
  return

/obj/item/device/syndicate_remote_cyborg_camera/attackby(obj/item/I, mob/user)
  return

/obj/item/device/syndicate_remote_cyborg_control_board/attack(mob/M, mob/user, def_zone)
  return

/obj/item/device/syndicate_remote_cyborg_control_board/attackby(obj/item/I, mob/user)
  return
//END REMOVE ATTACK MESSAGES//

/*
    START BOX
*/
/obj/item/weapon/storage/box/remotecontrolkit

/obj/item/weapon/storage/box/remotecontrolkit/New()
  ..()
  contents = list()
  new /obj/item/device/syndicate_remote_cyborg_control_board/(src)
  new /obj/item/device/syndicate_controller(src)
  for(var/i = 1 to 2)
    new /obj/item/device/syndicate_remote_cyborg_camera(src)

/*
    END BOX
*/
