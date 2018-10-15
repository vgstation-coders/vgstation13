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
