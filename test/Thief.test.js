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
let signer2;
let addrs;

beforeEach(async function () {
  [owner, signer0, signer1, signer2, ...addrs] = await ethers.getSigners();
  Thief = await ethers.getContractFactory("Thief");
  thiefContract = await Thief.deploy(
      ["A", "X", "Y", "Z"],
      ["Gold", "Silver", "Teal", "Purple"],
      ["ipfs://QmVCEsJhUm2KUxrcHnfEhP45szbnm1nLNiawgXYkT4dx69",
          "ipfs://QmUbgB3Xm73zCyWycd8eTqRNNtXN53X8jm19vVvovbbXBC",
          "ipfs://Qmdc1XpWbZCkgi3kzyWnWdUXqQuTVD3fY2y9EcGBJCuLHn",
          "ipfs://QmdgUCbCJqqebE4Q1FNFTk41etcTiT3zPbcuNN1maqheZn"
      ]
  );
  await thiefContract.deployed();
});

describe("Thief Game spin up and minting", function () {
  it("Should spin up the Thief Contract", async function () {
    await thiefContract.deployed();
  });
  it("Manager matches contract owner", async function () {
    expect(await thiefContract.manager()).to.equal(owner.address);
  });
  it("Mints 1 NFT for 1 account", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    const players = await thiefContract.getPlayerAddresses();
    expect(players[0]).to.equal(signer0.address);
    let playerAttribtues = await thiefContract.connect(signer0).checkIfUserHasNFT();
    expect(playerAttribtues.clan).to.equal("A");
  });
  it("Mints 2 NFT for 2 accounts", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(1);
    await txn.wait();
    const players = await thiefContract.getPlayerAddresses();
    expect(players[0] + players[1]).to.equal(signer0.address + signer1.address);
    let playerAttribtues = await thiefContract.connect(signer0).checkIfUserHasNFT();
    expect(playerAttribtues.clan).to.equal("A");
    playerAttribtues = await thiefContract.connect(signer1).checkIfUserHasNFT();
    expect(playerAttribtues.clan).to.equal("X");
    
  });
});

describe("Stealing scenearios, steal resets and level up", function () {
  it("1 account steals from another", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(0);
    await txn.wait();
    // account 0 steals from account 1
    txn = await thiefContract.connect(signer0).steal(signer1.address);
    await txn.wait();
    // get stealer info
    let playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("1");
    expect(playerAttribtues.daggerCount).to.equal("2");
    // get victim info
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer1.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    expect(playerAttribtues.daggerCount).to.equal("0");
  });

  it("check for steals count for all players to be reset", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(0);
    await txn.wait();
    // account 0 steals from account 1
    txn = await thiefContract.connect(signer0).steal(signer1.address);
    await txn.wait();
    // get stealer info
    let playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("1");
    expect(playerAttribtues.daggerCount).to.equal("2");
    // get victim info
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer1.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    expect(playerAttribtues.daggerCount).to.equal("0");
    // only manager can reset steals count
    await thiefContract.connect(owner).managerCallResetSteals();
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer1.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
  });

  it("check for player to steal twice and increase level on manual manager reset", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer2).mintThiefNFT(0);
    await txn.wait();
    // account 0 steals from account 1 and 2
    txn = await thiefContract.connect(signer0).steal(signer1.address);
    await txn.wait();
    txn = await thiefContract.connect(signer0).steal(signer2.address);
    await txn.wait();
    // get stealer info
    let playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("0");
    expect(playerAttribtues.daggerCount).to.equal("3");
    // only manager can reset steals count
    await thiefContract.connect(owner).managerCallResetSteals();
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    expect(playerAttribtues.level).to.equal("1");
  });

  it("check for player to steal twice and increase level on automatic reset", async function () {
    let txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer2).mintThiefNFT(0);
    await txn.wait();
    // account 0 steals from account 1 and 2
    txn = await thiefContract.connect(signer0).steal(signer1.address);
    await txn.wait();
    // check stealsLeft and daggerCount on stealing scenario
    let playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("1");
    expect(playerAttribtues.daggerCount).to.equal("2");
    txn = await thiefContract.connect(signer1).steal(signer2.address);
    await txn.wait();
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer1.address);
    expect(playerAttribtues.stealsLeft).to.equal("1");
    expect(playerAttribtues.daggerCount).to.equal("1");
    txn = await thiefContract.connect(signer0).steal(signer1.address);
    await txn.wait();
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer2.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    expect(playerAttribtues.daggerCount).to.equal("0");
    // check player 0 reset count and their level
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    expect(playerAttribtues.stealsLeft).to.equal("2");
    expect(playerAttribtues.level).to.equal("1");
  });
});


describe("Shields", function () {
  it("check if any player has a shield", async function () {
    let txn = await thiefContract.connect(owner).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer0).mintThiefNFT(0);
    await txn.wait();
    txn = await thiefContract.connect(signer1).mintThiefNFT(1);
    await txn.wait();
    txn = await thiefContract.connect(signer2).mintThiefNFT(3);
    await txn.wait();

    // checks if any of the players has a shield;
    let hasShield = 0;
    let playerAttribtues = await thiefContract.getAPlayerNftDetails(owner.address);
    hasShield = hasShield || parseInt(playerAttribtues.shieldCount);
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer0.address);
    hasShield = hasShield || parseInt(playerAttribtues.shieldCount);
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer1.address);
    hasShield = hasShield || parseInt(playerAttribtues.shieldCount);
    playerAttribtues = await thiefContract.getAPlayerNftDetails(signer2.address);
    hasShield = hasShield || parseInt(playerAttribtues.shieldCount);

    expect(hasShield).to.equal(1);
  });

  it("manager can update count to send shield to players on", async function () {
    // initial count on contract creation will be 4
    let shieldOnCount = await thiefContract.sendShieldOnNumber();
    expect(shieldOnCount).to.equal(4);
    // update count to 3454 and make sure it updated
    await thiefContract.connect(owner).updateSendShieldOnNumber(3454);
    let updateShieldOnCount = await thiefContract.sendShieldOnNumber();
    expect(updateShieldOnCount).to.equal(3454);
  });
});
