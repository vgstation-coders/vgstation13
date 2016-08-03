var/global/list/syndicate_roboticist_cameras = list(); //list of all the cameras
var/global/list/syndicate_roboticist_control_board = list(); //list of all control boards

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
  var/obj/item/device/syndicate_cyborg_camera_bug/current
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
      var/obj/item/device/syndicate_cyborg_control_board/board = device
      friendly_devices.Add(board.cyborg.name + "(Control Board)")
    if(istype(device, obj/item/device/syndicate_cyborg_camera_bug/))
      var/obj/item/device/syndicate_cyborg_camera_bug/camera = device
      friendly_devices.Add(camera.camera_target.name + "(Camera Bug)")
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_devices)
  if (!target)
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in devices)
    if (camera.camera_target.name + "(Camera Bug)" == target)
      target = camera
      break
  if(user.stat) return
  if(target && istype(target, obj/item/device/syndicate_cyborg_camera_bug/))
    user.client.eye = target
    user.set_machine(src)
    src.current = target
  else
    user.unset_machine()
    return

/obj/item/device/syndicate_reciver/check_eye(var/mob/user as mob)
  if ( src.loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current || !current.active )
    user.unset_machine()
    user.reset_view(user)
    src.current = null
    return null
  user.reset_view(current)
  return 1

//IMPORTANT
// Check MMI.dm and BORER.dm for making borg controlling boards
//IMPORTANT
/obj/item/device/syndicate_cyborg_control_board
  name = "Suspicious Looking Motherboard"
  desc = "A suspiciously looking motherboard with red and black colors. It seems it has connectors shaped like a Man-Machine Interface and an antenna."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_SMALL
  flags = FPRINT
  var/frequency = "syndicate" //in case someone wants to make a custom list of remote borgs
  var/active = 0 // check if the board is online
  var/mob/living/silicon/cyborg //robot that is under the control of this board
