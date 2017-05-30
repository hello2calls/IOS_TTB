#ifndef DEFINE_H
#define DEFINE_H

#include <string>
#include <vector>
#include <map>

#define WCHAR_T 								unsigned short
#define CHAR_T									char
#define TPDOUBLE								double
#define TPBOOLEAN								bool
#define TPSTRING								std::string
#define TPUTF8STRING							std::string
#define TPNUMERIC								long long
#define TPULONGLONG								unsigned long long
#define SHORT									short
#ifndef TRUE
#define TRUE									true
#endif
#ifndef FALSE
#define FALSE									false
#endif
#ifndef NULL
#define NULL									0
#endif

using std::vector;
using std::map;
using std::string;

#define VECTOR_T(X)					vector<X>
#define VECTOR_ITER_T(X)			        vector<X>::const_iterator
#define MAP_T(X, Y)                                     std::map<X,Y>
#define MAP_ITER_T(X, Y)                                std::map<X,Y>::iterator
#define PAIR_T(X, Y)                                    std::pair<X, Y>

#endif
