# blockchain
# 🛡️ Proof of Product Coverage — Solidity Smart Contract

### Network: **Ethereum Sepolia Testnet**  
**Deployed Transaction:**  
🔗 [View on Celoscan](https://sepolia.celoscan.io/tx/0x032541c3545dd1272c1f34a69a0d8f4dd466d19e9eef065719a6b66ad2e91d59)

---

## 📖 Project Description
**Proof of Product Coverage** is a simple and transparent **Solidity-based smart contract** that allows anyone to **register products and attach verifiable proofs of coverage** (like warranty, inspection, or authenticity data).  

Each proof is stored on-chain as a **hash (keccak256)** along with metadata (like IPFS URIs or notes).  
This ensures **tamper-proof verification** — anyone can later confirm that a product’s proof file has not been altered.

This project is designed to help **beginners learn smart contract development** while demonstrating a **real-world use case of blockchain verifiability**.

---

## 💡 What It Does

- Lets users **register products** with optional metadata.
- Allows product owners or third parties to **add coverage proofs** (e.g., warranty, certificate, authenticity record).
- Stores a **hash of the proof file** on-chain for permanent verification.
- Provides a built-in **verifyProof()** function to check if a claimed proof matches the recorded hash.
- Keeps all coverage events transparent and publicly auditable.

---

## ✨ Features

| Feature | Description |
|----------|-------------|
| 🏷️ **Product Registration** | Register a product with its metadata (like IPFS link or JSON data). |
| 🔒 **Tamper-proof Proofs** | Proofs stored as keccak256 hashes — impossible to alter without detection. |
| 🌐 **Decentralized Verification** | Anyone can verify product proofs using only the blockchain. |
| 🧾 **Event Logs** | Every registration and proof addition emits blockchain events for transparency. |
| 🧰 **Beginner-Friendly Solidity** | Simple contract structure, no dependencies — ideal for learners. |
| 🚀 **Upgradeable Design** | Easily extendable for access control, NFTs, or more product info. |

---

## 🧠 How It Works

1. **Register Product:**  
   Call `registerProduct("ipfs://...")` to create a new product entry.  
   The function returns a unique `productId`.

2. **Add Proof:**  
   Off-chain, compute:  
   ```js
   proofHash = keccak256(abi.encodePacked(fileContent))
