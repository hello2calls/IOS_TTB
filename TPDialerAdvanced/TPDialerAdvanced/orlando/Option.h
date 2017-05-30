/*
 * Option.cpp
 *
 *  Created on: 2011-3-23
 *      Author: Stony
 */

#ifndef OPTION_H_
#define OPTION_H_

#include "def.h"

namespace orlando {

	class IPhoneRule;
	class PhoneRuleManager;
	class IPhoneNumber;

	struct SIM_SLOT {
		enum __Enum {
			NONE = 0,
			MASTER = 1,
			SLAVE = 2,
			DUAL = 3
		};
		__Enum _value; 

		SIM_SLOT(int value = 0) : _value((__Enum)value) {}
		SIM_SLOT& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}

		operator int() const {
			return this->_value;
		}
	}; 

	struct Roaming {
		enum __Enum {
			INTERNATIONAL = 0,
			INTER_MSC = 1,
			REGIONAL = 2,
			DOMESTIC = 3,
			HOME_ONLY = 4,
			INTER_MSC_AND_HOME = 5,
			REGIONAL_AND_HOME = 6,
			DOMESTIC_AND_HOME = 7,
			ANY = 8
		};
		__Enum _value; 

		Roaming(int value = 0) : _value((__Enum)value) {}
		Roaming& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}

		Roaming& operator+=(int value) {
			this->_value = (__Enum)(this->_value + value);
			return *this;
		}

		Roaming& operator-=(int value) {
			this->_value = (__Enum)(this->_value - value);
			return *this;
		}

		operator int() const {
			return this->_value;
		}
	}; 

	struct Destination {
		enum __Enum {
			HOME = 0,
			REGION = 1,
			DOMESTIC = 2,
			INTER_MSC = 3,
			INTERNATION = 4,
			ANY = 5,
			CROSS_INTERNATIONALLY = 6,
			CROSS_DOMESTICLY = 7,
			PATTERN = 8
		};
		__Enum _value; 

		Destination(int value = 0) : _value((__Enum)value) {}
		Destination& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}
		operator int() const {
			return this->_value;
		}
	}; 


	struct OperatorInfo {
		string Country;
		string AreaCode;
		string OperatorCode;
		string OperatorName;
	};

	class Option {
		//bool(*mIsEnable)(string);
		OperatorInfo mNetwork;
		OperatorInfo mNetwork_Alt;
		OperatorInfo mSim;
		OperatorInfo mSim_Alt;
		bool mRoaming;
		bool mRoaming_Alt;
		SIM_SLOT mSIMMode;
		int mAttrImageFd;

		string stripArea(string, string);
	public:
		Option();
		virtual ~Option();
		void setSIM(OperatorInfo);
		OperatorInfo getSIM();
		void setSIM(OperatorInfo, SIM_SLOT);
		OperatorInfo getSIM(SIM_SLOT);
		void setNetwork(OperatorInfo);
		OperatorInfo getNetwork();
		void setNetwork(OperatorInfo, SIM_SLOT);
		OperatorInfo getNetwork(SIM_SLOT);
		void setRoaming(bool);
		void setRoaming(bool, SIM_SLOT);
		bool isRoaming();
		bool isRoaming(SIM_SLOT);
		void setSIMMode(SIM_SLOT);
		SIM_SLOT getSIMMode();

		void initAttrImage(void*);
		bool isAttrInit();
		void deinitAttrImage();

		void setIPPrefixList(vector<string>);
		void clearIPPrefixList();
		void setCurrentProfile(string);

		Roaming getRoamingType(SIM_SLOT) ;
		bool matchRoaming(Roaming) ;
		bool matchRoaming(Roaming , SIM_SLOT) ;
		bool matchHomeAreaByAttr(IPhoneRule* , IPhoneNumber*) ;
		bool matchHomeAreaByAttr(IPhoneRule* , IPhoneNumber*, SIM_SLOT) ;
		bool matchDestination(Destination , IPhoneNumber*, string  = "");
		bool matchDestination(Destination , IPhoneNumber*, SIM_SLOT ,string = "") ;
	};

	class OptionManager{
	private:
		static OptionManager* _Manager;
		Option* _Option;
	protected:
		OptionManager(void);
		~OptionManager(void);
	public:
		static OptionManager* getInst();
		Option* getOption();
	};

}

#endif /* OPTION_H_ */
