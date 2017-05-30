//
//  CouponCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-19.
//
//

#import "CouponCellView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "CTUrl.h"

@interface CouponCellView()
{
    NSString* url;
}

@end
@implementation CouponCellView

- (id) initWithFrame:(CGRect)frame andCouponItem:(CouponItem *)couponItem
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    
    int offsetY = 0;
    //set title
    int startX = frame.size.width / 3;
    self.title = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(startX, offsetY, self.frame.size.width - startX - COUPON_ITEM_DIS_WIDTH - COUPON_MARGIN_RIGHT, COUPON_ITEM_TITLE_HEIGHT)];
    self.title.verticalAlignment = VerticalAlignmentMiddle;
    self.title.font = [UIFont systemFontOfSize:COUPON_ITEM_TITLE_SIZE];
    self.title.lineBreakMode = NSLineBreakByTruncatingTail;
    self.title.numberOfLines = 1;
    [self addSubview:self.title];
    
    //set distance
    self.distance = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.frame.size.width - COUPON_ITEM_DIS_WIDTH - COUPON_MARGIN_RIGHT, offsetY, COUPON_ITEM_DIS_WIDTH, COUPON_ITEM_TITLE_HEIGHT)];
    self.distance.verticalAlignment = VerticalAlignmentMiddle;
    self.distance.font = [UIFont systemFontOfSize:COUPON_ITEM_DIS_SIZE];
    self.distance.textAlignment = NSTextAlignmentRight;
    self.distance.lineBreakMode = NSLineBreakByTruncatingTail;
    self.distance.numberOfLines = 1;
    self.distance.textColor = [ImageUtils colorFromHexString:COUPON_ITEM_DIS_COLOR andDefaultColor:nil];
    [self addSubview:self.distance];
    
    //set
    offsetY = offsetY + COUPON_ITEM_TITLE_HEIGHT;
    self.content = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(startX, offsetY, self.frame.size.width - startX - COUPON_MARGIN_RIGHT, COUPON_ITEM_CONTENT_HEIGHT)];
    self.content.verticalAlignment = VerticalAlignmentMiddle;
    self.content.font = [UIFont systemFontOfSize:COUPON_ITEM_CONTENT_SIZE];
    self.content.lineBreakMode = NSLineBreakByTruncatingTail;
    self.content.numberOfLines = 2;
    self.content.textAlignment = NSTextAlignmentLeft;
    self.content.textColor = [ImageUtils colorFromHexString:COUPON_ITEM_CONTENT_COLOR andDefaultColor:nil];
    [self addSubview:self.content];
    
    self.currentPrice = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(startX, self.content.frame.origin.y, 0, COUPON_ITEM_PRICE_HEIGHT)];
    self.currentPrice.verticalAlignment = VerticalAlignmentMiddle;
    self.currentPrice.font = [UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE];
    self.currentPrice.lineBreakMode = NSLineBreakByTruncatingTail;
    self.currentPrice.numberOfLines = 1;
    self.currentPrice.textAlignment = NSTextAlignmentLeft;
    self.currentPrice.textColor = [ImageUtils colorFromHexString:COUPON_ITEM_PRICE_COLOR andDefaultColor:nil];
    [self addSubview:self.currentPrice];
    
    
    self.oldPrice = [[UILabelStrikeThrough alloc]initWithFrame:CGRectMake(startX + self.currentPrice.frame.size.width, self.content.frame.origin.y, 0, COUPON_ITEM_PRICE_HEIGHT)];
    self.oldPrice.verticalAlignment = VerticalAlignmentMiddle;
    self.oldPrice.font = [UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE];
    self.oldPrice.lineBreakMode = NSLineBreakByTruncatingTail;
    self.oldPrice.numberOfLines = 1;
    self.oldPrice.textAlignment = NSTextAlignmentLeft;
    self.oldPrice.textColor = [ImageUtils colorFromHexString:COUPON_ITEM_OLD_PRICE_COLOR andDefaultColor:nil];
    [self addSubview:self.oldPrice];
    
    self.join = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(startX + self.oldPrice.frame.size.width, self.content.frame.origin.y, 0, COUPON_ITEM_PRICE_HEIGHT)];
    self.join.verticalAlignment = VerticalAlignmentMiddle;
    self.join.font = [UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE];
    self.join.lineBreakMode = NSLineBreakByTruncatingTail;
    self.join.numberOfLines = 1;
    self.join.textAlignment = NSTextAlignmentLeft;
    self.join.textColor = [ImageUtils colorFromHexString:COUPON_ITEM_JOIN_COLOR andDefaultColor:nil];
    self.join.backgroundColor = [UIColor redColor];
    [self addSubview:self.join];
    
    [self resetWithCouponData:couponItem andRect:self.frame];
    
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:COUPON_ITEM_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGRect couponRect = CGRectMake(COUPON_ITEM_LOGO_MARGIN, COUPON_ITEM_LOGO_MARGIN, rect.size.width / 3 - 20, rect.size.height - 20);
    
    CGFloat width = couponRect.size.width;
    CGFloat height = couponRect.size.height;
    CGFloat ratio = width/height;
    
    CGFloat couponWidth = self.couponIcon.size.width;
    CGFloat couponHeight = self.couponIcon.size.height;
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
    
    [self.couponIcon drawInRect:couponRect];
    
    
    CGSize sizePrice = [self.currentPrice.text sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width - self.currentPrice.frame.origin.x - COUPON_MARGIN_RIGHT, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    
    self.currentPrice.frame = CGRectMake(self.currentPrice.frame.origin.x, self.content.frame.origin.y + COUPON_ITEM_CONTENT_HEIGHT, sizePrice.width, COUPON_ITEM_PRICE_HEIGHT);
    
    CGSize sizeOldPrice = [self.oldPrice.text sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_PRICE_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width - self.currentPrice.frame.origin.x - self.currentPrice.frame.size.width - COUPON_MARGIN_RIGHT, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    
    self.oldPrice.frame = CGRectMake(self.currentPrice.frame.origin.x + self.currentPrice.frame.size.width, self.content.frame.origin.y + COUPON_ITEM_CONTENT_HEIGHT, sizeOldPrice.width, COUPON_ITEM_PRICE_HEIGHT);
    
    CGSize sizeJoin = [self.join.text sizeWithFont:[UIFont systemFontOfSize:COUPON_ITEM_JOIN_SIZE] constrainedToSize:CGSizeMake(1000, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    self.join.frame = CGRectMake(self.oldPrice.frame.origin.x + self.oldPrice.frame.size.width, self.content.frame.origin.y + COUPON_ITEM_CONTENT_HEIGHT, sizeJoin.width, COUPON_ITEM_PRICE_HEIGHT);
    
}

- (void) drawView:(CouponItem*) couponItem
{
    
    //set icon
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workSpacePath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* filePath = [NSString stringWithFormat:@"%@%@",workSpacePath,couponItem.iconPath];
    self.couponIcon = [UIImage imageWithContentsOfFile:filePath];
    url = couponItem.iconLink;
    if (self.couponIcon == nil) {
        self.couponIcon = [ImageUtils getImageFromLocalWithUrl:url];
    }
    if (self.couponIcon == nil) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    
    //set values
    self.title.text = couponItem.title;
    self.distance.text = couponItem.distance;
    self.content.text = couponItem.subTitle;
    self.currentPrice.text = couponItem.price;
    self.oldPrice.text = couponItem.priceSale;
    self.join.text = couponItem.join;
    
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font
                         constrainedToSize:CGSizeMake(self.title.bounds.size.width,
                                                      self.title.font.lineHeight)
                             lineBreakMode:NSLineBreakByTruncatingTail];
    self.title.bounds = CGRectMake(0, 0,
                              titleSize.width,
                              titleSize.height);
   
    CGSize contentSize = [self.content.text sizeWithFont:self.content.font
                                   constrainedToSize:CGSizeMake(self.content.bounds.size.width,
                                                                2 * self.content.font.lineHeight)
                                       lineBreakMode:NSLineBreakByTruncatingTail];
    self.content.bounds = CGRectMake(0, 0,
                                   contentSize.width,
                                   contentSize.height);
    
    [self setNeedsDisplay];
    
}

- (void) resetWithCouponData:(CouponItem*)couponData andRect:(CGRect)rect
{
    self.frame = rect;
    [self drawView:couponData];
}

- (void) doClick
{
    
}

- (void) downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.couponIcon = [ImageUtils getImageFromLocalWithUrl:url];
            [self setNeedsDisplay];
        });
    }
}

@end
