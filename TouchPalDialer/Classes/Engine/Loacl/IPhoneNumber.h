/*
 * PhoneNumber.h
 *
 *  Created on: 2011-3-23
 *      Author: Stony
 */

#ifndef IPHONENUMBER_H_
#define IPHONENUMBER_H_

#include "Option.h"
#include "IDialRule.h"

namespace orlando {

	class IPhoneRule;
	class IDialRule;

	class IPhoneNumber {
	public:
		virtual string getRawPhoneNumber() = 0;
		virtual void setRawPhoneNumber(string) = 0;
		virtual string getNormalizedNumber() = 0;
        virtual string getNormalizedNumberWithoutAreacode()=0;
		virtual void setRoaming(bool) = 0;
		virtual bool isRoaming() = 0;
		virtual bool isFromLocalNumber() = 0;
		virtual IPhoneRule* getLocationRule() = 0;
		virtual IPhoneRule* getDestinationRule() = 0;

		virtual bool isNested() = 0;
		virtual void setServiceNumber(string) = 0;
		virtual string getServiceNumber() = 0;
		virtual void setTransformFormat(string) = 0;
		virtual string getTransformFormat() = 0;
		virtual string getDialStringFromMethod(IDialRule* rule = NULL, bool withPrefix = true) = 0;
		virtual void normalize() = 0;

		virtual int getSuggestedGeoCodeLength() = 0;
		virtual string getLocalDialNumber() = 0;
		virtual string getDomesticDialNumber() = 0;
		virtual string getInternationDialNumber() = 0;
		virtual string getLocaNumberWithoutAreaCode() = 0;
		virtual string getDomesticNumberWithTrunk() = 0;
		virtual string getDomesticNumberWithoutTrunk() = 0;
		virtual string getInternationNumberWithoutPrefix() = 0;
		virtual string getInternationNumberWithPlus() = 0;
		virtual string getInternationNumberWithPrefix() = 0;
		virtual string getAreaCode() = 0;
		virtual string getAttr(int) = 0;
		virtual string getAttrMainInfo() = 0;
		virtual string getAttrMappedAreaCode() = 0;
        virtual string getCNnormalNumber() = 0;
		
		//vector<DialRule> getSuggestion(string, bool);

		virtual ~IPhoneNumber() = 0;
	};
	
	typedef std::map<std::string, orlando::IPhoneNumber*> NumberMap;

	class PhoneNumberFactory
	{
	private:
		static NumberMap _map;
	public:
		PhoneNumberFactory(void);
		~PhoneNumberFactory(void);

		static IPhoneNumber* Create(string raw, bool foNetwork = false);
		static void ClearCache();
	};
}

#endif /* IPHONENUMBER_H_ */
