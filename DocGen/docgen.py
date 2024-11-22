# pip3 install sphinx furo myst-parser
# Theme is https://pradyunsg.me/furo/quickstart/ 

import os
import glob
import re
import subprocess

SRC_DIR = '../Source/script/imports/'
BUILD_DIR = 'source/api/' 

# remove old build files, all but index
for file in glob.glob(f"{BUILD_DIR}*.md"):
  os.remove(file)

# extract all comments
comments = []
for source in glob.glob(f"{SRC_DIR}*.pas"):
  with open(source, 'r') as f:
    comments.extend(re.findall(r'\(\*(.*?)\*\)', f.read(), re.DOTALL))
   
# write comments, changing the file when a header is found
# header being a === line rather than ---
currentfile = None
for comment in comments:
  comment = comment.strip()
  if (comment.splitlines()[1][0] == '='):
    if currentfile:
      currentfile.close()
    currentfile = open(f"{BUILD_DIR}/{comment.splitlines()[0]}.md", 'a')
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