// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Base64.sol";

import "hardhat/console.sol";


// Our contract inherits from ERC721, which is the standard NFT contract!
contract MajocatTournament is ERC721 {
  // We'll hold our player's attributes in a struct
  // struct PlayerAttributes {
  //   uint characterIndex;
  //   string name;
  // }

  /*
    imageURI
    red, green, blue, purple
    A, B, C, X, Y, Z
    1, 2, etc.
    stealsLeft 2
    done 0
    daggetcount 1
    shield count 0 | 1 if random picked
    xp = 0
    level = 0
    special tiems = "" <-- none

  */

  struct PlayerAttributes {
    string playerIndex;
    string clan;
    string color;
    string imageURI;
    uint class;
    uint stealsLeft;
    uint stealsDone;
    uint daggerCount;
    uint shieldCount;
    uint xp;
    uint level;
  }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _totalStealsCount;

  PlayerAttributes[] defaultPlayerAttributes;

  // maps NFT tokenID to player attribtues
  mapping(uint256 => PlayerAttributes) public nftHolderAttributes;
  
  // maps public address to NFT ID
  mapping(address => uint256) public nftHolders;

  event PlayerNFTMinted(address sender, uint256 tokenId, uint256 playerIndex);

  constructor(
    string[] memory playerClan,
    string[] memory playerColors,
    string[] memory playerImageURIs
  ) ERC721("Theivary", "THIEF") {

    uint memory classNo = uint(_tokenIds) / uint(100) + 1;
    
   
    for(uint i = 0; i < playerClan.length; i += 1) {
      PlayerAttributes memory player = PlayerAttributes({
        playerIndex: i,
        clan: playerClan[i],
        color: playerColors[i],
        imageURI: playerImageURIs[i],
        class: classNo,
        stealsLeft: 2,
        stealsDone: 0,
        daggerCount: 1,
        shieldCount: 0,
        xp: 0,
        level: 0
      });
      defaultPlayerAttributes.push(player);

      console.log("Done initializing %s w/ HP %s, img %s", player.color, player.clan, player.imageURI);
    }

  }

  function makeThiefNFT(string memory username, string memory color) public {
        uint256 newItemId = _tokenIds.current();

        string memory tournamentNo = Strings.toString(uint(newItemId) / uint(16) + 1);

        // 23 is max for username to look good
        string memory finalSvg = string(abi.encodePacked(svgOpen, username, svgSecond, tournamentNo, svgThird, color, "'/></svg>"));

        console.log(finalSvg);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                            username,
                            '", "description": "Player card for the MajoCat Tournament.", "image": "data:image/svg+xml;base64,',
                            Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        // emit NewEpicNFTMinted(msg.sender, newItemId);
    }



}