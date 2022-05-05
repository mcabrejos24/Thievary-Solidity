const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('Thief');
    const gameContract = await gameContractFactory.deploy(
        ["A", "X", "Y", "Z"],
        ["Gold", "Silver", "Teal", "Purple"],
        ["ipfs://QmVCEsJhUm2KUxrcHnfEhP45szbnm1nLNiawgXYkT4dx69",
            "ipfs://QmUbgB3Xm73zCyWycd8eTqRNNtXN53X8jm19vVvovbbXBC",
            "ipfs://Qmdc1XpWbZCkgi3kzyWnWdUXqQuTVD3fY2y9EcGBJCuLHn",
            "ipfs://QmdgUCbCJqqebE4Q1FNFTk41etcTiT3zPbcuNN1maqheZn"
        ]
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn = await gameContract.mintThiefNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await gameContract.mintThiefNFT(1);
    await txn.wait();
    console.log("Minted NFT #2");

    txn = await gameContract.mintThiefNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");

    txn = await gameContract.mintThiefNFT(3);
    await txn.wait();
    console.log("Minted NFT #3");

    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(0);
    console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();