#ifndef SEARCHRESULT_CALLERID1_H
#define SEARCHRESULT_CALLERID1_H

namespace orlando{

    struct VipInfo{
        u16string  link;
        u16string  advertisement;
        unsigned int ID;
    };

	class SearchResult_CallerID
	{
		public:
			SearchResult_CallerID();
			~SearchResult_CallerID();
			const u16string & getName() const {return mName;}
			const u16string & getTags() const {return mTags;}
			const int GetCrankCount() const {return 0;}
			const int GetFraudCount() const {return 0;}
			const bool IsVip() const {return mIsVip;}
            const VipInfo GetVipInfo () const {return m_vip;}
            const bool IsVerify() const {return mIsVerify;}
			void SetName(u16string name){mName = name;}
			void SetSecurityLevel(u16string tags){mTags = tags;}
			const long long GetDataTime() const {return mTime;}
			const u16string & getClassifyType()const {return mClassifyType;}
			void SetClassifyType(u16string classify){mClassifyType = classify;}
            void SetDataTime(long long time){
                mTime = time;
            }
            void SetVipInfo(VipInfo vip_info){
                mIsVip = true;
                m_vip = vip_info;
            }
            void SetToVerify()
            {
                mIsVerify = true;
            }
		private:
			u16string mTags;
			u16string mName;
			u16string mClassifyType;
            bool mIsVip;
            bool mIsVerify;
            VipInfo m_vip;
            long long mTime;
	};
}

#endif
