#!/usr/bin/env python

import random # for seed, random
import sys    # for stdout

def changeAlignment(DNA1, DNA2, score):
	return {'strand1':DNA1,'strand2':DNA2, 'score':score }

# Computes the score of the optimal alignment of two DNA strands.
def findOptimalAlignment(alignment, calculatedDNA):
	
	DNA1 = alignment['strand1']
	DNA2 = alignment['strand2']
	score = alignment['score']
	DNAkey = DNA1 + "|"+ DNA2 

	if DNAkey in calculatedDNA: return calculatedDNA[DNAkey]
	
	# if one of the two strands is empty, then there is only
	# one possible alignment, and of course it's optimal
	
	if len(DNA1) == 0: return changeAlignment(len(DNA2) * ' ', DNA2, len(DNA2) * -2)
	if len(DNA2) == 0: return changeAlignment(DNA1, len(DNA1) * ' ', len(DNA1) * -2)

	# There's the scenario where the two leading bases of
	# each strand are forced to align, regardless of whether or not
	# they actually match.
	
	bestAlignment = findOptimalAlignment(changeAlignment(DNA1[1:], DNA2[1:],  score), calculatedDNA)
	resultDNA1 = DNA1[0] + bestAlignment['strand1']
	resultDNA2 = DNA2[0] + bestAlignment['strand2']
	resultScore = bestAlignment['score'] + 1
	
	if DNA1[0] == DNA2[0]: # no benefit from making other recursive calls
		calculatedDNA[DNAkey] = changeAlignment(resultDNA1, resultDNA2, resultScore)
		return calculatedDNA[DNAkey]

	resultScore = bestAlignment['score'] - 1
		
	# It's possible that the leading base of strand1 best
	# matches not the leading base of strand2, but the one after it.
 
	bestAlignment = findOptimalAlignment(changeAlignment(DNA1, DNA2[1:], score), calculatedDNA)
	bestScore = bestAlignment['score'] -2  # penalize for insertion of space
	if resultScore < bestScore:
		resultDNA1 = " "     + bestAlignment['strand1']
		resultDNA2 = DNA2[0] + bestAlignment['strand2']
		resultScore = bestScore
		
	# opposite scenario

	bestAlignment = findOptimalAlignment(changeAlignment(DNA1[1:], DNA2, score), calculatedDNA)
	bestScore = bestAlignment['score'] - 2 # penalize for insertion of space	
	if resultScore < bestScore:
		resultDNA1 = DNA1[0] + bestAlignment['strand1']
		resultDNA2 = " "     + bestAlignment['strand2']
		resultScore = bestScore
	

	calculatedDNA[DNAkey] = changeAlignment(resultDNA1, resultDNA2, resultScore)
	return calculatedDNA[DNAkey]
		

# Utility function that generates a random DNA string of
# a random length drawn from the range [minlength, maxlength]
def generateRandomDNAStrand(minlength, maxlength):
	assert minlength > 0, \
	       "Minimum length passed to generateRandomDNAStrand" \
	       "must be a positive number" # these \'s allow mult-line statements
	assert maxlength >= minlength, \
	       "Maximum length passed to generateRandomDNAStrand must be at " \
	       "as large as the specified minimum length"
	strand = ""
	length = random.choice(xrange(minlength, maxlength + 1))
	bases = ['A', 'T', 'G', 'C']
	for i in xrange(0, length):
		strand += random.choice(bases)
	return strand

# Method that just prints out the supplied alignment score.
# This is more of a placeholder for what will ultimately
# print out not only the score but the alignment as well.

def printAlignment(alignment, out = sys.stdout):
	DNA1 = alignment['strand1']
	DNA2 = alignment['strand2']
	resultPlusString = ""
	resultMinusString = ""
	
	for i in range(0, len(DNA1)):#doesn't matter wich one len(DNA1) = len(DNA2)
		if DNA1[i]==DNA2[i]:
			resultPlusString += "1"
			resultMinusString += " "
		elif DNA1[i]== " " or DNA2[i] == " ":
			resultPlusString += " "
			resultMinusString += "2"
		else: 
			resultPlusString += " "
			resultMinusString += "1"

	
	out.write("Optimal alignment score is " + str(alignment['score']) + "\n\n" +
		  "   -  " + resultMinusString + "\n" + 
		  "      " + DNA1 + "\n" + 
		  "      " + DNA2 + "\n" +
		  "   +  " + resultPlusString + "\n\n")

# Unit test main in place to do little more than
# exercise the above algorithm.  As written, it
# generates two fairly short DNA strands and
# determines the optimal alignment score.
#
# As you change the implementation of findOptimalAlignment
# to use memoization, you should change the 8s to 40s and
# the 10s to 60s and still see everything execute very
# quickly.
 
def main():
	while (True):
		sys.stdout.write("Generate random DNA strands? ")
		answer = sys.stdin.readline()
		if answer == "no\n": break
		strand1 = generateRandomDNAStrand(60, 60)
		strand2 = generateRandomDNAStrand(60, 60)
		sys.stdout.write("Aligning these two strands: " + strand1 + "\n")
		sys.stdout.write("                            " + strand2 + "\n")
		alignment = findOptimalAlignment({'strand1':strand1,'strand2':strand2, 'score':0 }, {})
		printAlignment(alignment)
		
if __name__ == "__main__":
  main()
