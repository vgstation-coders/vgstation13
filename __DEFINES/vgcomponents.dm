//Usage flags to specify what the component does (used for limiting which components can be attached to which assembly)
//bitflag, components can only have one tho

//see modules/vgcompontents

#define VGCOMP_USAGE_NONE 1
#define VGCOMP_USAGE_MOVEMENT 2
#define VGCOMP_USAGE_MANIPULATE_SMALL 4 //small manipulaters used on costum tools and such
#define VGCOMP_USAGE_MANIPULATE_LARGE 8 //large manipulators (doorcontroller, robotarm)
