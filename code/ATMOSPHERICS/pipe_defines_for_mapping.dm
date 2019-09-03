#define DEF_PIPELAYER_SUPPLY 2
#define DEF_PIXELX_SUPPLY (DEF_PIPELAYER_SUPPLY - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define DEF_PIXELY_SUPPLY (DEF_PIPELAYER_SUPPLY - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

#define DEF_PIPELAYER_SCRUBBERS 4
#define DEF_PIXELX_SCRUBBERS (DEF_PIPELAYER_SCRUBBERS - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define DEF_PIXELY_SCRUBBERS (DEF_PIPELAYER_SCRUBBERS - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/unary/vent_scrubber/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/unary/vent_scrubber/on/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/unary/vent_scrubber/on/vox/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	icon_state="adapter_4"
	name = "scrubbers pipe"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/pipe/simple/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/simple/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold4w/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/unary/vent_pump/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/unary/vent_pump/on/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/layer_adapter/supply
	piping_layer=DEF_PIPELAYER_SUPPLY
	icon_state="adapter_2"
	name = "\improper Air supply pipe"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/layer_adapter/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/layer_adapter/supply/hidden
	level = 1
	alpha=128

#define ROID_PIPELAYER_GENERAL1 1
#define ROID_PIXELX_GENERAL1 (ROID_PIPELAYER_GENERAL1 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define ROID_PIXELY_GENERAL1 (ROID_PIPELAYER_GENERAL1 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

#define ROID_PIPELAYER_GENERAL2 2
#define ROID_PIXELX_GENERAL2 (ROID_PIPELAYER_GENERAL2 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define ROID_PIXELY_GENERAL2 (ROID_PIPELAYER_GENERAL2 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

#define ROID_PIPELAYER_GENERAL4 4
#define ROID_PIXELX_GENERAL4 (ROID_PIPELAYER_GENERAL4 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define ROID_PIXELY_GENERAL4 (ROID_PIPELAYER_GENERAL4 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

#define ROID_PIPELAYER_GENERAL5 5
#define ROID_PIXELX_GENERAL5 (ROID_PIPELAYER_GENERAL5 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define ROID_PIXELY_GENERAL5 (ROID_PIPELAYER_GENERAL5 - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

//Layer 1
/obj/machinery/atmospherics/pipe/simple/general/visible/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/simple/general/hidden/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/manifold/general/visible/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/manifold/general/hidden/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layered/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	pixel_x=ROID_PIXELX_GENERAL1
	pixel_y=ROID_PIXELY_GENERAL1
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer1
	piping_layer=ROID_PIPELAYER_GENERAL1
	icon_state="adapter_1"
	name = "pipe"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer1/visible
	level = LEVEL_ABOVE_FLOOR
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer1/hidden
	level = LEVEL_BELOW_FLOOR
	alpha=128

//Layer 2
/obj/machinery/atmospherics/pipe/simple/general/visible/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/simple/general/hidden/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/manifold/general/visible/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/manifold/general/hidden/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layered/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	pixel_x=ROID_PIXELX_GENERAL2
	pixel_y=ROID_PIXELY_GENERAL2
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer2
	piping_layer=ROID_PIPELAYER_GENERAL2
	icon_state="adapter_2"
	name = "pipe"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer2/visible
	level = LEVEL_ABOVE_FLOOR
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer2/hidden
	level = LEVEL_BELOW_FLOOR
	alpha=128

//Layer 4
/obj/machinery/atmospherics/pipe/simple/general/visible/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/simple/general/hidden/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/manifold/general/visible/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/manifold/general/hidden/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layered/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	pixel_x=ROID_PIXELX_GENERAL4
	pixel_y=ROID_PIXELY_GENERAL4
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer4
	piping_layer=ROID_PIPELAYER_GENERAL4
	icon_state="adapter_4"
	name = "pipe"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer4/visible
	level = LEVEL_ABOVE_FLOOR
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer4/hidden
	level = LEVEL_BELOW_FLOOR
	alpha=128

//Layer 5
/obj/machinery/atmospherics/pipe/simple/general/visible/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/simple/general/hidden/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/manifold/general/visible/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/manifold/general/hidden/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/manifold4w/general/visible/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden/layered/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	pixel_x=ROID_PIXELX_GENERAL5
	pixel_y=ROID_PIXELY_GENERAL5
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer5
	piping_layer=ROID_PIPELAYER_GENERAL5
	icon_state="adapter_5"
	name = "pipe"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer5/visible
	level = LEVEL_ABOVE_FLOOR
/obj/machinery/atmospherics/pipe/layer_adapter/general/layer5/hidden
	level = LEVEL_BELOW_FLOOR
	alpha=128