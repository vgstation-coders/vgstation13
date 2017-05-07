// Component Signal names.
// Avoids any mishaps caused by typos.

/** Sent when a mob AI component wants to set new machine state.
 * @param state mixed: The new machine state (HOSTILE_STANCE_IDLE, etc)
 */
#define COMSIG_STATE "state"

/** Sent when we've been bumped.
 * @param movable /atom/movable: The bumping entity.
 */
#define COMSIG_BUMPED "bumped"

/** Sent when we've bumped someone else.
 * @param movable /atom/movable: The bumped entity.
 */
#define COMSIG_BUMP   "bump"

/** Sent by mob Life() tick. No arguments.
 */
#define COMSIG_LIFE   "life"

/** Sent when a mob AI component has identified a new target.
 * @param target /atom: The targetted entity.
 */
#define COMSIG_TARGET "target"

/** Sent when a mob wants to move or stop.
 * @param dir integer: 0 to stop, NORTH/SOUTH/WEST/EAST/etc to move in that direction.
 * @param loc /turf: Specify to move in the direction of that turf.
 */
#define COMSIG_MOVE "move"


/** BLURB
 * @param temp decimal: Adds value to body temperature
 */
#define COMSIG_ADJUST_BODYTEMP "add body temp" // DONE, NEEDS IMPL


/** BLURB
 * @param amount decimal: Adjust bruteloss by the given amount.
 */
#define COMSIG_ADJUST_BRUTE "adjust brute loss" // DONE, NEEDS IMPL


/** BLURB
 * @param target /atom: The target being attacked.
 */
#define COMSIG_ATTACKING "attacking target" // DONE


/** BLURB
 * @param state boolean: Busy if true.
 */
#define COMSIG_BUSY "busy" // DONE, NEEDS IMPL


/** BLURB
 * @param temp decimal: Sets body temperature to provided value, in kelvin.
 */
#define COMSIG_SET_BODYTEMP "body temp" // DONE, NEEDS IMPL

/** Sent when a component is added to the container.
 * @param component /datum/component: Component being added.
 */
#define COMSIG_COMPONENT_ADDED "component added"

/** Sent when a component is being removed from the container.
 * @param component /datum/component: Component being removed.
 */
#define COMSIG_COMPONENT_REMOVING "component removing"
