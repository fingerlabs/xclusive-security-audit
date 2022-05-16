//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "../../library/Context.sol";
import "../../common/Ownable.sol";

contract KlaytnMarketplaceStorage is Context, Ownable {
  mapping(bytes32 => uint) private saleCounts;
  mapping(address => bool) private adminAddresses;
  mapping(address => bool) private tradableTokenAddresses;
  mapping(bytes32 => bool) private cancelled;
  
  address payable private feeAddress;
  address private marketplaceAddress;
  address private definixHolderListAddress;
  address private sunmiyaAddress;
  address private stakingSunmiyaAddress;

  uint private marketplaceFee;
  bool private paused = false;

  modifier onlyMarketplace() {
    require(_msgSender() == marketplaceAddress, "storage modify function call is possible only marketplace address");
    _;
  }

  function setFeeAddress(address payable feeAddress_) public onlyOwner {
    require(feeAddress_ != address(0), "fee address must not be a zero address");
    require(feeAddress != feeAddress_, "already set fee address");

    feeAddress = feeAddress_;
  }

  function getFeeAddress() public view returns (address payable) {
    return feeAddress;
  }

  function setDefinixHolderListAddress(address definixHolderListAddress_) public onlyOwner {
    require(definixHolderListAddress_ != address(0), "definix holder list address must not be a zero address");
    require(definixHolderListAddress != definixHolderListAddress_, "already set definix holder list address");

    definixHolderListAddress = definixHolderListAddress_;
  }

  function getDefinixHolderListAddress() public view returns (address) {
    return definixHolderListAddress;
  }

  function setSunmiyaAddress(address sunmiyaAddress_) public onlyOwner {
    require(sunmiyaAddress_ != address(0), "sunmiya address must not be a zero address");
    require(sunmiyaAddress != sunmiyaAddress_, "already set sunmiya address");

    sunmiyaAddress = sunmiyaAddress_;
  }

  function getSunmiyaAddress() public view returns (address) {
    return sunmiyaAddress;
  }

  function setStakingSunmiyaAddress(address stakingSunmiyaAddress_) public onlyOwner {
    require(stakingSunmiyaAddress_ != address(0), "staking sunmiya address must not be a zero address");
    require(stakingSunmiyaAddress != stakingSunmiyaAddress_, "already set staking sunmiya address");
    
    stakingSunmiyaAddress = stakingSunmiyaAddress_;
  }

  function getStakingSunmiyaAddress() public view returns (address) {
    return stakingSunmiyaAddress;
  }

  function setMarketplaceAddress(address marketplaceAddress_) public onlyOwner {
    require(marketplaceAddress_ != address(0), "marketplace address must not be a zero address");
    require(marketplaceAddress != marketplaceAddress_, "already set marketplace address");

    marketplaceAddress = marketplaceAddress_;
  }

  function getMarketplaceAddress() public view returns (address) {
    return marketplaceAddress;
  }

  function setMarketplaceFee(uint marketplaceFee_) public onlyOwner {
    require(marketplaceFee_ != 0, "marketplace fee must not be a zero");

    marketplaceFee = marketplaceFee_;
  }

  function getMarketplaceFee() public view returns (uint) {
    return marketplaceFee;
  }

  function setSaleCount(bytes32 hash, uint count) public onlyMarketplace {
    require(count > 0, "count must more than zero");

    saleCounts[hash] += count;
  }

  function getSaleCount(bytes32 hash) public view returns (uint) {
    return saleCounts[hash];
  }

  function setCancelled(bytes32 hash, bool cancel) public onlyMarketplace {
    cancelled[hash] = cancel;
  }

  function isCancelled(bytes32 hash) public view returns (bool) {
    return cancelled[hash];
  }

  function setAdminAddress(address adminAddress, bool active) public onlyOwner {
    require(adminAddress != address(0), "admin address must not be a zero address");
    require(isActiveAdminAddress(adminAddress) != active, "already set admin adress");

    adminAddresses[adminAddress] = active;
  }

  function isActiveAdminAddress(address adminAddress) public view returns (bool) {
    return adminAddresses[adminAddress];
  }

  function setTradableTokenAddress(address tokenAddress, bool active) public onlyOwner {
    require(tokenAddress != address(0), "token address must not be a zero address");
    require(isActiveTradableTokenAddress(tokenAddress) != active, "already set tradable token address");
    
    tradableTokenAddresses[tokenAddress] = active;
  }

  function isActiveTradableTokenAddress(address tokenAddress) public view returns (bool) {
    return tradableTokenAddresses[tokenAddress];
  }
}