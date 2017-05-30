//
//  OrlandoEngine.h
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-9.
//
//

#import "NumberInfoModel.h"

@interface OrlandoEngine : NSObject {
    
}

+ (BOOL) fillNumberInfo:(NumberInfoModel*) data;
+(FILE*) openFile:(NSString*)fileName inFolder:(NSString*)folder;

@end
