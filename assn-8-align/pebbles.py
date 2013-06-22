#!/usr/bin/env python
#
# Handout part 2 code.  
#

# input board is formated 
#   [[1  2  3  4  5 ] 
#    [6  7  8  9  10]
#    [11 12 13 14 15]
#    [16 17 18 19 20]]
import sys
import copy
import datetime  

def printPermissions(perm, leng):
    result =""
    for i in xrange(0, len(perm)):
        if i%leng ==0:
            result+= "\n"
        if perm[i]:
            result+= " T"
        else:
            result+= " F"
    print result

# i just checked solution, and discovered really cool way to think about solving this problem...
# the idea of having only 1 row of permissions was really g8.
# was trying to do it with 1 more matrix of permissions 
# coz it gives us the solution and not only score if needed but  it is less efficient
# so i made both  


#
# My Solution
#
def myCalculateBestSolution(board):
    cache ={}
    permissions = map(lambda x: True, range(0, len(board[0])**2))
    return myRecurseCalcBestSolution(board, 0, 0, permissions, cache)

def markCells(permissions, row, col, length):
    currCell = row * length + col    
    if col < length - 1:  permissions[currCell + 1] = False #right
    if row < length - 1:    
        permissions[currCell + length] = False # downDown
        if col < length - 1: permissions[currCell + length + 1] = False #downRight
        if col > 0:          permissions[currCell + length - 1] = False #downLeft

def generateKey(row, col, permissions, length):
    return str(row)+ str(col) + str(permissions[row*length + col:(row+1)*length + col+1])
    
def myRecurseCalcBestSolution(board, row, col, permissions, cache):
    if col == len (board[0]): 
        row +=1 
        col = 0
        
    if row == len (board): return 0
    
    key = generateKey(row, col, permissions, len(board)) 
    if(cache.has_key(key)): return cache[key]
    
    newPermissions = copy.copy(permissions)
    bestSolution = skipedSolution = myRecurseCalcBestSolution(board, row, col + 1, newPermissions, cache)
    
    if permissions[row * len(board) + col]:
        markCells(newPermissions, row, col, len(board))    
        selectedSolution = board[row][col] + myRecurseCalcBestSolution(board, row, col+1, newPermissions, cache)
        if selectedSolution > skipedSolution:
            bestSolution = selectedSolution
            
    cache[key] = bestSolution
    return bestSolution


#
# My Second Solution
#

def my2CalculateBestSolution(board):
    cache ={}
    permissions = map(lambda x: True, range(0, len(board[0])**2))
    return my2RecurseCalcBestSolution(board, 0, 0, permissions, cache)

def my2RecurseCalcBestSolution(board, row, col, permissions, cache):
    if col == len (board[0]): 
        row +=1 
        col = 0
        
    if row == len (board): return 0
    
    key = generateKey(row, col, permissions, len(board)) 
    if(cache.has_key(key)): return cache[key]
    
    bestSolution = skipedSolution = my2RecurseCalcBestSolution(board, row, col + 1, permissions, cache)
    
    length = len(board)
    currCell = row * length + col    
        
    if permissions[currCell]:

        if col < length - 1: side = permissions[currCell + 1] #rightSide
        if row < length - 1:    
            down = permissions[currCell + length]  # downDown
            if col < length - 1: right = permissions[currCell + length + 1] #downRight
            if col > 0:          left = permissions[currCell + length - 1]  #downLeft

        if col < length - 1:  permissions[currCell + 1] = False #rightSide
        if row < length - 1:    
            permissions[currCell + length] = False # downDown
            if col < length - 1: permissions[currCell + length + 1] = False #downRight
            if col > 0:          permissions[currCell + length - 1] = False #downLeft

        selectedSolution = board[row][col] + my2RecurseCalcBestSolution(board, row, col+1, permissions, cache)

        if col < length - 1: permissions[currCell + 1] = side
        if row < length - 1:    
            permissions[currCell + length] = down
            if col < length - 1: permissions[currCell + length + 1] = right
            if col > 0:          permissions[currCell + length - 1] = left

        
        if selectedSolution > skipedSolution:
            bestSolution = selectedSolution
            
    cache[key] = bestSolution
    return bestSolution

#
# Handout Solution-stile example
#

def calculateBestSolution(board):
    cache ={}
    permissions = map(lambda x: True, range(0, len(board[0]) + 1))
    return recurseCalcBestSolution(board, 0, 0, permissions, cache)


def recurseCalcBestSolution(board, row, col, permissions, cache):
    if col == len (board[0]):
        row +=1
        col = 0
    if row == len (board):
        return 0
    
    key = str(row) + "|" + str(col) + "|" + str(permissions)
    if(cache.has_key(key)):
        return cache[key]
    
    newPermissions = copy.copy(permissions)
    newPermissions.pop(0)
    newPermissions.append(True)
    
    bestSolution = withoutCurrentValue = recurseCalcBestSolution(board, row, col + 1, newPermissions, cache)
    
    if permissions[0]:
        
        newPermissions[-2] = False #down down
        if col > 0 : 
            newPermissions[-3] = False # down left
        if col < len(board) - 1: 
            newPermissions[ 0] = False # right
            newPermissions[-1] = False # down right
        
        withCurrentValue = board[row][col] + recurseCalcBestSolution(board, row, col + 1, newPermissions, cache)
        
        if withCurrentValue > withoutCurrentValue:
            bestSolution = withCurrentValue
            
    cache[key] = bestSolution
    return bestSolution

#
# just validating input
#

def isWellFormated(boards):
    for board in boards:
        length = len(board[0])
        if length != len(board):
            return False
        for row in board:
            if length != len(row):
                return False
    return True
        
def createBoards(lines):
    boards = []
    boards.append([])
    
    for line in lines:
        line = line.rstrip("\n")
        if (line == "" and boards[-1]): 
            boards.append([])
        if line !="": 
            try:
                boards[-1].append(map (int, line.split(" ")))
            except ValueError:
                print 'Invalid integer in string: ' + line


    if not boards[-1]:
        boards.pop()

    return boards
                
def printBoards(boards):
    result =""
    for board in boards: 
        result+= "\n Board"
        for row in board: 
            result+= " Row\n "
            for pos in row:
                result+= str(pos) + " "
    print result

def askForInputBoards():

    while True:
        print "Enter boards input data:"
        inputText = sys.stdin 
        lines = inputText.readlines()
        boards = createBoards(lines)
        if isWellFormated(boards):
            return boards
        else: 
            printBoards(boards)
            print "wrong input format"


# less is better
# Time Stanford solution: 830207
# Time my 2-nd solution : 522084
# Time my 1-st solution : 998629
#
def printResults(boards, fn):
    result = ""
    a = datetime.datetime.now()
       
    for board in boards:
        result +="\n"+ str(fn(board))

    b = datetime.datetime.now()

    c = b - a 
    print "Time: " + str(c.microseconds)
    print result
def runPart2():
  
    boards = askForInputBoards()

    printResults(boards, calculateBestSolution)
    printResults(boards, my2CalculateBestSolution)
    
    printResults(boards, myCalculateBestSolution)

runPart2()
