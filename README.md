
Slip.nvim is a minimal Neovim plugin for managing a slip-box according to the
[Zettelkasten method][wiki].

### Warning
This plugin is currently in alpha stages. If you are looking for a more
complete solution, look elsewhere (e.g. [neuron.nvim][neuron]).

# Table of contents

1. [Features overview](#features-overview)
1. [Installation](#installation)
1. [Configuration](#configuration)
1. [About Zettelkasten](#about-zettelkasten)

# Features overview

Slip helps you manage two sets of markdown documents - bibliographical notes
and permanent notes. Slip's features:

- creating new permanent or bibliographical note
- inserting a link to another note
- keeping a list of yet unreferenced permanent notes in index file
- reviewing linked notes

# Installation

Slip heavily relies on [Telescope.nvim][telescope], which is probably the best
and most customizable fuzzy finder. Therefore it is a necessary dependency,
which you will need to install first.

Using Plug:

```vimscript
  Plug 'dburian/Slip.nvim'
```

# Configuration

TBD

# About Zettelkasten

There are now way too many articles about Zettelkasten, so you are probably
better off reading one of those. However if you want to truly adapt this
note-taking system I suggest you read *How to take smart notes* by Sönke
Ahrens(2017).


[wiki]: https://en.wikipedia.org/wiki/Zettelkasten
[neuron]: https://github.com/oberblastmeister/neuron.nvim
[telescope]: https://github.com/nvim-telescope/telescope.nvim
