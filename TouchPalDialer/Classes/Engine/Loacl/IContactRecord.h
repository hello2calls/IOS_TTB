#ifndef ICONTACT_RECORD_H
#define ICONTACT_RECORD_H 

namespace orlando
{

	class IContactRecord
	{
	public:
		virtual const long getId() const M_PURE({return 0;})
		virtual const u16string &getName() const M_PURE({return *((u16string *)-1);})
		virtual const int getContactedTimes() const M_PURE({return 0;})
		virtual const int getAccountId() const M_PURE({return 0;})
		virtual const bool isVisible() const M_PURE({return true;})
		virtual const bool hasPhoneNumber() const M_PURE({return true;})
		virtual ~IContactRecord()
		{
		}
	};

}

#endif /* ICONTACT_RECORD_H */
