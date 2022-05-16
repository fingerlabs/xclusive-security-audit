//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./VFinix.sol";
import "../../../common/Ownable.sol";

contract DefinixHolderList is Ownable {

  //vFinix 컨트랙트
  VFinix private vFinixContract;

  constructor(address _vFinixAddress) {
    vFinixContract = VFinix(_vFinixAddress);
  }

  function getHolderLevel(address addr) public view returns (int256) {

    int256 maxLevel = -1;

    uint256 lockCount = vFinixContract.lockCount(addr);
    (VFinix.LockInfo[] memory lockInfos, ) = vFinixContract.locks(addr, 0, lockCount);

    for(uint i = 0; i < lockCount; i++) {
      //LockInfo 정보
      VFinix.LockInfo memory lockInfo = lockInfos[i];

      if (lockInfo.isPenalty == false && lockInfo.isUnlocked == false) {
        int256 level = int256(uint256(lockInfo.level));
        if (maxLevel < level) {
            maxLevel = level;
        }
      }
    }
    return maxLevel;
  }

  /*
    * 다이아몬드 홀더인지 반환
    */
  function isDiamondHolder(address addr) public view returns (bool) {
    int256 level = getHolderLevel(addr);
    return level == 2;
  }

  /*
    * 골드 홀더인지 반환
    */
  function isGoldHolder(address addr) public view returns (bool) {
    int256 level = getHolderLevel(addr);
    return level == 1;
  }

  /*
    * 실버 홀더인지 반환
    */
  function isSilverHolder(address addr) public view returns (bool) {
    int256 level = getHolderLevel(addr);
    return level == 0;
  }
}
