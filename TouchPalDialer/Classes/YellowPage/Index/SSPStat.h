//
//  SSPStat.h
//  TouchPalDialer
//
//  Created by tanglin on 16/6/14.
//
//

#import <Foundation/Foundation.h>

#define SSPID_ALL 0
#define SSPID_DAVINCI 1
#define SSPID_BAIDU 100
#define SSPID_GDT 101

#define TU_FEEDS 3

@interface SSPStat : NSObject
@property(nonatomic, strong) NSMutableDictionary* mSCached;

+ (instancetype) instance;

- (NSString *) requestWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andPlacementId:(NSString*)placementId;
- (NSString *) requestWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andPlacementId:(NSString*)placementId andFtu:(NSInteger)ftu;
- (void) filledWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn;
- (void) filledWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andS:(NSString*)s andFtu:(NSInteger) ftu;
- (void) edWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andExpId:(NSInteger)expid andTitle:(NSString*)title andDesc:(NSString*)desc andS:(NSString*)s andFtu:(NSInteger)ftu;
- (void) edWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andExpId:(NSInteger)expid andTitle:(NSString*)title andDesc:(NSString*)desc;
- (void) clickWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andS:(NSString*)s andFtu:(NSInteger)ftu;
- (void) clickWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank;


@end
