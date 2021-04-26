import FlowToken from 0x01

// This script reads the Vault balances of two accounts.
pub fun main() {
    // Get the accounts' public account objects
    let acct1 = getAccount(0x01)
    let acct2 = getAccount(0x02)
    let acct3 = getAccount(0x03)

    let acct1ReceiverRef = acct1.getCapability<&FlowToken.Vault{FlowToken.Balance}>(/public/MainReceiver)
        .borrow()
        ?? panic("Could not borrow a reference to the acct1 receiver")

    let acct2ReceiverRef = acct2.getCapability<&FlowToken.Vault{FlowToken.Balance}>(/public/MainReceiver)
        .borrow()
        ?? panic("Could not borrow a reference to the acct2 receiver")

    let acct3ReceiverRef = acct3.getCapability<&FlowToken.Vault{FlowToken.Balance}>(/public/MainReceiver)
        .borrow()
        ?? panic("Could not borrow a reference to the acct2 receiver")

    // Read and log balance fields
    log("Account 1 Balance")
    log(acct1ReceiverRef.balance)
    log("Account 2 Balance")
    log(acct2ReceiverRef.balance)
    log("Account 3 Balance")
    log(acct3ReceiverRef.balance)
}
