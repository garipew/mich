# mich
mich is an item selector TUI applet made in lua.

The presented itens can be selected with <kbd>Tab</kbd>.

When <kbd>Enter</kbd> is pressed, all selected itens are written to stdout.

If no item is selected, on <kbd>Enter</kbd> mich will write the option highlighted by the cursor.


## Installation
To install mich, first clone this repository with
```
git clone https://github.com/garipew/mich.git
cd mich
```

Then, run the install script
```
sudo ./install.sh
```

To uninstall, ~~dont bother~~ 
```
sudo ./uninstall.sh
```

## Execution
To execute mich, pass the options as arguments
```
mich option1 option2 option3
```

In order to learn more about mich options, try
```
mich -h
```  

### Navigation
mich implements vim-**like** navigation

- <kbd>j</kbd> - Move cursor down
- <kbd>k</kbd> - Move cursor up
- <kbd>Shift</kbd>+<kbd>j</kbd> - Scroll down
- <kbd>Shift</kbd>+<kbd>k</kbd> - Scroll up
- <kbd>Tab</kbd> - Select item under the cursor
- <kbd>Enter</kbd> - Prints selected itens to stdout
