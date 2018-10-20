#!/usr/bin/env python3
# Generate a README.md based on the current file structure
# Usage: `python3 generate-readme.py > README.md`

import os

print("""
# #!book

A FOSS hacker's guide to CLI, privacy, security, self-hosting, and the Internet

## Table of Contents
""")

for root, dirs, files in os.walk("."):
    if ".git" in root or root == ".":
        continue

    slash_count = root.count("/") + 2  # don't override page header

    print("#" * slash_count, "[{}]({}/)".format(root.partition("/")[2], root))

    for filename in sorted(files):
        path = os.path.join(root, filename)
        display_path = path.partition("/")[2].partition(".")[0]
        print("#" * (slash_count + 1), "[{}]({})".format(display_path, path))
