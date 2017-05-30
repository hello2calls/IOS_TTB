//
//  EdgeSelector.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-3.
//
//

#import <Foundation/Foundation.h>



@interface IPAddress : NSObject

@property(nonatomic,copy) NSString *host;
@property(nonatomic,assign) int port;

+ (IPAddress *)edgeDataWith:(NSString *)host port:(int)port;

@end

@interface EdgeSelectPara : NSObject

@property (nonatomic, retain) IPAddress *edge;
@property (nonatomic, retain) IPAddress *postBoys;
@property (nonatomic, retain) IPAddress *source;
@property (nonatomic, retain) IPAddress *postKids;

- (id)copy;

@end


@interface EdgeSelector : NSObject

+ (NSString *)postKidsRank:(NSString *)address;

- (id)initWithEdge:(NSArray<IPAddress *> *)edge initPJ:(BOOL)isInit;

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block needRetry:(BOOL)retry;

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block enable2GSelect:(BOOL)enable;

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block enableSchedule:(BOOL)enable;

@end
