# RoyalCompanion (iOS)

Premium Clash Royale companion UI. Display name: **RoyalCompanion**.

Xcode target folder remains `NovaRoyale` for project stability.

## Run

```bash
open /Users/ryuk/Desktop/NovaRoyale/ios/NovaRoyale.xcodeproj
```

Then choose an iPhone Simulator and press **⌘R**.

## Architecture

- `Theme/` — RoyalTokens, Typography, Motion, Background
- `Components/` — reusable gaming UI
- `Views/` — Home, Battles (+ Detail), Cards (+ Detail), Stats, Profile
- `Services/` — `ClashRoyaleServing` + `MockClashRoyaleService` (swap later for Firebase)

Backend under `functions/` is untouched. No API keys in the iOS app.
