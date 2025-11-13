## Practice SysAdmin Simulator – Phase 1 (MVP)

### Folder Layout
```
ReplicatedStorage
└── Modules
    ├── CatalogModule.lua
    ├── CurrencyManager.lua
    ├── CrimpMinigame.lua
    ├── DatastoreModule.lua
    ├── MultiplayerInvite.lua
    ├── NetworkGraph.lua
    ├── PlacementSystem.lua
    ├── QuestManager.lua
    ├── TerminalModule.lua
    └── UIBinder.lua
ServerScriptService
└── Controllers
    ├── Bootstrap.server.lua
    ├── CurrencyController.lua
    ├── DataController.lua
    ├── MinigameController.lua
    └── PlacementController.lua
StarterPlayer
└── StarterPlayerScripts
    └── ClientInit.client.lua
Workspace
└── DataCenters (auto-created at runtime)
AssetsToReplace
└── Placeholder_* models or Parts (drop in Roblox Studio Explorer)
```

### Quick Start
1. Import the scripts above into matching services in Roblox Studio.
2. *(Optional)* Drop real models into `AssetsToReplace` and update the factory functions in `PlacementController` where noted.
3. Play solo test:
   - Press the catalog toggle button to open the build list.
   - Select `Rack` or `Server` to spawn a ghost. Click to place (snap-to-grid).
   - Select `Cable`, place it, then complete the 3-second crimp mini-game overlay.
4. Currency spends on each purchase; check HUD for balance updates. Failed placements refund automatically.
5. Stop the session and verify persistence by rejoining (profile uses `DC_<UserId>_Profile`).

### Testing Scenario
1. Join playtest with two players if possible.
2. Invite a friend (Phase 2 placeholder) — see `MultiplayerInvite.lua` comments for future wiring.
3. Build flow:
   - Place `Rack` near origin, rotate with `R`.
   - Place `Server` on adjacent grid cell.
   - Place `Cable`, finish crimp mini-game successfully to set high cable health.
4. Observe HUD updates (`Currency`, `Level` stubbed) and catalog availability.

### Asset Integration
- Replace placeholder parts/models by editing `_createRack`, `_createServer`, `_createCable` in `PlacementController`.
- Use `AssetsToReplace/<your model>` as reference; ensure the primary part aligns with a 4-stud grid.
- Update catalog entries for new cost, size, and unlock level.

### Multiplayer / Quests (Coming Phases)
- **Phase 2:** Implement `MultiplayerInvite` RemoteEvent flow, terminal command handling, and XP/Level gating.
- **Phase 3:** Expand `QuestManager` to issue tasks, integrate `NetworkGraph` for connectivity tracking.
- **Phase 4:** Add DHCP/DNS mini-games, persistence for network config, and server-side validation for terminal commands.

### Mini-Beta Checklist
- ✅ Placement system with grid snap and collision checks.
- ✅ Currency spend/refund, basic HUD.
- ✅ Cable crimp mini-game affecting cable health attribute.
- ✅ DataStore persistence with retry/backoff.
- ⬜ Cooperative build flow (Phase 2).
- ⬜ Quest issuance and completion rewards (Phase 2/3).
- ⬜ Terminal commands with validation (Phase 2).
- ⬜ Advanced network graph + analytics (Phase 3/4).

Contributions welcome — see inline comments for extension hooks.

