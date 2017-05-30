#ifndef SEARCHRESULT_CALLERID1_H
#define SEARCHRESULT_CALLERID1_H


#include "ISearchResult_YellowPage.h"

namespace orlando{
	class SearchResult_CallerID
	{
		public:
			SearchResult_CallerID();
			~SearchResult_CallerID();
			const u16string & getName() const {return mName;}
			const u16string & getTags() const {return mTags;}
			const u16string & getClassifyType()const {return mClassifyType;}
			const int GetCrankCount() const {return 0;}
			const int GetFraudCount() const {return 0;}
			const unsigned int GetVipID() const {return mVipID;}
			const bool IsVip() const {return mIsVip;}
			void SetName(u16string name){mName = name;}
			void SetSecurityLevel(u16string tags){mTags = tags;}
			void SetClassifyType(u16string classify){mClassifyType = classify;}
			const long long GetDataTime() const {return mTime;}
			const bool IsYellowPageResult(){
                return isYellowPage;
			}

			const ISearchResult_YellowPage * getYellowPageResult(){
                return yp;
			}

			void SetYellowPageResult(ISearchResult_YellowPage * result){
			    isYellowPage = true;
                yp = result;
            }
            void SetTheVipID(unsigned int vipID){
                mVipID = vipID;
                mIsVip = true;
            }
            void SetDataTime(long long time){
                mTime = time;
            }
		private:
			u16string mTags;
			u16string mName;
			u16string mCorp;
			u16string mClassifyType;
			bool isYellowPage;
            ISearchResult_YellowPage * yp;
            bool mIsVip;
            unsigned int mVipID;
            long long mTime;
	};
}

#endif
