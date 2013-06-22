/**
 * Provides a C++ equivalent to Java's StreamTokenizer, which allows
 * the client to tokenize a collection of characters according to the 
 * set of delimiters as specified at construction time.
 */

#pragma once
#include <istream>
#include <string>

class StreamTokenizer {
 public:
  StreamTokenizer(std::istream& is, 
                  const std::string& delimiters, 
                  bool skipDelimiters = true);  
  bool hasMoreTokens() const;
  std::string nextToken();

 private:
  std::istream& is;
  std::string delimiters;
  mutable std::string savedChar;
  bool skipDelimiters;
  
  std::string getNextXMLChar() const;

  /**
   * The following two lines delete the default implementations you'd
   * otherwise get for the copy constructor and operator=.  Because the implementation
   * involves std::istreams, it's not clear what the semantics of a
   * deep copy really should be.  By deleting these two items, we force all clients
   * of the StreamTokenizer class to pass instances around by reference or by addresses.
   */

  StreamTokenizer(const StreamTokenizer& orig) = delete;
  void operator=(const StreamTokenizer& other) = delete;
};

