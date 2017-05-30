#ifndef IYELLOWPAGE_RESULT_H
#define IYELLOWPAGE_RESULT_H

#include "Configs.h"

namespace orlando
{
	class IYellowPageResult
	{
	public:
		virtual const u16string &getId() const M_PURE({return *((u16string *)-1);})
		virtual const u16string &getName() const M_PURE({return *((u16string *)-1);})
		virtual const u16string &getNumber() const M_PURE({return *((u16string *)-1);})
		virtual ~IYellowPageResult(){}
	};

}

#endif /* IYELLOWPAGE_RESULT_H */
