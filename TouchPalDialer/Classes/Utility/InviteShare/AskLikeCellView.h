//
//  AskLikeCellView.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/10.
//
//

#import <UIKit/UIKit.h>

@protocol AskLikeCellViewDelegate <NSObject>
- (void)onButtonClick:(NSString *)phone isSelect:(BOOL)isSelect;
@end

@interface AskLikeCellView : UIButton
@property (nonatomic, weak) id<AskLikeCellViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSelect;
- (instancetype) initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict;
@end
