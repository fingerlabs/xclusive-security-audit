//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../ERC721/ERC721Token.sol";
import "../../../../library/Context.sol";
import "../../../../common/Ownable.sol";

contract ERCTokenFactory is Context, Ownable {

  address private contractOwner;
  address private marketplaceAddress;

  event ERC721TokenCreate(string tokenType, address tokenAddress, string name, string symbol);

  constructor (address _marketplaceAddress) {
    marketplaceAddress = _marketplaceAddress;
  }

  function createERC721Token(string memory name, string memory symbol, string memory contractURI, address erc721Owner) public returns (address) {

    ERC721Token erc721Token = new ERC721Token(name, symbol, contractURI, erc721Owner);
    
    address factoryOwner = owner();
    erc721Token.addMinter(factoryOwner);
    erc721Token.addMinter(marketplaceAddress);
    
    emit ERC721TokenCreate("ERC721", address(erc721Token), name, symbol);
    return address(erc721Token);
  }
}

