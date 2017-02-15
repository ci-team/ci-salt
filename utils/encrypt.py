#!/usr/bin/env python

import subprocess
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--dir",
                    default="/etc/salt/gpgkeys",
                    help="path to gpgkeys directory")
parser.add_argument("--oneline",
                    action='store_true',
                    help="switch to oneline output")
parser.add_argument("-f", "--filename",
                    help="input file. If not specified, data will be read from cli.")

args = parser.parse_args()

if args.filename:
    with open(args.filename) as f:
        data = f.read()
else:
    data = raw_input()


if not os.path.isdir(args.dir):
    print "homedir %s does not exist" % args.dir
    exit(1)

secret, stderr = subprocess.Popen(
    ['gpg',
     '--armor',
     '--batch',
     '--homedir', args.dir,
     '--trust-model', 'always',
     '--encrypt',
     '--default-recipient-self',
    ],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE).communicate(input=data)

if not secret:
    raise ValueError('No ciphertext found: {0}'.format(stderr))

if args.oneline:
    secret = secret.replace('\n', r'\n')

print secret
