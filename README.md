# The Thief Game Project

This project is a game Dapp where players can mint a THIEF NFT and try to steal from other players.

All players start with one "dagger" and two "steals". Each player can attempt two steals of a single dagger from any player.

Once the two steals have been used, players must wait for steals to be reset.

Steals are reset once a count has been reached that is equal to the total number of players.
Ex: all players steal once, half of the players steal twice, or a mixture of this

When the steals are reset, any players with 3 or more daggers are leveled up. All players start at level 0

Every 100 mints, the NFTs receive a new "class" where the classes start at class 1.

A shield item is also sent on every variable "sendShieldOnNumber" mint. The contract initially sets this variable "sendShieldOnNumber" to 4 on contract creation so this would mean on every 4th mint. However, this number can be updated by the manager at any moment.

## Getting Started

This project uses [git], [node] and [nvm]. Make sure these are all downloaded for your appropriate machine before continuing.

To start, run:
```
nvm use
```
so that the appropriate node version is used. In your terminal, you might have errors saying that you need to install the different node version. Follow the instructions on there to use the correct node version.

Next, run:
```
npm install
```
This will install of our project's dependencies. You don't need to run 'npm install' each time you exit your project and start working again but you might need to run 'nvm use' each time if your local machine isn't set up to default to this project's node version.

Once this is done, the project is ready to run.

## Running the website locally
Since this is a solidity project, running the contract locally works differently than any other web2 project.

We leverage [hardhat] to be able to spin up a local blockchain (think of it as a local database/server) and be able to test our contract. This should have been installed when running 'npm install' but if not then make sure to install this.

Next to simulate deploying the contract, minting NFTs, etc. then run the 'run.js' file.

```
npx hardhat run scripts/run.js
```

Feel free to mess with this file when wanting to simulate actions that would happen in your contract.

## Running and Adding Tests

For tests, we leverage the 'ethers' and 'chai' libraries.

To run tests, run:
```
npx hardhat test
```
This will run all of the tests in the project.

To add tests, navigate to the 'test' folder in the root directory. In here you can add to the current 'Thief.test.js' file or create a new test file to test this contract.

## Contributing

If you would like to contribute to this project, branch off from the master branch and name your branches accordingly:

- new features: feature/
- bug fixes: fix/
- simple updates: chore/

Once you make your changes on your new brach, commit and submit a pull request.

Once a review has been submitted and approved, you may merge the pull request.

## Deploying the contract

Since smart contracts can't be updated, a new contract has to be created each time in a test network. 

To deploy to the test network you will need a way to access the test network nodes and test 'ether' to deploy the contract.

This project uses [alchemy] to access the test network so take a look at that to get a staging link to deploy. You can set the 'STAGING_ALCHEMY_KEY' variable in the hardhat config to equal the url you get. Set the 'PROD_ALCHEMY_KEY' to the production url and set 'PRIVATE_KEY' to your wallet's private key. REMEMBER TO NOT SHARE YOUR PRIVATE KEY WITH ANYONE, not even me.

Make sure to set these variables in a '.env' folder in the root of the proejct.

To get ether for the rinkeby network, you can go to [rinkebyfaucet.com] and enter your public address.

This facuet is powered by [alchemy] so if you sign in with you alchemy account, then you you'll get even more test ether to deploy to the test network.

Once this is all done, then you can deploy the contract by running
```
npx hardhat run scripts/deploy.js
```

A message in the terminal will give you back the address that this contract was deployed to.

Grab that address and go check it out at the rinkeby [etherscan].

Note that this is not the mainnet etherscan.

Here is a link to the real etherscan: [etherscan.io].

Once you have the new address to the contract, you can copy that and the abi file over to front end of the project.

That is linked here: [thievary].

## Below are some hardhat terminal commands for reference
Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

[git]: https://git-scm.com/downloads
[node]: https://nodejs.org/en/download/
[nvm]: https://github.com/nvm-sh/nvm#installation-and-update
[hardhat]: https://hardhat.org/
[rinkebyfaucet.com]: https://rinkebyfaucet.com/
[alchemy]: https://www.alchemy.com/
[etherscan]: https://rinkeby.etherscan.io/
[etherscan.io]: https://etherscan.io/
[thievary]: https://github.com/mcabrejos24/Thievary-React-App