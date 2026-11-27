// Behavior tree statuses, node types and policies.
// Ported from tgstation/tgstation (code/__DEFINES/ai/behavior_trees.dm) with the
// AI controller integration left for the next porting phase. See
// code/datums/ai/README.md.

/// Maximum number of execution indices the future bt_viewer drain log may hold.
#define BT_EXECUTION_LOG_MAX 250

// BT node return values
/// Node completed its goal and succeeded.
#define BT_SUCCESS 1
/// Node failed.
#define BT_FAILURE 2
/// Node has an action running.
#define BT_RUNNING 3

// Parallel node completion policies (mutually exclusive per axis)
/// Parallel succeeds when child 1 succeeds (default).
#define BT_PARALLEL_SUCCESS_CHILD_ONE 0
/// Parallel succeeds only when all children succeed.
#define BT_PARALLEL_SUCCESS_ALL 1
/// Parallel fails when child 1 fails (default).
#define BT_PARALLEL_FAILURE_CHILD_ONE 0
/// Parallel fails when any child fails.
#define BT_PARALLEL_FAILURE_ANY 1

/// Subplan propagates BT_SUCCESS when all children succeed (default).
#define BT_SUBPLAN_SUCCEED_ON_SUCCESS 0
/// Subplan resets and loops (returns BT_RUNNING) when all children succeed.
#define BT_SUBPLAN_LOOP_ON_SUCCESS 1
/// Subplan propagates BT_FAILURE when a child fails (default).
#define BT_SUBPLAN_FAIL_ON_FAILURE 0
/// Subplan resets and loops (returns BT_RUNNING) when a child fails.
#define BT_SUBPLAN_LOOP_ON_FAILURE 1

/// No observer abort registered.
#define BT_ABORT_NONE 0
/// Abort this branch when the watched condition becomes FALSE.
#define BT_ABORT_SELF (1<<0)
/// Abort lower-priority running behaviors when the watched condition becomes TRUE.
#define BT_ABORT_LOWER_PRIORITY (1<<1)
/// Both BT_ABORT_SELF and BT_ABORT_LOWER_PRIORITY.
#define BT_ABORT_BOTH (BT_ABORT_SELF | BT_ABORT_LOWER_PRIORITY)

// BT viewer node type identifiers (stored on bt_node.node_type)
#define BT_NODE_SELECTOR 0
#define BT_NODE_SEQUENCE 1
#define BT_NODE_PARALLEL 2
#define BT_NODE_DECORATOR 3
#define BT_NODE_LEAF 4
#define BT_NODE_SUBTREE 5
#define BT_NODE_SUBPLAN 6

// Keys used by behavior tree descriptors/JSON.
/// Key storing the node typepath in a descriptor list.
#define BT_DESC_TYPE "type"
/// Key storing the children list in a descriptor list.
#define BT_DESC_CHILDREN "children"
/// Key storing the override slot ID in a subtree descriptor.
#define BT_DESC_OVERRIDE_ID "override_id"

/// Resolves the compiled JSON path from a behavior tree's source JSON path.
/// Compiled trees are committed under code/datums/ai/compiled/ and produced by
/// tools/behavior_tree/bt_compiler.py.
#define BT_COMPILED_PATH(json_path) (replacetext("code/datums/ai/compiled/" + json_path, ".json", ".compiled.json"))

// Return flags for ai_behavior/perform().
/// Update this behavior's cooldown.
#define AI_BEHAVIOR_DELAY (1<<0)
/// Finish the behavior successfully.
#define AI_BEHAVIOR_SUCCEEDED (1<<1)
/// Finish the behavior unsuccessfully.
#define AI_BEHAVIOR_FAILED (1<<2)
/// Performed to completion without returning a terminal flag.
#define AI_BEHAVIOR_INSTANT 0

// AI controller status. Controllers in AI_STATUS_OFF are not ticked.
#define AI_STATUS_ON "ai_on"
#define AI_STATUS_ON_LOW "ai_on_low"
#define AI_STATUS_OFF "ai_off"

// Minimal blackboard keys used by the controller and the starter behaviors.
#define BB_MY_PAWN "my_pawn"
#define BB_TARGET "target"

