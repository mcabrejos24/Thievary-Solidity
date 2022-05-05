const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('Thief');
    const gameContract = await gameContractFactory.deploy(
        ["A", "X", "Y", "Z"],
        ["gold", "silver", "teal", "purple"],
        ["https://ipfs.io/ipfs/QmVCEsJhUm2KUxrcHnfEhP45szbnm1nLNiawgXYkT4dx69",
            "https://ipfs.io/ipfs/QmUbgB3Xm73zCyWycd8eTqRNNtXN53X8jm19vVvovbbXBC",
            "https://ipfs.io/ipfs/Qmdc1XpWbZCkgi3kzyWnWdUXqQuTVD3fY2y9EcGBJCuLHn",
            "https://ipfs.io/ipfs/QmdgUCbCJqqebE4Q1FNFTk41etcTiT3zPbcuNN1maqheZn"
        ]
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn = await gameContract.mintThiefNFT(0);
    await txn.wait();

    txn = await gameContract.mintThiefNFT(3);
    await txn.wait();
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