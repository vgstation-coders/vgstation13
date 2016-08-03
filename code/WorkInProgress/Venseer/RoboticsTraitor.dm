var/global/list/syndicate_roboticist_cameras = list();
/obj/item/device/syndicate_cyborg_camera_bug
  name = "Cyborg Camera Bug"
  desc = "A crafty device designed by the syndicate. It can be placed inside on a cyborg. It will infiltrate the cyborg's sensors and transmit those in a encrypted signal to a reciever."
  icon = 'icons/obj/device.dmi'
  icon_state = "implant_evil"
  w_class = W_CLASS_TINY
  item_state = ""
  throw_speed = 4
  throw_range = 20
  flags = FPRINT  | NOBLUDGEON
  var/frequency = "syndicate"
  var/active = 0
  var/mob/camera_target

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

/obj/item/device/syndicate_reciver
  name = "Remote Cyborg Reciver"
  desc = "A weird looking device, with two thumbsticks, a set of buttons, a screen and a speaker."
  icon_state = "handtv"
  w_class = W_CLASS_TINY
  var/obj/item/device/syndicate_cyborg_camera_bug/current
  var/frequency = "syndicate"

/obj/item/device/syndicate_reciver/attack_self(mob/user as mob)
  var/list/cameras = list()
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in syndicate_roboticist_cameras)
    if(camera.frequency == frequency)
      cameras += camera
  if(!cameras.len)
    to_chat(user, "<span class='warning'>No signals detected.</span>")
    return

  var/list/friendly_cameras = new/list()

  for (var/obj/item/device/syndicate_cyborg_camera_bug/camera in cameras)
    friendly_cameras.Add(camera.camera_target.name)
  var/target = input("Select a signal.", null) as null|anything in sortList(friendly_cameras)
  if (!target)
    user.unset_machine()
    user.reset_view(user)
    return
  for(var/obj/item/device/syndicate_cyborg_camera_bug/camera in cameras)
    if (camera.camera_target.name == target)
      target = camera
      break
  if(user.stat) return
  if(target)
    user.client.eye = target
    user.set_machine(src)
    src.current = target
  else
    user.unset_machine()
    return

/obj/item/device/syndicate_reciver/check_eye(var/mob/user as mob)
  if ( src.loc != user || user.get_active_hand() != src || !user.canmove || user.blinded || !current || !current.active )
    return null
  user.reset_view(current)
  return 1
