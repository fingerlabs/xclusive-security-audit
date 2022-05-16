//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../KIP17/KIP17Token.sol";
import "../../../../library/Context.sol";
import "../../../../common/Ownable.sol";

contract KIPTokenFactory is Context, Ownable {

  address private contractOwner;
  address private marketplaceAddress;

  event KIP17TokenCreate(string tokenType, address tokenAddress, string name, string symbol);

  constructor (address _marketplaceAddress) {
    marketplaceAddress = _marketplaceAddress;
  }

  function createKIP17Token(string memory name, string memory symbol, string memory contractURI, address kip17Owner) public returns (address) {
    KIP17Token kip17Token = new KIP17Token(name, symbol, contractURI, kip17Owner);
    
    address factoryOwner = owner();
    kip17Token.addMinter(factoryOwner);
    kip17Token.addMinter(marketplaceAddress);
    
    emit KIP17TokenCreate("KIP17", address(kip17Token), name, symbol);
    return address(kip17Token);
  }
}

