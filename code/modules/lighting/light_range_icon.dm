// -- Light icon selection.

/proc/try_get_light_range_icon(block_1, block_2, light_range, num)
	/*
	//if (lighting_engine)
	//	lighting_engine.choose_light_range_icon(two_bordering_walls, light_range, num)
	//else
	//	world.log << "Auto-init of the lighting engine datum..."
	//	lighting_engine = new lighting_system_used
	//	lighting_engine.choose_light_range_icon(two_bordering_walls, light_range, num)
	*/
	var/shadowicon
	switch (num)
		if(FRONT_SHADOW)
			if (!(block_1 || block_2))
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow2/light_range_2_shadows2_soft.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow2/light_range_3_shadows2_soft.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow2/light_range_4_shadows2_soft.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow2/light_range_5_shadows2_soft.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow2/light_range_6_shadows2_soft.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow2/light_range_7_shadows2_soft.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow2/light_range_8_shadows2_soft.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow2/light_range_9_shadows2_soft.dmi'

			else if (block_1)
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow2/light_range_2_shadows2_block1.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow2/light_range_3_shadows2_block1.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow2/light_range_4_shadows2_block1.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow2/light_range_5_shadows2_block1.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow2/light_range_6_shadows2_block1.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow2/light_range_7_shadows2_block1.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow2/light_range_8_shadows2_block1.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow2/light_range_9_shadows2_block1.dmi'

			else if (block_2)
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow2/light_range_2_shadows2_block2.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow2/light_range_3_shadows2_block2.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow2/light_range_4_shadows2_block2.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow2/light_range_5_shadows2_block2.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow2/light_range_6_shadows2_block2.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow2/light_range_7_shadows2_block2.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow2/light_range_8_shadows2_block2.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow2/light_range_9_shadows2_block2.dmi'

			else
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow2/light_range_2_shadows2.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow2/light_range_3_shadows2.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow2/light_range_4_shadows2.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow2/light_range_5_shadows2.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow2/light_range_6_shadows2.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow2/light_range_7_shadows2.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow2/light_range_8_shadows2.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow2/light_range_9_shadows2.dmi'
		if (CORNER_SHADOW)
			if (!(block_1 || block_2))
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1_soft.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow1/light_range_3_shadows1_soft.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow1/light_range_4_shadows1_soft.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow1/light_range_5_shadows1_soft.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow1/light_range_6_shadows1_soft.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow1/light_range_7_shadows1_soft.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow1/light_range_8_shadows1_soft.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow1/light_range_9_shadows1_soft.dmi'

			else if (block_1)
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1_block1.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow1/light_range_3_shadows1_block1.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow1/light_range_4_shadows1_block1.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow1/light_range_5_shadows1_block1.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow1/light_range_6_shadows1_block1.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow1/light_range_7_shadows1_block1.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow1/light_range_8_shadows1_block1.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow1/light_range_9_shadows1_block1.dmi'

			else if (block_2)
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1_block2.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow1/light_range_3_shadows1_block2.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow1/light_range_4_shadows1_block2.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow1/light_range_5_shadows1_block2.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow1/light_range_6_shadows1_block2.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow1/light_range_7_shadows1_block2.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow1/light_range_8_shadows1_block2.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow1/light_range_9_shadows1_block2.dmi'

			else
				switch(light_range)
					if(2)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(3)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(4)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(5)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(6)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(7)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(8)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'
					if(9)
						shadowicon = 'icons/lighting/shadow1/light_range_2_shadows1.dmi'

	return shadowicon
