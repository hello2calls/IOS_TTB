//
//  UpdateService.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-24.
//
//

#ifndef TouchPalDialer_UpdateService_h
#define TouchPalDialer_UpdateService_h

@interface UpdateService : NSObject

+ (id)instance;
-(void) initZipFromLocal;
-(void) run;
-(void) deploy;
-(void) requestForIndexData:(NSString*) url;
//-(void) requestNewsData:(NSString *)queryId withBlock:(void (^)(NSMutableArray *))block;
-(NSMutableArray *) requestForNews:(NSString *)url;
-(NSMutableArray *) requestForAds:(NSString *)url;
-(void) requestForMiniBannerData:(NSString*) url;
-(void) requestServiceBottomData:(NSString*) url withServiceId:(NSString*)serviceId;
-(void) checkDeployForLocalZip;
-(NSString*) getSelectedCity:(NSString*) city;
-(NSString*) getWebSearchPath;
-(void) requestForWeatherData;
-(void) requestForCUrl:(NSString*) url;
-(NSDictionary *)requestUrlWithDicResult:(NSString *)url;

+ (NSString *) generateParamsWithDictionary:(NSDictionary *)parasDic;
+ (NSString *) createNormalParams;

@end
#endif
