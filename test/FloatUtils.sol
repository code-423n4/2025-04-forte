/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "src/Float128.sol";

contract FloatUtils is Test {
    using Float128 for packedFloat;

    int256 constant BOUNDS_LOW = -3000;
    int256 constant BOUNDS_HIGH = 3000;

    function _buildFFIMul128(
        int aMan,
        int aExp,
        int bMan,
        int bExp,
        string memory operation,
        int largeResult
    ) internal pure returns (string[] memory) {
        string[] memory inputs = new string[](8);
        inputs[0] = "python3";
        inputs[1] = "script/float128_test.py";
        inputs[2] = vm.toString(aMan);
        inputs[3] = vm.toString(aExp);
        inputs[4] = vm.toString(bMan);
        inputs[5] = vm.toString(bExp);
        inputs[6] = operation;
        inputs[7] = vm.toString(largeResult);
        return inputs;
    }

    function _reverseNormalize(packedFloat float) internal pure returns (int256 mantissa) {
        int normalizedExponent;
        (mantissa, normalizedExponent) = float.decode();
        bool negative = false;
        if (normalizedExponent < 0) {
            normalizedExponent = normalizedExponent * -1;
            negative = true;
        }
        int256 expo = 1;
        for (int i = 0; i < normalizedExponent; i++) {
            expo = expo * 10;
        }
        if (negative) {
            mantissa = mantissa / expo;
        } else {
            mantissa = mantissa * expo;
        }
    }

    function setBounds(
        int aMan,
        int aExp,
        int bMan,
        int bExp
    ) internal pure returns (int _aMan, int _aExp, int _bMan, int _bExp) {
        // numbers with more than 38 digits lose precision
        _aMan = bound(aMan, -99999999999999999999999999999999999999, 99999999999999999999999999999999999999);
        _aExp = bound(aExp, BOUNDS_LOW, BOUNDS_HIGH);
        _bMan = bound(bMan, -99999999999999999999999999999999999999, 99999999999999999999999999999999999999);
        _bExp = bound(bExp, BOUNDS_LOW, BOUNDS_HIGH);
    }

    function setBounds(int aMan, int aExp) internal pure returns (int _aMan, int _aExp) {
        // numbers with more than 38 digits lose precision
        _aMan = bound(aMan, -99999999999999999999999999999999999999, 99999999999999999999999999999999999999);
        _aExp = bound(aExp, BOUNDS_LOW, BOUNDS_HIGH);
    }
}
