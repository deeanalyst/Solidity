# Compound Health Guardian Trap

As a DeFi enthusiast, I've always been fascinated by the intricate mechanisms of lending protocols like Compound. However, the risk of liquidation due to market volatility is a constant concern for borrowers. This project, the **Compound Health Guardian Trap**, is my attempt to address this challenge by creating a proactive, decentralized monitoring and response system using the innovative Drosera protocol.

## What is the Compound Health Guardian Trap?

This trap is a decentralized application (dApp) built on the Drosera network that monitors the health of a specific user account on the Compound protocol. When the account's liquidity falls below a certain threshold, indicating a risk of liquidation, the trap triggers a response to protect the account by repaying a portion of the user's debt.

## How it Works

The system consists of two main components:

1.  **`AccountHealthTrap.sol`**: This is the core of the trap. It has the `comptroller` and `accountToMonitor` addresses hardcoded for simplicity and security. Its `collect` function is called by the Drosera network to fetch the account's current liquidity from the Compound protocol. If the liquidity is below a threshold, Drosera calls the `onTrapTriggered` function.

2.  **`Response.sol`**: This contract holds the funds and performs the rescue action. The `onTrapTriggered` function in the trap calls the `repayBorrowBehalf` function on this `Response` contract, which then repays a small portion of the unhealthy account's debt to improve its health.

This design leverages the power of the Drosera network to run its monitoring logic off-chain, which is more efficient and cost-effective than on-chain solutions.

## How to Deploy

The deployment process is designed to be simple and secure.

### Step 1: Edit the Trap Contract

Before deploying, you must edit the `src/AccountHealthTrap.sol` file. Inside the contract, you will find two placeholder constants:

```solidity
// !!! IMPORTANT !!!
// REPLACE THESE PLACEHOLDER ADDRESSES WITH YOUR ACTUAL ADDRESSES BEFORE DEPLOYMENT
IComptroller public constant comptroller = IComptroller(0x0000000000000000000000000000000000000000);
address public constant accountToMonitor = 0x0000000000000000000000000000000000000000;
```

Replace the zero addresses with the **actual addresses** of the Compound `Comptroller` contract and the specific user `account` you want to monitor on the target network (e.g., Ethereum Mainnet or a testnet like Sepolia).

### Step 2: Deploy the Response Contract

Deploy the `Response.sol` contract to your target network. This contract will hold the funds used for repayments. You can use Foundry or any other deployment tool. You will need to pass the address of the appropriate `cToken` (the token that was borrowed and needs to be repaid) as a constructor argument.

Example using Foundry:
```bash
forge create src/Response.sol:Response --rpc-url <your_rpc_url> --private-key <your_private_key> --constructor-args <cToken_address>
```
Note the address of the newly deployed `Response` contract.

### Step 3: Deploy the Trap with Drosera

Deploy the `AccountHealthTrap.sol` contract using the `drosera apply` command. This will register the trap with the Drosera network.

### Step 4: Configure the Trap

The final step is to link the two contracts together. Call the `setResponseContract()` function on your newly deployed `AccountHealthTrap`, passing it the address of the `Response` contract you deployed in Step 2.

```bash
cast send <your_trap_address> "setResponseContract(address)" <your_response_contract_address> --rpc-url <your_rpc_url> --private-key <your_private_key>
```

After this transaction is complete, the trap is fully armed and operational.

## Local Testing

The project includes a full suite of tests using mock contracts. You can run them using Foundry:
```bash
forge test
```

## Conclusion

The Compound Health Guardian Trap is a powerful example of how the Drosera network can be used to build proactive and decentralized security solutions for DeFi protocols. By monitoring account health and automating responses, this trap can help protect users from liquidation and contribute to a more stable and secure DeFi ecosystem.
