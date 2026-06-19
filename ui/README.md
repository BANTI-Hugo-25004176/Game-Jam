# Template d'interface (GUI)

Un petit système réutilisable pour créer des menus/écrans rapidement et de façon
cohérente. Tout est **piloté par les données** et **traduit (FR/EN)** d'origine.

## Fichiers

| Fichier | Rôle |
|---------|------|
| `components/menu_screen.tscn` (+ `.gd`) | L'écran réutilisable : un titre + une liste de boutons, construite à partir des données. |
| `components/menu_button.tscn` (+ `.gd`) | Le bouton réutilisable (focus + son survol/clic). Tu y touches rarement. |
| `data/menu_item.gd` | Une ressource `MenuItem` = un bouton (clé de libellé + action ou scène cible). |
| `theme/game_theme.tres` | Le thème visuel partagé. **C'est ici qu'on style tout.** |
| `localization/ui_text.csv` | Tous les textes de l'UI, en français et anglais. |
| `autoload/ui_manager.tscn` (+ `.gd`) | Autoload `UI` : transitions (fondu) entre scènes + changement de langue. |
| `screens/` | Les écrans déjà faits : `main_menu`, `options`, `pause`, `game_over`, `victory`. |

## Créer un nouvel écran en 3 étapes

1. **Duplique** `screens/main_menu.tscn` et renomme-le (ex. `credits.tscn`).
2. Sélectionne le nœud **`MenuScreen`** et, dans l'Inspecteur, règle :
   - **Title Key** — une clé de `ui_text.csv` (ex. `TITLE_PAUSE`).
   - **Items** — un `MenuItem` par bouton. Pour chaque item :
     - **Text Key** — une clé de `ui_text.csv` (ex. `MENU_RESUME`).
     - Soit **Target Scene** (le bouton ouvre cette scène)…
     - … soit une chaîne **Action** (le bouton signale une action à gérer en code).
3. Si tu as utilisé des boutons **Action**, gère-les dans le script de l'écran
   (voir `screens/main_menu.gd`). Un écran de pure navigation (uniquement des
   boutons Target Scene) n'a **besoin d'aucun script**.

C'est tout — la navigation clavier + manette et le FR/EN sont automatiques.

## Boutons : deux modes

- **Bouton de navigation** → renseigne `target_scene` sur le `MenuItem`. Appuyer
  dessus change de scène (avec un fondu, via l'autoload `UI`).
- **Bouton d'action** → laisse `target_scene` vide et renseigne `action`
  (ex. `"quit"`). L'écran émet `action_pressed(action)` ; gère-le dans le script :

```gdscript
func _on_action(action: String) -> void:
	match action:
		"resume": get_tree().paused = false
		"quit":   get_tree().quit()
```

## Textes & traduction (FR/EN)

- Tous les libellés sont des **clés**, jamais du texte brut. Ajoute une ligne à
  `localization/ui_text.csv` :

  ```csv
  keys,en,fr
  MENU_CREDITS,Credits,Crédits
  ```

- Utilise la clé comme Title Key ou Text Key. Godot traduit automatiquement et
  re-traduit en direct quand la langue change.
- Le jeu démarre en **français**. Pour changer à l'exécution :
  `UI.set_language("en")` (c'est ce qu'appelle le sélecteur de langue des Options).

## Style (le thème)

Ouvre `theme/game_theme.tres` : un **double-clic** affiche l'éditeur de thème dans
le panneau du bas de Godot. Polices, couleurs et états des boutons (normal /
survol / pressé / focus) y sont tous définis — modifier le thème restyle **tous**
les écrans d'un coup. Des ajustements par écran restent possibles sur chaque nœud.

## L'autoload `UI`

- `UI.change_scene("res://chemin/vers/scene.tscn")` — fondu, change de scène, fondu.
- `UI.set_language("fr" | "en")` — change la langue de l'UI à l'exécution.
