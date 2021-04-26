import FlowToken from 0x01

/*
  @desc perform a change of the withdraw restriction (only parent can perform)
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
    self.temporaryVault.changeWithdrawRestriction(canWithdraw: true, account: self.account)
    log("Restriction changed...")
  }
}
