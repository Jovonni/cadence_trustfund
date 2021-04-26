import FlowToken from 0x01

/*
  @desc setup a vault for the transaction signer (must perform for the parent account, and the beneficiary/child)
*/
transaction {
  let account: AuthAccount

  prepare(acct: AuthAccount) {
    self.account = acct;
    let vault <- FlowToken.createEmptyVault()
    acct.save<@FlowToken.Vault>(<-vault, to: /storage/MainVault)
    log("Empty Vault stored")
    let ReceiverRef = acct.link<&FlowToken.Vault{FlowToken.Receiver, FlowToken.Balance}>(/public/MainReceiver, target: /storage/MainVault)
    log("References created")
  }

  post {
    getAccount(self.account.address).getCapability(/public/MainReceiver)
                    .check<&FlowToken.Vault{FlowToken.Receiver}>():
                    "Vault Receiver Reference was not created correctly"
  }
}
