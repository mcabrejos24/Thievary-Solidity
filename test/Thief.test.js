const { expect } = require("chai");
const { ethers } = require("hardhat");
// const ganache = require("ganache-core");
// const provider = new ethers.providers.Web3Provider(ganache.provider());

// const signer0 = provider.getSigner(0);
// const signer1 = provider.getSigner(1);

// console.log(signer0);
// console.log(signer1);
let Thief;
let thiefContract;
let owner;
let signer0;
let signer1;
let addrs;

beforeEach(async function () {
    Thief = await ethers.getContractFactory("Thief");
    [owner, signer0, signer1, ...addrs] = await ethers.getSigners();

    thiefContract = await Thief.deploy(
        ["A", "X", "Y", "Z"],
        ["Gold", "Silver", "Teal", "Purple"],
        ["ipfs://QmVCEsJhUm2KUxrcHnfEhP45szbnm1nLNiawgXYkT4dx69",
            "ipfs://QmUbgB3Xm73zCyWycd8eTqRNNtXN53X8jm19vVvovbbXBC",
            "ipfs://Qmdc1XpWbZCkgi3kzyWnWdUXqQuTVD3fY2y9EcGBJCuLHn",
            "ipfs://QmdgUCbCJqqebE4Q1FNFTk41etcTiT3zPbcuNN1maqheZn"
        ]
    );
});

describe("Thief Game", function () {
  it("Should spin up the Thief Contract", async function () {
    
    // await thiefContract.deployed();
    // console.log(await thiefContract.manager());
    // expect(thiefContractmanager)

    await thiefContract.connect(signer0);
    let txn = await thiefContract.mintThiefNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    const players = await thiefContract.getPlayers();
     
    // console.log(players);

    console.log(signer0);

   
    expect(players[0]).to.equal(signer0.address);

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});


// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

