#!env python3

import argparse
import csv
import re

if __name__ == '__main__':
    PARSER = argparse.ArgumentParser(description="Converts a word into an FST")
    PARSER.add_argument('word', help='a word')
    args = PARSER.parse_args()

    string = args.word
    tokens = []
    temp = ""
    last_char_is_alpha = False
    for char in string:
        if char.isalpha():
            last_char_is_alpha = True
            temp += char
        elif last_char_is_alpha:
            tokens.append(temp)
            tokens.append(char)
            temp = ""
            last_char_is_alpha = False
        else:
            tokens.append(char)

    for i,c in enumerate(tokens):
        print("%d %d %s %s" % (i, i+1, c, c) )
    print(i+1)
