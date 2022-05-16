//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../library/Context.sol";

contract Ownable is Context {
  address private _owner;
  /* owner 제거 시 event*/
  event OwnershipRenounced(address indexed previousOwner);
  /* 기존 owner에서 새로운 Owner로 owner 변경*/
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    _owner = _msgSender();
  }

  modifier onlyOwner() {
    require(_msgSender() == _owner, "Ownable: owner not matched");
    _;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  /* owner 변경 */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: owner is must be not zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  /* owner 제거 */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }
}