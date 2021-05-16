#!/usr/local/bin/python3.9

import secrets
import string
import sys


__PASSW_LEN = 8
__ALPHABET = '#%+23456789?@ABCEFGHJKLMNPRSTUVWXYZabcdefghjkmnpqrstuvwxyz'


class User:
    def __init__(self, row):
        items = row.split(',')
        self.first_name = items[0]
        self.last_name = items[1]
        self.klas = items[2]
        self.email = items[3]

    def __str__(self):
        return "%s,%s,%s,%s,%s" % (self.first_name, self.last_name, self.username, self.password, self.email)

def genUsername(u):
    u.username = u.email


def genPassword(u):
    u.password = ''.join(secrets.choice(__ALPHABET) for i in range(__PASSW_LEN))


def main():
    with open(sys.argv[1]) as inp:
        for line in inp:
            user = User(line[:-1])
            genUsername(user)
            genPassword(user)
            print(user)


if __name__ == '__main__':
    main()
