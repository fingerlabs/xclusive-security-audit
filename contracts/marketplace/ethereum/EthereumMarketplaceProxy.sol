//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../../registry/OwnableDelegateProxy.sol";
import "../../library/Context.sol";

contract EthereumMarketplaceProxy is Context, OwnableDelegateProxy {
  constructor (address implementation, address storageAddress_) 
    OwnableDelegateProxy(_msgSender(), implementation, storageAddress_) {}

  function proxy(bytes memory callData) payable public whenNotPaused returns (bytes memory) {
    (bool success, bytes memory data) = _implementation.delegatecall(callData);
    
    require(success, "delegatecall failed");
    return data;
  }
}