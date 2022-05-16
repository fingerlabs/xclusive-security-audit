//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./IKIP17.sol";

interface IKIP17Metadata is IKIP17 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function tokenURI(uint256 tokenId) external view returns (string memory);
}
