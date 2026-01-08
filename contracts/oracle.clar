;; Oracle trait interface for verifying Bitcoin Ordinal ownership
(define-trait trait
    (
        (verify-inscription-owner (principal uint (buff 128)) (response bool uint))
    )
)
