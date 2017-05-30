/*
* IRules.h
*
*  Created on: 2011-3-23
*      Author: Stony
*/

#ifndef IRULES_H_
#define IRULES_H_

namespace orlando {

	struct DialingPlan {
		enum __Enum {
			UNKNOWN=0,
			OPEN=1,
			CLOSED=2,
			CLOSED_WITH_TRUNK=3,
			NANP=4
		};
		__Enum _value; 

		DialingPlan(int value = 0) : _value((__Enum)value) {}
		DialingPlan& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}
		operator int() const {
			return this->_value;
		}
	}; 

	struct NumberType {
		enum __Enum {
			UNKNOWN = 0,
			LAND_LINE = 1,
			MOBILE_GEO = 2,
			MOBILE_NONE_GEO = 3,
			MIXED_LAND_LINE_MOBILE = 4,
			TOLL_FREE = 5,
			SHARED_COST = 6,
			PERSONAL_NUMBER = 7,
			PAGER = 8,
			PREMIUM_RATE = 9
		};
		__Enum _value;

		NumberType(int value = 0) : _value((__Enum)value) {}
		NumberType& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}
	};

	class IPhoneRule{
	public:
		virtual std::string stripRawNumber(std::string) = 0;
		virtual std::string getCountryName() = 0;
		virtual void setCountryName(std::string) = 0;
		virtual std::string getCountryFullName() = 0;
		virtual void setCountryFullName(std::string) = 0;
		virtual std::string getInternationalPrefix() = 0;
		virtual void setInternationalPrefix(std::string) = 0;
		virtual std::string getTrunkPrefix() = 0;
		virtual void setTrunkPrefix(std::string) = 0;
		virtual void addInternationalPrefix(std::string , std::string ) = 0;
		virtual void clearInternationalPrefix() = 0;
		virtual bool hasMoreInternationalPrefix() = 0;
		virtual std::string getCountryCode() = 0;
		virtual void setCountryCode(std::string) = 0;
		virtual std::string getAreaCode(bool) = 0;
		virtual void setAreaCode(std::string) = 0;
		virtual std::string getMainMCC() = 0;
		virtual void setMainMCC(std::string) = 0;
		virtual int getMNCLength() = 0;
		virtual void setMNCLength(int) = 0;
		virtual unsigned int getLocalMaxNumberLength() = 0;
		virtual void setLocalMaxNumberLength(unsigned int ) = 0;
		virtual void setMixedLandMobile(bool) = 0;
		virtual bool isMixedLandMobile() = 0;
		virtual DialingPlan getDiallingPlan() = 0;
		virtual void setDiallingPlan(DialingPlan) = 0;
		virtual bool isNoneClosedPlan() = 0;

		virtual bool isStartWithPlus(std::string) = 0;
		virtual bool isStartWithInternationalPrefix(std::string) = 0;
		virtual int IndexOfInternationalPrefix(std::string) = 0;
		virtual bool isDomesticFormat(std::string) = 0;
		virtual bool matchSpecialNumber(std::string) = 0;
		virtual bool matchNoneGeoCodes(std::string) = 0;
		virtual bool matchGeoCodes(std::string) = 0;
		virtual bool matchLocalService(std::string)=0;
		virtual bool isStartWithZero(std::string)=0;

		virtual std::string normalizedFromLocalIDDNumber(std::string) = 0;
		virtual std::string normalizedFromCarrierIDDNumber(std::string, int) = 0;
		virtual std::string normalizedFromDomesticNumber(std::string) = 0;
		virtual std::string normalizedFromSpecialNumber(std::string, bool) = 0;
		virtual std::string normalizedFromNoneGeoCodesNumber(std::string) = 0;
		virtual std::string normalizedFromGeoCodesNumber(std::string, bool) = 0;
		virtual std::string normalizedFromDefaultRule(std::string, bool) = 0;

		virtual std::string getLocalDialNumber(std::string) = 0;
		virtual std::string getDomesticDialNumber(std::string) = 0;
		virtual std::string getInternationDialNumber(std::string) = 0;

		virtual std::string getDomesticNumberWithTrunk(std::string) = 0;
		virtual std::string getDomesticNumberWithoutTrunk(std::string) = 0;
		virtual std::string getInternationNumberWithPrefix(std::string) = 0;
		virtual std::string getInternationNumberWithoutPrefix(std::string) = 0;
		virtual std::string getInternationNumberWithPlus(std::string) = 0;
		virtual std::string getSpecificLocalNumber(std::string) = 0;
		virtual std::string getSpecificCountryCode(std::string) = 0;
		virtual std::string getSpecificAreaCode(std::string) = 0;

		virtual bool isMobile(std::string) = 0;
		virtual bool isNoneGeo(std::string) = 0;
		virtual bool isLandLine(std::string) = 0;
		virtual bool isNested(std::string) = 0;

		virtual std::string getSpecificVoIPServiceNumber(std::string) = 0;
		virtual std::string getSpecificVoIPMessageBody(std::string) = 0;

		virtual std::string getMainOperateCode(std::string) = 0;
	};

	typedef std::map<std::string, orlando::IPhoneRule*> RuleMap;

	class PhoneRuleManager{
	private:
		RuleMap mRules;
		static PhoneRuleManager* _Manager;
	protected:
		PhoneRuleManager(void);
		~PhoneRuleManager(void);
	public:
		static PhoneRuleManager* getInst();
		IPhoneRule* getDefaultRule();
		IPhoneRule* getDefaultRule(bool);
		IPhoneRule* getCN();
		IPhoneRule* getUS();
		IPhoneRule* getPhoneRule(std::string);
		IPhoneRule* getPhoneRuleFromNormailzedNumber(std::string);
		IPhoneRule* getPhoneRuleFromMNC(std::string);
	};
}
#endif /* IRULES_H_ */
