/*
 * Option.cpp
 *
 *  Created on: 2011-3-23
 *      Author: Stony
 */

#ifndef OPTION_H_
#define OPTION_H_

namespace orlando {

	class IPhoneRule;
	class PhoneRuleManager;
	class IPhoneNumber;

        enum SIM_SLOT {
            SIM_SLOT_NONE = 0,
            SIM_SLOT_MASTER = 1,
            SIM_SLOT_SLAVE = 2,
            SIM_SLOT_DUAL = 3,
        };

        enum Roaming {
            ROAMING_INTERNATIONAL = 0,
            ROAMING_INTER_MSC = 1,
            ROAMING_REGIONAL = 2,
            ROAMING_DOMESTIC = 3,
            ROAMING_HOME_ONLY = 4,
            ROAMING_INTER_MSC_AND_HOME = 5,
            ROAMING_REGIONAL_AND_HOME = 6,
            ROAMING_DOMESTIC_AND_HOME = 7,
            ROAMING_ANY = 8,
        };

        enum Destination {
            DESTINATION_HOME = 0,
            DESTINATION_REGION = 1,
            DESTINATION_DOMESTIC = 2,
            DESTINATION_INTER_MSC = 3,
            DESTINATION_INTERNATIONAL = 4,
            DESTINATION_ANY = 5,
            DESTINATION_CROSS_INTERNATIONAL = 6,
            DESTINATION_CROSS_DOMESTICLY = 7,
            DESTINATION_PATTERN = 8,
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

		string stripArea(string &, string &);
	public:
		Option();
		virtual ~Option();
		void setSIM(OperatorInfo &);
		const OperatorInfo& getSIM();
		void setSIM(OperatorInfo &, SIM_SLOT);
		const OperatorInfo& getSIM(SIM_SLOT);
		void setNetwork(OperatorInfo &);
		const OperatorInfo& getNetwork();
		void setNetwork(OperatorInfo &, SIM_SLOT);
		const OperatorInfo& getNetwork(SIM_SLOT);
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
