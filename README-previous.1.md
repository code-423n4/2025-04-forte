# Forte audit details
- Total Prize Pool: $40,000 in USDC
  - HM awards: up to $32,600 in USDC 
    - If no valid Highs or Mediums are found, the HM pool is $0 
  - QA awards: $1,400 in USDC
  - Judge awards: $3,300 in USDC
  - Validator awards: $2,200 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts April 1, 2025 20:00 UTC
- Ends April 11, 2025 20:00 UTC

**Note re: risk level upgrades/downgrades**

Two important notes about judging phase risk adjustments: 
- High- or Medium-risk submissions downgraded to Low-risk (QA) will be ineligible for awards.
- Upgrading a Low-risk finding from a QA report to a Medium- or High-risk finding is not supported.

As such, wardens are encouraged to select the appropriate risk level carefully during the submission phase.

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2025-03-thrackle/blob/main/4naly3er-report.md).

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

### Exponent Limitations

Floating number representations with exponents greater than `3000` or less than `-3000` are not within acceptable bounds for this library. Failure to abide by this limitation may result in precision loss and/or arithmetic overflows/underflows.

### Acceptable Errors in Operations

The library's arithmetic operations' errors have been calculated against results from Python's Decimal library. The errors are defined in Units of Least Precision (ULP):

| Operation              | Max Error (ULP) |
| ---------------------- | ---------------- |
| Addition (add)         | 1                |
| Subtraction (sub)      | 1                |
| Multiplication (mul)   | 0                |
| Division (div/divL)    | 0                |
| Square root (sqrt)     | 0                |
| Natural Logarithm (ln) | 40                |

# Overview

## Float128 Solidity Library

This is a signed floating-point library optimized for Solidity.

### General Floating-Point Concepts

A floating point number is a way to represent numbers in an efficient way. It is composed of 3 elements:

- **Mantissa**: The significant digits of the number. It is an integer that is later multiplied by the base elevated to the exponent's power.
- **Base**: Generally either 2 or 10. It determines the base of the multiplier factor.
- **Exponent**: The amount of times the base will multiply/divide itself to later be applied to the mantissa.

Some examples:

- -0.0001 can be expressed as -1 x $10^{-4}$.

  - Mantissa: -1
  - Base: 10
  - Exponent: -4

- 2222000000000000 can be expressed as 2222 x $10^{12}$.
  - Mantissa: 2222
  - Base: 10
  - Exponent: 12

Floating point numbers can represent the same number in infinite ways by playing with the exponent. For instance, the first example could be also represented by -10 x $10^{-5}$, -100 x $10^{-6}$, -1000 x $10^{-7}$, etc.

#### Library main features

- Base: 10
- Significant digits: 38 or 72
- Exponent range: -8192 and +8191
- Maximum exponent for 38-digit mantissas: -18

#### Available operations

- Addition (`add`)
- Subtraction (`sub`)
- Multiplication (`mul`)
- Division (`div`/`divL`)
- Square root (`sqrt`)
- Natural Logarithm (`ln`)
- Less Than (`lt`)
- Less Than Or Equal To (`le`)
- Greater Than (`gt`)
- Greater Than Or Equal To (`ge`)
- Equal (`eq`)

### Types

#### packedFloat:

This type uses a `uint256` under the hood:

```Solidity
type packedFloat is uint256;
```

##### Bitmap:

| Bit range | Reserved for    |
| --------- | --------------- |
| 255 - 242 | EXPONENT        |
| 241       | L_MANTISSA_FLAG |
| 240       | MANTISSA_SIGN   |
| 239 - 0   | L_MANTISSA      |
| 128 - 0   | M_MANTISSA      |

#### Mantissa sizes:

The packedFloat can handle 2 different lengths of mantissas:

- **Medium-size mantissas (38 digits)**: This is the more gas efficient representation of a floating-point number when it comes to arithmetic since all the operations, including results, will fit inside a 256-bit word. This representation, however, offers a limited storage for the number which might not be enough for ocasions where very high precision is required.

- **Large-size mantissas (72 digits)**: This is the more precise representation of a floatint-point number since it can store 72 significand digits of information. The trade-off is higher gas consumption as its arithmetic will require 512-bit multiplication and division which can be expensive operations.

#### Maximum exponent and mantissa-size autoscaling

The library counts with a `MAXIMUM_EXPONENT` constant to keep a minimum amount of decimals of precision before it autoscales to a large mantissa. This is done to guarantee a minimum precision level among operations.

For example, if the result of an arithmetic operation results in a number big enough to have its exponent bigger than `MAXIMUM_EXPONENT`, then the result will be given in a large-mantissa format to make sure that we can store enough information about the resulting number with at least our minimum amount of decimals of precision. This also works the other way around where operations between large-mantissa numbers result in a value that has its exponent small enough to be stored as a medium-size mantissa number.

In other words, the library down scales the size of the mantissa to make sure it is as gas efficient as possible, but it up scales to make sure it keeps a minimum level of precision. The library prioritizes precision over gas efficiency.

#### Conversion methods:

The library offers 2 functions for conversions. One to go from signed integer to _packedFloat_ and another one to go the other way around:

```Solidity
function toPackedFloat(int mantissa, int exponent) internal pure returns (packedFloat float);

function decode(packedFloat float) internal pure returns (int mantissa, int exponent);
```

### Usage

Imagine you need to express a fractional number in Solidity such as 12345.678. The way to achieve that is:

```Solidity
import "lib/Float128.sol"

contract Mathing{
    using Float128 for int256;

    ...

    int mantissa = 12345678;
    int exponent = -3;
    packedFloat n = mantissa.toPackedFloat(exponent);

    ...

}
```

Once you have your floating-point numbers in the correct format, you can start using them to carry out calculations:

