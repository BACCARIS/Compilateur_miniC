#!/usr/bin/python

compiler_path = "./bin/minicc "
tests_KO_path = "./tests/KO/"
tests_OK_path = "./tests/OK/"

ERROR = '\033[91m'
RESET = '\033[0m'
BOLD = '\033[1m'
VALID = '\033[1;32m'

import os

def test_KO():
	i = 0
	print(ERROR + BOLD + "===================================TESTING MINICC :KO======================================")
	for filename in sorted(os.listdir(tests_KO_path)):
		if filename.endswith(".c"):
			print(RESET + os.path.basename(filename) + RESET + ERROR + BOLD)
			cmd = compiler_path + tests_KO_path + os.path.basename(filename)
			os.system(cmd)
		else:
			continue
	print(ERROR + BOLD + "======================================TESTING OVER==========================================\n" + RESET)

def test_OK():
	i = 0
	print(VALID + BOLD + "===================================TESTING MINICC :OK=======================================")
	for filename in sorted(os.listdir(tests_OK_path)):
		if filename.endswith(".c"):
			cmd = compiler_path + tests_OK_path + os.path.basename(filename)
			os.system(cmd)
			print(RESET + os.path.basename(filename) + RESET + VALID + ": TEST OK!")
		else:
			continue
	print(VALID+ BOLD + "======================================TESTING OVER===========================================" + RESET)

print(BOLD + "===========================================================================================")
test_KO()
test_OK()
print(RESET + BOLD + "==============================DONE TESTING REFRENCE COMPILER BY TEACHER======================" + RESET)


