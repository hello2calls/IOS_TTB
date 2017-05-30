#ifndef CONTACT_ENGINE_H
#define CONTACT_ENGINE_H
#include "ICityGroup.h"
#include <map>
namespace orlando
{

	class IndexTable;
	class IContactRecord;
	class ISearchResult;
    class PhoneSearch;
    class CityGroup;
    class CityGroupMgr;
    class YellowSearch;
    class YellowSearchManager;
    class SearchResult_CallerID;

    enum FileType{
        CallerID = 0,
        CountryYellowPage = 1,
        CityYellowPage = 2
    };
    const int file_size = 10;
    const int priorityFile = 0;
    const int dataFile = 1 ;
    const int indexFile = 2 ;
    const int tableFile = 3;
    const int calleridFile = 4 ;
    const int delta_dataFile = 5;
    const int delta_indexFile = 6;
    const int delta_tableFile = 7;
    const int delta_calleridFile = 8;
    const int logoFile = 9;
    struct FileDescription{
        FileType type;
        void * files[file_size];
        FileDescription(){
            memset(files,0,sizeof(files));
        }
    };

	enum KEYTYPE{
		 KEYTYPE_DIAL = 1,
		 KEYTYPE_YELLOWPAGE = 2,
		 KEYTYPR_CONTACTER = 3,
		 KEYTYPE_PHONENUMBER = 4,
		 KEYTYPE_SHOPID = 5,
		 KEYTYPE_SHOPID_WITH_CHILD = 6
	};

    struct VipInfo{
        u16string  link;
        u16string  advertisement;
        unsigned int ID;
    };

	class ContactEngine
	{
	public:

        static int ChineseType;
        static const int PINYIN_INDEX_ENGINE = 0;
        static const int ZHUYIN_INDEX_ENGINE = 1;
        static const int USE_OLD_MATCH_ENGINE = -1;
        static const int USE_NEW_MATCH_ENGINE_SEQ = 0;
        static const int USE_NEW_MATCH_ENGINE_CYC = 1;
        static const int USE_NEW_MATCH_ENGINE_SKIP = 2;
		static const int ALL_INDEX = 0;
		static const int PHONEPAD_INDEX = 1;
		static const int QWERTY_INDEX = 2;
        static const int ERROR_BASEFILE_ERROR = -1;
    	static const int ERROR_DELTAFILE_ERROR = -2;
    	static const int ERROR_ALL_FILL_ERROR = -3;
    	static const int ERROR_CREATE_TYPE_ERROR = -4;
    	static const int BUCKETSIZE = 11;

        ContactEngine();
		ContactEngine(int type);
		virtual ~ContactEngine();
		virtual bool index(int type);
		virtual bool addContact(long id, const u16string &name, int contactedTimes = 0, int accountId = 0, bool visible = true, bool hasNumber = false);
		virtual bool addContactandIndex(long id, const u16string &name, int contactedTimes = 0, int accountId = 0, bool visible = true, bool hasNumber = false);
		virtual bool deleteContact(const long id);
		virtual bool updateContact(const long id, const u16string &name, int contactedTimes = 0, int accountId = 0, bool visible = true, bool hasNumber = false);
		virtual const IContactRecord *getContactRecord(const long id);
		virtual bool isContactRecordExist(const long id);
		virtual int  requestQuery(const u16string &query, int accountId = 0, bool isVisible = true, bool hasNumber = false);
		virtual int  getResultList(vector<ISearchResult*> &resultList,int queryType = USE_NEW_MATCH_ENGINE_SKIP);
		virtual bool addPhoneNumber(long id , long contactId, const u16string &number, const u16string &type, bool isPrimary);
		virtual bool deletePhoneNumber(long id, long contactId, const u16string &number);
		virtual bool queryPhoneNuber(const u16string &number, int length, vector<long> & resultList);
	    virtual int  getCityGroups(vector<ICityGroup*> &cityGroups, int cityCount);
        virtual void clearCityGroups();
		virtual int  CreatFile(FileDescription fd);
		virtual int  CreatFileForCaller(FileDescription fd);
		virtual bool DeleteFile(int id);
		virtual bool setSearchScope(int size, unsigned int ids[]);
		void Query(KEYTYPE keyType,u16string key,vector<ISearchResult*> & resultList, bool isVisible = true, bool hasNumber = false);
		void GetDetailInfo(vector<ISearchResult*> & resultList,int beginPos,int size);
        VipInfo GetTheVipInfo(unsigned int id);
		bool GetDetailInfo(ISearchResult * result);
        bool PhoneInCountryDB(u16string ph);


		bool GetCallerIDInfo(SearchResult_CallerID * result, u16string phoneNumber);
		ISearchResult *GetDetailInfoByPhoneNumber(u16string phoneNumber);
		bool AddShopData(int shopID, u16string & name);

	private:
		IndexTable *mIndexTable;
        PhoneSearch *mPhoneSearch;
		CityGroupMgr *mCityGroupMgr;
		YellowSearchManager *mYSManager;
        void Initialize(int type);
	};
}

#endif /* CONTACT_ENGINE_H */
