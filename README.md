## Ordige Contract

This contract provides a minimal framework for unlocking game levels based on Bitcoin Ordinal ownership verified by an external oracle contract.

### Key Concepts
- **Oracle trait**: `contracts/ordige.clar` imports `.oracle.trait` via `use-trait oracle-trait`.
- **Admin**: A single `admin` data var (defaults to `tx-sender`) controls configuration.
- **State**:
  - `ordinal-levels` maps `ordinal-id -> level-id`.
  - `level-unlocks` maps `{player, level-id} -> ordinal-id`.

### Public Functions
- `set-admin(new-admin)` — changes the admin (admin-only).
- `set-oracle(oracle)` — stores the configured oracle contract principal (admin-only).
- `set-ordinal-level(ordinal-id, level-id)` — sets the required ordinal for a level (admin-only).
- `unlock-level(ordinal-id, proof, oracle)` — verifies ownership with the configured oracle, prevents repeat unlocks, stores the unlock, and emits a `print` event.

### Read-Only Functions
- `get-oracle()` — returns the configured oracle (optional principal).
- `get-level-for-ordinal(ordinal-id)` — returns the mapped level for an ordinal (optional uint).
- `is-level-unlocked(player, level-id)` — checks if a level is already unlocked for a player (bool).
