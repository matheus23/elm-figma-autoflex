# elm-figma-autoflex

## Motivation

Figma will have [really cool features](https://youtu.be/lWy4fB3G9Gc?t=282):
* Instance Swap
* Variants
* Interactive Components

This will push figma prototypes to another level. They'll become more like code. Also, editing them will become more like using a UI builder.

I don't want to code the same flexbox layouts over and over again in code, when it is so much more fun to do in figma itself.

Of course, figma can't and won't become a complete replacement for coding in the near term. You still need to handle actual data, build up dependencies between view objects (input field -> label) and talk to web APIs.
But I've always seperated the almost template-like modules in my elm code from the rest. The rest would handle the interesting things, and the template-like modules really only handles html and css and a minimal amount of event listeners.

Elm-figma-autoflex will make most of the code in these template-like modules redundant.
* No more need to write html or css.
* The figma design and the implementation won't go out of sync. The code will depend on the figma design.

## To do

* [X] Create first small test figma file
* [X] Mock html and css which matches this file
* [X] Test for screenshot equality
* [X] Generate the html and css via elm
* [X] Fetch the file json via the figma api
* [ ] Generate the html and css in elm by using the figma file json
* [ ] Test all the frames in the figma file
* [ ] Add more test frames to the figma file
