#ifndef YELLOW_PAGE_H
#define YELLOW_PAGE_H

#include "Configs.h"

//#include "ct_predefined.h"


namespace orlando
{
	class IYellowPageResult;

	class YellowPage
	{
	public:
		YellowPage(void*);
		int getResultList(const u16string &, vector<IYellowPageResult*> &, string, string, int);
		const u16string getYellowPageDetail(const u16string &, string &);
		virtual ~YellowPage();


	private:
		void U16stringTOstring(const u16string&, string &);

	};

}

#endif /* YELLOW_PAGE_H */
