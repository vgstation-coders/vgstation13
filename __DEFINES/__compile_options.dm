// This file is for you to edit as you desire.
// Don't commit the changes you apply to this file unless
// you're adding/removing entries, or changing the defaults for everyone.
// * You can teach git to ignore this file with the following:
// `git update-index --assume-unchanged __DEFINES/__compile_options.dm`
// and undo it with the following:
// `git update-index --no-assume-unchanged __DEFINES/__compile_options.dm`

// Uncomment one of these to choose which map will be compiled,
// without having to touch the .dme file itself.
// Unfortunately BYOND is garbage, so this is the most readable approach
// I could find. When (if) http://www.byond.com/forum/?post=2404042 is
// fixed, this can be changed to something better.

// bagelstation.dm:
//#define MAP_OVERRIDE 0
// defficiency.dm:
//#define MAP_OVERRIDE 1
// metaclub.dm:
//#define MAP_OVERRIDE 2
// packedstation.dm
//#define MAP_OVERRIDE 3
// roidstation.dm
//#define MAP_OVERRIDE 4
// test_box.dm:
//#define MAP_OVERRIDE 5
// test_tiny.dm:
//#define MAP_OVERRIDE 6
// tgstation.dm:
//#define MAP_OVERRIDE 7


// Toggles several features, explained in their respective comments.
// You can turn those on and off manually if you prefer, instead of setting this
#define DEVELOPER_MODE 0

// If 1, unit tests will be compiled
#define UNIT_TESTS_ENABLED DEVELOPER_MODE
// If 1, unit tests run automatically
#define UNIT_TESTS_AUTORUN DEVELOPER_MODE
// If 1, the server stops after the tests are done
#define UNIT_TESTS_STOP_SERVER_WHEN_DONE 0

#if DEVELOPER_MODE
// If defined, overrides the default lobby timer duration
#define GAMETICKER_LOBBY_DURATION 5 SECONDS
#endif
// If 1, mob/Login checks for multiple connections from the same IP on different ckeys and warns the user
#define WARN_FOR_CLIENTS_SHARING_IP !DEVELOPER_MODE

// I wonder what this does
#define SHOW_CHANGELOG_ON_NEW_PLAYER_LOGIN !DEVELOPER_MODE
