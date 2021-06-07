#!/usr/bin/python3
# Generate test file from MNIST dataset

import sys
import numpy as np
from random import randint

from tensorflow.keras.datasets import mnist


def print_digit(data, write_func=sys.stdout.write):
    for line in data:
        for p in line:
            write_func(f"{p:>08b}")
        write_func("\n")


def main():
    num_tests = 10
    if len(sys.argv) > 1:
        num_tests = int(sys.argv[1])

    (train_images, train_labels), (test_images, test_labels) = mnist.load_data()

    f = open("testdata.txt", "w")
    write_func = f.write
    #write_func = sys.stdout.write

    write_func(f"{num_tests}\n")
    for i in np.random.randint(0, len(test_labels), num_tests):
        write_func(f"{test_labels[i]}\n")
        print_digit(test_images[i], write_func)

    f.close()


if __name__ == "__main__":
    main()
