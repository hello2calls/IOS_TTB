//
//  QRContentView.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/21.
//
//

#ifndef QRContentView_h
#define QRContentView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define TAG_FIRST_LINE (101)
#define TAG_SECOND_LINE_LEFT (102)
#define TAG_SECOND_LINE_CLICKABLE (103)
#define TAG_SECOND_LINE_RIGH (104)

#define KEY_FIRST_LINE @"firstLine"
#define KEY_LEFT @"left"
#define KEY_CLICKABLE @"clickable"
#define KEY_RIGHT @"right"

@protocol QRContentViewDelegate <NSObject>
- (void) onClickQRImage;
@end

@interface QRContentView : UIView
- (instancetype) initWithFrame:(CGRect)frame status:(NSInteger)currentStatus;

@property (nonatomic, assign) NSInteger status;
@property (nonatomic) id<QRContentViewDelegate> delegate;

- (void) refreshQRImage;
- (BOOL) isGeneratingError;

@end

#endif /* QRContentView_h */
