//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

interface KIP7Basic {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

interface KIP7 is KIP7Basic {
  function allowance(address owner, address spender)
    external view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
