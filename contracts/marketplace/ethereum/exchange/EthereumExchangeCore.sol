// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../token/ERC20/ERC20Basic.sol";

import "../../../library/ArrayUtils.sol";
import "../../../library/Context.sol";
import "../MarketplaceStorage.sol";

import "solidity-bytes-utils/contracts/BytesLib.sol";

contract EthereumExchangeCore is Context {

  address private storageAddress;

  enum SellType { FixedPrice, Auction, Offer }
  enum PublishType { Mint, Transfer }

  uint public constant INVERSE_BASIS_POINT = 10000;
  
  struct Sig {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  struct SellOrder {
    address payable royaltyReceiver;
    address payable creator;
    address payable maker;
    address payable taker;
    address target;
    address paymentToken;
    uint itemId;
    uint offerId;
    uint bidId;
    uint editionCount;
    uint royalty;
    uint basePrice;
    uint reservePrice;
    uint listingTime;
    uint expirationTime;
    SellType sellType;
    PublishType publishType;
    bytes callData;
  }

  struct BuyOrder {
    address payable maker;
    address payable taker;
    address target;
    address paymentToken;
    uint itemId;
    uint royalty;
    uint price;
    uint expirationTime;
    bytes callData;
  }

  event OrdersMatched (address indexed from, address indexed to, address indexed paymentToken, uint itemId, uint price);
  event AcceptOffer (address indexed offeror, uint itemId, uint offerId);
  event AcceptBid (address indexed bidder, uint itemId, uint bidId);
  event SaleAmount (address indexed paymentToken, uint itemId, uint price, uint royalty, uint fee);
  event OrderCancelled (address indexed sender, uint itemId);
  event OrderResale (address indexed sender, uint itemId);
  
  constructor() {}

  function sizeOfSellOrder(SellOrder memory sellOrder) internal pure returns (uint) {
    return ((0x14 * 6) + (0x20 * 9) + 2 + sellOrder.callData.length);
  }

  function sizeOfBuyOrder(BuyOrder memory buyOrder) internal pure returns (uint) {
    return ((0x14 * 4) + (0x20 * 4) + buyOrder.callData.length);
  }

  function hashSellOrder_(SellOrder memory sellOrder) internal pure returns (bytes32 hash) {
    uint size = sizeOfSellOrder(sellOrder);
    bytes memory array = new bytes(size);
		uint index;
		assembly {
			index := add(array, 0x20)
		}
		index = ArrayUtils.unsafeWriteAddress(index, sellOrder.royaltyReceiver);
    index = ArrayUtils.unsafeWriteAddress(index, sellOrder.creator);
		index = ArrayUtils.unsafeWriteAddress(index, sellOrder.maker);
		index = ArrayUtils.unsafeWriteAddress(index, sellOrder.taker);
    index = ArrayUtils.unsafeWriteAddress(index, sellOrder.target);
    index = ArrayUtils.unsafeWriteAddress(index, sellOrder.paymentToken);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.itemId);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.offerId);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.bidId);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.editionCount);
		index = ArrayUtils.unsafeWriteUint(index, sellOrder.royalty);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.basePrice);
		index = ArrayUtils.unsafeWriteUint(index, sellOrder.reservePrice);
    index = ArrayUtils.unsafeWriteUint(index, sellOrder.listingTime);
		index = ArrayUtils.unsafeWriteUint(index, sellOrder.expirationTime);
    index = ArrayUtils.unsafeWriteUint8(index, uint8(sellOrder.sellType));
		index = ArrayUtils.unsafeWriteUint8(index, uint8(sellOrder.publishType));
    index = ArrayUtils.unsafeWriteBytes(index, sellOrder.callData);
		assembly {
			hash := keccak256(add(array, 0x20), size)
		}
		return hash;
  }

  function hashBuyOrder_(BuyOrder memory buyOrder) internal pure returns (bytes32 hash) {
    uint size = sizeOfBuyOrder(buyOrder);
    bytes memory array = new bytes(size);
		uint index;
		assembly {
			index := add(array, 0x20)
		}
		index = ArrayUtils.unsafeWriteAddress(index, buyOrder.maker);
		index = ArrayUtils.unsafeWriteAddress(index, buyOrder.taker);
    index = ArrayUtils.unsafeWriteAddress(index, buyOrder.target);
    index = ArrayUtils.unsafeWriteAddress(index, buyOrder.paymentToken);
    index = ArrayUtils.unsafeWriteUint(index, buyOrder.itemId);
    index = ArrayUtils.unsafeWriteUint(index, buyOrder.royalty);
    index = ArrayUtils.unsafeWriteUint(index, buyOrder.price);
    index = ArrayUtils.unsafeWriteUint(index, buyOrder.expirationTime);
    index = ArrayUtils.unsafeWriteBytes(index, buyOrder.callData);
		assembly {
			hash := keccak256(add(array, 0x20), size)
		}
		return hash;
  }

  function buyOrderToHash(BuyOrder memory buyOrder) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashBuyOrder_(buyOrder)));
	}

  function sellOrderToHash(SellOrder memory sellOrder) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashSellOrder_(sellOrder)));
	}

  function requireValidBuyOrder(BuyOrder memory buyOrder, Sig memory sig) internal pure returns (bytes32) {
    bytes32 hash = buyOrderToHash(buyOrder);
    
    require(ecrecover(hash, sig.v, sig.r, sig.s) == buyOrder.maker, "not matched buy hash maker");
    return hash;
  }

  function requireValidSellOrder(SellOrder memory sellOrder, Sig memory sig) internal pure returns (bytes32) {
    bytes32 hash = sellOrderToHash(sellOrder);

    require(ecrecover(hash, sig.v, sig.r, sig.s) == sellOrder.maker, "not matched sell hash maker");
    return hash;
  }

  function calculatePrice(SellOrder memory sellOrder, BuyOrder memory buyOrder) pure internal returns (uint) {
    if (sellOrder.sellType == SellType.FixedPrice) {
      require(sellOrder.basePrice == buyOrder.price, "sell price and buy price not matched");
    } else if (sellOrder.sellType == SellType.Auction) {
      require(sellOrder.basePrice <= buyOrder.price, "buyPrice must be greater or equal than sellPrice when auction order");
    } else if (sellOrder.sellType == SellType.Offer) {
      require(sellOrder.basePrice == buyOrder.price, "sell price and buy price not matched");
    } else {
      revert("sell type not matched");
    }

    return buyOrder.price;
  }

  function tokenTransfer(SellOrder memory sellOrder, BuyOrder memory buyOrder) internal returns (uint, uint, uint) {
    EthereumMarketplaceStorage marketStorage = EthereumMarketplaceStorage(storageAddress);

    uint fee = marketStorage.getMarketplaceFee();
    if (sellOrder.paymentToken != address(0)) {
      require(msg.value == 0, "when ERC20 transfer, must be value is zero");
      require(marketStorage.isActiveTradableTokenAddress(sellOrder.paymentToken), "impossible transfer token type");
    }

    uint price = calculatePrice(sellOrder, buyOrder);

    if (price == 0) {
      return (0, 0, 0);
    }

    uint royaltyAmount = 0;
    uint feeAmount = 0;
    uint receiveAmount = 0;
    
    if (sellOrder.royaltyReceiver != address(0) && sellOrder.royalty > 0) {
      royaltyAmount = SafeMath.div(SafeMath.mul(sellOrder.royalty, price), INVERSE_BASIS_POINT);
    }
    
    address payable feeAddress = marketStorage.getFeeAddress();
    bool isActiveAdminAddress = marketStorage.isActiveAdminAddress(sellOrder.maker);

    if (feeAddress != address(0) && fee > 0) {
      feeAmount = SafeMath.div(SafeMath.mul(fee, price), INVERSE_BASIS_POINT);
    }

    receiveAmount = SafeMath.sub(SafeMath.sub(price, royaltyAmount), feeAmount);

    if (sellOrder.paymentToken == address(0)) {
      require(_msgValue() == buyOrder.price, "not matched buy price with value");
      feeAddress.transfer(feeAmount);

      if (sellOrder.publishType == PublishType.Mint && isActiveAdminAddress) {
        sellOrder.creator.transfer(receiveAmount);
        sellOrder.royaltyReceiver.transfer(royaltyAmount);
      } else {
        sellOrder.maker.transfer(receiveAmount);
        sellOrder.royaltyReceiver.transfer(royaltyAmount);
      }
    } else {
      require(ERC20(sellOrder.paymentToken).transferFrom(buyOrder.maker, feeAddress, feeAmount), "failed fee amount transfer");
      if (sellOrder.publishType == PublishType.Mint && isActiveAdminAddress) {
        require(ERC20(sellOrder.paymentToken).transferFrom(buyOrder.maker, sellOrder.creator, receiveAmount), "failed receive amount transfer to royaltyReceiver");
        require(ERC20(sellOrder.paymentToken).transferFrom(buyOrder.maker, sellOrder.royaltyReceiver, royaltyAmount), "failed royalty amount transfer to royaltyReceiver");
      } else {
        require(ERC20(sellOrder.paymentToken).transferFrom(buyOrder.maker, sellOrder.maker, receiveAmount), "failed receive amount transfer to maker");
        require(ERC20(sellOrder.paymentToken).transferFrom(buyOrder.maker, sellOrder.royaltyReceiver, royaltyAmount), "failed royalty amount transfer to royaltyReceiver");
      }
    }

    return (price, royaltyAmount, feeAmount);
  }

  function ordersMatch(BuyOrder memory buyOrder, SellOrder memory sellOrder) internal view returns (bool) {
    EthereumMarketplaceStorage marketStorage = EthereumMarketplaceStorage(storageAddress);
    bool isAdminMaker = marketStorage.isActiveAdminAddress(sellOrder.maker);

    if (buyOrder.target != sellOrder.target || buyOrder.paymentToken != sellOrder.paymentToken || buyOrder.itemId != sellOrder.itemId || buyOrder.royalty != sellOrder.royalty) {
      return false;
    }

    if (sellOrder.sellType == SellType.FixedPrice) {
      if (sellOrder.listingTime != 0 && sellOrder.listingTime > block.timestamp) {
        return false;
      }

      if (sellOrder.expirationTime != 0 && sellOrder.expirationTime < block.timestamp) {
        return false;
      }

      if (buyOrder.maker != _msgSender()) {
        return false;
      }

      if (isAdminMaker && sellOrder.creator != buyOrder.taker) {
        return false;
      }

      if (!isAdminMaker && sellOrder.maker != buyOrder.taker) {
        return false;
      }
    } else if (sellOrder.sellType == SellType.Auction) {
      if (buyOrder.price == 0) {
        return false;
      }
      
      if (sellOrder.reservePrice != 0 && sellOrder.basePrice > sellOrder.reservePrice) {
        return false;
      }

      if (sellOrder.reservePrice > buyOrder.price) {
        if (sellOrder.expirationTime != 0 && sellOrder.expirationTime > block.timestamp) {
          return false;
        }
      }

      if (sellOrder.reservePrice <= buyOrder.price && buyOrder.maker != _msgSender()) {
        return false;
      } 

      if (isAdminMaker) {
        if (sellOrder.creator != buyOrder.taker) {
          return false;
        }

        if (sellOrder.reservePrice > buyOrder.price && sellOrder.creator != _msgSender()) {
          return false;
        }
      } else {
        if (sellOrder.maker != buyOrder.taker) {
          return false;
        }

        if (sellOrder.reservePrice > buyOrder.price && sellOrder.maker != _msgSender()) {
          return false;
        }
      }
    } else if (sellOrder.sellType == SellType.Offer) {
      if (buyOrder.price == 0) {
        return false;
      }

      if (buyOrder.expirationTime != 0 && buyOrder.expirationTime < block.timestamp) {
        return false;
      }
      
      if (sellOrder.maker != _msgSender()) {
        return false;
      }

      if (buyOrder.taker != sellOrder.maker) {
        return false;
      }
    } else {
      return false;
    }

    return true;
  }

  function nftTransfer(SellOrder memory sellOrder, BuyOrder memory buyOrder) internal returns (bool) {
    bool result;

    address sellOrderCallDataFrom = BytesLib.toAddress(sellOrder.callData, 16);
    address buyOrderCallDataFrom = BytesLib.toAddress(buyOrder.callData, 16);

    require(
      sellOrderCallDataFrom == sellOrder.maker || 
      buyOrderCallDataFrom == sellOrder.maker || 
      sellOrderCallDataFrom == buyOrder.maker ||
      buyOrderCallDataFrom == buyOrder.maker
      , "signer not matched from address");

    if (sellOrder.sellType == SellType.Offer) {
      (result, ) = sellOrder.target.call(sellOrder.callData);
    } else if (sellOrder.sellType == SellType.Auction) {
      if (_msgSender() == sellOrder.creator || _msgSender() == sellOrder.maker) {
        (result, ) = sellOrder.target.call(sellOrder.callData);
      } else {
        (result, ) = sellOrder.target.call(buyOrder.callData);
      }
    } else {
      (result, ) = sellOrder.target.call(buyOrder.callData);
    }

    return result;
  }

  function executeOrder_(SellOrder memory sellOrder, Sig memory sellSig, BuyOrder memory buyOrder, Sig memory buySig) internal {
    bytes32 sellHash = hashSellOrder_(sellOrder);
    EthereumMarketplaceStorage marketStorage = EthereumMarketplaceStorage(storageAddress);
    
    require(!marketStorage.isCancelled(sellHash), "already cancel order");
    require(buyOrder.maker == _msgSender() || sellOrder.maker == _msgSender() || sellOrder.creator == _msgSender(), "msg sender unknown");
    
    if (sellOrder.maker == _msgSender()) {
      requireValidBuyOrder(buyOrder, buySig);
    } else {
      requireValidSellOrder(sellOrder, sellSig);
    }

    require(ordersMatch(buyOrder, sellOrder), "orders that cannot be processed");
    require(marketStorage.getSaleCount(sellHash) < sellOrder.editionCount, "not enough quantity");
    
    uint size;
    address target = sellOrder.target;
    assembly {
      size := extcodesize(target)
    }
    require(size > 0, "target not exist");

    (uint price, uint royalty, uint fee) = tokenTransfer(sellOrder, buyOrder);
    
    bool nftTransferResult = nftTransfer(sellOrder, buyOrder);
    require(nftTransferResult, "NFT transfer or mint failed");
    
    marketStorage.setSaleCount(sellHash, 1);
    
    if (sellOrder.sellType == SellType.Auction) {
      emit AcceptBid(buyOrder.maker, sellOrder.itemId, sellOrder.bidId);
    } else if (sellOrder.sellType == SellType.Offer) {
      emit AcceptOffer(buyOrder.maker, sellOrder.itemId, sellOrder.offerId);
    }

    emit OrdersMatched(sellOrder.maker, buyOrder.maker, sellOrder.paymentToken, sellOrder.itemId, price);
    emit SaleAmount(sellOrder.paymentToken, sellOrder.itemId, price, royalty, fee);
  }

  function cancelOrder_(SellOrder memory sellOrder, Sig memory sig) internal {
    bytes32 hash = hashSellOrder_(sellOrder);
    requireValidSellOrder(sellOrder, sig);

    require(sellOrder.maker == _msgSender(), "not matched signed address");

    EthereumMarketplaceStorage marketStorage = EthereumMarketplaceStorage(storageAddress);
    marketStorage.setCancelled(hash, true);

    emit OrderCancelled(sellOrder.maker, sellOrder.itemId);
  }
}