//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../library/Context.sol";

contract TokenOwnable is Context{
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor (address owner_) {
    _owner = owner_;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "caller is not the owner");
    _;
  }

  function isOwner() public view returns (bool) {
    return _msgSender() == _owner;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "owner is must be not zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  /* owner 제거 */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
}