import FlowToken from 0x01

/*
  @desc perform a change of the withdraw limit (only parent can perform)
*/
transaction {

  var temporaryVault: &FlowToken.Vault{FlowToken.RestrictVault}
  var account: AuthAccount;

  prepare(acct: AuthAccount) {
    self.account = acct
    let trustAccount = getAccount(0x01)
    let vaultRef = trustAccount.getCapability(/public/Restrictions)
                            .borrow<&FlowToken.Vault{FlowToken.RestrictVault}>()
                            ?? panic("Could not borrow owner's provider reference")
    self.temporaryVault = vaultRef
  }

  execute {
    self.temporaryVault.setWithdrawLimit(limit: 1500.0, account: self.account)
    log("Withdraw Limit Changed...")
  }
}
