# RecipeReward Smart Contract

A decentralized tipping platform for food bloggers and recipe creators built on the Stacks blockchain using Clarity smart contracts.

## Overview

RecipeReward enables fans and followers to support their favorite recipe creators with STX token tips. Creators can register on the platform, receive tips directly, and track their earnings, all secured by blockchain technology.

## Features

### For Recipe Creators
- **Easy Registration**: Register as a creator with a custom display name
- **Direct Tips**: Receive STX tips directly to your wallet
- **Tip Tracking**: View total tips received and tip count
- **Profile Management**: Update display name and toggle active status
- **Transparent Fees**: 5% platform fee (95% goes directly to creators)

### For Supporters
- **Send Tips**: Support creators with any amount of STX
- **Personal Messages**: Include optional messages (up to 280 characters) with tips
- **Transparent Records**: All tips are recorded on-chain with full transparency

### Platform Features
- **Low Fees**: Only 5% platform fee (adjustable by contract owner, max 10%)
- **Decentralized**: No intermediaries, direct creator-to-supporter transactions
- **Secure**: Built with Clarity for maximum security and predictability

## Contract Functions

### Public Functions

#### `register-creator`
Register as a recipe creator on the platform.

```clarity
(register-creator (display-name (string-ascii 50)))
```

**Parameters:**
- `display-name`: Your creator name (max 50 characters)

**Returns:** `(ok true)` on success

---

#### `send-tip`
Send a tip to a registered creator.

```clarity
(send-tip (creator principal) (amount uint) (message (optional (string-utf8 280))))
```

**Parameters:**
- `creator`: The principal address of the creator
- `amount`: Amount of STX to tip (in microSTX)
- `message`: Optional message to include with the tip

**Returns:** 
```clarity
(ok {tip-id: uint, amount-sent: uint, fee-charged: uint})
```

---

#### `update-display-name`
Update your creator display name.

```clarity
(update-display-name (new-name (string-ascii 50)))
```

**Parameters:**
- `new-name`: Your new display name

**Returns:** `(ok true)` on success

---

#### `toggle-active-status`
Toggle your creator account between active and inactive.

```clarity
(toggle-active-status)
```

**Returns:** `(ok true)` on success

---

### Read-Only Functions

#### `get-creator-info`
Get information about a creator.

```clarity
(get-creator-info (creator principal))
```

**Returns:**
```clarity
(optional {
  display-name: (string-ascii 50),
  total-tips-received: uint,
  tip-count: uint,
  active: bool
})
```

---

#### `get-tip-info`
Get details of a specific tip.

```clarity
(get-tip-info (tipper principal) (creator principal) (tip-id uint))
```

**Returns:**
```clarity
(optional {
  amount: uint,
  message: (optional (string-utf8 280)),
  tip-block-height: uint
})
```

---

#### `get-platform-fee-percentage`
Get the current platform fee percentage.

```clarity
(get-platform-fee-percentage)
```

**Returns:** `(ok uint)` - Current fee percentage

---

#### `is-creator-registered`
Check if a principal is registered as a creator.

```clarity
(is-creator-registered (creator principal))
```

**Returns:** `bool` - true if registered, false otherwise

---

### Admin Functions

#### `set-platform-fee`
Update the platform fee percentage (owner only).

```clarity
(set-platform-fee (new-fee uint))
```

**Parameters:**
- `new-fee`: New fee percentage (max 10%)

**Returns:** `(ok true)` on success

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | err-owner-only | Action restricted to contract owner |
| u101 | err-invalid-amount | Invalid tip amount or fee percentage |
| u102 | err-creator-not-found | Creator not registered or inactive |
| u103 | err-already-registered | Principal already registered as creator |
| u104 | err-transfer-failed | STX transfer failed |

## Usage Examples

### Register as a Creator

```clarity
(contract-call? .RecipeReward register-creator "Chef Alice's Kitchen")
```

### Send a Tip

```clarity
(contract-call? .RecipeReward send-tip 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
  u1000000 ;; 1 STX (1,000,000 microSTX)
  (some u"Love your pasta recipes! Thanks for sharing!"))
```

### Check Creator Stats

```clarity
(contract-call? .RecipeReward get-creator-info 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Deployment

1. Deploy the contract to Stacks blockchain using Clarinet or Hiro Platform
2. The deploying address becomes the contract owner
3. Default platform fee is set to 5%

## Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) for local development and testing
- Stacks wallet for mainnet/testnet deployment

### Local Testing

```bash
# Clone the repository
git clone <your-repo-url>
cd recipe-reward

# Check contract syntax
clarinet check

# Run tests
clarinet test

# Launch console for interactive testing
clarinet console
```

## Security Considerations

- All STX transfers are atomic and secure
- Creator registration prevents duplicate registrations
- Platform fee is capped at 10% maximum
- Inactive creators cannot receive tips
- All transactions are recorded immutably on-chain

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Support

For questions or issues, please open an issue on GitHub or contact the maintainers.

---

**Built with ❤️ on Stacks blockchain**