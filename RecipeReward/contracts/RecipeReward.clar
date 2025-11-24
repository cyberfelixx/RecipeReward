;; RecipeReward - A tipping service for food bloggers and recipe creators
;; Built on Stacks blockchain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-creator-not-found (err u102))
(define-constant err-already-registered (err u103))
(define-constant err-transfer-failed (err u104))

;; Data Variables
(define-data-var platform-fee-percentage uint u5) ;; 5% platform fee

;; Data Maps
(define-map creators
  principal
  {
    display-name: (string-ascii 50),
    total-tips-received: uint,
    tip-count: uint,
    active: bool
  }
)

(define-map tips
  {tipper: principal, creator: principal, tip-id: uint}
  {
    amount: uint,
    message: (optional (string-utf8 280)),
    tip-block-height: uint
  }
)

(define-data-var tip-nonce uint u0)

;; Read-only functions

(define-read-only (get-creator-info (creator principal))
  (map-get? creators creator)
)

(define-read-only (get-tip-info (tipper principal) (creator principal) (tip-id uint))
  (map-get? tips {tipper: tipper, creator: creator, tip-id: tip-id})
)

(define-read-only (get-platform-fee-percentage)
  (ok (var-get platform-fee-percentage))
)

(define-read-only (is-creator-registered (creator principal))
  (is-some (map-get? creators creator))
)

;; Public functions

(define-public (register-creator (display-name (string-ascii 50)))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (is-none (map-get? creators caller)) err-already-registered)
    (ok (map-set creators caller
      {
        display-name: display-name,
        total-tips-received: u0,
        tip-count: u0,
        active: true
      }
    ))
  )
)

(define-public (send-tip (creator principal) (amount uint) (message (optional (string-utf8 280))))
  (let
    (
      (tipper tx-sender)
      (creator-data (unwrap! (map-get? creators creator) err-creator-not-found))
      (fee-amount (/ (* amount (var-get platform-fee-percentage)) u100))
      (creator-amount (- amount fee-amount))
      (current-nonce (var-get tip-nonce))
    )
    ;; Validations
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (get active creator-data) err-creator-not-found)
    
    ;; Transfer STX to creator
    (unwrap! (stx-transfer? creator-amount tipper creator) err-transfer-failed)
    
    ;; Transfer platform fee to contract owner
    (if (> fee-amount u0)
      (unwrap! (stx-transfer? fee-amount tipper contract-owner) err-transfer-failed)
      true
    )
    
    ;; Update creator stats
    (map-set creators creator
      (merge creator-data
        {
          total-tips-received: (+ (get total-tips-received creator-data) creator-amount),
          tip-count: (+ (get tip-count creator-data) u1)
        }
      )
    )
    
    ;; Record the tip
    (map-set tips
      {tipper: tipper, creator: creator, tip-id: current-nonce}
      {
        amount: creator-amount,
        message: message,
        tip-block-height: burn-block-height
      }
    )
    
    ;; Increment tip nonce
    (var-set tip-nonce (+ current-nonce u1))
    
    (ok {tip-id: current-nonce, amount-sent: creator-amount, fee-charged: fee-amount})
  )
)

(define-public (update-display-name (new-name (string-ascii 50)))
  (let
    (
      (caller tx-sender)
      (creator-data (unwrap! (map-get? creators caller) err-creator-not-found))
    )
    (ok (map-set creators caller
      (merge creator-data {display-name: new-name})
    ))
  )
)

(define-public (toggle-active-status)
  (let
    (
      (caller tx-sender)
      (creator-data (unwrap! (map-get? creators caller) err-creator-not-found))
    )
    (ok (map-set creators caller
      (merge creator-data {active: (not (get active creator-data))})
    ))
  )
)

;; Admin functions

(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u10) err-invalid-amount) ;; Max 10% fee
    (ok (var-set platform-fee-percentage new-fee))
  )
)