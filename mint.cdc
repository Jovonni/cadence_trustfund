import FlowToken from 0x01

/*
  @desc mint new tokens, and deposit them to an account (can only be performed by the trust fund account)
*/
transaction {

  let mintingRef: &FlowToken.VaultMinter
  var receiverRef: &FlowToken.Vault{FlowToken.Receiver}

  prepare(acct: AuthAccount) {
    self.mintingRef = acct.borrow<&FlowToken.VaultMinter>(from: /storage/MainMinter)
        ?? panic("Could not borrow a reference to the minter")
    let recipient = getAccount(0x02)
    let cap = recipient.getCapability(/public/MainReceiver)
    self.receiverRef = cap.borrow<&FlowToken.Vault{FlowToken.Receiver}>()
        ?? panic("Could not borrow a reference to the receiver")
}

  execute {
      let token_amount = 100000.0;
      self.mintingRef.mintTokens(amount: UFix64(token_amount), recipient: self.receiverRef)
      log("100000 tokens minted and deposited to account 0x01")
  }
}
