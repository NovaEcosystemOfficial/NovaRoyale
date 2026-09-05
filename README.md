# NovaRoyale

Personal Clash Royale Companion App — backend foundation.

## Architecture

```
iPhone Companion App
        ↓  (Firebase Auth + Callable Functions)
Firebase Cloud Functions  (TypeScript, europe-west1)
        ↓  (Bearer token — server-side only)
Clash Royale API  (api.clashroyale.com/v1)
        ↓  (cache / sync)
Firestore  (eur3)
        ↓  (read cached data)
iPhone Companion App
```

**Security principle:** the Clash Royale API key never leaves the server. The iPhone client calls Firebase Callable Functions; Cloud Functions call the Clash Royale API and write/read Firestore.

## Project structure

```
NovaRoyale/
├── firebase.json           # Firestore (eur3) + Functions config
├── firestore.rules         # Restrictive security rules
├── firestore.indexes.json
└── functions/
    └── src/
        ├── index.ts                    # Function exports
        ├── config/
        │   ├── constants.ts            # TTLs, collection names, region
        │   ├── secrets.ts              # CLASH_ROYALE_API_KEY (defineSecret)
        │   └── firebase.ts             # Admin SDK init
        ├── clashRoyale/
        │   ├── client.ts               # ClashRoyaleClient (HTTP layer)
        │   ├── endpoints.ts            # API path definitions
        │   └── errors.ts               # ClashRoyaleApiError
        ├── models/                     # Firestore + API types
        ├── repositories/               # Firestore data access
        ├── services/
        │   ├── clashRoyale.service.ts  # API service layer
        │   ├── sync.service.ts         # Sync orchestration + cache TTL
        │   └── factory.ts              # Service wiring
        ├── functions/
        │   └── player.functions.ts     # Callable entry points
        └── utils/
            ├── playerTag.ts            # Tag validation/normalization
            ├── errors.ts               # HttpsError mapping
            └── timestamps.ts           # Sync state helpers
```

## Firestore data model

| Collection / Path | Purpose |
|---|---|
| `users/{uid}` | Links Firebase Auth user → player tag |
| `players/{tagId}` | Cached player profile (`tagId` = tag without `#`) |
| `players/{tagId}/battleLogs/{battleId}` | Cached battle log entries |
| `players/{tagId}/upcomingChests/current` | Upcoming chest queue |
| `clans/{tagId}` | Clan cache (future) |
| `cards/global` | Global cards cache (future) |
| `syncMetadata/{tagId}` | Per-resource sync state, errors, next sync time |

All client writes are blocked by security rules. Only Cloud Functions (Admin SDK) write data.

## Callable functions

| Function | Description |
|---|---|
| `syncPlayer` | Link a player tag to the authenticated user and sync profile |
| `getPlayer` | Get cached/synced player profile for the linked user |
| `getBattleLog` | Get battle log (cache-first, sync when stale) |
| `getUpcomingChests` | Get upcoming chest queue (cache-first) |

All functions require Firebase Authentication (`request.auth`).

### Example payloads

```typescript
// syncPlayer
{ playerTag: "#ABC123", forceRefresh?: boolean }

// getPlayer
{ forceRefresh?: boolean }

// getBattleLog / getUpcomingChests
{ playerTag?: string, forceRefresh?: boolean }
```

## API key configuration

The API key is stored as a Firebase Functions secret — **never** in client code or committed files.

### Production

```bash
firebase functions:secrets:set CLASH_ROYALE_API_KEY
```

Obtain your key from the [Supercell Developer Portal](https://developer.clashroyale.com/).

### Local emulator

Create `functions/.secret.local` (gitignored via `*.local`):

```
CLASH_ROYALE_API_KEY=your_key_here
```

## Local authentication (emulator only)

Production always requires a real Firebase Auth identity (`request.auth.uid`).

Local smoke tests must use the **Auth Emulator** (anonymous sign-in → ID token → callable).

Optional opt-in only (not used by the smoke test): set `EMULATOR_AUTH_UID` when
`FUNCTIONS_EMULATOR=true` to allow a controlled local UID without a token.
If unset, missing auth still returns `UNAUTHENTICATED` even in the emulator.

## Firebase configuration

| Setting | Value |
|---|---|
| Project ID | `novaroyale-b5f5a` |
| Firestore region | `eur3` |
| Functions region | `europe-west1` |
| Node.js | 24 |

## Local development

```bash
cd functions
npm install
npm run build
npm run lint
npm test
```

### Emulator (Auth + Functions + Firestore)

**Prerequisites**
1. Java JDK 21+ on PATH (`java -version`) — required by Firestore Emulator  
   Example: `brew install --cask temurin@21`
2. `functions/.secret.local` with `CLASH_ROYALE_API_KEY=...`

**Important:** do **not** start with `--only functions`.  
That skips Auth + Firestore and causes:
- `Auth Emulator unavailable` / `fetch failed`
- `syncPlayer failed: 5 NOT_FOUND` (Admin SDK hitting production Firestore)

```bash
# From functions/
npm run serve
```

Equivalent from project root:

```bash
firebase emulators:start --only auth,functions,firestore
```

You should see Auth **9099**, Functions **5001**, Firestore **8080** in the emulator table.

UI: http://127.0.0.1:4000

| Emulator | Host |
|---|---|
| Auth | 127.0.0.1:9099 |
| Functions | 127.0.0.1:5001 |
| Firestore | 127.0.0.1:8080 |

### Smoke-test getPlayer with #29G9Q92RL

With emulators running and `.secret.local` configured:

```bash
# Terminal 1
cd ~/Desktop/NovaRoyale/functions
npm run serve

# Terminal 2
cd ~/Desktop/NovaRoyale/functions
npm run test:emulator:getPlayer
```

Flow:
1. Health-check Auth / Functions / Firestore ports
2. Anonymous sign-in via Auth Emulator
3. `syncPlayer({ playerTag: "#29G9Q92RL" })` with real `request.auth`
4. `getPlayer()` reading the linked profile (Clash Royale API + Firestore cache)

## Testing

```bash
cd functions
npm test
```

Tests cover:
- `ClashRoyaleClient` — HTTP headers, error handling (mocked `fetch`)
- `normalizePlayerTag` — validation and encoding
- Emulator auth helpers — production rejects unauthenticated; opt-in `EMULATOR_AUTH_UID` only in emulator

## Sync behaviour

| Resource | Cache TTL | Min sync interval |
|---|---|---|
| Player profile | 5 min | 1 min |
| Battle log | 2 min | 1 min |
| Upcoming chests | 15 min | 5 min |

When the API fails, stale cache is returned if available. Errors are recorded in `syncMetadata`.

## Future deploy

> Not part of Phase 1 — documented for reference only.

```bash
# Deploy rules + indexes + functions
firebase deploy --only firestore:rules,firestore:indexes,functions
```

Pre-deploy hooks run `lint` and `build` automatically (see `firebase.json`).

## Phase 1 scope

**Included:**
- Backend architecture (client → service → repository)
- Callable functions entry points
- Firestore schema + restrictive rules
- Sync system with TTL cache
- Tests + documentation

**Not included (future phases):**
- iPhone UI
- User login flows beyond Firebase Auth
- Push notifications
- AI / analytics
- Automated deploy pipelines
