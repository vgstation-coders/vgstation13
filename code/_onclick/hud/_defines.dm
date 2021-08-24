/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Overlays that cover the entire screen
#define ui_entire_screen "WEST,SOUTH TO EAST,NORTH"

//Lower left, persistant menu
#define ui_inventory "WEST:[6*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"

//Lower center, persistant menu
#define ui_sstore1 "WEST+2:[10*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_id "WEST+3:[12*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_belt "WEST+4:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_back "CENTER-2:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_rhand "CENTER-1:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_lhand "CENTER:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_equip "CENTER-1:[16*PIXEL_MULTIPLIER],SOUTH+1:[5*PIXEL_MULTIPLIER]"
#define ui_swaphand1 "CENTER-1:[16*PIXEL_MULTIPLIER],SOUTH+1:[5*PIXEL_MULTIPLIER]"
#define ui_swaphand2 "CENTER:[16*PIXEL_MULTIPLIER],SOUTH+1:[5*PIXEL_MULTIPLIER]"
#define ui_storage1 "CENTER+1:[18*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_storage2 "CENTER+2:[20*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"

#define ui_monkey_uniform "WEST+2:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"//monkey
#define ui_monkey_hat "WEST+3:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"	//monkey
#define ui_monkey_glasses "WEST+1:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"	//monkey
#define ui_monkey_mask "WEST+4:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"	//monkey
#define ui_monkey_back "WEST+5:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"	//monkey

//Lower right, persistant menu
#define ui_dropbutton "EAST-4:[22*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_drop_throw "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_pull_resist "EAST-2:[26*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_kick_bite "EAST-3:[24*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_acti "EAST-2:[26*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_movi "EAST-3:[24*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_zonesel "EAST-1:28,SOUTH:5" //Used as compile time value
#define ui_acti_alt "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]" //alternative intent switcher for when the interface is hidden (F12)

//Screen Alerts
#define ui_alert1 "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+4.5:[27*PIXEL_MULTIPLIER]"
#define ui_alert2 "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+3.5:[25*PIXEL_MULTIPLIER]"
#define ui_alert3 "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+2.5:[23*PIXEL_MULTIPLIER]"
#define ui_alert4 "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+1.5:[21*PIXEL_MULTIPLIER]"
#define ui_alert5 "EAST-1:[28*PIXEL_MULTIPLIER],CENTER+0.5:[19*PIXEL_MULTIPLIER]"

//Gun buttons
#define ui_gun1 "EAST-2:26,SOUTH+2:7" //Used as compile time value
#define ui_gun2 "EAST-1:28, SOUTH+3:7" //Used as compile time value
#define ui_gun3 "EAST-2:26,SOUTH+3:7" //Used as compile time value
#define ui_gun_select "EAST-1:28,SOUTH+2:7" //Used as compile time value

//Middle right (status indicators)
#define ui_internal "EAST-1:[28*PIXEL_MULTIPLIER],CENTER-0.5:[17*PIXEL_MULTIPLIER]"
#define ui_health "EAST-1:[28*PIXEL_MULTIPLIER],CENTER-1.5:[15*PIXEL_MULTIPLIER]"
#define ui_under_health "EAST-1:[28*PIXEL_MULTIPLIER],CENTER-2.5:[13*PIXEL_MULTIPLIER]"
#define ui_more_under_health "EAST-1:[28*PIXEL_MULTIPLIER],CENTER-3.5:[11*PIXEL_MULTIPLIER]"
#define ui_more_under_health_and_to_the_left "EAST-2:[14*PIXEL_MULTIPLIER],CENTER-5:[24*PIXEL_MULTIPLIER]"
//borgs
#define ui_borg_health "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+5:[7*PIXEL_MULTIPLIER]"
#define ui_borg_album "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+4:[7*PIXEL_MULTIPLIER]"
#define ui_borg_camera "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+3:[7*PIXEL_MULTIPLIER]"
#define ui_borg_pull "EAST-3:[24*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"

#define ui_borg_panel "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_borg_sight "CENTER-3:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_inv1 "CENTER-2:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_inv2 "CENTER-1:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_inv3 "CENTER:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_borg_module "CENTER+1:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_borg_store "CENTER+2:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"

#define ui_mommi_store "CENTER+1:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_mommi_module "CENTER:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_mommi_sight "CENTER-2:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_mommi_hats "CENTER-3:[16*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"

//aliens
#define ui_alien_health "EAST-1:[28*PIXEL_MULTIPLIER],CENTER-1.5:[15*PIXEL_MULTIPLIER]" //same as humans

//constructs
#define ui_construct_health "EAST,CENTER-1.5:[15*PIXEL_MULTIPLIER]" //same height as humans, hugging the right border
#define ui_construct_sword "EAST:[-1*PIXEL_MULTIPLIER],CENTER-2.5:[15*PIXEL_MULTIPLIER]" //bellow the health HUD
#define ui_construct_pull "EAST-1:[28*PIXEL_MULTIPLIER],SOUTH+1:[10*PIXEL_MULTIPLIER]" //above the zone_sel icon

