autofit
=======

A refactored version of the public domain 'autofit' module for the [Monkey programming language](https://github.com/blitz-research/monkey).

The original module was developed by James "DruggedBunny" Boyd. Due to a lack of a proper license, I can only assume the statements of "[Public domain code]" allow me the right to sublicense. That being said, this code-base contains very little of the original source, and is only identical name-wise for the sake of compatibility with existing applications.

## Features
* Compatibility with the original 'autofit' module.
* Internal 'Strict' language conformity.
* Sub-displays: Sub-displays can be used to have a "picture-in-picture" or "split-screen" effect in games.
* Support for matrix operations within Mojo. (Scaling and position related)
* Custom border colors, and border-draw toggling.
* Easy integration of sub-displays and sub-displays for those displays. (Through simple property overloading; see 'CameraDisplay')

## Installation
This module is officially available from the [Regal Modules](https://github.com/Regal-Internet-Brothers/regal-modules#regal-modules) project, and may be installed by following the installation guide provided with that repository.

Although this can be installed with the Regal Modules, this particular module aims to be as dependency free as possible. This means the only requirements this module has are covered by the ["standard library"](https://github.com/blitz-research/monkey/tree/develop/modules) provided with Monkey. There are exceptions, such as the use of 'regal.mojoemulator' as a fallback, but normal usage is not affected by this dependency.

This means this module may be used as a completely separate entity, without being tied to '[regal](https://github.com/Regal-Internet-Brothers/regal-modules)'.

Import syntax varies with usage, with the official distribution using 'regal' as a parent namespace. (e.g. regal.autofit)

### References
* [The original forum thread for 'autofit'](http://www.monkey-x.com/Community/posts.php?topic=1500&page=1).
