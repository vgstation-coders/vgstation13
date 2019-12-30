#define TGS_EXTERNAL_CONFIGURATION
#define TGS_V3_API
#define TGS_DEFINE_AND_SET_GLOBAL(Name, Value) var/global/##Name = ##Value
#define TGS_READ_GLOBAL(Name) ##Name
#define TGS_WRITE_GLOBAL(Name, Value) ##Name = ##Value
#define TGS_WORLD_ANNOUNCE(message) to_chat(world, "<span class='boldannounce'>[html_encode(##message)]</span>")
#define TGS_INFO_LOG(message) world.log << "TGS: Info: [##message]"
#define TGS_ERROR_LOG(message) world.log << "TGS: Error: [##message]"
#define TGS_NOTIFY_ADMINS(event) message_admins(##event)
#define TGS_CLIENT_COUNT var/list/clients.len
#define TGS_PROTECT_DATUM(Path) GENERAL_PROTECT_DATUM(##Path)
