import sys
originalFile = open(sys.argv[1]).read()
findStr = sys.argv[2]
replaceWithFile = open(sys.argv[3]).read()
before = '' if len(sys.argv) < 5 else sys.argv[4]
after = '' if len(sys.argv) < 6 else sys.argv[5]
print(originalFile.replace(findStr, before + replaceWithFile + after))
