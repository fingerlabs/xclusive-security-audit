//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./SafeMath.sol";

library ArrayUtils {
  function guardedArrayReplace(bytes memory array, bytes memory desired, bytes memory mask) internal pure {
    require(array.length == desired.length);
    require(array.length == mask.length);

    uint words = array.length / 0x20;
    uint index = words * 0x20;
    assert(index / 0x20 == words);
    uint i;

    for (i = 0; i < words; i++) {
      assembly {
        let commonIndex := mul(0x20, add(1, i))
        let maskValue := mload(add(mask, commonIndex))
        mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
      }
    }

    if (words > 0) {
      i = words;
      assembly {
        let commonIndex := mul(0x20, add(1, i))
        let maskValue := mload(add(mask, commonIndex))
        mstore(add(array, commonIndex), or(and(not(maskValue), mload(add(array, commonIndex))), and(maskValue, mload(add(desired, commonIndex)))))
      }
    } else {
      for (i = index; i < array.length; i++) {
        array[i] = ((mask[i] ^ 0xff) & array[i]) | (mask[i] & desired[i]);
      }
    }
  }

  function arrayEq(bytes memory a, bytes memory b) internal pure returns (bool) {
    bool success = true;

    assembly {
      let length := mload(a)

      switch eq(length, mload(b))
      case 1 {
        let cb := 1

        let mc := add(a, 0x20)
        let end := add(mc, length)

        for { 
          let cc := add(b, 0x20)
        } eq(add(lt(mc, end), cb), 2) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          if iszero(eq(mload(mc), mload(cc))) {
            success := 0
            cb := 0
          }
        }
      }
      default {
        success := 0
      }
    }
    return success;
  }

  function unsafeWriteBytes(uint index, bytes memory source) internal pure returns (uint) {
    if (source.length > 0) {
      assembly {
        let length := mload(source)
        let end := add(source, add(0x20, length))
        let arrIndex := add(source, 0x20)
        let tempIndex := index
        for { } eq(lt(arrIndex, end), 1) {
          arrIndex := add(arrIndex, 0x20)
          tempIndex := add(tempIndex, 0x20)
        } {
          mstore(tempIndex, mload(arrIndex))
        }
        index := add(index, length)
      }
    }
    return index;
  }

  function unsafeWriteAddress(uint index, address source) internal pure returns (uint) {
    uint conv = uint(uint160(source)) << 0x60;
    assembly {
      mstore(index, conv)
      index := add(index, 0x14)
    }
    return index;
  }

  function unsafeWriteUint(uint index, uint source) internal pure returns (uint) {
    assembly {
      mstore(index, source)
      index := add(index, 0x20)
    }
    return index;
  }

  function unsafeWriteUint8(uint index, uint8 source) internal pure returns (uint) {
    assembly {
      mstore8(index, source)
      index := add(index, 0x1)
    }
    return index;
  }
}