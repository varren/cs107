#include "hashset.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/*

typedef struct {
  int length;
  void*data;
  int numBuckets;
  HashSetCompareFunction compareFn;
  HashSetHashFunction hashFn;
} hashset;

*/



void HashSetNew(hashset *h, int elemSize, int numBuckets,
		HashSetHashFunction hashfn, HashSetCompareFunction comparefn, HashSetFreeFunction freefn)
{
  assert (elemSize>0);
  assert (numBuckets>0);
  assert (hashfn != NULL);
  assert (comparefn!=NULL);
 
  h->compareFn = comparefn;
  h->length = 0;
  h->hashFn = hashfn;
  //h->freeFn = freefn;
  //h->elemSize = elemSize;
  h->data = malloc(numBuckets*sizeof(vector));
  
  assert(h->data!=NULL);
  h->numBuckets = numBuckets;
  
  
  for(int i=0; i<numBuckets;i++)
    VectorNew(&h->data[i],elemSize,freefn, 0);
     
}

void HashSetDispose(hashset *h)
{
  for(int bucket =0; bucket<h->numBuckets;bucket++)
    //if(VectorIsNull(&h->data[bucket])!=1)
    VectorDispose(&h->data[bucket]);
  free(h->data); 
}

int HashSetCount(const hashset *h)
{ return  h->length; }

void HashSetMap(hashset *h, HashSetMapFunction mapfn, void *auxData)
{
  assert(mapfn!=NULL);
  for(int bucket=0; bucket< h->numBuckets;bucket++)
    //if(VectorIsNull(&h->data[bucket])!=1)
    VectorMap(&h->data[bucket] ,mapfn, auxData);
}

int findElemBucket(const hashset *h, const void *elemAddr ){

  assert(elemAddr !=NULL);
  int bucket = h->hashFn(elemAddr, h->numBuckets);
  assert(bucket>=0 && bucket < h->numBuckets);
  return bucket;

}

static const int kNotFound = -1;
void HashSetEnter(hashset *h, const void *elemAddr)
{
  int bucket =  findElemBucket(h,elemAddr);
  // printData(h);
  
  //if(VectorIsNull(&h->data[bucket]))
  //  VectorNew(&h->data[bucket],h->elemSize,h->freeFn, 4);
  
    
  int elemPosition = VectorSearch(&h->data[bucket], elemAddr, h->compareFn, 0, false);

  if(elemPosition!= kNotFound)
    VectorReplace(&h->data[bucket], elemAddr,elemPosition );
  else{ 
    VectorAppend(&h->data[bucket], elemAddr);
    h->length++;
  }
}

void *HashSetLookup(const hashset *h, const void *elemAddr)
{ 
  int bucket =  findElemBucket(h,elemAddr);
  //if(VectorIsNull(&h->data[bucket]))
  //return NULL;
  int elemPosition = VectorSearch(&h->data[bucket], elemAddr, h->compareFn, 0, false);
 
 if(elemPosition !=  kNotFound)
    return VectorNth(&h->data[bucket],elemPosition);
  return NULL; 

}
