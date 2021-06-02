import numpy as np
import argparse

def checkArgs():
    args = argparse.ArgumentParser(description='Watermark Program')
    args.add_argument("-i", "--din", type=str, dest="din", help="npy file name")
    args.add_argument("-f", "--frac", type=int, dest="frac", help="fraction length of the data")
    return args.parse_args()


def np2hex(din):
    din_int = int(din)
    if din_int < 0:
        din_int = din_int & 0b1111111111111111

    if din_int < 16:
        return "0"+hex(din_int)[-1]
    else:
        return hex(din_int)[-2:]

def main():
    args = checkArgs()
    din = np.load(args.din, "r")
    din_flat = din.flatten() * 2**args.frac
    din_str = np.array(list(map(np2hex, din_flat)))
    np.savetxt("output/"+args.din[:-4]+"_hex.txt", din_str, fmt="%s", delimiter=" ")
    np.savetxt("output/"+args.din[:-4]+"_flat.txt", din_flat, fmt="%.2d", delimiter=" ")


if __name__=="__main__":
    main()

