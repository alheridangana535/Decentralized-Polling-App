(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-poll-not-found (err u101))
(define-constant err-poll-expired (err u102))
(define-constant err-poll-not-expired (err u103))
(define-constant err-already-voted (err u104))
(define-constant err-invalid-option (err u105))
(define-constant err-poll-not-active (err u106))

(define-data-var poll-counter uint u0)

(define-map polls
    { poll-id: uint }
    {
        title: (string-ascii 64),
        description: (string-ascii 256),
        creator: principal,
        start-block: uint,
        end-block: uint,
        status: (string-ascii 10),
        option-count: uint
    }
)

(define-map poll-options
    { poll-id: uint, option-id: uint }
    {
        text: (string-ascii 64),
        votes: uint
    }
)

(define-map user-votes
    { voter: principal, poll-id: uint }
    { option-id: uint }
)

(define-read-only (get-poll (poll-id uint))
    (map-get? polls { poll-id: poll-id })
)

(define-read-only (get-poll-option (poll-id uint) (option-id uint))
    (map-get? poll-options { poll-id: poll-id, option-id: option-id })
)

(define-read-only (get-user-vote (voter principal) (poll-id uint))
    (map-get? user-votes { voter: voter, poll-id: poll-id })
)

(define-read-only (get-poll-results (poll-id uint))
    (let ((poll-data (unwrap! (get-poll poll-id) (err err-poll-not-found))))
        (ok {
            poll: poll-data,
            option-1: (default-to { text: "", votes: u0 } (get-poll-option poll-id u1)),
            option-2: (default-to { text: "", votes: u0 } (get-poll-option poll-id u2)),
            option-3: (default-to { text: "", votes: u0 } (get-poll-option poll-id u3)),
            option-4: (default-to { text: "", votes: u0 } (get-poll-option poll-id u4))
        })
    )
)

(define-read-only (get-current-block)
    stacks-block-height
)

(define-read-only (is-poll-active (poll-id uint))
    (match (get-poll poll-id)
        poll-data
        (let ((current-block stacks-block-height))
            (and 
                (>= current-block (get start-block poll-data))
                (<= current-block (get end-block poll-data))
                (is-eq (get status poll-data) "active")
            )
        )
        false
    )
)

(define-public (create-poll 
    (title (string-ascii 64)) 
    (description (string-ascii 256)) 
    (duration-blocks uint)
    (option-1 (string-ascii 64))
    (option-2 (string-ascii 64))
    (option-3 (optional (string-ascii 64)))
    (option-4 (optional (string-ascii 64)))
)
    (let 
        (
            (new-poll-id (+ (var-get poll-counter) u1))
            (current-block stacks-block-height)
            (end-block (+ current-block duration-blocks))
            (option-count (+ u2 
                (if (is-some option-3) u1 u0)
                (if (is-some option-4) u1 u0)
            ))
        )
        (map-set polls
            { poll-id: new-poll-id }
            {
                title: title,
                description: description,
                creator: tx-sender,
                start-block: current-block,
                end-block: end-block,
                status: "active",
                option-count: option-count
            }
        )
        (map-set poll-options
            { poll-id: new-poll-id, option-id: u1 }
            { text: option-1, votes: u0 }
        )
        (map-set poll-options
            { poll-id: new-poll-id, option-id: u2 }
            { text: option-2, votes: u0 }
        )
        (match option-3
            opt3 (map-set poll-options
                { poll-id: new-poll-id, option-id: u3 }
                { text: opt3, votes: u0 }
            )
            true
        )
        (match option-4
            opt4 (map-set poll-options
                { poll-id: new-poll-id, option-id: u4 }
                { text: opt4, votes: u0 }
            )
            true
        )
        (var-set poll-counter new-poll-id)
        (ok new-poll-id)
    )
)

(define-public (vote (poll-id uint) (option-id uint))
    (let 
        (
            (poll-data (unwrap! (get-poll poll-id) err-poll-not-found))
            (current-block stacks-block-height)
            (voter tx-sender)
        )
        (asserts! (is-poll-active poll-id) err-poll-not-active)
        (asserts! (is-none (get-user-vote voter poll-id)) err-already-voted)
        (asserts! (<= option-id (get option-count poll-data)) err-invalid-option)
        (asserts! (> option-id u0) err-invalid-option)
        
        (let ((option-data (unwrap! (get-poll-option poll-id option-id) err-invalid-option)))
            (map-set poll-options
                { poll-id: poll-id, option-id: option-id }
                { 
                    text: (get text option-data),
                    votes: (+ (get votes option-data) u1)
                }
            )
            (map-set user-votes
                { voter: voter, poll-id: poll-id }
                { option-id: option-id }
            )
            (ok true)
        )
    )
)

(define-public (end-poll (poll-id uint))
    (let ((poll-data (unwrap! (get-poll poll-id) err-poll-not-found)))
        (asserts! (is-eq (get creator poll-data) tx-sender) err-owner-only)
        (asserts! (>= stacks-block-height (get end-block poll-data)) err-poll-not-expired)
        
        (map-set polls
            { poll-id: poll-id }
            (merge poll-data { status: "ended" })
        )
        (ok true)
    )
)
