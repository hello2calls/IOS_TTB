#ifndef ICITYGROUP_H
#define ICITYGROUP_H 

#include <vector>
namespace orlando{
class ICityGroup
    {
      public:
        virtual const u16string getCityName () = 0;
        virtual const vector<long> getContactIDs () = 0;   
        virtual ~ICityGroup() {}; 
    };
 
}
#endif
