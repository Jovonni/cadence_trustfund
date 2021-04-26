import FlowToken from 0x01

/*
  @desc perform a withdrawal as the beneficiary (only child/beneficiary can perform)
*/
transaction {
  var temporaryVault: &FlowToken.Vault{FlowToken.Beneficiary}
  var account: AuthAccount;

  prepare(acct: AuthAccount) {
    self.account = acct
    let trustAccount = getAccount(0x01)
    let vaultRef = trustAccount.getCapability(/public/MainProvider)
                            .borrow<&FlowToken.Vault{FlowToken.Beneficiary}>()
                            ?? panic("Could not borrow owner's provider reference")
    self.temporaryVault = vaultRef
  }

  execute {
    let recipient = getAccount(0x03)
    let receiverRef = recipient.getCapability(/public/MainReceiver)
                      .borrow<&FlowToken.Vault{FlowToken.Receiver}>()
                      ?? panic("Could not borrow a reference to the receiver")
    let new_vault <- self.temporaryVault.withdrawFundsForBeneficiary(amount: 10.0, account: self.account)
    log(new_vault.balance)
    receiverRef.deposit(from: <-new_vault)
    log("Withdraw completed...")
  }
}
