//
//  CitySelectView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#ifndef TouchPalDialer_CitySelectView_h
#define TouchPalDialer_CitySelectView_h
#import "YPUIView.h"

@class CTUrl;
@interface CitySelectView : YPUIView

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) CTUrl *ctUrl;

- (void) drawView:(NSString*)city;

@end
#endif