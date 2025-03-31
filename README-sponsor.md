# Float128 Solidity Library

## Overview

This is a signed floating-point library optimized for Solidity.

### General floating-point concepts

a floating point number is a way to represent numbers in an efficient way. It is composed of 3 elements:

- **The mantissa**: the significant digits of the number. It is an integer that is later multiplied by the base elevated to the exponent's power.
- **The base**: generally either 2 or 10. It determines the base of the multiplier factor.
- **The exponent**: the amount of times the base will multiply/divide itself to later be applied to the mantissa.

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

> [!CAUTION]
> This library will only handle numbers with exponents within the range of **-3000** to **3000**. Larger or smaller numbers may result in precision loss and/or overflow/underflow.

#### Library main features

- Base: 10
- Significant digits: 38 or 72
- Exponent range: -8192 and +8191
- Maximum exponent for 38-digit mantissas: -18

Available operations:

- Addition (add)
- Subtraction (sub)
- Multiplication (mul)
- Division (div/divL)
- Square root (sqrt)
- Natural Logarithm (ln)
- Less Than (lt)
- Less Than Or Equal To (le)
- Greater Than (gt)
- Greater Than Or Equal To (ge)
- Equal (eq)

### Error in operations

The library's arithmetic operations' error have been calculated against results from Python's Decimal library. The error appear in the Units of Least Precision (ulp):

| Operation              | Max error (ulps) |
| ---------------------- | ---------------- |
| Addition (add)         | 1                |
| Subtraction (sub)      | 1                |
| Multiplication (mul)   | 0                |
| Division (div/divL)    | 0                |
| Square root (sqrt)     | 0                |
| Natural Logarithm (ln) | 9                |

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

## Usage

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
    ...

    packedFloat E = m.mul(C.mul(C));

```

## Normalization

Normalization is a **vital** step to ensure the highest gas efficiency and precision in this library. Normalization in this context means that the number is always expressed using 38 or 72 significant digits without leading zeros. Never more, and never less. The way to achieve this is by playing with the exponent.

For example, the number 12345.678 will have only one proper representation in this library: 12345678000000000000000000000000000000 x $10^{-33}$

> [!NOTE]
> It is encouraged to store the numbers as floating-point values, and not to convert them to fixed-point numbers or any other conversion that might truncate the significant digits as this will mean nothing less than loss of precision.\_

> [!NOTE]
> Additionally when using constants (i.e. multiplcation or division by 2) it is most efficient from a gas perspective to normalize beforehand.\_

### Representation of zero

Zero is a special case in this library. It is the only number which mantissa is represented by all zeros. Its exponent is the smallest possible which is -8192.

### Gas Profile

To run the gas estimates from the repo use the following command:

```c
forge test --ffi -vv --match-contract GasReport
```

Here are the current Gas Results:

#### Gas Report - functions using packedFloats

| Function (and scenario)                | Min  | Average | Max  |
| -------------------------------------- | ---- | ------- | ---- |
| Addition                               | 596  | 1174    | 1778 |
| Addition (matching exponents)          | 499  | 941     | 1556 |
| Addition (subtraction via addition)    | 609  | 1331    | 1791 |
| Subtraction                            | 577  | 1175    | 1769 |
| Subtraction (matching exponents)       | 491  | 928     | 1567 |
| Subtraction (addition via subtraction) | 604  | 1018    | 1784 |
| Multiplication                         | 295  | 575     | 856  |
| Multiplication (by zero)               | 295  | 576     | 858  |
| Division                               | 296  | 590     | 886  |
| Division (numerator is zero)           | 295  | 577     | 860  |
| Square Root                            | 1247 | 1416    | 1588 |
