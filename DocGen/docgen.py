# pip3 install sphinx furo myst-parser
# Theme is https://pradyunsg.me/furo/quickstart/ 
# https://myst-parser.readthedocs.io/en/v0.13.3/using/syntax.html

import os
import glob
import re
import subprocess

SRC_DIR = '../Source/script/imports/'
BUILD_DIR = 'source/api/' 

# between that handles nested comments, regex did not handle this!
def between(str, start, stop):
  result = []
  init = 0
  while True:
    first = str.find(start, init)
    if first == -1: break

    first += len(start)
    last = str.find(stop, first)

    if last == -1: break

    nested_start = str.find(start, first)
    while nested_start != -1 and nested_start < last:
      last = str.find(stop, last + 1)
      if last == -1: break
      nested_start = str.find(start, nested_start + len(start))
    
    result.append(str[first:last])
    init = last + len(stop)
  return result


# remove old build files, all but index
for file in glob.glob(f"{BUILD_DIR}*.md"):
  os.remove(file)

# extract all comments
comments = []
for source in glob.glob(f"{SRC_DIR}*.pas"):
  with open(source, 'r') as f:
    comments.extend(between(f.read(), '(*', '*)'))


# write comments, changing the file when a header is found
# header being a === line rather than ---
currentfile = None
for comment in comments:
  comment = comment.strip()
  lines   = comment.splitlines();
  
  if (len(lines[1]) > 0) and (lines[1][0] == '='):
    if currentfile:
      currentfile.close()
    currentfile = open(f"{BUILD_DIR}/{lines[0]}.md", 'a')
    currentfile.write(comment)  
  else:
    currentfile.write('\n\n' + '-----' + '\n\n' + comment) 

if currentfile:
  currentfile.close()

# build it
subprocess.run(["sphinx-build", "-q", "-E", "source", "build"])

# smaller text looks better for api declarations
for source in glob.glob("build/api/*.html"):
  with open(source, 'r', encoding='utf-8') as f:
    contents = f.read().replace("h2", "h3")
  with open(source, 'w', encoding='utf-8') as f:
    f.write(contents)
