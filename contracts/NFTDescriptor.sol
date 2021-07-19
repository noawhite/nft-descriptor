// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
pragma abicoder v2;

import "openzeppelin-solidity/contracts/utils/Strings.sol";

import 'base64-sol/base64.sol';
import './HexStrings.sol';
import './NFTSVG.sol';

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
        string memory description =
            generateDescription(escapeQuotes(params.name));
        string memory image = Base64.encode(bytes(generateSVGImage(params)));

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

    struct DecimalStringParams {
        // significant figures of decimal
        uint256 sigfigs;
        // length of decimal string
        uint8 bufferLength;
        // ending index for significant figures (funtion works backwards when copying sigfigs)
        uint8 sigfigIndex;
        // index of decimal place (0 if no decimal)
        uint8 decimalIndex;
        // start index for trailing/leading 0's for very small/large numbers
        uint8 zerosStartIndex;
        // end index for trailing/leading 0's for very small/large numbers
        uint8 zerosEndIndex;
        // true if decimal number is less than one
        bool isLessThanOne;
        // true if string should include "%"
        bool isPercent;
    }

    function generateDecimalString(DecimalStringParams memory params) private pure returns (string memory) {
        bytes memory buffer = new bytes(params.bufferLength);
        if (params.isPercent) {
            buffer[buffer.length - 1] = '%';
        }
        if (params.isLessThanOne) {
            buffer[0] = '0';
            buffer[1] = '.';
        }

        // add leading/trailing 0's
        for (uint256 zerosCursor = params.zerosStartIndex; zerosCursor < params.zerosEndIndex + 1; zerosCursor++) {
            buffer[zerosCursor] = bytes1(uint8(48));
        }
        // add sigfigs
        while (params.sigfigs > 0) {
            if (params.decimalIndex > 0 && params.sigfigIndex == params.decimalIndex) {
                buffer[params.sigfigIndex--] = '.';
            }
            buffer[params.sigfigIndex--] = bytes1(uint8(uint256(48) + (params.sigfigs % 10)));
            params.sigfigs /= 10;
        }
        return string(buffer);
    }

    function sigfigsRounded(uint256 value, uint8 digits) private pure returns (uint256, bool) {
        bool extraDigit;
        if (digits > 5) {
            value = value / ((10**(digits - 5)));
        }
        bool roundUp = value % 10 > 4;
        value = value / 10;
        if (roundUp) {
            value = value + 1;
        }
        // 99999 -> 100000 gives an extra sigfig
        if (value == 100000) {
            value /= 10;
            extraDigit = true;
        }
        return (value, extraDigit);
    }

    function abs(int256 x) private pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
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
        // FIXME
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