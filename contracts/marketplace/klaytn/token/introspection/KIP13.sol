//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

import "./IKIP13.sol";

contract KIP13 is IKIP13 {
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;
    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
      _registerInterface(_INTERFACE_ID_KIP13);
    }

    function supportsInterface(bytes4 interfaceId) external override view returns (bool) {
      return _supportedInterfaces[interfaceId];
    }
    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "KIP13: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
