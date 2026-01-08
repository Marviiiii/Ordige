
;; Requires an Oracle because Stacks nodes don't index Ordinals natively yet
(use-trait oracle-trait .oracle.trait)

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ORACLE_NOT_SET (err u101))
(define-constant ERR_ORACLE_MISMATCH (err u102))
(define-constant ERR_LEVEL_NOT_CONFIGURED (err u103))
(define-constant ERR_ALREADY_UNLOCKED (err u104))
(define-constant ERR_NOT_OWNER (err u105))

(define-data-var admin principal tx-sender)
(define-data-var oracle-contract (optional principal) none)

(define-map ordinal-levels uint uint)
(define-map level-unlocks {player: principal, level-id: uint} uint)

(define-read-only (get-oracle)
    (var-get oracle-contract)
)

(define-read-only (get-level-for-ordinal (ordinal-id uint))
    (map-get? ordinal-levels ordinal-id)
)

(define-read-only (is-level-unlocked (player principal) (level-id uint))
    (is-some (map-get? level-unlocks {player: player, level-id: level-id}))
)

(define-public (set-admin (new-admin principal))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
        (var-set admin new-admin)
        (ok true)
    )
)

(define-public (set-oracle (oracle <oracle-trait>))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
        (var-set oracle-contract (some (contract-of oracle)))
        (ok true)
    )
)

(define-public (set-ordinal-level (ordinal-id uint) (level-id uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
        (map-set ordinal-levels ordinal-id level-id)
        (ok true)
    )
)

(define-public (unlock-level (ordinal-id uint) (proof (buff 128)) (oracle <oracle-trait>))
    (let (
        (oracle-opt (var-get oracle-contract))
        (level-opt (map-get? ordinal-levels ordinal-id))
    )
        (match oracle-opt oracle-principal
            (begin
                (asserts! (is-eq (contract-of oracle) oracle-principal) ERR_ORACLE_MISMATCH)
                (match level-opt level-id
                    (begin
                        (asserts!
                            (is-none (map-get? level-unlocks {player: tx-sender, level-id: level-id}))
                            ERR_ALREADY_UNLOCKED
                        )
                        (let ((is-owner (try! (contract-call? oracle verify-inscription-owner tx-sender ordinal-id proof))))
                            (asserts! is-owner ERR_NOT_OWNER)
                        )
                        (map-set level-unlocks {player: tx-sender, level-id: level-id} ordinal-id)
                        (print {event: "level-unlocked", player: tx-sender, level-id: level-id, ordinal-id: ordinal-id})
                        (ok level-id)
                    )
                    ERR_LEVEL_NOT_CONFIGURED
                )
            )
            ERR_ORACLE_NOT_SET
        )
    )
)
