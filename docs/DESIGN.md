# Design system: "Ink & Paper"

Calm, warm, premium, bookish. Covers are the hero.

## Colours

| Token | Light "Paper" | Dark "Lamplight" |
|---|---|---|
| background | #FBF7F0 | #15120F |
| surface | #FFFFFF | #1E1A16 |
| surface-variant | #F3EDE3 | #2A241E |
| text | #1F1B16 | #F2EBE1 |
| muted | #6B6259 | #B3A89A |
| outline | #E5DDD0 | #3A322A |
| primary | #B4532A | #E08A5B |
| secondary | #1F5C5B | #7FB8B5 |

Light-only status colours: success #3E7A4F, warning #B7791F, error #B3261E; on-primary #FFFFFF.

## Typography

Fraunces (display, headlines, book titles) and Inter (UI/body), both bundled as assets.
Scale: display 34/40, headline 26/32, title 20/26, body 16/24, label 14/20, caption 12/16.
Supports system text scaling up to 200%.

## Shape and space

- Spacing (4-pt grid): 4, 8, 12, 16, 24, 32, 48. Screen padding 20.
- Radii: cards 20, sheets 28 (top), chips 12, buttons 14, covers 6.
- 1px outlines and soft warm shadows (black 6-10%, blur 16-24).

## Motion

200-300ms, easeOutCubic, 30ms list stagger, hero on covers; respects reduce-motion.

## Layout breakpoints

compact < 600dp (bottom nav), medium 600-1000dp (rail), expanded > 1000dp (rail + two-pane).
Minimum tap target 48x48dp; WCAG AA contrast.
