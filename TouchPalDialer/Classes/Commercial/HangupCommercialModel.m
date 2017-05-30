//
//  VoipCommercialModel.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import "HangupCommercialModel.h"
#import "CootekNotifications.h"

@implementation HangupCommercialModel

- (void)setMaterial:(NSString *)material {
    [super setMaterial:material];
    if ([material rangeOfString:@"http"].length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            cootek_log(@"ad-voip, material pic downloaded");
            self.materialPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:material]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_LAUNCH_AD_MATERIAL_PIC_DOWNLOADED object:nil];
        });
    }
}

@end
