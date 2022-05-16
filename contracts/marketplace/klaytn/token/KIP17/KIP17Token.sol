//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./KIP17.sol";
import "./KIP17Metadata.sol";
import "./KIP17Enumerable.sol";

import "../../../../library/Counters.sol";
import "../../../../library/Context.sol";
import '../../../../library/Strings.sol';
import "../../../../common/TokenOwnable.sol";
import "../../../../access/MinterRole.sol";

contract KIP17Token is Context, KIP17, KIP17Enumerable, KIP17Metadata, TokenOwnable, MinterRole {

  using Counters for Counters.Counter;
  Counters.Counter private tokenIdCounter;

  string private _contractURI;

  event FingerprintTransfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 editionId);
  
  constructor (
    string memory name, 
    string memory symbol, 
    string memory contractURI_,
    address owner_
  ) KIP17Metadata(name, symbol) TokenOwnable(owner_) {
    _contractURI = contractURI_;
  }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function mintTo(address to, string memory uri, uint256 editionId) public onlyMinter returns (uint256) {
    require(to != address(0), "KIP17: mint to the zero address");
    
    tokenIdCounter.increment();
    uint256 tokenId = tokenIdCounter.current();
    
    _mint(to, tokenId);
    _setTokenURI(tokenId, uri);

    emit FingerprintTransfer(address(0), to, tokenId, editionId);

    return tokenId;
  }

  function burn(uint256 tokenId) public {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "KIP17Token: caller is not owner nor approved");
    _burn(tokenId);

    emit FingerprintTransfer(_msgSender(), address(0), tokenId, 0);
  }

  function _mint(address to, uint256 tokenId) internal override(KIP17, KIP17Enumerable) {
		KIP17Enumerable._mint(to, tokenId);
	}

  function _burn(address owner, uint256 tokenId) internal override(KIP17, KIP17Enumerable) {
    KIP17Enumerable._burn(owner, tokenId);
  }

  function _transferFrom(address from, address to, uint256 tokenId) internal override(KIP17, KIP17Enumerable) {
    KIP17Enumerable._transferFrom(from, to, tokenId);
  }
}