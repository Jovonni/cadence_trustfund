import FlowToken from 0x01

/*
  @desc setup the signer to be able to perform a withdrawal as the beneficiary 
*/
transaction {

    prepare(acct: AuthAccount) {
        acct.link<&FlowToken.Vault{FlowToken.Beneficiary}>(/public/MainProvider, target: /storage/MainVault)
        log("Setting up account to attempt withdrawals")
    }

    post {
        getAccount(0x03).getCapability(/public/MainProvider)
        .check<&FlowToken.Vault{FlowToken.Beneficiary}>():
        "Vault Provider Reference was not created correctly"
    }
}
