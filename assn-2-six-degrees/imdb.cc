using namespace std;
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include "imdb.h"
#include <cstring>

const char *const imdb::kActorFileName = "actordata";
const char *const imdb::kMovieFileName = "moviedata";

imdb::imdb(const string& directory)
{
  const string actorFileName = directory + "/" + kActorFileName;
  const string movieFileName = directory + "/" + kMovieFileName;
  
  actorFile = acquireFileMap(actorFileName, actorInfo);
  movieFile = acquireFileMap(movieFileName, movieInfo);
}

bool imdb::good() const
{
  return !( (actorInfo.fd == -1) || 
	    (movieInfo.fd == -1) ); 
}

film createFilmObj(char* &entry)
{
  film nextFilm; 
  nextFilm.title = entry;
  nextFilm.year = 1900 + *(entry+(strlen(entry)+1));
  
  return nextFilm;
}

short getRecordsNum(char* & offset, int byteNameSize)
{
  offset+=byteNameSize;
  //skip 1 '/0' char if current name size is even => chars used to store it is odd
  if(byteNameSize%2!=0){
    byteNameSize++;
    offset+=1;
  }
  // find num of films assotiated with this actor
  short numOfFilms = *(short*)offset;
  offset+=2;
    
  //just skip 2 more '/0'      
  if ((byteNameSize+2)%4!=0)
    offset+=2;
  
  return numOfFilms;
}
//need this struct to path data array to cmp function of bsearch
struct keyP {const void* key;const  void* array;}newKey;

void* createKeyPointer(const void* elem, const void* array)
{
  newKey.key = elem;
  newKey.array = array;
  return (void*)&newKey; 
}
 
int cmpPlayers(const void * one, const void * two)
{
  // one is key pointer of struct keyP{void*key, void*dataArray}
  char* first = *(char**)one;
  char* second = *((char**)one + 1) + *(int*)two;
  return strcmp(first, second);
}

int cmpFilms(const void * one, const void * two)
{
   // one is key pointer of struct keyP{void*key, void*dataArray}
  film first = **(film**)one;
  char* secondP = *((char**)one + 1) + *(int*)two;
  film second = createFilmObj(secondP);
 
  if(first == second) return 0;
  else if(first < second) return -1;
  else return 11;
}

int* findElem(const void* elem, const void* array, int (*cmp)(const void*,const void*))
{
  void* key = createKeyPointer(elem, array);
  void* base = (void*)((char*)array + sizeof(int));
  size_t num = (size_t)*(int*)array;
  size_t size = sizeof(int);
  int* find = (int*) bsearch(key, base, num, size, cmp);
  return find;
}

// you should be implementing these two methods right here... 
bool imdb::getCredits(const string& player, vector<film>& films) const 
{
  int* find = findElem((void*)player.c_str(), actorFile, cmpPlayers);
  
  if(find!=NULL){     
    char* offset = (char*)actorFile + *find;
    short numOfFilms = getRecordsNum(offset, strlen(offset)+1);// +1 because of '/0' char in the end of the string
    for (int j =0; j<numOfFilms;j++){
      char * movieP = (char*)movieFile + *((int*)offset + j);
      films.push_back(createFilmObj(movieP));
    }	
    return true;
}  
 return false;
}

bool imdb::getCast(const film& movie, vector<string>& players) const {
  const film* moviePointer = &movie; 
  int* find = findElem((void*)moviePointer, movieFile,cmpFilms);

  if(find!=NULL){   
    char* offset = (char*)movieFile + *find;
    short numOfPlayers = getRecordsNum(offset, movie.title.size()+2);//+2 because '/0' char in the end of the string and 1 more byte for year
      
    for(int j = 0; j < numOfPlayers;j++){
      char * playerP = (char*)actorFile + *((int*)offset + j);
      players.push_back(playerP);
    }
      return true;
  }
  return false;
}

imdb::~imdb()
{
  releaseFileMap(actorInfo);
  releaseFileMap(movieInfo);
}

// ignore everything below... it's all UNIXy stuff in place to make a file look like
// an array of bytes in RAM.. 
const void *imdb::acquireFileMap(const string& fileName, struct fileInfo& info)
{
  struct stat stats;
  stat(fileName.c_str(), &stats);
  info.fileSize = stats.st_size;
  info.fd = open(fileName.c_str(), O_RDONLY);
  return info.fileMap = mmap(0, info.fileSize, PROT_READ, MAP_SHARED, info.fd, 0);
}

void imdb::releaseFileMap(struct fileInfo& info)
{
  if (info.fileMap != NULL) munmap((char *) info.fileMap, info.fileSize);
  if (info.fd != -1) close(info.fd);
}
