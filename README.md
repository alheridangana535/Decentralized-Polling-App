# 🗳️ Decentralized Polling App

A blockchain-based polling system built on Stacks that enables secure, transparent, and tamper-proof surveys and voting.

## 📋 Features

✅ **Create Polls** - Launch surveys with custom titles, descriptions, and options  
🗳️ **Secure Voting** - One vote per address, immutably stored on-chain  
⏰ **Time-bound** - Set poll duration with automatic expiration  
📊 **Real-time Results** - View voting results as they happen  
🔒 **Transparent** - All votes and results are publicly verifiable  

## 🚀 Usage

### Creating a Poll

```clarity
(contract-call? .decentralized-polling-app create-poll 
    "Favorite Programming Language" 
    "Vote for your preferred language for web development"
    u1000  ;; Duration in blocks (~7 days)
    "JavaScript"
    "Python" 
    (some "Rust")
    (some "Go"))
```

### Voting on a Poll

```clarity
(contract-call? .decentralized-polling-app vote u1 u2)  ;; Vote for option 2 in poll 1
```

### Getting Poll Results

```clarity
(contract-call? .decentralized-polling-app get-poll-results u1)
```

### Checking if Poll is Active

```clarity
(contract-call? .decentralized-polling-app is-poll-active u1)
```

## 🔧 Contract Functions

| Function | Description |
|----------|-------------|
| `create-poll` | Create a new poll with 2-4 options |
| `vote` | Cast your vote for a specific option |
| `get-poll` | Retrieve poll information |
| `get-poll-results` | View voting results |
| `get-user-vote` | Check if user already voted |
| `is-poll-active` | Verify if poll is accepting votes |
| `end-poll` | Manually end poll (creator only) |

## 📈 Data Structure

### Poll Object
```clarity
{
    title: (string-ascii 64),
    description: (string-ascii 256),
    creator: principal,
    start-block: uint,
    end-block: uint,
    status: (string-ascii 10),
    option-count: uint
}
```

### Option Object
```clarity
{
    text: (string-ascii 64),
    votes: uint
}
```

## 🛡️ Security Features

- **Anti-double voting** - Users can only vote once per poll
- **Time validation** - Votes only accepted during active period  
- **Creator controls** - Poll creators can end their polls early
- **Immutable records** - All votes permanently stored on blockchain

## ⚡ Getting Started

1. Deploy the contract to Stacks testnet/mainnet
2. Create your first poll using the `create-poll` function
3. Share the poll ID with participants
4. Monitor results in real-time
5. Poll automatically ends after specified duration

## 🔍 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only operation |
| u101 | Poll not found |
| u102 | Poll expired |
| u103 | Poll not expired yet |
| u104 | User already voted |
| u105 | Invalid option selected |
| u106 | Poll not active |

## 🌐 Network Compatibility

- ✅ Stacks Mainnet
- ✅ Stacks Testnet  
- ✅ Clarinet Local Development

## 📄 License

MIT License - Build amazing polling applications! 🚀
