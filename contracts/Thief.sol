// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";

contract Thief is ERC721 {
  address public manager;
  uint public sendShieldOnNumber;

  struct PlayerAttributes {
    uint playerIndex;
    string clan;
    string color;
    string imageURI;
    uint class;
    uint stealsLeft;
    uint maxSteals;
    uint totalStealsAttempted;
    uint daggerCount;
    uint shieldCount;
    uint level;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _totalStealsCount;

  PlayerAttributes[] defaultPlayerAttributes;

  // maps NFT tokenID to player attribtues
  mapping(uint256 => PlayerAttributes) public nftHolderAttributes;
  // maps public address to NFT ID
  mapping(address => uint256) public nftHolders;
  address[] public players;

  event PlayerNFTMinted(address sender, uint256 tokenId, uint256 playerIndex);

  constructor(
    string[] memory playerClan,
    string[] memory playerColors,
    string[] memory playerImageURIs
  ) ERC721("Theivary", "THIEF") {
    for(uint i = 0; i < playerClan.length; i += 1) {
      PlayerAttributes memory player = PlayerAttributes({
        playerIndex: i,
        clan: playerClan[i],
        color: playerColors[i],
        imageURI: playerImageURIs[i],
        class: 0,
        stealsLeft: 2,
        maxSteals: 2,
        totalStealsAttempted: 0,
        daggerCount: 1,
        shieldCount: 0,
        level: 0
      });
      defaultPlayerAttributes.push(player);
      console.log("Done initializing color %s w/ clan %s, img %s", player.color, player.clan, player.imageURI);
    }
    sendShieldOnNumber = 50;
  }

  function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.timestamp * block.difficulty)));
  }

  function sendShieldToPlayer() private {
    uint index = random() % (_tokenIds.current() + 1);
    address winnerOfShield = players[index];
    uint256 nftTokenIdOfPlayer = nftHolders[winnerOfShield];
    PlayerAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    player.shieldCount = player.shieldCount + 1;
  } 

  function mintThiefNFT(uint _playerIndex) public {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    uint classNo = uint(newItemId) / uint(100) + 1;

    nftHolderAttributes[newItemId] = PlayerAttributes({
      playerIndex: _playerIndex,
      clan: defaultPlayerAttributes[_playerIndex].clan,
      color: defaultPlayerAttributes[_playerIndex].color,
      imageURI: defaultPlayerAttributes[_playerIndex].imageURI,
      class: classNo,
      stealsLeft: defaultPlayerAttributes[_playerIndex].stealsLeft,
      maxSteals: defaultPlayerAttributes[_playerIndex].maxSteals,
      totalStealsAttempted: defaultPlayerAttributes[_playerIndex].totalStealsAttempted,
      daggerCount: defaultPlayerAttributes[_playerIndex].daggerCount,
      shieldCount: defaultPlayerAttributes[_playerIndex].shieldCount,
      level: defaultPlayerAttributes[_playerIndex].level
    });

    console.log("Minted NFT w/ tokenId %s and playerIndex %s", newItemId, _playerIndex);
    nftHolders[msg.sender] = newItemId;
    players.push(msg.sender);
    _tokenIds.increment();

    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit PlayerNFTMinted(msg.sender, newItemId, _playerIndex);

    // call this every X (sendShieldOnNumber) amount of mints
    if(newItemId % sendShieldOnNumber == 0) {
      sendShieldToPlayer();
    }
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    PlayerAttributes memory playerAttributes = nftHolderAttributes[_tokenId];

    string memory strClass = Strings.toString(playerAttributes.class);
    string memory strStealsLeft = Strings.toString(playerAttributes.stealsLeft);
    string memory strMaxSteals = Strings.toString(playerAttributes.maxSteals);
    string memory strTotalSteals = Strings.toString(playerAttributes.totalStealsAttempted);
    string memory strDaggerCount = Strings.toString(playerAttributes.daggerCount);
    string memory strShieldCount = Strings.toString(playerAttributes.shieldCount);
    string memory strLevel = Strings.toString(playerAttributes.level);

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "Thievary #: ',
        Strings.toString(_tokenId),
        '", "description": "This is an NFT that lets people play in the game Thievary!", "image": "',
        playerAttributes.imageURI,
        '", "attributes": [ {"trait_type": "Clan", "value": "', playerAttributes.clan, '"}, {"trait_type": "Color", "value": "', playerAttributes.color, '"}, {"trait_type": "Class", "value": "#', strClass, '"}, { "trait_type": "Steals Left", "value": ', strStealsLeft,', "max_value": ', strMaxSteals,'}, { "trait_type": "Total Lifetime Steals", "value": ',
        strTotalSteals,'}, {"trait_type": "Dagger Count", "value": ', strDaggerCount, '}, {"trait_type": "Shield Count", "value": ', 
        strShieldCount, '}, {"trait_type": "Level", "value": ', strLevel, '} ]}'
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }
  

  function checkIfUserHasNFT() public view returns (PlayerAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return their character.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    } else {
      PlayerAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function updateSendShieldOnNumber (uint count) public restricted {
    sendShieldOnNumber = count;
  }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  
}
