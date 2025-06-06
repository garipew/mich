# mich
mich is an item selector TUI applet made in lua.

The presented itens can be selected with tab.

When enter is pressed, all selected itens are written to stdout.

If no item is selected, on enter mich will write the option highlighted by the cursor.


## Building
To build mich, first clone this repository with
```
git clone https://github.com/garipew/mich.git
cd mich
```

Then, execute the build script
```
./build.sh
```

## Executing
To execute mich, pass the options as arguments
```
./main.lua option1 option2 option3
```

In order to learn more about mich options, try
```
./main.lua -h
```  
