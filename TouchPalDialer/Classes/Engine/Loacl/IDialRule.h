/*
 * Option.cpp
 *
 *  Created on: 2011-3-23
 *      Author: Stony
 */

#ifndef IDIALRULE_H_
#define IDIALRULE_H_

#include "Option.h"
#include "IPhoneNumber.h"

namespace orlando {

	class IRuleProfile;

	class MobileNetworkCode{
	public:
		int MCC;
		int MNC;
		bool three_digits;

		MobileNetworkCode();
		MobileNetworkCode(string);
		MobileNetworkCode(int);
		MobileNetworkCode(int c, int n);
		~MobileNetworkCode();
		void set(int);
		void set(int,int);
		int get();
		string getString();
		bool operator==(const int);
		bool operator==(MobileNetworkCode&);
		bool operator%(const int);
		bool operator%(MobileNetworkCode&);
	};

	struct IDialMethod{
		int Id;
		string ServiceNumber;
		string TransformFormat;
		virtual ~IDialMethod();
	};

	struct DialRuleType {
		enum __Enum {
			DEFAULT = 0,
			E164 = 1,
			DOMESTIC = 2,
			LOCAL = 3,
			CALL_BACK = 4,
			CARD = 5,
			DIRECT = 6,
			VOIP = 7,
			ANY = 8
		};
		__Enum _value;

		DialRuleType(int value = 0) : _value((__Enum)value) {}

		DialRuleType& operator=(int value) {
			this->_value = (__Enum)value;
			return *this;
		}

		DialRuleType& operator+=(int value) {
			this->_value = (__Enum)(this->_value + value);
			return *this;
		}

		DialRuleType& operator-=(int value) {
			this->_value = (__Enum)(this->_value - value);
			return *this;
		}

		operator int() const {
			return this->_value;
		}
	};

	struct DialRuleSource {
			enum __Enum {
				DEFAULT = 0,
				INTERNAL = 1,
				CUSTOM = 2,
			};
			__Enum _value;

			DialRuleSource(int value = 0) : _value((__Enum)value) {}

			DialRuleSource& operator=(int value) {
				this->_value = (__Enum)value;
				return *this;
			}

			DialRuleSource& operator+=(int value) {
				this->_value = (__Enum)(this->_value + value);
				return *this;
			}

			DialRuleSource& operator-=(int value) {
				this->_value = (__Enum)(this->_value - value);
				return *this;
			}

			operator int() const {
				return this->_value;
			}
		};

	class IDialRule{
	protected:
		int _id;
		string _name;
		string _description;
		Roaming _roamingType;
		Destination _destinationType;
		string _destinationPattern;
		bool _enable;
		IDialMethod* _DialMethod;
		DialRuleType _type;
		DialRuleSource _source;
	public:
		IDialRule(){ };
		virtual ~IDialRule();

		inline int getId() const{ return _id;};
		inline void setId(int id) {_id = id;};
		inline string getName() const{return _name;};
		inline void setName(string name) {_name = name;};
		inline string getDescription() const{return _description;};
		inline void setDecscrition(string desc) {_description = desc;};
		inline Roaming getRoamingType() {return _roamingType;};
		inline void setRoamingType(Roaming roaming) { _roamingType = roaming;};
		inline Destination getDestinationType() {return _destinationType;};
		inline void setDestination(Destination dest) {_destinationType = dest;};
		inline string getDestinationPattern() const{ return _destinationPattern;};
		inline void setDestinationPattern(string pattern) {_destinationPattern = pattern;};
		inline bool isEnable() const{return _enable;};
		inline void setEnable(bool enable) { _enable = enable;};
		inline IDialMethod* getDialMethod() const{return _DialMethod;};
		inline void setDialMethod(IDialMethod * method) {_DialMethod = method;};
		inline DialRuleType getType() {return _type;};
		inline void setType(DialRuleType type) {_type = type;};
		inline DialRuleSource getSource() {return _source;};
		inline void setSource(DialRuleSource source) {_source = source;};
		
		string getKey(IRuleProfile*);
		string getDialString(IPhoneNumber*, bool withPrefix = false);
	};

	class ProfileMeta{
	public:
		ProfileMeta();
		~ProfileMeta();
		vector<int> _mncs;
		string _network;
		string _area;
		string _brand;
		string _description;
		string _author;
		bool acceptCode(int);
		bool isSameCountry(int);
		void add(string);
		void add(int);
		void remove(string);
		void remove(int);
	};

	class IRuleProfile{
	protected:
		int _id;
		int _version;
		ProfileMeta* _meta;
		bool _enable;
		int getMinFreeId();
	public:
		static const int ID_INTERNAL = 10101;
		static const int ID_CUSTOM = 10102;
		static const int INTERNAL_RULE_DIRECT_DIAL = 1;
		static const int INTERNAL_RULE_LOCAL_CALL = 2;
		static const int INTERNAL_RULE_DOMESTIC_CALL = 3;
		static const int INTERNAL_RULE_INTERNATIONAL_CALL = 4;

		// Do NOT modify outside Orlando.
		vector<IDialRule *> _rules;

		inline int getId() const{return _id;};
		inline void setId(int id) {_id = id;};
		inline int getVersion() const{return _version;};
		inline void setVersion(int v) {_version = v;};
		ProfileMeta* getMeta() const { return _meta;};
		void setMeta(ProfileMeta* meta) {_meta = meta;};
		inline bool isEnable() const{return _enable;};
		inline void setEnable(bool enable) { _enable = enable;};

		IDialRule* getRuleById(int);
		int getFullKeyByRule(IDialRule*);
		int getKeyOfRuleById(int);
		void addRule(IDialRule*) ;
		void removeRuleById(int) ;

		void getSuggestions(IPhoneNumber*, vector<IDialRule *>&);
		virtual ~IRuleProfile();
	};



	class ProfileManager{
	private:
		static ProfileManager* _inst;
	protected:
		vector<IRuleProfile*> _profiles;
		int _activeId;
		ProfileManager();
		~ProfileManager();
	public:
		static ProfileManager* getInst();

		ProfileMeta* createMeta(string, string, string, string);
		IRuleProfile* createProfile(ProfileMeta*);
		IDialRule* createRule(string , string , Roaming , Destination);
		IDialMethod* createMethod(string, string);
		void addProfile(IRuleProfile*);
		void removeProfile(IRuleProfile*);
		void getProfilesByOperateCode(string, vector<IRuleProfile*>&);
		void getProfilesByOperateCode(int, vector<IRuleProfile*>&);
		IRuleProfile* getProfileInternal();
		IRuleProfile* getProfileCustom();
		IRuleProfile* getProfileById(int);
		void getProfileByCountry(int, vector<IRuleProfile*>&);
		IRuleProfile* getActiveProfile();
		void setActiveProfile(int id);
		void setActiveProfile(IRuleProfile*);
		void getSuggestions(IPhoneNumber*, vector<IDialRule *>&);

		void freeMeta(ProfileMeta*);
		void freeRule(IDialRule*);
		void freeMethod(IDialMethod*);
		void freeProfile(IRuleProfile*);
	};
}

#endif /* IDIALRULE_H_ */
