# Deployment Notes

## Before Deployment Checklist

1. **Update Target Contract Address** in `src/CodeSizeMonitorTrap.sol`:
   - Change `TARGET_CONTRACT` constant to the address you want to monitor

2. **Adjust Size Threshold** in `src/CodeSizeMonitorTrap.sol` if needed:
   - Modify `SIZE_THRESHOLD` constant (default: 100 bytes)

3. **Deploy Response Contract**:
   ```bash
   export PRIVATE_KEY=0xYourPrivateKey
   forge script script/DeployCodeSizeResponse.s.sol:DeployCodeSizeResponse \
     --rpc-url hoodi \
     --broadcast \
     --verify
   ```

4. **Update drosera.toml**:
   - Set `response_contract` to the deployed response contract address
   - Add operator addresses to `whitelist` array

5. **Deploy Main Trap**:
   ```bash
   forge build
   DROSERA_PRIVATE_KEY=0xYourPrivateKey drosera apply
   ```

## Important Reminders

- The main trap contract uses hardcoded addresses - update before deployment
- Operators are whitelisted in `drosera.toml`, not in the contract
- Both contracts have no constructor arguments or initialize functions
- The trap is reactive - it only triggers when code size changes are detected
