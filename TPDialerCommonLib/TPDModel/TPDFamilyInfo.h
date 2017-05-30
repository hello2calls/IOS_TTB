//
//  TPDFamilyInfo.h
//  TouchPalDialer
//
//  Created by weyl on 17/1/20.
//
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface TPDFamilyInfoItem: NSObject
@property (nonatomic,strong) NSString* phone;
@property (nonatomic,strong) NSString* contacts_name;
@property (nonatomic,strong) NSString* update_time;
@property (nonatomic,strong) NSString* label;
@property (nonatomic) NSInteger type;
@end


@interface TPDFamilyInfo : NSObject
@property (nonatomic,strong) NSArray* bind_success_list;
@property (nonatomic,strong) NSArray* binding_refused_list;
@property (nonatomic,strong) NSArray* news_list;
@property (nonatomic) NSInteger error_code;

+(RACSignal*)familyInfoSignal;
-(BOOL)isFamilyNumber:(NSString*)number;
+(TPDFamilyInfo*)getFamilyInfoDetail;
+(BOOL)bindFamily:(NSString*)number name:(NSString*)name;
@end

@interface TPDFamilyInfoIndex : NSObject
@property (nonatomic) NSInteger error_code;
@property (nonatomic) NSInteger has_binded_success;
@property (nonatomic) NSInteger news_num;

+(TPDFamilyInfoIndex*)getFamilyInfoIndex;
@end
