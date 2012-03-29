csc: Color Scheme Compiler
==========================

csc allows you to create a single color theme which works in several
text editors and syntax highlighting tools, e.g., Emacs and Vim.

Compiling
---------

Compiling csc requires OCaml version 3.12 or newer.

To compile, run "make".

To install into /usr/bin, run "make install". To install into another
location, add the argument PREFIX=<path>, as in

```
make PREFIX=~/bin/ install
```

Usage
-----

```
csc [options] themeFile.css
```

The following options control which output backend is used. The Emacs
backend is the default.

* -emacs: Output an Emacs 24 color theme to themeFile-theme.el.
* -vim: Output a Vim color theme to themeFile.vim.
* -css: Output a CSS file to themeFile.css.

The -o option can be used to specify the name of an output file.

Input File Format
-----------------

The input syntax is a small subset of CSS, with the added ability to
use variable definitions.

The elements that may be syntax highlighted, like keywords, constants,
and strings, are known as "faces".

An input CSS file consists of a series of face definitions, each of
which contains a number of attributes. The following is an example
definition for the "keyword" face:

```css
keyword {
    color       : blue;
    font-weight : bold;
}
```

The above definition states that keywords should be colored blue and
typeset in bold.

Multiple selectors can be used on a single definition to define the
attributes of several faces simultaneously, as in

```css
builtin, keyword {
    color       : blue;
    font-weight : bold;
}
```

The above definition states that both builtin operators and keywords
should be colored blue and typeset in bold.

You can define "pseudofaces" whose attributes define values you would
like to use repeatedly in face definitions. For example, you can
define a face for holding color values:

```css
def colors {
    dark-gray   : #4a4a4a;
    medium-gray : #858585;
    ...
}
```

You can then reference the values in the colors pseudoface when
defining attributes of other faces:

```css
builtin, keyword {
    color       : colors.medium-gray;
    font-weight : bold;
}
```

Examples
--------

See the examples/ directory for example color themes.
