all:
	cargo build --release --target i686-unknown-linux-gnu
	[ -f ../libvg.so ] && rm ../libvg.so
	cp target/i686-unknown-linux-gnu/release/liblibvg.so ../libvg.so
