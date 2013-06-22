#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <search.h>
/*
typedef struct {
  int elemSize;
  int allocSpace;
  int realSize;
  void* dataP;
  void (*VectorFreeFunction)(void *elemAddr);
  // to be filled in by you
} vector;
*//*
int VectorIsNull(const vector*v)
{
  if(
     v->dataP == NULL &&
     v->elemSize == 0&&
     v->freeFn == NULL&&
     v->allocSpace == 0 &&
     v->realSize == 0
     )
    return 1;
  return 0;
  }*/
void VectorNew(vector *v, int elemSize, VectorFreeFunction freeFn, int initialAllocation)
{
  
  assert(elemSize > 0);
   
  v->dataP = malloc(elemSize* initialAllocation);
  assert(v->dataP!=NULL);
  v->elemSize = elemSize;
  v->freeFn = freeFn;
  v->allocSpace = initialAllocation;
  v->realSize = 0;
}

void VectorDispose(vector *v)
{
  assert (v!=NULL);
  if(v->realSize>0 && v->freeFn!=NULL){
    for(int i=0; i< v->realSize;i++){
      void* currentElem = (char*)v->dataP+i*v->elemSize;
      v->freeFn(currentElem);
    }
  }
  free(v->dataP);
}

int VectorLength(const vector *v)
{ 
  assert (v!=NULL);
  return v-> realSize; 
}

void *VectorNth(const vector *v, int position)
{
  assert (v!=NULL);
  assert(position <v->realSize);
  assert(position>=0);
  return (char*)v->dataP+position*v->elemSize; 
}

void VectorReplace(vector *v, const void *elemAddr, int position)
{
  assert (v!=NULL);
  assert(position < v->realSize);
  assert(position >= 0);
  void* positionP = ((char*)v->dataP+position*v->elemSize);  
  if(v->freeFn!=NULL)
    v->freeFn(positionP);
  memcpy(positionP, elemAddr, v->elemSize); 
}

void VectorInsert(vector *v, const void *elemAddr, int position)
{
  assert (v!=NULL);
  assert(position >= 0);
  assert(position <= v->realSize);
  if (v->allocSpace == v->realSize){
    if(v->allocSpace == 0)
      v->allocSpace = 1;
    else
      v->allocSpace*= 2;
  
    v->dataP = realloc(v->dataP, v->allocSpace*v->elemSize);
    assert(v->dataP!=NULL);
  }

  char* insertPosition = (char*)v->dataP + position * v->elemSize;
 
  if(position!=v->realSize){
    char* destination = insertPosition + v->elemSize;
    char* end = (char*)v->dataP + v->realSize*v->elemSize;
    int numOfBytes = end - insertPosition;
    memmove(destination, insertPosition, numOfBytes);
  }
    
  memcpy(insertPosition, elemAddr, v->elemSize); 
 
  v->realSize++;

}

void VectorAppend(vector *v, const void *elemAddr)
{
  assert (v!=NULL);
  VectorInsert(v,elemAddr,v->realSize);
}

void VectorDelete(vector *v, int position)
{ 
  assert (v!=NULL);
  assert(position>=0);
  assert(position<v->realSize);

  void* positionP = (char*)v->dataP+position*v->elemSize;
 
  if(v->freeFn!=NULL)
    v->freeFn(positionP);
  
  void *source = (char*)positionP+v->elemSize;
  int numOfBytes = (v->realSize-1 - position)*v->elemSize;
  memmove(positionP,source,  numOfBytes);
  
  v->realSize--;  
}

void VectorSort(vector *v, VectorCompareFunction compare)
{
  assert(compare!= NULL);
  assert (v!=NULL);
  qsort(v->dataP, v->realSize, v->elemSize, compare);
}

void VectorMap(vector *v, VectorMapFunction mapFn, void *auxData)
{
  assert(mapFn!=NULL);
  assert (v!=NULL);
    for(int i=0;i<v->realSize;i++)
      mapFn((char*)v->dataP+i*v->elemSize, auxData);
}

static const int kNotFound = -1;
int VectorSearch(const vector *v, const void *key, VectorCompareFunction searchFn, int startIndex, bool isSorted)
{ 
  assert (v!=NULL);
  if(v->realSize == 0)
    return kNotFound;

  assert (searchFn!=NULL);
  assert (startIndex < v->realSize);
  assert (key !=NULL);
  assert (startIndex >=0);


  void * start =  (char*)v->dataP+startIndex*v->elemSize;
  size_t size = v->realSize-startIndex;
  char* position;
  
  if(isSorted==true)
    position =  bsearch(key,start,size,v->elemSize, searchFn);
  else
    position = lfind(key, start, &size,v->elemSize, searchFn);
    
  if(position !=NULL)
    return(position - (char*)v->dataP)/v->elemSize;
   
  return kNotFound;

} 
