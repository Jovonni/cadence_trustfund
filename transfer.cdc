import FlowToken from 0x01

/*
  @desc perform a standard transfer of tokens between accounts
*/
transaction {
  var temporaryVault: @FlowToken.Vault

  prepare(acct: AuthAccount) {
    let amountToSend: UFix64 = 1000.0;
    let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/MainVault)
        ?? panic("Could not borrow a reference to the owner's vault")
    self.temporaryVault <- vaultRef.withdraw(amount: amountToSend)
  }

  execute {
    let recipient = getAccount(0x01)
    let receiverRef = recipient.getCapability(/public/MainReceiver)
                      .borrow<&FlowToken.Vault{FlowToken.Receiver}>()
                      ?? panic("Could not borrow a reference to the receiver")
    receiverRef.deposit(from: <-self.temporaryVault)
    log("Transfer succeeded!")
  }
}
