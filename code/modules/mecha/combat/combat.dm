

/obj/mecha/combat
	force = MECHA_FORCE_COMBAT
	mecha_punch_sound = 'sound/mecha/mechsmash.ogg'
	internal_damage_threshold = 50
	light_range_off = 0 //combat mechs leak no cabin light for stealth operation
	cursor_enabled = 1 //cursor is enabled by default for combat mechs
	maint_access = 0
	//add_req_access = 0
	//operation_req_access = list(access_hos)
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.7,"laser"=0.85,"energy"=1,"bomb"=0.8)
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"

/*
/obj/mecha/combat/range_action(target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
	if(selected_weapon)
		selected_weapon.fire(target)
	return
*/

/obj/mecha/proc/melee_action(target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = safepick(oview(1,src))
	if(!istype(target, /atom))
		return
	if(!Adjacent(target))
		return
	var/image/fist_icon = image(icon = 'icons/mob/screen_spells.dmi', icon_state = "wiz_fist") //wizard fist placeholder for robot fist
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(src.occupant.a_intent == I_HURT)
			playsound(src, mecha_punch_sound, 50, 1)
			if(damtype == "brute")
				step_away(M,src,15)
			var/target_zone //null is acceptable here, apply_damage will just pick a target if it's necessary
			if(istype(target, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				target_zone = H.get_organ(pick(LIMB_CHEST, LIMB_CHEST, LIMB_CHEST, LIMB_HEAD)) //Mech attacks too unwieldly to directly target
			var/armor_reduction = 0 //Disabled, use = M.run_armor_check(target_zone, "melee") to have this enabled
			if (prob(50))//this is still busted but now you have a chance to get out of stunlock
				M.Paralyse(1)
			M.apply_damage(rand(force/2, force), damtype, target_zone, armor_reduction, 0, 0) //handles all the damage specifics such as updatehealth()
			src.occupant_message("You hit [target].")
			src.visible_message("<span class='red'><b>[src.name] hits [target].</b></span>")
			message_admins("[key_name_and_info(src.occupant)] mech punched [target] with [src.name] ([formatJumpTo(src)])",0,1)
			log_attack("[key_name(src.occupant)] mech punched [target] with [src.name] ([formatLocation(src)])")
		else
			step_away(M,src)
			src.occupant_message("You push [target] out of the way.")
			src.visible_message("[src] pushes [target] out of the way.")
			fist_icon = image(icon = 'icons/mob/screen_spells.dmi', icon_state = "wiz_push") //wizard hand placeholder for robot hand
		if(target) //in case target got gibbed, qdel'd, or some other horrible thing
			do_attack_animation(target, src, fist_icon)
	else
		for(var/target_type in src.destroyable_obj)
			if(istype(target, target_type) && hascall(target, "attackby"))
				playsound(src, mecha_punch_sound, 50, 1)
				src.occupant_message("You hit [target].")
				src.visible_message("<span class='red'><b>[src.name] hits [target].</b></span>")
				if(!istype(target, /turf/simulated/wall))
					target:attackby(src.fist,src.occupant)
				else if(prob(5))
					if ((force >= MECHA_FORCE_COMBAT) && !(target:dismantle_wall(1)))
						//this currently won't do anything to shuttle walls!
						//also this doesn't account for reinforced walls but whatever, I don't want to deal with this right now
						src.occupant_message("<span class='notice'>You smash through the wall.</span>")
						src.visible_message("<b>[src.name] smashes through the wall!</b>")
						playsound(src, 'sound/effects/stone_crumble.ogg', 50, 1)
					else
						src.occupant_message("<span class='notice'>You get a feeling that this [target] isn't gonna break ever.</span>")
				if(target) //in case wall got obliterated
					do_attack_animation(target, src, fist_icon)
				break
	occupant.delayNextAttack(MECHA_MELEE_DELAY)

/*
/obj/mecha/combat/proc/mega_shake(target)
	if(!istype(target, /obj) && !istype(target, /mob))
		return
	if(istype(target, /mob))
		var/mob/M = target
		M.Dizzy(3)
		M.adjustBruteLoss(1)
		M.updatehealth()
		for (var/mob/V in viewers(src))
			V.show_message("[src.name] shakes [M] like a rag doll.")
	return
*/

/*
	if(energy>0 && can_move)
		if(step(src,direction))
			can_move = 0
			spawn(step_in) can_move = 1
			if(overload)
				energy = energy-2
				health--
			else
				energy--
			return 1

	return 0
*/
/*
/obj/mecha/combat/hear_talk(mob/M as mob, text)
	..()
	if(am && M==occupant)
		if(findtext(text,""))
			sam()
	return

/obj/mecha/combat/proc/sam()
	if(am)
		var/window = {"<html>
							<head>
							<style>
							body {background:#000;color: #00ff00;font-family:"Courier",monospace;font-size:12px;}
							#target {word-wrap: break-word;width:100%;padding-right:2px;}
							#form {display:none;padding:0;margin:0;}
							#input {background:#000;color: #00ff00;font-family:"Courier",monospace;border:none;padding:0;margin:0;width:90%;font-size:12px;}
							</style>
							<script type="text/javascript">
							var text = "SGNL RCVD\\nTAG ANL :: STTS ACCPTD \\nINITSOC{buff:{128,0,NIL};p:'-zxf';stddev;inenc:'bin';outenc:'plain'}\\nSOD ->\\n0010101100101011001000000101010001101000011010010111001100100000011011010110000101100011011010000110100101101110011001010010000001101001011100110010000001100100011010010111001101100011011010000110000101110010011001110110010101100100001000000110100101101110011101000110111100100000011110010110111101110101011100100010000001100011011000010111001001100101001000000010101100101011000011010000101000101011001010110010000001000110011010010110011101101000011101000010000001110111011010010111010001101000001000000111010001101000011010010111001100100000011011010110000101100011011010000110100101101110011001010010110000100000011000010110111001100100001000000110011101110101011000010111001001100100001000000110100101110100001000000110011001110010011011110110110100100000011101000110100001100101001000000111001101101000011000010110110101100101001000000110111101100110001000000110010001100101011001100110010101100001011101000010000000101011001010110000110100001010001010110010101100100000010100110110010101110010011101100110010100100000011101000110100001101001011100110010000001101101011000010110001101101000011010010110111001100101001011000010000001100001011100110010000001111001011011110111010100100000011101110110111101110101011011000110010000100000011010000110000101110110011001010010000001100110011010010110011101101000011101000010000001101001011101000010000001100110011011110111001000100000011110010110111101110101001000000010101100101011\\n<- EOD\\nSOCFLUSH\\n";
							var target_id = "target";
							var form_id = "form";
							var input_id = "input";
							var delay=5;
							var currentChar=0;
							var inter;
							var cur_el;
							var maiden_el;

							function type()
							{
							  maiden_el = cur_el = document.getElementById(target_id);
							  if(cur_el && typeof(cur_el)!='undefined')
							  	{
									inter = setInterval(function(){appendText(cur_el)},delay);
							  }
							}

							function appendText(el){
								if(currentChar>text.length)
									{
									maiden_el.style.border = 'none';
									clearInterval(inter);
									var form = document.getElementById(form_id);
									var input = document.getElementById(input_id);
									if((form && typeof(form)!='undefined') && (input && typeof(input)!='undefined'))
										{
										form.style.display = 'block';
										input.focus();
									}
									return;
								}
								var tchar = text.substr(currentChar, 1);
								if(tchar=='\\n')
									{
									el = cur_el = document.createElement('div');
									maiden_el.appendChild(cur_el);
									currentChar++;
									return;
								}
								if(!el.firstChild)
									{
									var tNode=document.createTextNode(tchar);
									el.appendChild(tNode);
								}
								else
									{
									el.firstChild.nodeValue = el.firstChild.nodeValue+tchar
								}
								currentChar++;
							}

							function addSubmitEvent(form, input) {
							    input.onkeydown = function(e) {
							        e = e || window.event;
							        if (e.keyCode == 13)
							        	{
							            form.submit();
							            return false;
							        }
							    };
							}

							window.onload = function(){
								var form = document.getElementById(form_id);
								var input = document.getElementById(input_id);
								if((!form || typeof(form)=='undefined') || (!input || typeof(input)=='undefined'))
									{
									return false;
								}
								addSubmitEvent(form,input);
								type();
							}
							</script>
							</head>
							<body>
							<div id="wrapper"><div id="target"></div>
							<form id="form" name="form" action="byond://" method="get">
							<label for="input">&gt;</label><input name="saminput" type="text" id="input" value="" />
							<input type=\"hidden\" name=\"src\" value=\"\ref[src]\">
							</form>
							</div>
							</body>
							</html>
						  "}
		occupant << browse(window, "window=sam;size=800x600;")
		onclose(occupant, "sam", src)
	return
*/

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/topic_filter = new (href,href_list)
	if(topic_filter.get("close"))
		am = null
		return
	/*
	if(filter.get("saminput"))
		if(md5(filter.get("saminput")) == am)
			occupant_message("From the lies of the Antipath, Circuit preserve us.")
		am = null
	return
	*/
