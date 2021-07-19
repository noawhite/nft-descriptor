// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./NFTDescriptor.sol";

contract ERC721Token is ERC721 {
    constructor() ERC721("ERC721", "ERC721") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        NFTDescriptor.ConstructTokenURIParams memory params =
            NFTDescriptor.ConstructTokenURIParams({
                name: name(),
                symbol: symbol(),
                tokenId: tokenId,
                colorSeed1: 1,
                colorSeed2: 2
            });

        return NFTDescriptor.constructTokenURI(params);
    }
}