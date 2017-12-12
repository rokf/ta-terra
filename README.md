# Textadept Terra

A module for the [Terra](http://terralang.org/) programming language

#### Includes
- lexer (built upon the `lua` lexer)
- autocomplete via *fake* `ctags`
- docs via Textadept `api` files

#### Installation

Copy the `terra.lua` file to your `lexers` folder.

On Linux: `~/.textadept/lexers/`

Add `textadept.file_types.extensions.t = "terra"` to your main `init.lua` file.

On Linux: `~/.textadept/init.lua`

For autocomplete and docs copy the `terra` module folder into your
Textadept `modules` folder.

On Linux: `~/.textadept/modules/`

The files have to be in `~/.textadept/modules/terra/` for example.

In your main `init.lua` file do `require('terra')` and you're done.