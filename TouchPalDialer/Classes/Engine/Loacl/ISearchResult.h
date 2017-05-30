#ifndef ISEARCH_RESULT_H
#define ISEARCH_RESULT_H

#include "Configs.h"

namespace orlando
{



    enum RESULT_TYPE{
		CONTACTER_RESULT,
		YELLOWPAGE_RESULT
	};
	class ISearchResult
	{
	public:
        static const int SEQ_MATCH_RESULT = 0;
        static const int CYC_MATCH_RESULT = 1;
        static const int SKIP_MATCH_RESULT = 2;
        static const int STRICT_SEQ_MATCH = 3;
		virtual const unsigned long long getId() const M_PURE({return 0;})
		virtual const u16string &getName() const M_PURE({return *((u16string *)-1);})
		virtual const vector<int> &getHitInfo() const M_PURE({return *((vector<int> *)NULL);})
		virtual const RESULT_TYPE getTheResultType() const M_PURE({return (RESULT_TYPE)0;});
		virtual const int getHitType() const M_PURE({return 0;})
		virtual ~ISearchResult()
		{
		}
		virtual const int getResultType() const M_PURE({return 0;})
	};

}

#endif /* ISEARCH_RESULT_H */
