//
//  TPDFamilyInfo.m
//  TouchPalDialer
//
//  Created by weyl on 17/1/20.
//
//

#import "TPDFamilyInfo.h"
#import "TPDLib.h"
#import "ASIWrapper.h"
#import "SeattleFeatureExecutor.h"
#import <MJExtension.h>
@implementation TPDFamilyInfoItem

@end


@implementation TPDFamilyInfo
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"bind_success_list":[TPDFamilyInfoItem class],
             @"binding_refused_list":[TPDFamilyInfoItem class],
             @"news_list":[TPDFamilyInfoItem class]
             };
}

+(RACSignal*)familyInfoSignal{

    
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        TPDFamilyInfo* f = [TPDFamilyInfo getFamilyInfoDetail];
        [subscriber sendNext:f];
        return nil;
    }] subscribeOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]]  replay] deliverOnMainThread];
}

-(BOOL)isFamilyNumber:(NSString*)number{
    for (TPDFamilyInfoItem* item in self.bind_success_list) {
        if ([item.phone isEqualToString:number]) {
            return YES;
        }
    }
    return NO;
}

+(TPDFamilyInfo*)getFamilyInfoDetail{
   NSString* url = @"http://search.cootekservice.com/page_v3/activity_family_detail";
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    wrapper.pathStr = url;
    wrapper.params = @{@"_token":[SeattleFeatureExecutor getToken]};
    wrapper.responseStructKey = @"result";
    [ASIWrapper getRequest:wrapper];

    if (wrapper.success) {
        NSLog(@"%@",wrapper.cache);
        NSDictionary* info = wrapper.responseStruct;
        TPDFamilyInfo* ret = [TPDFamilyInfo mj_objectWithKeyValues:info];
        return ret;
    }else
        return nil;
    
}

+(BOOL)bindFamily:(NSString*)number name:(NSString*)name{
    NSString* url = @"http://search.cootekservice.com/page_v3/activity_family_bind";
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    wrapper.pathStr = url;
    wrapper.params = @{@"_token":[SeattleFeatureExecutor getToken],
                       @"phone":number,
                       @"label":@"",
                       @"contacts_name":name,
                       @"is_binding_eachother":@"true"
                       };
    wrapper.responseStructKey = @"result";
    [ASIWrapper getRequest:wrapper];
    
    if (wrapper.success) {
        NSLog(@"%@",wrapper.cache);
        NSDictionary* info = wrapper.responseStruct;
        TPDFamilyInfo* ret = [TPDFamilyInfo mj_objectWithKeyValues:info];
        return ret;
    }else
        return nil;

}
//+(void)load{
//    [self getFamilyInfoDetail];
//}

@end

@implementation TPDFamilyInfoIndex
+(TPDFamilyInfoIndex*)getFamilyInfoIndex{
    NSString* url = @"http://search.cootekservice.com/page_v3/activity_family_index";
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    wrapper.pathStr = url;
    wrapper.params = @{@"_token":[SeattleFeatureExecutor getToken]};
    wrapper.responseStructKey = @"result";
    [ASIWrapper getRequest:wrapper];
    
    if (wrapper.success) {
        NSLog(@"%@",wrapper.cache);
        NSDictionary* info = wrapper.responseStruct;
        TPDFamilyInfoIndex* ret = [TPDFamilyInfoIndex mj_objectWithKeyValues:info];
        return ret;
    }else
        return nil;
    
}
@end

