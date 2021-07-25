// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;

import "openzeppelin-solidity/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

library SimpleNFTSVG {
    using Strings for uint256;

    struct SVGParams {
        string symbol;
        string name;
        uint256 tokenId;
    }

    function generateSVG(SVGParams memory params) internal pure returns (string memory svg) {
        return
            string(
                abi.encodePacked(
                    '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg"',
                    " xmlns:xlink='http://www.w3.org/1999/xlink'>",
                    '<g><text x="270px" y="270px" font-family="\'Courier New\', monospace" font-size="40px" fill="black">',
                    params.tokenId.toString(),
                    '</text></g>',
                    '</svg>'
                )
            );
    }
}