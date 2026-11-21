# Store listing

Everything the stores ask for in text and pictures.

| File | Used for | Limit |
| --- | --- | --- |
| `title.txt` | App name (Play and App Store) | 30 characters |
| `short_description.txt` | Play short description | 80 characters |
| `subtitle_ios.txt` | App Store subtitle | 30 characters |
| `keywords_ios.txt` | App Store keywords | 100 characters, comma separated |
| `full_description.md` | Play full description and App Store description | 4,000 characters |
| `release_notes.md` | "What's new" | Play 500, App Store 4,000 |
| `screenshots/phone-ios/` | iPhone 6.7" (1290 x 2796) | 1 to 10 |
| `screenshots/phone-play/` | Play phone (1080 x 1920) | 2 to 8 |
| `screenshots/tablet/` | iPad 12.9" and Play tablets (2048 x 2732) | 1 to 10 |

`test/store/store_listing_test.dart` checks the text limits.

## Screenshots

Made by `test/tool/generate_store_screenshots_test.dart`: real screens of the app
filled with the public-domain classics from `StoreDemoSeeder`, in a terracotta
frame with a Fraunces caption.

```
GENERATE_ASSETS=1 flutter test test/tool/generate_store_screenshots_test.dart
```

The five captions: "Never buy a book twice", "Know where every book lives",
"Lend without losing", "Keep the lines you love", "Your books, your device".
For screenshots on a real device, run the dev flavour and use More, "Load store
demo data (dev)".

Pictures to add by hand: none required. If a store wants a feature graphic
(Play, 1024 x 500), `assets/brand/icon_rounded_512.png` on a terracotta field
with the title in Fraunces works.
