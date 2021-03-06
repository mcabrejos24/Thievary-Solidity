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
    uint itemId;
    uint nftTypeIndex;
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

  event PlayerNFTMinted(address sender, uint256 tokenId, uint256 nftTypeIndex);

  constructor(
    string[] memory playerClan,
    string[] memory playerColors,
    string[] memory playerImageURIs
  ) ERC721("Theivary", "THIEF") {
    manager = msg.sender;
    for(uint i = 0; i < playerClan.length; i += 1) {
      PlayerAttributes memory player = PlayerAttributes({
        itemId: 0,
        nftTypeIndex: i,
        clan: playerClan[i],
        color: playerColors[i],
        imageURI: playerImageURIs[i],
        class: 1,
        stealsLeft: 2,
        maxSteals: 2,
        totalStealsAttempted: 0,
        daggerCount: 1,
        shieldCount: 0,
        level: 0
      });
      defaultPlayerAttributes.push(player);
    }
    sendShieldOnNumber = 4;
    _tokenIds.increment();
  }

  function mintThiefNFT(uint _nftTypeIndex) public {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    uint classNo = (uint(newItemId) - 1) / uint(100) + 1;

    nftHolderAttributes[newItemId] = PlayerAttributes({
      itemId: newItemId,
      nftTypeIndex: _nftTypeIndex,
      clan: defaultPlayerAttributes[_nftTypeIndex].clan,
      color: defaultPlayerAttributes[_nftTypeIndex].color,
      imageURI: defaultPlayerAttributes[_nftTypeIndex].imageURI,
      class: classNo,
      stealsLeft: defaultPlayerAttributes[_nftTypeIndex].stealsLeft,
      maxSteals: defaultPlayerAttributes[_nftTypeIndex].maxSteals,
      totalStealsAttempted: defaultPlayerAttributes[_nftTypeIndex].totalStealsAttempted,
      daggerCount: defaultPlayerAttributes[_nftTypeIndex].daggerCount,
      shieldCount: defaultPlayerAttributes[_nftTypeIndex].shieldCount,
      level: defaultPlayerAttributes[_nftTypeIndex].level
    });

    nftHolders[msg.sender] = newItemId;
    players.push(msg.sender);
    _tokenIds.increment();

    emit PlayerNFTMinted(msg.sender, newItemId, _nftTypeIndex);

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
        Strings.toString(playerAttributes.itemId),
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

  function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.timestamp * block.difficulty)));
  }

  function sendShieldToPlayer() private {
    uint index = random() % (_tokenIds.current() - 1);
    address winnerOfShield = players[index];
    uint256 nftTokenIdOfPlayer = nftHolders[winnerOfShield];
    PlayerAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    player.shieldCount = player.shieldCount + 1;
  } 

  function steal(address addressToStealFrom) public {
    uint256 nftTokenIdOfThief = nftHolders[msg.sender];
    PlayerAttributes storage thief = nftHolderAttributes[nftTokenIdOfThief];
    
    require(
      thief.stealsLeft > 0,
      "Error: player thief must have at least one steal to steal."
    );

    uint256 nftTokenIdOfVictim = nftHolders[addressToStealFrom];
    PlayerAttributes storage victim = nftHolderAttributes[nftTokenIdOfVictim];
    
    require(
      victim.daggerCount > 0 || victim.shieldCount > 0,
      "Error: player victim must have at least one dagger to steal."
    );

    if (victim.shieldCount > 0) {
      thief.shieldCount += 1;
      thief.stealsLeft -= 1;
      victim.shieldCount -= 1;
    } else {
      thief.daggerCount += 1;
      thief.stealsLeft -= 1;
      victim.daggerCount -= 1;
    }

    thief.totalStealsAttempted = thief.totalStealsAttempted + 1;
    _totalStealsCount.increment();

    // at least half of all players have stolen twice, or all once, then reset everyone's steal count;
    if (_totalStealsCount.current() % players.length == 0) {
      resetStealsAndLevelUp();
    }
  }

  function resetStealsAndLevelUp() private {
    for (uint256 i = 0; i < players.length; i += 1) {
      uint256 nftTokenIdOfPlayer = nftHolders[players[i]];
      PlayerAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
      if (player.daggerCount > 2) {
        player.level += 1;
      }
      player.stealsLeft = 2;
    }
  }

  function managerCallResetSteals() public restricted {
    resetStealsAndLevelUp();
  }

  function getPlayerAddresses() public view returns (address[] memory) {
    return players;
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

  function getAPlayerNftDetails(address playerAddy) public view returns (PlayerAttributes memory) {
    uint256 playerNftTokenId = nftHolders[playerAddy];

    if (playerNftTokenId > 0) {
      return nftHolderAttributes[playerNftTokenId];
    } else {
      PlayerAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function updateSendShieldOnNumber(uint count) public restricted {
    sendShieldOnNumber = count;
  }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }

  function getAllDefaultThiefs() public view returns (PlayerAttributes[] memory) {
    return defaultPlayerAttributes;
  }
}
