/**
 * File: news-aggregator-utils.cc
 * ------------------------------
 * Provides the implementation of those functions exported
 * by news-aggregator-utils.h.
 */

#include "news-aggregator-utils.h"
using namespace std;

static const string kHTTPPrefix = "http://";
static const string kHTTPSPrefix = "https://";
string getURLServer(const string& url) {
  size_t start = 0;
  if (url.find(kHTTPPrefix) != string::npos) start = kHTTPPrefix.size();
  else if (url.find(kHTTPSPrefix) != string::npos) start = kHTTPSPrefix.size();  
  size_t end = url.find('/', start);
  if (end == string::npos) end = url.size();
  return url.substr(start, end - start);
}

static const size_t kMaxLength = 75;
static const size_t kRetainedSuffixLength = 5;
static const size_t kInternalPaddingLength = 5;
static const size_t kRetainedPrefixLength = kMaxLength - kInternalPaddingLength - kRetainedSuffixLength;
bool shouldTruncate(const string& str) {
  return str.size() > kMaxLength;
}

string truncate(const string& str) {
  if (!shouldTruncate(str)) return str;
  string front = str.substr(0, kRetainedPrefixLength);
  string middle = string(kInternalPaddingLength, '.');
  string end = str.substr(str.size() - kRetainedSuffixLength);
  return front + middle + end;
}
