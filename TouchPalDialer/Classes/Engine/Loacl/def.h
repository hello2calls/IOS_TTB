#ifndef PLATFORM_IOS_DEF_H
#define PLATFORM_IOS_DEF_H

#include <string>
#include <map>
#include <vector>
#include <stdio.h>
#include <set>
//stl
#define M_PURE(f) 	f

namespace orlando
{
	typedef unsigned short u16char_t;
	typedef std::basic_string<char> string;
	typedef std::basic_string<u16char_t> u16string;

	typedef unsigned long long tick_t;
	
	using std::map;
	using std::vector;
    using std::set;

	typedef int FILE_HANDLE;
}

#endif //PLATFORM_IOS_DEF_H
