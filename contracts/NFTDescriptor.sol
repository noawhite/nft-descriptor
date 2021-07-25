// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.3;
// pragma abicoder v2;

import "openzeppelin-solidity/contracts/utils/Strings.sol";

import 'base64-sol/base64.sol';
import './HexStrings.sol';
import './NFTSVG.sol';
import './SimpleNFTSVG.sol';

library NFTDescriptor {
    using HexStrings for uint256;

    struct ConstructTokenURIParams {
        string name;
        string symbol;
        uint256 tokenId;
        uint256 colorSeed1;
        uint256 colorSeed2;
    }

    function constructTokenURI(ConstructTokenURIParams memory params) public pure returns (string memory) {
        string memory name = generateName(params);
        string memory description = generateDescription(escapeQuotes(params.name));
        // string memory image = Base64.encode(bytes(generateSVGImage(params)));
        string memory image = Base64.encode(bytes(generateSimpleSVGImage(params)));

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                'data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function escapeQuotes(string memory symbol) internal pure returns (string memory) {
        bytes memory symbolBytes = bytes(symbol);
        uint8 quotesCount = 0;
        for (uint8 i = 0; i < symbolBytes.length; i++) {
            if (symbolBytes[i] == '"') {
                quotesCount++;
            }
        }
        if (quotesCount > 0) {
            bytes memory escapedBytes = new bytes(symbolBytes.length + (quotesCount));
            uint256 index;
            for (uint8 i = 0; i < symbolBytes.length; i++) {
                if (symbolBytes[i] == '"') {
                    escapedBytes[index++] = '\\';
                }
                escapedBytes[index++] = symbolBytes[i];
            }
            return string(escapedBytes);
        }
        return symbol;
    }

    function generateDescription(
        string memory name
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    'DescripterNFT Test ',
                    '-',
                    name
                )
            );
    }

    function generateName(ConstructTokenURIParams memory params)
        private
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    'DescripterNFT - ',
                    escapeQuotes(params.name)
                )
            );
    }

    function generateSimpleSVGImage(ConstructTokenURIParams memory params) internal pure returns (string memory svg) {
        SimpleNFTSVG.SVGParams memory svgParams =
            SimpleNFTSVG.SVGParams({
                symbol: params.symbol,
                name: params.name,
                tokenId: params.tokenId
            });

        return SimpleNFTSVG.generateSVG(svgParams);
    }

    function generateSVGImage(ConstructTokenURIParams memory params) internal pure returns (string memory svg) {
        NFTSVG.SVGParams memory svgParams =
            NFTSVG.SVGParams({
                symbol: params.symbol,
                name: params.name,
                tokenId: params.tokenId,
                color0: tokenToColorHex(params.colorSeed1, 136),
                color1: tokenToColorHex(params.colorSeed2, 136),
                color2: tokenToColorHex(params.colorSeed1, 0),
                color3: tokenToColorHex(params.colorSeed2, 0),
                x1: scale(getCircleCoord(params.colorSeed1, 16, params.tokenId), 0, 255, 16, 274),
                y1: scale(getCircleCoord(params.colorSeed2, 16, params.tokenId), 0, 255, 100, 484),
                x2: scale(getCircleCoord(params.colorSeed1, 32, params.tokenId), 0, 255, 16, 274),
                y2: scale(getCircleCoord(params.colorSeed2, 32, params.tokenId), 0, 255, 100, 484),
                x3: scale(getCircleCoord(params.colorSeed1, 48, params.tokenId), 0, 255, 16, 274),
                y3: scale(getCircleCoord(params.colorSeed2, 48, params.tokenId), 0, 255, 100, 484)
            });

        return NFTSVG.generateSVG(svgParams);
    }

    function scale(
        uint256 n,
        uint256 inMn,
        uint256 inMx,
        uint256 outMn,
        uint256 outMx
    ) private pure returns (string memory) {
        // return (n.sub(inMn).mul(outMx.sub(outMn)).div(inMx.sub(inMn)).add(outMn)).toString();
        // return Strings.toString(((n - inMn) * (outMx - outMn) / (inMx * inMn) + outMn));
        return "1";
    }

    function tokenToColorHex(uint256 token, uint256 offset) internal pure returns (string memory str) {
        return string((token >> offset).toHexStringNoPrefix(3));
    }

    function getCircleCoord(
        uint256 tokenAddress,
        uint256 offset,
        uint256 tokenId
    ) internal pure returns (uint256) {
        return (sliceTokenHex(tokenAddress, offset) * tokenId) % 255;
    }

    function sliceTokenHex(uint256 token, uint256 offset) internal pure returns (uint256) {
        return uint256(uint8(token >> offset));
    }
}