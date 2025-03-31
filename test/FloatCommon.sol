/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/console2.sol";
import "src/Float128.sol";
import "test/FloatUtils.sol";

contract FloatCommon is FloatUtils {
    using Float128 for int256;
    using Float128 for packedFloat;

    int constant ZERO_OFFSET_NEG = -8192;

    function testEncoded_mul_zero(int bMan, int bExp) public pure {
        (bMan, bExp) = setBounds(bMan, bExp);
        // check when a == 0
        int aMan = 0;
        int aExp = ZERO_OFFSET_NEG;

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        packedFloat result = Float128.mul(a, b);
        (int rMan, int rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not zero");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");

        // check when b == 0
        a = Float128.toPackedFloat(aMan, aExp);
        b = Float128.toPackedFloat(bMan, bExp);

        result = Float128.mul(b, a);
        (rMan, rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not zero");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");

        // check when a and b == 0
        result = Float128.mul(a, a);
        (rMan, rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not zero");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_div_zero(int bMan, int bExp) public {
        (bMan, bExp) = setBounds(bMan, bExp);
        int aMan = 0;
        int aExp = ZERO_OFFSET_NEG;

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);
        console2.log("packedFloat a", packedFloat.unwrap(a));
        console2.log("packedFloat b", packedFloat.unwrap(b));
        if (bMan == 0) {
            vm.expectRevert("float128: division by zero");
        }
        packedFloat result = Float128.div(a, b);
        (int rMan, int rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not zero");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_divL_zero(int bMan, int bExp) public {
        (bMan, bExp) = setBounds(bMan, bExp);
        int aMan = 0;
        int aExp = ZERO_OFFSET_NEG;

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);
        console2.log("packedFloat a", packedFloat.unwrap(a));
        console2.log("packedFloat b", packedFloat.unwrap(b));
        if (bMan == 0) {
            vm.expectRevert("float128: division by zero");
        }
        packedFloat result = Float128.divL(a, b);
        (int rMan, int rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not zero");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not zero");
    }

    function testEncoded_add_zero(int bMan, int bExp) public pure {
        (bMan, bExp) = setBounds(bMan, bExp);
        int aMan = 0;
        int aExp = ZERO_OFFSET_NEG;
        // 0 + b = b
        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        packedFloat result = Float128.add(a, b);
        (int rMan, int rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (bMan, bExp) = Float128.decode(result);
        console2.log("rExp", rExp);

        assertEq(rMan, bMan, "Solidity result is not consistent with zero rules");
        assertEq(rExp, bExp, "Solidity result is not consistent with zero rules");

        // b + 0 = b
        result = Float128.add(b, a);
        (rMan, rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (bMan, bExp) = Float128.decode(result);
        console2.log("rExp", rExp);

        assertEq(rMan, bMan, "Solidity result is not consistent with zero rules");
        assertEq(rExp, bExp, "Solidity result is not consistent with zero rules");

        // 0 + 0 = 0
        result = Float128.add(a, a);
        (rMan, rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (aMan, aExp) = Float128.decode(result);
        console2.log("rExp", rExp);

        assertEq(rMan, aMan, "Solidity result is not consistent with zero rules");
        assertEq(rExp, aExp, "Solidity result is not consistent with zero rules");
    }

    function testEncoded_sub_zero(int bMan, int bExp) public pure {
        (bMan, bExp) = setBounds(bMan, bExp);
        int aMan = 0;
        int aExp = ZERO_OFFSET_NEG;

        packedFloat a = Float128.toPackedFloat(aMan, aExp);
        packedFloat b = Float128.toPackedFloat(bMan, bExp);

        // 0 - b should equal -b
        packedFloat result = Float128.sub(a, b);
        (int rMan, int rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (bMan, bExp) = Float128.decode(b);
        assertEq(rMan, int(bMan * -1), "Solidity result is not consistent with zero rules");
        assertEq(rExp, bExp, "Solidity result is not consistent with zero rules");

        // b - 0 should equal b
        result = Float128.sub(b, a);
        (rMan, rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (bMan, bExp) = Float128.decode(b);
        assertEq(rMan, bMan, "Solidity result is not consistent with zero rules");
        assertEq(rExp, bExp, "Solidity result is not consistent with zero rules");

        // 0 - 0 should equal 0
        result = Float128.sub(a, a);
        (rMan, rExp) = Float128.decode(result);
        // b must be decoded in the same way to account for the 38 digits in the return value mantissa
        (bMan, bExp) = Float128.decode(a);
        assertEq(rMan, bMan, "Solidity result is not consistent with zero rules");
        assertEq(rExp, bExp, "Solidity result is not consistent with zero rules");
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function testEncoded_sqrt_0() public pure {
        packedFloat a = Float128.toPackedFloat(0, ZERO_OFFSET_NEG);

        // sqrt of 0 = 0
        packedFloat result = Float128.sqrt(a);
        (int rMan, int rExp) = Float128.decode(result);
        assertEq(rMan, 0, "Solidity result is not consistent with zero rules");
        assertEq(rExp, ZERO_OFFSET_NEG, "Solidity result is not consistent with zero rules");
    }
}
