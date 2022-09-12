# Custom Theme Nvim (Which is not a theme)
## What is custom theme?
Custom theme is a highlights editor.
Allows you to edit highlights in a more convenient way.

## Update
    Now while you are editing highlights, you can see higlihts on the theme in real time.
## Why?
- Let's say your happy with your current theme but function highlights is annoy you.
- Let's say your happy with your theme but your theme dosen't support some of your plugins.
- You can build a theme as you like from scrach.
## Demo
![Demo](https://github.com/Djancyp/nvim-plugin-demo/blob/main/custom-theme/demo1.png)
## Requirements
- [plenary](https://github.com/nvim-lua/plenary.nvim)
#### Optinal
You can use any colorizer.
- [Colorizer](https://github.com/norcalli/nvim-colorizer.lua)

## Installation

```lua
{
    "Djancyp/custom-theme.nvim",
    config = function()
        require("custom-theme").setup()
    end,
},
```

## Usage
```
    :CustomTheme (Will open all highlights to split windown)
    :CustomThemeReset (Will revert your changes how it was)
```
 
#### Set highlights
Ones you done making changes on split window
***Enter*** on normal mode will set highlights
***q*** will close the split window without changes