//spells
#define ui_spell_master "EAST-1:16,NORTH-1:16" //Used as compile time value
#define ui_genetic_master "EAST-1:16,NORTH-3:16" //Used as compile time value
#define ui_alien_master "EAST-0:-4,NORTH-0:-6" //Used as compile time value
#define ui_racial_master "EAST-0:-4,NORTH-2:-6" //Used as compile time value

//Pop-up inventory
#define ui_shoes "WEST+1:[8*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"

#define ui_iclothing "WEST:[6*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_oclothing "WEST+1:[8*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"
#define ui_gloves "WEST+2:[10*PIXEL_MULTIPLIER],SOUTH+1:[7*PIXEL_MULTIPLIER]"

#define ui_glasses "WEST:[6*PIXEL_MULTIPLIER],SOUTH+2:[9*PIXEL_MULTIPLIER]"
#define ui_mask "WEST+1:[8*PIXEL_MULTIPLIER],SOUTH+2:[9*PIXEL_MULTIPLIER]"
#define ui_ears "WEST+2:[10*PIXEL_MULTIPLIER],SOUTH+2:[9*PIXEL_MULTIPLIER]"

#define ui_head "WEST+1:[8*PIXEL_MULTIPLIER],SOUTH+3:[11*PIXEL_MULTIPLIER]"

//Intent small buttons
#define ui_help_small "EAST+3:[8*PIXEL_MULTIPLIER],SOUTH:[1*PIXEL_MULTIPLIER]"
#define ui_disarm_small "EAST+3:15,SOUTH:[18*PIXEL_MULTIPLIER]"
#define ui_grab_small "EAST+3:[32*PIXEL_MULTIPLIER],SOUTH:[18*PIXEL_MULTIPLIER]"
#define ui_harm_small "EAST+3:[39*PIXEL_MULTIPLIER],SOUTH:[1*PIXEL_MULTIPLIER]"

//#define ui_swapbutton "6:-16,1:5" //Unused

//#define ui_headset "SOUTH,8"
#define ui_hand "CENTER-1:[14*PIXEL_MULTIPLIER],SOUTH:[5*PIXEL_MULTIPLIER]"
#define ui_hstore1 "CENTER-2,CENTER-2"
//#define ui_resist "EAST+1,SOUTH-1"
#define ui_sleep "EAST+1, NORTH-13"
#define ui_rest "EAST+1, NORTH-14"


#define ui_iarrowleft "SOUTH-1,11"
#define ui_iarrowright "SOUTH-1,13"

// AI (Ported straight from /tg/)

#define ui_ai_core "SOUTH:[6*PIXEL_MULTIPLIER],WEST:[16*PIXEL_MULTIPLIER]"
#define ui_ai_camera_list "SOUTH:[6*PIXEL_MULTIPLIER],WEST+1:[16*PIXEL_MULTIPLIER]"
#define ui_ai_track_with_camera "SOUTH:[6*PIXEL_MULTIPLIER],WEST+2:[16*PIXEL_MULTIPLIER]"
#define ui_ai_camera_light "SOUTH:[6*PIXEL_MULTIPLIER],WEST+3:[16*PIXEL_MULTIPLIER]"
//#define ui_ai_crew_monitor "SOUTH:[6*PIXEL_MULTIPLIER],WEST+4:16"
#define ui_ai_crew_manifest "SOUTH:[6*PIXEL_MULTIPLIER],WEST+4:[16*PIXEL_MULTIPLIER]"
#define ui_ai_alerts "SOUTH:[6*PIXEL_MULTIPLIER],WEST+5:[16*PIXEL_MULTIPLIER]"
#define ui_ai_announcement "SOUTH:[6*PIXEL_MULTIPLIER],WEST+6:[16*PIXEL_MULTIPLIER]"
#define ui_ai_shuttle "SOUTH:[6*PIXEL_MULTIPLIER],WEST+7:[16*PIXEL_MULTIPLIER]"
#define ui_ai_state_laws "SOUTH:[6*PIXEL_MULTIPLIER],WEST+8:[16*PIXEL_MULTIPLIER]"
#define ui_ai_pda_send "SOUTH:[6*PIXEL_MULTIPLIER],WEST+9:[16*PIXEL_MULTIPLIER]"
#define ui_ai_pda_log "SOUTH:[6*PIXEL_MULTIPLIER],WEST+10:[16*PIXEL_MULTIPLIER]"
#define ui_ai_take_picture "SOUTH:[6*PIXEL_MULTIPLIER],WEST+11:[16*PIXEL_MULTIPLIER]"
#define ui_ai_view_images "SOUTH:[6*PIXEL_MULTIPLIER],WEST+12:[16*PIXEL_MULTIPLIER]"
#define ui_ai_config_radio "SOUTH:[6*PIXEL_MULTIPLIER],WEST+13:[16*PIXEL_MULTIPLIER]"

//Cult HUD
#define ui_cult_Act "WEST+0:[6*PIXEL_MULTIPLIER],SOUTH+5:[15*PIXEL_MULTIPLIER]"
#define ui_cult_tattoos "WEST+0:[6*PIXEL_MULTIPLIER], SOUTH+4:[13*PIXEL_MULTIPLIER]"
