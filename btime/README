To build on windows:

Using a recent version of VC++, such as 2012, 2013, or 2015, open btime.vcxproj, switch to release configuration, and compile. The dll will be output in the Release folder.

To build on linux:

Ensure the build environment is installed and gnu make and g++ are available. On debian/ubuntu machines, running
sudo apt-get install build-essential lib32stdc++-4.8 lib32stdc++-4.8-dev

should be sufficient.

From the btime directory:
make && sudo make install

You will need to run DreamDaemon with the -trusted flag in order for the game to access the library.

If DreamDaemon complains that btime.so cannot be found, place btime.so in the same directory as your .dmb, and prepend the following to your DreamDaemon command line:

LD_LIBRARY_PATH=/path/to/directory/dmb/is/in:$LD_LIBRARY_PATH 

So if your .dmb is in /var/ss13, the command line might look like:

LD_LIBRARY_PATH=/var/ss13:$LD_LIBRARY_PATH DreamDaemon /var/ss13/ss13.dmb 26200 -trusted

