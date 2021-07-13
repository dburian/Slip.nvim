# Mindset

I do not know yet how exactly this is going to work. Implement the bare minimum
to support the features you are sure you are going to need.

Make minimal assumptions.

# Goal features

- creating a new note

I need:
  - path to slip-box directory
  Just exact path

  - naming system
  A lua function. Default: incrementing hex numbers with fixed number of digits
    - con: limited number of notes - however can be supplied optional function
    - pro: automatically alphabetically sorted (ls)
