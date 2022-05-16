//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./EthereumExchangeCore.sol";

contract EthereumExchange is EthereumExchangeCore {
  constructor () EthereumExchangeCore() {}

  function executeOrder(
    address payable[10] memory addrs,
    uint[13] memory uints,
    uint8[2] memory enumValues,
    bytes memory sellCallData,
    bytes memory buyCallData,
    uint8[2] memory vs,
    bytes32[4] memory metadata
  ) public payable {
    executeOrder_(
      SellOrder(addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], addrs[5], uints[0], uints[1], uints[2], uints[3], uints[4], uints[5], uints[6], uints[7], uints[8], SellType(enumValues[0]), PublishType(enumValues[1]), sellCallData),
      Sig(vs[0], metadata[0], metadata[1]),
      BuyOrder(addrs[6], addrs[7], addrs[8], addrs[9], uints[9], uints[10], uints[11], uints[12], buyCallData),
      Sig(vs[1], metadata[2], metadata[3])
    );
  }

  function cancelOrder(
    address payable[6] memory addrs,
    uint[9] memory uints,
    uint8[2] memory enumValues,
    bytes memory sellCallData,
    uint8 v,
		bytes32 r,
		bytes32 s
  ) public {
    cancelOrder_(
      SellOrder(addrs[0], addrs[1], addrs[2], addrs[3], addrs[4], addrs[5], uints[0], uints[1], uints[2], uints[3], uints[4], uints[5], uints[6], uints[7], uints[8], SellType(enumValues[0]), PublishType(enumValues[1]), sellCallData),
      Sig(v, r, s)
    );
  }
}