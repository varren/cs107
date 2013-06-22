#!/usr/bin/env python
 
# Only count a word if it.s all lowercase letters, and assume the favorite word is the
# one with the highest score, where the score of a word is equal to freqlen, where freq is
# the word.s frequency and len is the word.s length. For simplicity, assume all
# punctuation marks are separated from real words by whitespace.
#
import sys
from urllib2 import urlopen 

def isGoodFormatedWord(word):
    return True #need to wright function to filter results

def calculateFavoriteWord(database):
    maxScore = 0
    favoriteWord = ""
    for word, score in database.iteritems():
        if(isGoodFormatedWord(word)):
            newScore = score * len(word)
            if(newScore>maxScore):
                favoriteWord = word
                maxScore = newScore

    return favoriteWord

def processLine(line, database):
    line = line.rstrip("\n")
    words = line.split()
    for word in words:
        if word.islower():
            freq = database.get(word, 0)
            database[word] = freq + 1

def getURLResponse(url):
    response = urlopen(url)
    if response.code != 200: return []
    resultData = response.readlines()
    response.close()
    return resultData
    
def collectURLData(url, database):
    resultData = getURLResponse(url)
    for line in resultData:
        processLine(line, database)
#
# Pulls all of the contents from each of the URLs in the 'urls' list,
# and returns what appears to be the favorite word, where the
# metric for what favorite means is outlined above
#   
def getFavoriteWord(urls):
    wordsCounters = {}
    for url in urls:
        collectURLData(url, wordsCounters)
    return calculateFavoriteWord(wordsCounters)

 
def runPart1():    
    favoriteWord = getFavoriteWord(["http://www.gutenberg.org/files/5200/5200.txt"])
    print "It appears Jane Austen really likes the word \"%s\"." % favoriteWord

runPart1()

