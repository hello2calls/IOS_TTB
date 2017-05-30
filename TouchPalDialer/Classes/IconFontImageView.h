//
//  IconFontImageView.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/11/24.
//
//

#ifndef IconFontImageView_h
#define IconFontImageView_h
#import "VerticallyAlignedLabel.h"
#import "CategoryItem.h"
@interface IconFontImageView : UIView
@property(nonatomic, retain)UIImage *icon;
@property(nonatomic, retain)BaseItem* item;
@property(nonatomic, retain)VerticallyAlignedLabel* label;
@property(nonatomic, assign)CGFloat labelFontSize;
@property(nonatomic, assign)BOOL pressed;
@property(nonatomic, assign)CGRect iconFontImageRect;
@property(nonatomic, retain)NSString* url;
@property(nonatomic, retain)UIFont* font;
- (id) initWithFrame:(CGRect)frame;
- (void) resetFrameWithData:(BaseItem *)item;
@end

#endif /* IconFontImageView_h */
