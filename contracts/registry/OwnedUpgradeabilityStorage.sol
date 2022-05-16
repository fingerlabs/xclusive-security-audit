//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

contract OwnedUpgradeabilityStorage {

  /* 현재 storage로 사용하는 contract address */
  address internal _storage;
  /* 현재 구현체 address */
  address internal _implementation;
  /* 현재 해당 contract의 소유자 */
  address private _upgradeabilityOwner;
  /* pausable */
  bool internal _paused = false;

  function paused() public view returns (bool) {
    return _paused;
  }
  
  /* 현재 해당 contract의 소유자를 return */
  function upgradeabilityOwner() public view returns (address) {
    return _upgradeabilityOwner;
  }

  /* 해당 contract의 소유자 변경 */
  function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
    _upgradeabilityOwner = newUpgradeabilityOwner;
  }

  /* 현재 구현체의 address return */
  function implementation() public view returns (address) {
    return _implementation;
  }

  function storageAddress() public view returns (address) {
    return _storage;
  }
  
  /**
   * proxy type return 
   * EIP 897 Interface에 따른 proxy type
   * 1: Forwarding proxy, 2: Upgradeable proxy
  */
  function proxyType() public pure returns (uint256 proxyTypeId) {
    return 2;
  }
}