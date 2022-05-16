//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

interface IStakingSunmiya {
  function getStakingCount(address _to) external view returns (uint256 count);
}