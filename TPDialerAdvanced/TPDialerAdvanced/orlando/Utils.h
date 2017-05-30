#ifndef UTILS_H
#define UTILS_H 

namespace orlando
{
	class AsianUtils;
	class Utils
	{
	public:
		inline static bool isChineseChar(u16char_t c){
			return ((c>=0x4e00)&&(c<=0x9fa5)) ? true : false; 
		};

		inline static u16string getPinyinByCHS(u16char_t c) {
			return AsianUtils::getPinyinByCHS(c);
		}

		inline static bool isDuoyinChar(u16char_t c) {
			return AsianUtils::isDuoyinChar(c);
		}

		inline static u16string getDuoyinChar(u16char_t c) {
			return AsianUtils::getDuoyinChar(c);
		}
	};

}

#endif /* UTILS_H */
