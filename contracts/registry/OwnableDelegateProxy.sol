//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./OwnedUpgradeabilityProxy.sol";

contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {
  constructor(address owner, address initialImplementation, address storageAddress) {
    setUpgradeabilityOwner(owner);
    _upgradeTo(initialImplementation);
    _replaceStorage(storageAddress);
  }
}