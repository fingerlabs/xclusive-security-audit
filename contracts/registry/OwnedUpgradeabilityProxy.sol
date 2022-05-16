//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../library/Context.sol";
import "./OwnedUpgradeabilityStorage.sol";

contract OwnedUpgradeabilityProxy is Context, OwnedUpgradeabilityStorage {
  /**
   * 소유권 이전 이벤트
   * @param previousOwner 이전 소유자
   * @param newOwner 변경된 소유자
   */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  /**
   * implementation의 upgrade에 대한 event
   * @param implementation upgrade된 contract의 address
   */
  event Upgraded(address indexed implementation);

  modifier whenNotPaused {
    require(!paused(), "Pausable: paused");
    _;
  }

  modifier whenPaused {
    require(paused(), "Pausable: not paused");
    _;
  }

  function pause() public whenNotPaused onlyProxyOwner {
    _paused = true;
  }

  function unpause() public whenPaused onlyProxyOwner {
    _paused = false;
  }

  /**
   * implementation contract upgrade
   * @param implementation upgrade할 contract의 address
   */
  function _upgradeTo(address implementation) internal {
    require(_implementation != implementation, "OwnedUpgradeabilityProxy: same implementation");
    _implementation = implementation;
    emit Upgraded(implementation);
  }

  function _replaceStorage(address storageAddress) internal {
    require(_storage != storageAddress, "already used storage");
    _storage = storageAddress;
  }

  /* owner인지 check */
  modifier onlyProxyOwner() {
    require(_msgSender() == proxyOwner(), "OwnedUpgradeabilityProxy: message sender must be equal proxyOwner");
    _;
  }

  /* proxy에 대해 upgrade가 가능한 owner인지 check */
  function proxyOwner() public view returns (address) {
    return upgradeabilityOwner();
  }

  /* proxy owner 변경 */
  function transferProxyOwnership(address newOwner) public onlyProxyOwner {
    require(newOwner != address(0), "OwnedUpgradeabilityProxy: same owner");
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  /* implementation upgrade */
  function upgradeTo(address implementation) public onlyProxyOwner {
    _upgradeTo(implementation);
  }

  function replaceStorage(address storageAddress) public onlyProxyOwner {
    _replaceStorage(storageAddress);
  }
}