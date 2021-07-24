// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./NFTDescriptor.sol";

contract ERC721Token is ERC721 {
    constructor() ERC721("ERC721", "ERC721") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // require(_exists(tokenId), "URI query for nonexistent token");

        NFTDescriptor.ConstructTokenURIParams memory params =
            NFTDescriptor.ConstructTokenURIParams({
                name: name(),
                symbol: symbol(),
                tokenId: tokenId,
                colorSeed1: uint256(uint160(address(0x6B175474E89094C44Da98b954EedeAC495271d0F))),
                colorSeed2: uint256(uint160(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)))
            });

        return NFTDescriptor.constructTokenURI(params);
    }
}