```Solidity
packedFloat E = m.mul(C.mul(C));
```

### Normalization

Normalization is a **vital** step to ensure the highest gas efficiency and precision in this library. Normalization in this context means that the number is always expressed using 38 or 72 significant digits without leading zeros. Never more, and never less. The way to achieve this is by playing with the exponent.

For example, the number 12345.678 will have only one proper representation in this library: 12345678000000000000000000000000000000 x $10^{-33}$

> [!NOTE] 
> It is encouraged to store the numbers as floating-point values, and not to convert them to fixed-point numbers or any other conversion that might truncate the significant digits as this will mean nothing less than loss of precision.

> [!NOTE]
> Additionally when using constants (i.e. multiplcation or division by 2) it is most efficient from a gas perspective to normalize beforehand.

#### Representation of zero

Zero is a special case in this library. It is the only number which mantissa is represented by all zeros. Its exponent is the smallest possible which is `-8192`.

## Links

- **Previous audits:** N/A 
- **Documentation:** https://github.com/thrackle-io/float128/blob/main/docs/float128.pdf
- **Website:** https://www.forte.io/
- **X/Twitter:** https://x.com/forteplatform

---

# Scope

### Files in scope

| Contract | nSLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| [src/Float128.sol](https://github.com/code-423n4/2025-03-forte/blob/main/src/Float128.sol) | 1016 | Main operation implementations | [lib/Uint512.sol](https://github.com/code-423n4/2025-03-forte/blob/main/lib/Uint512.sol) (Out-of-Scope) |
| [src/Ln.sol](https://github.com/code-423n4/2025-03-forte/blob/main/src/Ln.sol) | 512 | Implementation of natural logarithm | [src/Float128.sol](https://github.com/code-423n4/2025-03-forte/blob/main/src/Float128.sol)  |
| [src/Types.sol](https://github.com/code-423n4/2025-03-forte/blob/main/src/Types.sol) | 2 | Declares user-defined `packedFloat` type | N/A  |
| **Total nSLOC** | **1530** | | |

### Files out of scope

| File / Path |  
| ----------- |
| [lib/Uint512.sol](https://github.com/code-423n4/2025-03-forte/blob/main/lib/Uint512.sol) |
| [test/\*\*.\*\*](https://github.com/code-423n4/2025-03-forte/tree/main/test) |

## Scoping Q &amp; A

### General questions

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       None             |
| Test coverage                           | 96.19% (% Lines), 96.46% (% Statements)                          |
| ERC721 used  by the protocol            |            None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Any EVM Chain w/ Support of Utilized Opcodes  |

### ERC20 token behaviors in scope

Not Applicable.

### External integrations (e.g., Uniswap) behavior in scope:


Not Applicable.

### EIP compliance checklist

Not Applicable.

# Additional context

## Main invariants

No state is maintained by the library.

## Attack ideas (where to focus for bugs)

Edge cases and bounds testing within the acceptable bounds of the library.

Adherence of implementations to their technical description within the research paper.

Breach of acceptable tolerances within acceptable bounds of the library.

## All trusted roles in the protocol

Not Applicable.

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

The library implements a utility library meant to support floating-point number representations in Solidity via a 256-bit bitmap with support for two complex arithmetic models; evaluation of the square root and evaluation of the natural logarithm of a floating-point number w/ a mantissa.

The mathematical models employed for those two operations are described within the documentational PDF of the contest as well as via in-line documentation.

## Running Tests

Ensure you have installed `python` and `foundry`. Run the following:

```bash 
git clone https://github.com/code-423n4/2025-03-forte
cd 2025-03-forte
virtualenv venv 
source venv/bin/activate
pip install -r requirements.txt
```

To run tests:

```bash 
forge test --ffi
```

## Running Coverage

To run code coverage:

```bash 
forge coverage --ffi --no-match-coverage test
```

### Coverage Report


| File             | % Lines          | % Statements     | % Branches       | % Funcs        |
| ---------------- | ---------------- | ---------------- | ---------------- | -------------- |
| src/Float128.sol | 95.08% (638/671) | 94.99% (607/639) | 87.70% (164/187) | 93.33% (14/15) |
| src/Ln.sol       | 98.90% (270/273) | 99.66% (293/294) | 100.00% (53/53)  | 57.14% (4/7)   |
| Total            | 96.19% (908/944) | 96.46% (900/933) | 90.42% (217/240) | 81.82% (18/22) |


## Running Gas Benchmarks

To run gas benchmarks:

```bash
forge test --ffi --match-contract GasReport
```

### Gas Report - Functions Using `packedFloats`

The list below is meant to be indicative and results may vary depending on compiler configurations as well as fuzz test seeds; these values are not expected to be 100% accurate.

| Function (and scenario)                | Min  | Average (Mean) | Max  |
| -------------------------------------- | ---- | ------- | ---- |
| Addition                               | 881  | 1237    | 1528 |
| Addition (matching exponents)          | 739  | 1052     | 1457 |
| Addition (subtraction via addition)    | 1354  | 1472    | 1528 |
| Subtraction                            | 878  | 1230    | 1526 |
| Subtraction (matching exponents)       | 736  | 1028     | 1392 |
| Subtraction (addition via subtraction) | 878  | 962    | 994 |
| Multiplication                         | 550  | 957     | 1124  |
| Multiplication (by zero)               | 171  | 171     | 171  |
| Division                               | 585  | 1125     | 1238  |
| Division (numerator is zero)           | 189  | 189     | 189  |
| Division Large                         | 1149 | 1194    | 1239 |
| Division Large (numerator is zero)     | 190  | 190     | 190  |
| Square Root                            | 1320 | 2178    | 3108 |

## Miscellaneous

Employees of Forte and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
