# Reversi bot
Marco Herrero <me@marhs.de>
> Feb 2015, Knowledge Engineering.
> Master's degree in AI. University of Seville
> 
> This project is **discontinued**

## Introduction
This is an implementation in [CLIPS](http://clipsrules.sourceforge.net/) (a tool for building expert systems) of a console layout to play [Reversi / Othello](https://en.wikipedia.org/wiki/Reversi) with a basic rule-based AI to play with.

## Game
The UI in console based because the goal of this project is to have a working AI to play with the player. It will work in any CLIPS version. The game implementation is based in a finite state machine. Contains a couple of bugs

## AI - Bot
The AI is a **rule system** with priorities. The system checks the high priority rules first, like avoiding the enenemy big score moves. I've take advantage of the CLIPS built-in Rete algorithm to define rules based in patterns so the activation is prioritized.

The [Rete algorithm](https://en.wikipedia.org/wiki/Rete_algorithm) is a pattern matching algorithm for implementing production rule systems. It is used to determine which of the system's rules should fire based on its data store.

## Play
To play, download a working copy for your system of CLIPS and load the file.

## Notes
The internal comments and docs of the source are in spanish.

