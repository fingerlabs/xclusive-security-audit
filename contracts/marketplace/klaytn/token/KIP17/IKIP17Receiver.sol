//SPDX-License-Identifier: Buki
pragma solidity ^0.8.0;

/** ERC721 interface 기반의 contract와 safeTransfer를 지원하기 위한 interface */
interface IKIP17Receiver {
	function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) external returns (bytes4);
}
