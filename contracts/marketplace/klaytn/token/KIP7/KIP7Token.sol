//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../introspection/KIP13.sol";
import "../../../../library/SafeMath.sol";
import "../../../../library/AddressUtils.sol";

contract KIP7Token is KIP13 {
  using SafeMath for uint256;
  using AddressUtils for address;

  bytes4 private constant _KIP7_RECEIVED = 0x9d188c22;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply = 100000000000000000000;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  bytes4 private constant _INTERFACE_ID_KIP7 = 0x65787371;
  bytes4 private constant _INTERFACE_ID_KIP7_METADATA = 0xa219a025;

  constructor(string memory name_, string memory symbol_, uint8 decimals_) {
    _registerInterface(_INTERFACE_ID_KIP7);
    _registerInterface(_INTERFACE_ID_KIP7_METADATA);

    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 value) public returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  function mint(address account, uint256 amount) public {
    _mint(account, amount);
  }

  function burn(address account, uint256 value) public {
    _burn(account, value);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "KIP7: transfer from the zero address");
    require(recipient != address(0), "KIP7: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "KIP7: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
  }

  function _burn(address account, uint256 value) internal {
    require(account != address(0), "KIP7: burn from the zero address");

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
  }

  function _approve(address owner, address spender, uint256 value) internal {
    require(owner != address(0), "KIP7: approve from the zero address");
    require(spender != address(0), "KIP7: approve to the zero address");

    _allowances[owner][spender] = value;
  }

}