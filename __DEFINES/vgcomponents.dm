//Usage flags to specify what the component does (used for limiting which components can be attached to which assembly)
//bitflag, components can only have one tho

//see modules/vgcompontents

#define VGCOMP_USAGE_NONE 0
#define VGCOMP_USAGE_MOVEMENT 1
#define VGCOMP_USAGE_MANIPULATE_SMALL 2 //small manipulaters used on costum tools and such
#define VGCOMP_USAGE_MANIPULATE_LARGE 3 //large manipulators (doorcontroller, robotarm)
