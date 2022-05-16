//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

contract Context {
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal pure returns (bytes memory) {
    return msg.data;
  }

  function _msgValue() internal view returns (uint256) {
    return msg.value;
  }
}
