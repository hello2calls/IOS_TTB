//
//  CouponRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "CouponRowView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "CouponCellView.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "NSString+Draw.h"

@interface CouponRowView(){
    UIImage* couponIcon;
    NSString* url;
}

@end
@implementation CouponRowView
@synthesize couponSection;
@synthesize rowIndexPath;

- (id)initWithFrame:(CGRect)frame andData:(SectionCoupon *)data andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame];
    
    [self resetDataWithCouponItem:data andIndexPath:indexPath];
    [self setTag:COUPON_TAG];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:COUPON_ITEM_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    
    
    int offsetY = 0;
    int offsetX = rect.size.width / 3;
    if (couponSection.isFirst) {
        offsetY = offsetY + COUPON_TITLE_HEIGHT;
        if (self.pressed) {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, rect);
            
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:COUPON_ITEM_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
            CGContextFillRect(context, CGRectMake(rect.origin.x, rect.origin.y + offsetY, rect.size.width, rect.size.height));
        } else {
            CGContextFillRect(context, rect);
        }
    } else {
        CGContextFillRect(context, rect);
    }
    
    if (couponSection.isFirst) {
        //draw title
        NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont systemFontOfSize:COUPON_TITLE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COMMON_TITLE_TEXT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize title = [self.couponSection.title sizeWithFont:[UIFont systemFontOfSize:COUPON_TITLE_SIZE] constrainedToSize:CGSizeMake(rect.size.width - COUPON_MARGIN_LEFT - COUPON_MARGIN_RIGHT, COUPON_TITLE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        
        [self.couponSection.title drawInRect:CGRectMake(COUPON_MARGIN_LEFT, (COUPON_TITLE_HEIGHT - title.height) / 2, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:COUPON_TITLE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:COMMON_TITLE_TEXT_COLOR andDefaultColor:nil]];
    }
    
    CGRect couponRect = CGRectMake(COUPON_ITEM_LOGO_MARGIN, offsetY + COUPON_ITEM_LOGO_MARGIN, rect.size.width / 3 - 20, rect.size.height - offsetY - 20);
    
    CGFloat width = couponRect.size.width;
    CGFloat height = couponRect.size.height;
    CGFloat ratio = width/height;
    
    CGFloat couponWidth = couponIcon.size.width;
    CGFloat couponHeight = couponIcon.size.height;
    CGFloat couponRatio = couponWidth / couponHeight;
    if (ratio > couponRatio) {
        couponHeight = height;
        couponWidth = couponHeight * couponRatio;
        couponRect = CGRectMake(couponRect.origin.x + (width - couponWidth) / 2, couponRect.origin.y, couponWidth, couponRect.size.height);
    } else {
        couponWidth = width;
        couponHeight = couponWidth / couponRatio;
        couponRect = CGRectMake(couponRect.origin.x, couponRect.origin.y + (height - couponHeight) / 2, couponRect.size.width, couponHeight);
    }
    
    [couponIcon drawInRect:couponRect];
    
    //draw line
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:COUPON_BORDER_COLOR andDefaultColor:nil] andFromX:0 andFromY:offsetY andToX:rect.size.width andToY:offsetY andWidth:1];
    
    if (couponSection.coupon.subTitle.length <= 0) {
        offsetY = offsetY + COUPON_ITEM_CONTENT_HEIGHT / 2;
    }
    if (couponSection.coupon.priceSale.length <= 0) {
        offsetY = offsetY + COUPON_ITEM_PRICE_HEIGHT / 2;
    }
    
   offsetY = offsetY + COUPON_MARGIN_TOP;
    //draw title
    NSMutableParagraphStyle *titleStyle= [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    titleStyle.alignment = NSTextAlignmentLeft;
    NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:COUPON_ITEM_TITLE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_TITLE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,titleStyle, NSParagraphStyleAttributeName, nil];
    
    int sizeX = rect.size.width - offsetX - COUPON_ITEM_DIS_WIDTH - COUPON_MARGIN_RIGHT;
    if (self.couponSection.coupon.distance.length == 0) {
        sizeX = rect.size.width - offsetX - COUPON_MARGIN_RIGHT;
    }
    
    CGSize title = [self.couponSection.coupon.title sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_TITLE_SIZE] constrainedToSize:CGSizeMake(sizeX, COUPON_ITEM_TITLE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
    
    [self.couponSection.coupon.title drawInRect:CGRectMake(offsetX, (COUPON_ITEM_TITLE_HEIGHT - title.height) / 2 + offsetY, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_TITLE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_TITLE_COLOR andDefaultColor:nil]];
    
    
    //draw distance
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentRight;
    
    NSDictionary* distanceAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont systemFontOfSize:COUPON_ITEM_DIS_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_DIS_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    CGSize distance = [self.couponSection.coupon.title sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_DIS_SIZE] constrainedToSize:CGSizeMake(rect.size.width - COUPON_MARGIN_RIGHT - COUPON_ITEM_DIS_WIDTH, COUPON_ITEM_TITLE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
    
    [self.couponSection.coupon.distance drawInRect:CGRectMake(rect.size.width - COUPON_MARGIN_RIGHT - COUPON_ITEM_DIS_WIDTH, (COUPON_ITEM_TITLE_HEIGHT - distance.height) / 2 + offsetY, COUPON_ITEM_DIS_WIDTH, distance.height) withAttributes:distanceAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_DIS_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_DIS_COLOR andDefaultColor:nil]];
    
    offsetY = offsetY + COUPON_ITEM_TITLE_HEIGHT;
    
    //draw Content
    NSMutableParagraphStyle *contentStyle= [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    titleStyle.alignment = NSTextAlignmentLeft;
    NSDictionary* contentAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:COUPON_ITEM_CONTENT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_CONTENT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,contentStyle, NSParagraphStyleAttributeName, nil];

   CGSize content = [self.couponSection.coupon.subTitle sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_CONTENT_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - COUPON_MARGIN_RIGHT, COUPON_ITEM_CONTENT_HEIGHT + 15) lineBreakMode:NSLineBreakByTruncatingTail];
    
    NSString* contentStr = self.couponSection.coupon.subTitle;
    int i = contentStr.length;
    while (content.height > COUPON_ITEM_CONTENT_HEIGHT) {
        contentStr = [NSString stringWithFormat:@"%@...", [self.couponSection.coupon.subTitle substringToIndex:i--]];
        content = [contentStr sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_CONTENT_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - COUPON_MARGIN_RIGHT, COUPON_ITEM_CONTENT_HEIGHT + 15) lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    [contentStr drawInRect:CGRectMake(offsetX, (COUPON_ITEM_CONTENT_HEIGHT - content.height) / 2 + offsetY, content.width, content.height) withAttributes:contentAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_CONTENT_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_CONTENT_COLOR andDefaultColor:nil]];
    offsetY = offsetY + COUPON_ITEM_CONTENT_HEIGHT;
    
    
    
    if (self.couponSection.coupon.priceSale.length > 0) {
        //draw price
        NSMutableParagraphStyle *priceStyle= [[NSMutableParagraphStyle alloc] init];
        priceStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        priceStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary* priceAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_PRICE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,priceStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize price = [[NSString stringWithFormat:@"¥%@",self.couponSection.coupon.priceSale] sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - COUPON_MARGIN_RIGHT, COUPON_ITEM_PRICE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        [[NSString stringWithFormat:@"¥%@",self.couponSection.coupon.priceSale] drawInRect:CGRectMake(offsetX, (COUPON_ITEM_PRICE_HEIGHT - price.height) / 2 + offsetY, price.width, price.height) withAttributes:priceAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_PRICE_COLOR andDefaultColor:nil]];
        
        //draw old price
        NSDictionary* oldPriceAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:COUPON_ITEM_OLD_PRICE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_OLD_PRICE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,priceStyle, NSParagraphStyleAttributeName, nil];
        CGSize oldPrice = [[NSString stringWithFormat:@"¥%@",self.couponSection.coupon.price] sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_OLD_PRICE_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - price.width - COUPON_MARGIN_RIGHT, COUPON_ITEM_PRICE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        [[NSString stringWithFormat:@"¥%@",self.couponSection.coupon.price] drawInRect:CGRectMake(offsetX + price.width, (COUPON_ITEM_PRICE_HEIGHT - oldPrice.height) / 2 + offsetY, oldPrice.width, oldPrice.height) withAttributes:oldPriceAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_OLD_PRICE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_OLD_PRICE_COLOR andDefaultColor:nil]];
        
        //draw line
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:COUPON_ITEM_OLD_PRICE_COLOR andDefaultColor:nil] andFromX:offsetX + price.width andFromY:COUPON_ITEM_PRICE_HEIGHT / 2 + offsetY andToX:offsetX + price.width  + oldPrice.width andToY:COUPON_ITEM_PRICE_HEIGHT / 2 + offsetY andWidth:1];
        
        //draw join
        NSMutableParagraphStyle *joinStyle= [[NSMutableParagraphStyle alloc] init];
        joinStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        joinStyle.alignment = NSTextAlignmentRight;
        
        NSDictionary* joinAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_JOIN_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,joinStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize join = [self.couponSection.coupon.join sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - price.width -oldPrice.width - COUPON_MARGIN_RIGHT, COUPON_ITEM_PRICE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        [self.couponSection.coupon.join drawInRect:CGRectMake(offsetX + price.width + oldPrice.width, (COUPON_ITEM_PRICE_HEIGHT - join.height) / 2 + offsetY, rect.size.width - offsetX - price.width - oldPrice.width - COUPON_MARGIN_RIGHT, join.height) withAttributes:joinAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_JOIN_COLOR andDefaultColor:nil]];
    } else {
        //draw join
        NSMutableParagraphStyle *joinStyle= [[NSMutableParagraphStyle alloc] init];
        joinStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        joinStyle.alignment = NSTextAlignmentRight;
        
        NSDictionary* joinAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:COUPON_ITEM_JOIN_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,joinStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize join = [self.couponSection.coupon.join sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE] constrainedToSize:CGSizeMake(rect.size.width - offsetX - COUPON_MARGIN_RIGHT, COUPON_ITEM_PRICE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        [self.couponSection.coupon.join drawInRect:CGRectMake(offsetX, (COUPON_ITEM_PRICE_HEIGHT - join.height) / 2 + offsetY, rect.size.width - offsetX - COUPON_MARGIN_RIGHT, join.height) withAttributes:joinAttr withFont:[UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight UIColor:[ImageUtils colorFromHexString:COUPON_ITEM_JOIN_COLOR andDefaultColor:nil]];
    }
  
    
}


- (void) resetDataWithCouponItem:(SectionCoupon*)item andIndexPath:(NSIndexPath*)indexPath
{
    self.couponSection = item;
    self.rowIndexPath = indexPath;
    
   self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [CouponRowView getRowHeight:item]);
    
    //set icon
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workSpacePath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* filePath = [NSString stringWithFormat:@"%@%@",workSpacePath,item.coupon.iconPath];
    couponIcon = [UIImage imageWithContentsOfFile:filePath];
    url = item.coupon.iconLink;
    if (couponIcon == nil) {
        couponIcon = [ImageUtils getImageFromLocalWithUrl:url];
    }
    if (couponIcon == nil) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    [self setNeedsDisplay];
    
}

+(int) getRowHeight:(SectionCoupon *)item
{
    int offset = 0;
    if (item.isFirst) {
        offset = offset + COUPON_TITLE_HEIGHT;
    }
    offset = offset + COUPON_ITEM_HEIGHT;
    
    return offset;
}

- (void) downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            couponIcon = [ImageUtils getImageFromLocalWithUrl:url];
            [self setNeedsDisplay];
        });
    }
}

- (void) doClick
{
    [couponSection.coupon.ctUrl startWebView];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_COUPON_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title",couponSection.coupon.title), Pair(@"url",couponSection.coupon.ctUrl.url), nil];
}
@end
