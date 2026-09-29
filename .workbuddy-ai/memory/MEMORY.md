# Rent Car — Project Conventions

Durable rules for this Flutter app. Read before making UI changes.

## Tech constraints (non-negotiable)
- **Flutter / Dart, Material 3, NO external packages.** No `provider`, no
  `go_router`, no `intl`, no code-gen. State is a hand-rolled `ChangeNotifier`
  (`AppState`) exposed via `InheritedNotifier` (`AppStateScope`).
- Everything visual is drawn with **`CustomPainter`** wherever it adds value —
  cards, panels, gauges, rings, bars, backdrops.
- Cross-tab navigation goes through `MainWrapper.goToTab(MainWrapper.xTab)`.
  Never hardcode tab indices.

## Theme: LIGHT ONLY, NO GRADIENTS
- The app is light theme only. `canvas #F3F5F9` page, `surface #FFFFFF` cards.
- **No gradients anywhere.** All `AppColor.*Gradient` tokens are flat stand-ins
  (both stops identical) kept only for source compatibility. Do not add a real
  gradient. `grep -rn "Gradient" lib/ | grep -v app_color.dart` must stay empty.
- Elevation = **soft two-layer shadow + hairline border**, never a colour ramp.

## BLUE ONLY
- **`secondary` is an alias of `primary`.** The app has one structural accent.
  That alias is deliberate and load-bearing — it is what made ~100 existing
  `AppColor.secondary` call sites blue without editing them. Do not give
  `secondary` its own hue again.
- `accentFor(index)` always returns `primary`. It used to cycle blue/teal/amber,
  which gave every card in a list a different accent colour.
- **Only three colours are not blue, and they are semantic only:**
  `amber` (rating stars, prices), `success` (availability, compare winner),
  `danger` (favourite heart, destructive). Never use them as decoration.
  A test asserts they stay distinct from `primary`.
- New gauges/bars/rings must use `AppColor.primary`. Do not accept a
  `gradientColors` list in a new painter — it invites the old rainbow back.

## Speedometer geometry
The readout is painted on canvas, not composited as widgets. `_paintReadout`
anchors the block **below the hub** (`center.dy + radius * 0.155 + gap`) so the
value never sits on the dial centre; `_paintCaption` stacks directly beneath it.
`SpeedometerPainter` exposes `readoutBand` and `valueTextRect` for tests. If you
move the text, keep both getters updated — the placement tests read them.

## THE `obsidian` TRAP
`obsidian` is now **near-white**. Any widget that used it as *foreground on a
bright fill* must use `Colors.white`; any that used it as *dark ink* (modal
barrier, badge border) must use `AppColor.scrim`. If text disappears after a
surface change, this is why.

## Car images must be visually identical across cards
Use `CarCard.imageBoxWidth × CarCard.imageBoxHeight` (240 × 104) in a fixed
`SizedBox` with `BoxFit.contain`. Never rely on the source PNG's intrinsic size;
never use `BoxFit.cover` (it crops). A test asserts the measured box is
pixel-identical across six different cars.

## Performance invariants (do not regress)
- **`AppStateScope.updateShouldNotify` MUST return `false`.** The notifier is
  final; returning `true` marks every `AppState.of` caller dirty on every
  `notifyListeners()`, and since each tab is an `IndexedStack` child that
  rebuilds the entire app on every tap and keystroke. Listeners still fire.
- **`EntranceFade` must return its bare child once settled.** A lingering
  `Opacity` is a `saveLayer` every frame for every visible list item.
- **Every `Image.asset` of a car PNG needs `cacheWidth`.** Without it the
  full-resolution asset is decoded and downscaled per scroll frame.

## Layout safety
- Prefer **bounded columns/rows** over `Stack` + `Positioned` for card content.
  Absolutely-positioned siblings are what caused the original price/speed
  overlap. If something must be positioned, reserve its space in the flow.
- Wrap flexible text in `Flexible` + `TextOverflow.ellipsis`.
- Never read an `InheritedWidget` in `initState` — use `didChangeDependencies`
  with a seed guard.
- Use the radius tokens (`radiusChip 10`, `radiusControl 14`, `radiusCard 18`,
  `radiusPanel 24`), not literals.
- Header controls are 44×44 circular icon buttons. The details header is
  back-arrow … `Spacer()` … calendar + favourite. Keep it icon-only; a labelled
  chip there overflows on narrow phones.
- The stock `DateRangePickerDialog` header overflows below ~420px width unless
  both `rangePickerHeaderHeadlineStyle` and `rangePickerHeaderHelpStyle` are
  pinned to small sizes and `insetPadding.horizontal` is ≤ 12.

## Animations
Subtle and purposeful only: 110–280ms, `Curves.easeOut`. List items use
`EntranceFade` (staggered, one-shot). Never add infinite decorative motion —
it also breaks `pumpAndSettle` in tests.

## Commands
Always prefix with the proxy env, or the test harness WebSocket fails:
```
HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= flutter <analyze|test|build web>
```
Run `analyze`, `test` and `build web` **sequentially** — issuing a build
concurrently with a test causes a spurious compiler-lock error.

## Visual verification
Widget tests do not catch layout collisions. Two collisions this project hit —
the hero price under the car image, and the 106px date-picker header overflow —
were both invisible to tests and only found by looking at pixels.

**A ready-made harness lives at `tools/shoot.js`.** Use it rather than rewriting
one:

```bash
cd build/web && (python -m http.server 8899 --bind 127.0.0.1 >/dev/null 2>&1 &) \
  && sleep 3 && cd .. \
  && NODE_PATH="C:/Users/FIREFLY LAPTOP'S/.workbuddy-ai/binaries/node/workspace/node_modules" \
     SHOOT_OUT="C:/flutter_projects/rent_car/tools/shot" \
     "C:/Users/FIREFLY LAPTOP'S/.workbuddy-ai/binaries/node/versions/22.22.2-2/node.exe" \
     tools/shoot.js
pkill -f "http.server 8899"
```

It drives the system Chrome through `playwright-core` (`executablePath`), taps
through intro → home → list → details → performance, and writes `-00`…`-04`
PNGs. Start the server **and** run the script in the *same* Bash invocation — a
backgrounded server dies between calls. Flutter web renders to canvas, so a DOM
screenshot shows nothing; wait ~9s for the engine to boot.

Delete the PNGs afterwards; keep `shoot.js`.
