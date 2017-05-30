//
//  HighLightView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#ifndef TouchPalDialer_HighLightView_h
#define TouchPalDialer_HighLightView_h

@class HighLightItem;
@interface HighLightView : UIView

@property(nonatomic, retain) HighLightItem* highLightItem;
@property(nonatomic, assign) BOOL drawWithLine;
@property(nonatomic, assign) CGPoint* drawPoints;

- (void)drawView:(HighLightItem*)item andPoints:(CGPoint[])points withLine:(BOOL)drawLine;
- (BOOL)checkIfExpriedWithItem:(HighLightItem *)item ;
@end

#endif
