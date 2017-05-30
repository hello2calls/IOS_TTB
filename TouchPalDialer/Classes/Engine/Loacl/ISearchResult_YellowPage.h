#ifndef ISEARCH_RESULT_YELLOWPAGE_H
#define ISEARCH_RESULT_YELLOWPAGE_H

#include "ISearchResult.h"
#include <vector>

namespace orlando
{

    using std::vector;
	enum ShopForm{
		NormalShop = 0,
		MainShop = 1,
		BranchShop = 2,
		Any = 3
	};

	class ISearchResult_YellowPage : public ISearchResult
	{
	public:
		///while the result is contacter ,the following function is not useful
		virtual const vector<u16string> & getPhoneNumber()const M_PURE({return *((vector<u16string> *)NULL);})/// get the Phonemunber ( if the result is a Contacter ,)
		virtual const int  getBranchShopSize() const M_PURE({return 0;})/// if the reuslt is a Mother_Merchant, tell you how many sub_shop be hit.
		virtual const unsigned long long getMainShopID()const M_PURE({return 0;}) /// get the shop'sMotherMerchant ID
		virtual const int getDataBaseID()const M_PURE({return -1;})
		virtual const vector<u16string> &  getShopType() const M_PURE({return *((vector<u16string> *)NULL);})
		virtual const u16string & getRemarks() const M_PURE({return *((u16string *)-1);})
		virtual const ShopForm getShopForm()  const M_PURE({return (ShopForm)0;})
		virtual const bool HaveDetailInfo() const M_PURE({return 0;})
		virtual const u16string & getDefaultNumber() const M_PURE({return *((u16string *)-1);})
		virtual const u16string & getShortName() const M_PURE({return *((u16string *)-1);})
		virtual const unsigned long long  getId() const M_PURE({return 0;})
        virtual const bool getIsAddV() const M_PURE ({ return 0;})
        virtual const long long GetDataTime() const {return 0;}
		virtual ~ISearchResult_YellowPage()
		{
		}
	};

}

#endif /* ISEARCH_RES../../src/SearchResult_YellowPage.h:82:3:ULT_H */
