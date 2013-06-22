/**
 * File: news-aggregator.cc
 * ------------------------
 * When fully implements, pulls and parses every single
 * news article reachable from some RSS feed in the user-supplied
 * RSS News Feed XML file, and then allows the user to query the
 * index.
 */

#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
#include <algorithm>
#include <libxml/parser.h>

#include "article.h"
#include "rss-feed-list.h"
#include "rss-feed.h"
#include "rss-index.h"
#include "html-document.h"
#include "html-document-exception.h"
#include "rss-feed-exception.h"
#include "rss-feed-list-exception.h"
#include "news-aggregator-utils.h"
#include "string-utils.h"
using namespace std;

static RSSIndex index;

/**
 * Function: printUsage
 * --------------------
 * Prints usage information.  Should be invoked whenever the
 * user fails to provide a RSS feed name.
 */
static void printUsage(const string& executableName) {
  cerr << "Usage: " << executableName << " <feed-url>" << endl;
}

static void processAllFeeds(const string& feedListURI) {
  RSSFeedList feedList(feedListURI);
  try {
    feedList.parse();
  } catch (const RSSFeedListException& rfle) {
    cerr << "Ran into trouble while pulling full RSS feed list from \""
	 << feedListURI << "\"." << endl; 
    cerr << "Aborting...." << endl;
    exit(0);
  }

  // note to student
  // ---------------
  // add well-decomposed code to read all of the RSS news feeds from feedList
  // for their news articles, and for each news article URL, process it
  // as an HTMLDocument and add all of the tokens to the master RSSIndex.
}

/**
 * Function: queryIndex
 * --------------------
 * queryIndex repeatedly prompts the user for search terms, and
 * for each nonempty search term returns the list of matching documents,
 * ranked by frequency.
 */

static const size_t kMaxMatchesToShow = 15;
static void queryIndex() {
  while (true) {
    cout << "Enter a search term [or just hit <enter> to quit]: ";
    string response;
    getline(cin, response);
    response = trim(response);
    if (response.empty()) break;
    const vector<pair<Article, int> >& matches = index.getMatchingArticles(response);
    if (matches.empty()) {
      cout << "Ah, we didn't find the term \"" << response << "\". Try again." << endl;
    } else {
      cout << "That term appears in " << matches.size() << " article" 
	   << (matches.size() == 1 ? "" : "s") << ".  ";
      if (matches.size() > kMaxMatchesToShow) 
	cout << "Here are the top " << kMaxMatchesToShow << " of them:" << endl;
      else 
	cout << "Here they are:" << endl;
      size_t count = 0;
      for (const pair<Article, int>& match: matches) {
	if (count == kMaxMatchesToShow) break;
	count++;
	string title = match.first.title;
	if (shouldTruncate(title)) title = truncate(title);
	string url = match.first.url;
	if (shouldTruncate(url)) url = truncate(url);
	string times = match.second == 1 ? "time" : "times";
	cout << "  " << setw(2) << setfill(' ') << count << ".) "
	     << "\"" << title << "\" [appears " << match.second << " " << times << "]." << endl;
	cout << "       \"" << url << "\"" << endl;
      }
    }
  }
}

/**
 * Function: main
 * --------------
 * Defines the entry point into the entire executable.
 */

int main(int argc, const char *argv[]) {
  if (argc != 2) {
    cerr << "Error: wrong number of arguments." << endl;
    printUsage(argv[0]);
    exit(0);
  }
  
  string rssFeedListURI = argv[1];
  xmlInitParser();
  processAllFeeds(rssFeedListURI);
  xmlCleanupParser();
  cout << endl;
  queryIndex();
  cout << "Exiting...." << endl;
  return 0;
}
