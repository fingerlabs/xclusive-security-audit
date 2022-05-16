//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./IERC721Metadata.sol";
import "../introspection/ERC165.sol";

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    
  string private _name;
  string private _symbol;

  mapping(uint256 => string) private _tokenURIs;

  bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

  constructor (string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;

    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(_INTERFACE_ID_ERC721_METADATA);
  }

  function name() external override view returns (string memory) {
    return _name;
  }

  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  function tokenURI(uint256 tokenId) external override view returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return _tokenURIs[tokenId];
  }

  function _setTokenURI(uint256 tokenId, string memory uri) internal {
    require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    _tokenURIs[tokenId] = uri;
  }
}
