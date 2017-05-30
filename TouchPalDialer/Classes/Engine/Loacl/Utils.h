#ifndef UTILS_H
#define UTILS_H 

namespace orlando
{
	class Utils
	{
	public:
		static bool isChineseChar(u16char_t c);

                static bool isWesternLetter(u16char_t ch);

                static void getPinyinByCHS(u16char_t c, u16string & ret);

		static bool isDuoyinChar(u16char_t c);

		static void getDuoyinChar(u16char_t c, u16string & ret);
	};

}

#endif /* UTILS_H */
