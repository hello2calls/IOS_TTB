//
//  SelectSingleView.h
//  TouchPalDialer
//
//  Created by game3108 on 16/4/13.
//
//

#import <Foundation/Foundation.h>

@protocol SelectSingleViewDelegate <NSObject>
- (void)select:(NSDictionary *)dict;
@end

@interface SelectSingleView : UIView
@property (nonatomic, weak) id<SelectSingleViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andSelectArray:(NSArray *)selectArray;
@end
