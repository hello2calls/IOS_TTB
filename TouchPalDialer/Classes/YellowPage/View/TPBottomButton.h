//
//  TPBottomButton.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-11.
//
//

#import <Foundation/Foundation.h>
#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"
#import "CTUrl.h"

@interface TPBottomButton : YPUIView

@property(nonatomic, retain) VerticallyAlignedLabel *title;
@property(nonatomic, retain) CTUrl *url;
@property(nonatomic, retain) NSString *serviceRateUrl;
@property(nonatomic, retain) NSString* serviceRate;
- (void) drawView:(NSDictionary*)json;
- (void) drawViewForService:(NSDictionary *)json;

- (id) initWithFrame:(CGRect)frame;
@end
