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