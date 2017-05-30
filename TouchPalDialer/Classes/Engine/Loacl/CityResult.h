#ifndef CITYRESULT_H
#define CITYRESULT_H

#include "def.h"

namespace orlando
{
    class CityResult
    {
    public:
        CityResult();
        ~CityResult();
        
        const u16string & get_cityname() const;
        const set<long> & get_contacts() const;
        const string & get_cityname_utf() const;
        int size() const;
        void set_name_utf(const string &);
        void set_name(const u16string &);
        void add(long cid);
    private:
        string m_name_utf;
        u16string m_name;
        set<long> m_contacts;
    };
}

#endif
