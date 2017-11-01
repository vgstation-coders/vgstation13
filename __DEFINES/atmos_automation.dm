#define SIGNAL_TYPE_ATMOS_VOLUME_PUMP "volume pump"
#define SIGNAL_TYPE_ATMOS_GAS_PUMP "gas pump"

#define CHECK_ATMOS_COMMAND_SIGNAL(atmos_type) ( \
	(signal.data["tag"]) && \
	(signal.data["tag"] == id_tag) && \
	(signal.data["sigtype"] == "command") && \
	(signal.data["type"]) && \
	(signal.data["type"] == atmos_type))