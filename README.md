# Cadence Trust Fund exercise

# Playground
The playground can be found here (All files are included in this repo -- just in case the playground fails to load the content):
https://play.onflow.org/a23a65e1-fc05-4c58-85ef-c80d5e14a004?type=account&id=07bc1f34-42f9-4e97-af4a-defe99e10bbd

## Accounts
- ```0x01``` - Trust Fund
- ```0x02``` - Parent
- ```0x03``` - Beneficiary/Child

## Approach
The trust fund will hold the contract. The trust fund will also mint tokens, and only send them to the parent. The parent will use these tokens to fund the beneficiary's account over time. The parent account will have the power to change the ```withdrawLimit```, and also alter the boolean restrictionm ```canWithdraw```. We implement a ```Beneficiary``` interface, and a ```RestrictVault``` interface onto the ```Vault``` resource. We could have simply created ```x``` amount of tokens upon contract creation, but we wanted to create the tokens as needed -- hence minting, and depositing them to the parent account.

### Key Ideas
The beneficiary/child cannot withdraw any funds unless the in memory value of ```canWithdraw```, under the RestrictVault interface, is true. Upon contract creation, it is ```false```. Also, we ensure the beneficiary cannot withdraw any amount greater than that of which the parent sets using the ```setWithdrawLimit``` function.

## Steps to reproduce
- Deploy contract at ```0x01```, and observe resources in storage
	- This displays a few resources that will come in handy later
- Submit two new_vault transactions (To enable both parties to be able to receive/send tokens):
  - one signed by ```0x02``` (parent)
  - one signed by ```0x03``` (beneficiary/child)
- Submit a ```setup_trust``` transaction signed by ```0x03``` to enable the signer to be a beneficiary for withdrawing later from the fund
- Submit the ```mint``` transaction signed by ```0x01``` (This will give mint tokens and deposit them to the parent)
- Submit a ```transfer``` transaction signed by ```0x02``` to send tokens to the trust fund (The parent will do this as many times as needed throughout the life of the fund)
- Submit a ```change_restrictions``` transaction signed by ```0x02``` (The parent will do this only when they approve the beneficiary/child to withdraw funds)
- Submit a ```change_limit``` transaction signed by ```0x02``` (Parent can call this as many times as needed)
- Submit a ```withdraw``` transactions signed by ```0x03``` (The beneficiary/child can call this as many times as needed)

## Conclusion
With this simple approach, the beneficiary/child can only withdraw when the parent has approved withdrawals, and the child is the only account that can withdraw. Originally, we were looking for a way to time-lock the tokens, just in case the parent dies before the child becomes an adult, resulting in the parent not being able to change ```canWithdraw```. This would be ideal. For now, the parent must explicitly adjust the restriction. In solidity, we can do this by taking the current block timestamp, and adding a given amount of time/blocks into the future to create a time lock. I saw we cannot get the current ```Block``` timestamp in the playground, so I paused this approach for a more basic one.

Only the child can withdraw funds. Another consideration is the actual trust fund is not owned by the parent, but must be owned by someone. To ensure non-approved accounts are restriced from invoking specific functionality, we make use of ```AuthAccount```, and pass this to our mission-critical functions. If we would have just allowed a transaction to pass an ```Address``` in the transaction, this would allow a security vulnerability whereby any account could forge a fake address if they knew which address-value would satisfy our security constraints. Passing ```AuthAccount``` enables us to reference the actual account of the transaction signer directly.

## Enhancements
All three account's ```Vault``` resources all have the concept of ```canWithdraw```, and ```setWithdrawLimit```. This is only needed for the trust fund account, so we can create capabilities to only expose them when needed. We can also breakout the vault restriction logic to exist on a contract in the parent's account, instead of all of the logic on the trust funds account. 
