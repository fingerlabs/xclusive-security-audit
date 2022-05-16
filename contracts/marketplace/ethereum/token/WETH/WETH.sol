//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../../../../library/Context.sol";

contract WETH is Context {
	string public name     = "Wrapped ETH";
	string public symbol   = "WETH";
	uint8  public decimals = 18;

	event  Approval(address indexed src, address indexed guy, uint wad);
	event  Transfer(address indexed src, address indexed dst, uint wad);
	event  Deposit(address indexed dst, uint wad);
	event  Withdrawal(address indexed src, uint wad);

	mapping (address => uint)                       public  balanceOf;
	mapping (address => mapping (address => uint))  public  allowance;

	fallback() external payable {
		deposit();
	}

	receive() external payable {

	}

	function deposit() public payable {
		balanceOf[_msgSender()] += msg.value;
		emit Deposit(_msgSender(), msg.value);
	}
	
	function withdraw(uint wad) public {
		require(balanceOf[_msgSender()] >= wad);
		balanceOf[_msgSender()] -= wad;
		_msgSender().transfer(wad);
		emit Withdrawal(_msgSender(), wad);
	}

	function totalSupply() public view returns (uint) {
		return address(this).balance;
	}

	function approve(address guy, uint wad) public returns (bool) {
		allowance[_msgSender()][guy] = wad;
		emit Approval(_msgSender(), guy, wad);
		return true;
	}

	function transfer(address dst, uint wad) public returns (bool) {
		return transferFrom(_msgSender(), dst, wad);
	}

	function transferFrom(address src, address dst, uint wad) public returns (bool) {
		require(balanceOf[src] >= wad);

		if (src != _msgSender() && allowance[src][_msgSender()] != type(uint128).max) {
			require(allowance[src][_msgSender()] >= wad, "WETH: allowance value must be greater or equal than wad");
			allowance[src][_msgSender()] -= wad;
		}

		balanceOf[src] -= wad;
		balanceOf[dst] += wad;

		emit Transfer(src, dst, wad);

		return true;
	}
}