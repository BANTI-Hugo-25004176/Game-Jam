class_name MenuItem
extends Resource

## One entry in a MenuScreen's button list. Configure these in the Inspector —
## no code needed to define a menu.

## Translation key for the button label (see ui/localization/ui_text.csv).
@export var text_key:String = "MENU_ITEM"

## Identifier emitted by the screen when this button is pressed
## (e.g. "play", "options", "resume", "quit"). Listen via MenuScreen.action_pressed.
## Ignored when target_scene is set.
@export var action:String = ""

## Optional: if set, pressing this button changes directly to that scene.
@export_file("*.tscn") var target_scene:String = ""
