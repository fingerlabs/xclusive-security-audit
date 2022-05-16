//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

interface VFinix {
  enum LockLevel {Level1, Level2, Level3}

  struct LockInfo {
    uint256 id;
    LockLevel level;
    uint256 lockAmount;
    uint256 voteAmount;
    uint256 lockTimestamp;
    uint256 penaltyFinixAmount;
    uint256 penaltyUnlockTimestamp;
    bool isPenalty;
    bool isUnlocked;
  }

  function lockCount(address _user) external view returns(uint256);
  function locks(address _user,uint256 _startIndex,uint256 _limit) external view returns(LockInfo[] memory locks_, uint256[] memory locksTopup); 
}