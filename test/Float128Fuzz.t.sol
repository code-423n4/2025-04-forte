/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/FloatCommon.sol";
import "forge-std/console2.sol";
import "src/Float128.sol";
import {Ln} from "src/Ln.sol";
import "test/FloatUtils.sol";

contract Float128FuzzTest is FloatCommon {
    using Float128 for int256;
    using Float128 for packedFloat;
    using Ln for packedFloat;

    function checkResults(int rMan, int rExp, int pyMan, int pyExp) internal pure {
        checkResults(packedFloat.wrap(0), rMan, rExp, pyMan, pyExp, 0);
    }

    function checkResults(int rMan, int rExp, int pyMan, int pyExp, uint _ulpsOfTolerance) internal pure {
        checkResults(packedFloat.wrap(0), rMan, rExp, pyMan, pyExp, _ulpsOfTolerance);
    }

    function checkResults(
        packedFloat r,
        int rMan,
        int rExp,
        int pyMan,
        int pyExp,
        uint _ulpsOfTolerance
    ) internal pure {
        int ulpsOfTolerance = int(_ulpsOfTolerance);
        console2.log("solResult", packedFloat.unwrap(r));
        console2.log("rMan", rMan);
        console2.log("rExp", rExp);
        console2.log("pyMan", pyMan);
        console2.log("pyExp", pyExp);
        bool isLarge = packedFloat.unwrap(r) & Float128.MANTISSA_L_FLAG_MASK > 0;
        console2.log("isLarge", isLarge);
        // we always check that the result is normalized since this is vital for the library. Only exception is when the result is zero
        uint nDigits = findNumberOfDigits(uint(rMan < 0 ? rMan * -1 : rMan));
        console2.log("nDigits", nDigits);
        if (pyMan != 0) assertTrue(((nDigits == 38) || (nDigits == 72)), "Solidity result is not normalized");
        if (pyMan == 0) {
            assertEq(rMan, 0, "Solidity result is not zero");
            assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");
        }
        if (packedFloat.unwrap(r) != 0) nDigits == 38 ? assertFalse(isLarge) : assertTrue(isLarge);
        // we fix the python result due to the imprecision of python's log10. We cut precision where needed
        if (pyExp != rExp) {
            if (pyExp > rExp) {
                ++rExp;
                rMan /= 10;
            } else {
                ++pyExp;
                pyMan /= 10;
            }
        }
        // we only accept off by 1 if explicitly signaled. (addition/subtraction are famous for rounding difference with Python)
        if (ulpsOfTolerance > 0) {
            // we could be off by one due to rounding issues. The error should be less than 1/1e76
            if (pyMan != rMan) {
                console2.log("ulpsOfTolerance", ulpsOfTolerance);
                if (pyMan > rMan) assertLe(pyMan, rMan + ulpsOfTolerance);
                else assertGe(pyMan + ulpsOfTolerance, rMan);
            }
        } else {
            assertEq(pyMan, rMan);
        }
        if (pyMan != 0) assertEq(pyExp, rExp);
    }

    function testEncoded_mul(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);

        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "mul", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        packedFloat result = Float128.mul(a, b);
        (int rMan, int rExp) = Float128.decode(result);

        checkResults(result, rMan, rExp, pyMan, pyExp, 0);
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_div(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);

        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan == 0 ? int(1) : bMan, bExp, "div", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);
        console2.log("packedFloat a", packedFloat.unwrap(a));
        console2.log("packedFloat b", packedFloat.unwrap(b));
        if (bMan == 0) {
            vm.expectRevert("float128: division by zero");
        }
        packedFloat result = Float128.div(a, b);
        if (bMan != 0) {
            (int rMan, int rExp) = Float128.decode(result);

            checkResults(result, rMan, rExp, pyMan, pyExp, 0);
        }
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_divL(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);

        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan == 0 ? int(1) : bMan, bExp, "div", 1);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);
        console2.log("packedFloat a", packedFloat.unwrap(a));
        console2.log("packedFloat b", packedFloat.unwrap(b));
        if (bMan == 0) {
            vm.expectRevert("float128: division by zero");
        }
        packedFloat result = Float128.divL(a, b);
        if (bMan != 0) {
            (int rMan, int rExp) = Float128.decode(result);

            checkResults(result, rMan, rExp, pyMan, pyExp, 0);
        }
    }

    function testEncoded_add(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);

        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "add", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        packedFloat result = Float128.add(a, b);
        (int rMan, int rExp) = Float128.decode(result);

        checkResults(result, rMan, rExp, pyMan, pyExp, 1);
    }

    function testEncoded_sub(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);

        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "sub", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        packedFloat result = Float128.sub(a, b);
        (int rMan, int rExp) = Float128.decode(result);

        checkResults(result, rMan, rExp, pyMan, pyExp, 1);
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_sqrt(int aMan, int aExp) public {
        (aMan, aExp, , ) = setBounds(aMan, aExp, 0, 0);
        aExp = bound(aExp, -74, 1); // TODO increse this when finishing sqrt
        string[] memory inputs = _buildFFIMul128(aMan < 0 ? aMan * -1 : aMan, aExp, 0, 0, "sqrt", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));
        packedFloat a = Float128.toPackedFloat(aMan, aExp);

        if (aMan < 0) {
            vm.expectRevert("float128: squareroot of negative");
        }
        packedFloat result = Float128.sqrt(a);
        if (aMan >= 0) {
            (int rMan, int rExp) = Float128.decode(result);

            checkResults(result, rMan, rExp, pyMan, pyExp, 0);
        }
    }

    function testLEpackedFloatFuzz(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);
        packedFloat pA = Float128.toPackedFloat(aMan, aExp);
        packedFloat pB = Float128.toPackedFloat(bMan, bExp);
        bool retVal = Float128.le(pA, pB);
        console2.log("retVal", retVal);

        // Creating the float struct to normalize the mantissas and exponents before doing the comparison
        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "le", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, ) = abi.decode((res), (int256, int256));
        bool pyRes = pyMan > 0;
        assertEq(retVal, pyRes);
    }

    function testLTpackedFloatFuzz(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);
        packedFloat pA = Float128.toPackedFloat(aMan, aExp);
        packedFloat pB = Float128.toPackedFloat(bMan, bExp);
        bool retVal = Float128.lt(pA, pB);
        console2.log("retVal", retVal);

        // Creating the float struct to normalize the mantissas and exponents before doing the comparison
        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "lt", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, ) = abi.decode((res), (int256, int256));
        bool pyRes = pyMan > 0;
        assertEq(retVal, pyRes);
    }

    function testGTpackedFloatFuzz(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);
        packedFloat pA = Float128.toPackedFloat(aMan, aExp);
        packedFloat pB = Float128.toPackedFloat(bMan, bExp);
        bool retVal = Float128.gt(pA, pB);
        console2.log("retVal", retVal);

        // Creating the float struct to normalize the mantissas and exponents before doing the comparison
        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "gt", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, ) = abi.decode((res), (int256, int256));
        bool pyRes = pyMan > 0;
        assertEq(retVal, pyRes);
    }

    function testGEpackedFloatFuzz(int aMan, int aExp, int bMan, int bExp) public {
        (aMan, aExp, bMan, bExp) = setBounds(aMan, aExp, bMan, bExp);
        packedFloat pA = Float128.toPackedFloat(aMan, aExp);
        packedFloat pB = Float128.toPackedFloat(bMan, bExp);
        bool retVal = Float128.ge(pA, pB);
        console2.log("retVal", retVal);

        // Creating the float struct to normalize the mantissas and exponents before doing the comparison
        string[] memory inputs = _buildFFIMul128(aMan, aExp, bMan, bExp, "ge", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, ) = abi.decode((res), (int256, int256));
        bool pyRes = pyMan > 0;
        assertEq(retVal, pyRes);
    }

    function testLnpackedFloatFuzz(int aMan, int aExp) public {
        aMan = bound(aMan, 1, 999999999999999999999999999999999999999999999999999999999999999999999999);
        console2.log("aMan", aMan);
        aExp = bound(aExp, -140, 0);
        console2.log("aExp", aExp);
        packedFloat a = Float128.toPackedFloat(aMan, aExp);

        packedFloat retVal = Ln.ln(a);

        // Creating the float struct to normalize the mantissas and exponents before doing the comparison
        string[] memory inputs = _buildFFIMul128(aMan, aExp, 0, 0, "ln", 0);
        bytes memory res = vm.ffi(inputs);
        (int pyMan, int pyExp) = abi.decode((res), (int256, int256));
        (int rMan, int rExp) = Float128.decode(retVal);
        console2.log("rMan", rMan);
        console2.log("rExp", rExp);

        checkResults(retVal, rMan, rExp, pyMan, pyExp, 9);
    }

    function testToPackedFloatFuzz(int256 man, int256 exp) public pure {
        (man, exp, , ) = setBounds(man, exp, 0, 0);

        packedFloat float = man.toPackedFloat(exp);
        (int manDecode, int expDecode) = Float128.decode(float);
        packedFloat comp = manDecode.toPackedFloat(expDecode - exp);

        int256 retVal = 0;
        if (man != 0) {
            retVal = _reverseNormalize(comp);
        }
        assertEq(man, retVal);
    }

    function testFindNumbeOfDigits(uint256 man) public pure {
        console2.log(man);
        uint256 comparison = 1;
        uint256 iter = 0;
        while (comparison <= man) {
            comparison *= 10;
            iter += 1;
            if (comparison == 1e77 && comparison < man) {
                iter += 1;
                break;
            }
        }

        uint256 retVal = Float128.findNumberOfDigits(man);

        assertEq(iter, retVal);
    }

    function findNumberOfDigits(uint x) internal pure returns (uint log) {
        assembly {
            if gt(x, 0) {
                if gt(x, 9999999999999999999999999999999999999999999999999999999999999999) {
                    log := 64
                    x := div(x, 10000000000000000000000000000000000000000000000000000000000000000)
                }
                if gt(x, 99999999999999999999999999999999) {
                    log := add(log, 32)
                    x := div(x, 100000000000000000000000000000000)
                }
                if gt(x, 9999999999999999) {
                    log := add(log, 16)
                    x := div(x, 10000000000000000)
                }
                if gt(x, 99999999) {
                    log := add(log, 8)
                    x := div(x, 100000000)
                }
                if gt(x, 9999) {
                    log := add(log, 4)
                    x := div(x, 10000)
                }
                if gt(x, 99) {
                    log := add(log, 2)
                    x := div(x, 100)
                }
                if gt(x, 9) {
                    log := add(log, 1)
                }
                log := add(log, 1)
            }
        }
    }

    function testLNCaseOne() public pure {
        // Test Case 1:
        int mantissa = 339046758471559584917568900955540863464438633576559162723246173766731092;
        int exponent = -84;
        int expectedResultMantissa = -28712638366447213800267852694553857212;
        int expectedResultExp = -36;
        packedFloat a = Float128.toPackedFloat(mantissa, exponent);

        packedFloat retVal = Ln.ln(a);
        (int mantissaF, int exponentF) = Float128.decode(retVal);
        assertEq(mantissaF, expectedResultMantissa);
        assertEq(exponentF, expectedResultExp);
    }

    function testLNCaseTwo() public pure {
        // Test Case 2:
        int mantissa = 419133353677143729020445529447665547757094903875495880378394873359780286;
        int exponent = -72;
        int expectedResultMantissa = -86956614316348604164580027803497950664;
        int expectedResultExp = -38;
        packedFloat a = Float128.toPackedFloat(mantissa, exponent);

        packedFloat retVal = Ln.ln(a);
        (int mantissaF, int exponentF) = Float128.decode(retVal);
        assertEq(mantissaF, expectedResultMantissa);
        assertEq(exponentF, expectedResultExp);
    }

    function testLNCaseThree() public pure {
        // Test Case 3:
        int mantissa = 471738548555985204842829168083810940950366912454141453216936305944405297;
        int exponent = -73;
        int expectedResultMantissa = -30539154624132792807849865290472860264;
        int expectedResultExp = -37;
        packedFloat a = Float128.toPackedFloat(mantissa, exponent);

        packedFloat retVal = Ln.ln(a);
        (int mantissaF, int exponentF) = Float128.decode(retVal);
        assertEq(mantissaF, expectedResultMantissa);
        assertEq(exponentF, expectedResultExp);
    }

    function testLNCaseFour() public pure {
        // Test Case 1:
        int mantissa = 100000000000000000000000000000000000000000000000000000000000000000000000;
        int exponent = -71;
        int expectedResultMantissa = 0;
        int expectedResultExp = -8192;
        packedFloat a = Float128.toPackedFloat(mantissa, exponent);

        packedFloat retVal = Ln.ln(a);
        (int mantissaF, int exponentF) = Float128.decode(retVal);
        assertEq(mantissaF, expectedResultMantissa);
        assertEq(exponentF, expectedResultExp);
    }
}
