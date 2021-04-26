/*
    @name FlowToken
    @desc Contract for our FlowToken to enable parent->child trust fund logic
    @author Jovonni L. Pharr (jovonnipharr@gmail.com)
    Date April 25, 2021
*/
pub contract FlowToken {

    // Total supply of all tokens in existence.
    pub var totalSupply: UFix64;

    /*
        @name Provider interface
        @desc resource interface for standard withdrawals
    */
    pub resource interface Provider {

        /*
            @name withdraw
            @desc resource function to perform a standard vault withdrawal
        */
        pub fun withdraw(amount: UFix64): @Vault {
            post {
                // `result` refers to the return value of the function
                result.balance == UFix64(amount):
                    "Withdrawal amount must be the same as the balance of the withdrawn Vault"
            }
        }

    }

    /*
        @name Beneficiary interface
        @desc resource interface to hold beneficiary actions
    */
    pub resource interface Beneficiary {
        pub var withdrawLimit: UFix64;
        //boolean flag to represent withdraw restriction
        pub var canWithdraw: Bool;

        /*
            @name withdrawFundsForBeneficiary
            @desc perform a withdraw for the beneficiary. Precondition to ensure account is the beneficiary, restriction is not active, and amount if less than limit
        */
        pub fun withdrawFundsForBeneficiary(amount: UFix64, account: AuthAccount): @Vault {
            pre{
                account.address == Address(0x03) : "Must be approved address"; 
                self.canWithdraw : "Restricted from withdrawing, try again later";
                amount <= self.withdrawLimit : "Withdraw amount must be less than or equal to withdraw limit"
            }
            post{

            }
        }
    }
    
    /*
        @name Receiver interface
        @desc resource interface to hold deposit logic
    */
    pub resource interface Receiver {
        /*
            @name deposit
            @desc resource function to deposit
        */
        pub fun deposit(from: @Vault)
    }

    /*
        @name Balance
        @desc interface for the vault balance resource
    */
    pub resource interface Balance {
        /*
            @name balance
            @desc hold Vault balance
        */
        pub var balance: UFix64
    }

    /*
        @name RestrictVault interface
        @desc interface for resource responsible for vault restriction
    */
    pub resource interface RestrictVault {
        pub var balance: UFix64;
        pub var withdrawLimit: UFix64;
        pub var canWithdraw: Bool;
        /*
            @name setWithdrawLimit
            @desc change the withdraw limit, precondition to verify only the parent can change the withdraw limit
        */
        pub fun setWithdrawLimit(limit: UFix64, account: AuthAccount) : Void {
            pre{
                account.address == Address(0x02) : "Must be the parent to change withdraw limit"
            }
        }

        /*
            @name changeWithdrawRestriction
            @desc change the status of the withdraw restriction, precondition to verify only the parent can change the restriction
        */
        pub fun changeWithdrawRestriction(canWithdraw: Bool, account: AuthAccount) : Void {
            pre{
                account.address == Address(0x02) : "Must be the parent to change withdraw restriction"
            }
        }
    }

    /*
        @name Vault Interface
        @desc interface for the vault resource
    */
    pub resource Vault: Provider, Receiver, Balance, Beneficiary, RestrictVault {

        // keeps track of the total balance of the account's tokens
        pub var balance: UFix64
        pub var withdrawLimit: UFix64;
        pub var canWithdraw: Bool;
        
        /*
            @name init
            @desc init function for the Vault resource
        */
        init(balance: UFix64) {
            self.balance = balance
            self.withdrawLimit = 100.0;
            self.canWithdraw = false;
        }

        /*
            @name withdraw
            @desc decrease the account's Vault balance by the amount passed
        */
        pub fun withdraw(amount: UFix64): @Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        /*
            @name withdrawFundsForBeneficiary
            @desc allow the beneficiary to withdraw tokens
        */
        pub fun withdrawFundsForBeneficiary(amount: UFix64, account: AuthAccount): @Vault {
            log("withdrawing money for beneficiary")    
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        /*
            @name deposit
            @desc deposit a balance from the Vault resource passed
        */
        pub fun deposit(from: @Vault) {
            self.balance = self.balance + from.balance
            destroy from
        }


        /*
            @name setWithdrawLimit
            @desc overwrite withdraw limit to 'limit'
        */
        pub fun setWithdrawLimit(limit: UFix64, account: AuthAccount) : Void  {
            self.withdrawLimit = limit;
        }

        /*
            @name changeWithdrawRestriction
            @desc update the withdraw restriction by setting it to "canWithdraw"
        */
        pub fun changeWithdrawRestriction(canWithdraw: Bool, account: AuthAccount) : Void  {
            self.canWithdraw = canWithdraw;
        }

    }

    /*
        @name createEmptyVault
        @desc contract function to return a Vault resource
    */
    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    /*
        @name VaultMinter
        @desc resource to mint tokens
    */
    pub resource VaultMinter {

        /*
            @name mintTokens
            @desc mint tokens and deposit them to receiver's Vault
        */
        pub fun mintTokens(amount: UFix64, recipient: &AnyResource{Receiver}) {
            FlowToken.totalSupply = FlowToken.totalSupply + UFix64(amount)
            recipient.deposit(from: <-create Vault(balance: amount))
        }
    }

    /*
        @name init
        @desc overall contract init function
    */
    init() {
        self.totalSupply = 0.0;

        self.account.save(<-create Vault(balance: self.totalSupply), to: /storage/MainVault)

        self.account.save(<-create VaultMinter(), to: /storage/MainMinter)

        self.account.link<&FlowToken.Vault{FlowToken.Receiver, FlowToken.Balance}>(/public/MainReceiver, target: /storage/MainVault)

        self.account.link<&FlowToken.Vault{FlowToken.Beneficiary}>(/public/MainProvider, target: /storage/MainVault)

        self.account.link<&FlowToken.Vault{FlowToken.RestrictVault}>(/public/Restrictions, target: /storage/MainVault)

    }
}
