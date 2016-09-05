Building on Windows
----
1. Download `https://github.com/hoedown/hoedown`
2. Run `nmake` for `x86` or add files to project in your IDE.
3. Include header files for `markdown_byond.cpp` from `hoedown`
4. Compile for `x86` and copy the library made to the directory where the `.dmb` resides.
5. Copy the `hoedown.dll` to the same directory

##One DLL
1. Copy `*.c` into your project `src` directory
2. Copy `*.h` into your project `headers`
3. Compile and copy the newly made `markdown_byond.dll`to the directory where the `.dmb` resides.

##General Usage
1. Uncomment or add `PAPERWORK_LIBRARY` to `config/config.txt`
2. markdown syntax is handled from user input and then `markdown_byond.dll` is called to render the html and returns the rendered html.