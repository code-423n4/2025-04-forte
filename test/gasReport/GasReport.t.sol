// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {GasHelpers} from "test/gasReport/GasHelpers.sol";
import {packedFloat, Float128} from "src/Float128.sol";
import {Ln} from "src/Ln.sol";
import "test/FloatUtils.sol";
import "forge-std/console2.sol";

contract GasReport is Test, GasHelpers, FloatUtils {
    using Float128 for packedFloat;
    using Float128 for int256;
    using Ln for packedFloat;

    uint256 runs = 1_000;
    string path = "test/gasReport/GasReport.json";

    // We use a delay here, increasing each test instance. This ensures only a single test is writing to the gas report json at a time.
    uint256 delay = 1_00;

    /*******************************************************/
    /********************  PACKED FLOAT ********************/
    /*******************************************************/
    function test_gasUsedPacked_add() public {
        vm.sleep(delay * 11);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);
            startMeasuringGas("Packed - Add");
            Float128.add(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.add.", min, avg / runs, max);
    }

    function test_gasUsedPacked_add_matching_exponents() public {
        vm.sleep(delay * 12);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, ) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, aExp);
            startMeasuringGas("Packed - Add - Matching Exponents");
            Float128.add(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.add.matchingexponents.", min, avg / runs, max);
    }

    function test_gasUsedPacked_add_sub() public {
        vm.sleep(delay * 13);
        _primer();
        _resetGasUsed();

        packedFloat a;
        packedFloat b;

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );

            // We want a positive aMan and a negative bMan
            if (aMan < 0) {
                bMan = aMan;
                aMan *= -1;
            }

            if (bMan > 0) {
                bMan *= -1;
            }

            a = Float128.toPackedFloat(aMan, aExp);
            b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Add by Sub");
            Float128.add(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.add.addsub.", min, avg / runs, max);
    }

    function test_gasUsedPacked_sub() public {
        vm.sleep(delay * 14);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);
            startMeasuringGas("Packed - Sub");
            Float128.sub(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.sub.", min, avg / runs, max);
    }

    function test_gasUsedPacked_sub_matching_exponents() public {
        vm.sleep(delay * 15);
        _primer();
        _resetGasUsed();

        int aExp = -36;
        int bExp = -36;

        for (uint i = 0; i < runs; ++i) {
            (int aMan, , int bMan, ) = setBounds(vm.randomInt(), vm.randomInt(), vm.randomInt(), vm.randomInt());
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Sub - Matching Exponents");
            Float128.sub(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.sub.matchingexponents.", min, avg / runs, max);
    }

    function test_gasUsedPacked_sub_add() public {
        vm.sleep(delay * 16);
        _primer();
        _resetGasUsed();

        packedFloat a;
        packedFloat b;

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );

            // We want a positive aMan and a negative bMan
            if (aMan < 0) {
                bMan = aMan;
                aMan *= -1;
            }

            if (bMan > 0) {
                bMan *= -1;
            }

            a = Float128.toPackedFloat(aMan, aExp);
            b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Sub by Add");
            Float128.sub(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.sub.subadd.", min, avg / runs, max);
    }

    function test_gasUsedPacked_mul() public {
        vm.sleep(delay * 17);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Mul");
            Float128.mul(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.mul.", min, avg / runs, max);
    }

    function test_gasUsedPacked_mul_by_zero() public {
        vm.sleep(delay * 18);
        _primer();
        _resetGasUsed();

        packedFloat b = Float128.toPackedFloat(0, -8192);

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, , ) = setBounds(vm.randomInt(), vm.randomInt(), vm.randomInt(), vm.randomInt());
            packedFloat a = Float128.toPackedFloat(aMan, aExp);

            startMeasuringGas("Packed - Mul By Zero");
            Float128.mul(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.mul.mulbyzero.", min, avg / runs, max);
    }

    function test_gasUsedPacked_div() public {
        vm.sleep(delay * 19);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            // This is simply ensuring no division by zero revert
            if (bMan == 0) {
                bMan = 1;
            }
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Div");
            Float128.div(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.div.", min, avg / runs, max);
    }

    function test_gasUsedPacked_divL() public {
        vm.sleep(delay * 20);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp, int bMan, int bExp) = setBounds(
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt(),
                vm.randomInt()
            );
            // This is simply ensuring no division by zero revert
            if (bMan == 0) {
                bMan = 1;
            }
            packedFloat a = Float128.toPackedFloat(aMan, aExp);
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Div");
            Float128.divL(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.divL.", min, avg / runs, max);
    }

    function test_gasUsedPacked_div_numerator_zero() public {
        vm.sleep(delay * 21);
        _primer();
        _resetGasUsed();

        packedFloat a = Float128.toPackedFloat(0, -8192);

        for (uint i = 0; i < runs; ++i) {
            (, , int bMan, int bExp) = setBounds(vm.randomInt(), vm.randomInt(), vm.randomInt(), vm.randomInt());
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Div - Numerator Zero");
            Float128.div(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.div.numeratorzero.", min, avg / runs, max);
    }

    function test_gasUsedPacked_divL_numerator_zero() public {
        vm.sleep(delay * 22);
        _primer();
        _resetGasUsed();

        packedFloat a = Float128.toPackedFloat(0, -8192);

        for (uint i = 0; i < runs; ++i) {
            (, , int bMan, int bExp) = setBounds(vm.randomInt(), vm.randomInt(), vm.randomInt(), vm.randomInt());
            packedFloat b = Float128.toPackedFloat(bMan, bExp);

            startMeasuringGas("Packed - Div - Numerator Zero");
            Float128.divL(a, b);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.divL.numeratorzero.", min, avg / runs, max);
    }

    function test_gasUsedPacked_sqrt() public {
        vm.sleep(delay * 23);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp) = setBoundsSqrt(vm.randomInt(), vm.randomInt());
            // This is to circumvent sqrt of negative revert scenario
            if (aMan < 0) {
                aMan *= -1;
            }

            packedFloat a = Float128.toPackedFloat(aMan, aExp);

            startMeasuringGas("Packed - Sqrt");
            Float128.sqrt(a);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.sqrt.", min, avg / runs, max);
    }

    function test_gasUsedPacked_ln() public {
        vm.sleep(delay * 24);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            (int aMan, int aExp) = setBoundsSqrt(vm.randomInt(), vm.randomInt());
            // This is to circumvent sqrt of negative revert scenario
            if (aMan < 0) {
                aMan *= -1;
            }

            packedFloat a = Float128.toPackedFloat(aMan, aExp);

            startMeasuringGas("Packed - ln");
            Ln.ln(a);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Packed.ln.", min, avg / runs, max);
    }

    /*******************************************************/
    /*********************  HELPERS ************************/
    /*******************************************************/
    function test_gasUsedLog10() public {
        vm.sleep(delay * 25);
        _primer();
        _resetGasUsed();

        for (uint i = 0; i < runs; ++i) {
            uint256 x = vm.randomUint();
            startMeasuringGas("Packed - Sqrt");
            Float128.findNumberOfDigits(x);

            gasUsed = stopMeasuringGas();
            if (gasUsed > max) max = gasUsed;
            if (gasUsed < min) min = gasUsed;
            avg += gasUsed;
        }

        _writeJson(".Helpers.Log10.", min, avg / runs, max);
    }

    function _writeJson(string memory obj, uint256 min, uint256 avg, uint256 max) public {
        vm.writeJson(vm.toString(min), path, string.concat(obj, "min"));
        vm.writeJson(vm.toString(avg), path, string.concat(obj, "avg"));
        vm.writeJson(vm.toString(max), path, string.concat(obj, "max"));
    }

    function setBoundsSqrt(int aMan, int aExp) public pure returns (int _aMan, int _aExp) {
        // numbers with more than 38 digits lose precision
        _aMan = bound(aMan, 0, 99999999999999999999999999999999999999);
        _aExp = bound(aExp, -74, 74);
    }
}
