# GUI Template

A small, reusable system for building menus/screens fast and consistently.
Everything is **data-driven** and **localized (FR/EN)** out of the box.

## Files

| File | What it is |
|------|------------|
| `components/menu_screen.tscn` (+ `.gd`) | The reusable screen: a title + a vertical list of buttons, built from data. |
| `components/menu_button.tscn` (+ `.gd`) | The reusable button (focus + hover/click sound). You rarely touch this. |
| `data/menu_item.gd` | A `MenuItem` resource = one button (label key + action or target scene). |
| `theme/game_theme.tres` | The shared visual theme. **Style everything from here.** |
| `localization/ui_text.csv` | All UI text, in English and French. |
| `autoload/ui_manager.tscn` (+ `.gd`) | Autoload `UI`: scene fade transitions + language switch. |
| `screens/main_menu.tscn` (+ `.gd`) | Example screen built with the template — copy this as a starting point. |

## Make a new screen in 3 steps

1. **Duplicate** `screens/main_menu.tscn` and rename it (e.g. `pause_menu.tscn`).
2. Select the inner **`MenuScreen`** node and, in the Inspector, set:
   - **Title Key** — a key from `ui_text.csv` (e.g. `TITLE_PAUSE`).
   - **Items** — one `MenuItem` per button. For each item set:
     - **Text Key** — a key from `ui_text.csv` (e.g. `MENU_RESUME`).
     - Either **Target Scene** (the button opens that scene) …
     - … **or** an **Action** string (the button reports an action to handle in code).
3. If you used any **Action** buttons, edit the screen's script to handle them
   (see `screens/main_menu.gd`). Pure navigation screens (only Target Scene
   buttons) need **no script at all**.

That's it — keyboard + gamepad navigation and FR/EN are automatic.

## Buttons: two modes

- **Navigation button** → set `target_scene` on the `MenuItem`. Pressing it changes
  to that scene (with a fade, via the `UI` autoload).
- **Action button** → leave `target_scene` empty and set `action` (e.g. `"quit"`).
  The screen emits `action_pressed(action)`; handle it in the screen's script:

```gdscript
func _on_action(action: String) -> void:
    match action:
        "resume": get_tree().paused = false
        "quit":   get_tree().quit()
```

## Text & translation (FR/EN)

- All labels are **keys**, never raw text. Add a row to `localization/ui_text.csv`:

  ```csv
  keys,en,fr
  MENU_CREDITS,Credits,Crédits
  ```

- Use the key as a Title Key or Text Key. Godot translates automatically and
  re-translates live when the language changes.
- The game starts in **French**. Switch at runtime with `UI.set_language("en")`
  (this is what the Options language toggle will call).

## Styling

Open `theme/game_theme.tres` and edit it. Fonts, colours, and button states
(normal / hover / pressed / focused) all live here, so changing it restyles
**every** screen at once. Per-screen tweaks can still be set on individual nodes.

## The `UI` autoload

- `UI.change_scene("res://path/to/scene.tscn")` — fade out, swap, fade in.
- `UI.set_language("fr" | "en")` — switch UI language at runtime.
