import argparse
from decimal import *
from eth_abi import encode
from math import log10


def calculate_float(args):
    getcontext().prec = 150
    max_digits_m = 38
    max_digits_l = 72
    max_exponent = -18
    base = 10
    aMan = Decimal(args.aMan)
    aExp = Decimal(args.aExp)
    bMan = Decimal(args.bMan)
    bExp = Decimal(args.bExp)
    operation = args.operation
    largeResult = args.largeResult > 0
    result_float = 0

    a = Decimal(aMan * (base**aExp))
    b = Decimal(bMan * (base**bExp))

    if(operation == "mul"): 
        result_float = a * b
    elif(operation == "div"):
        result_float = a / b
    elif(operation == "add"):
        result_float = a + b
    elif(operation == "sub"):
        result_float = a - b
    elif(operation == "sqrt"):
        result_float = a.sqrt()
    elif(operation == "le"):
        result_float = 1 if a <= b else 0
    elif(operation == "lt"):
        result_float = 1 if a < b else 0
    elif(operation == "gt"):
        result_float = 1 if a > b else 0
    elif(operation == "ge"):
        result_float = 1 if a >= b else 0
    elif(operation == "ln"):
        result_float = a.ln()

    # print(result_float)
    log_10 = 0 if result_float == 0 else Decimal(abs(result_float)).log10()
    result_digits = int(log_10) + 1
    if (result_digits < 0): result_digits -= 1
    result_exp = Decimal(result_digits - max_digits_m)
    if(result_exp > max_exponent or largeResult):
        result_exp -= max_digits_l - max_digits_m
    result_man = int(result_float*10**(-result_exp))

    return result_man, int(result_exp)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("aMan", type=int)
    parser.add_argument("aExp", type=int)
    parser.add_argument("bMan", type=int)
    parser.add_argument("bExp", type=int)
    parser.add_argument("operation", type=str)
    parser.add_argument("largeResult", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    (result_man, result_exp) = calculate_float(args)
    enc = encode(["(int256,int256)"], [(result_man, result_exp)])
    print("0x" + enc.hex(), end="")


if __name__ == "__main__":
    main()