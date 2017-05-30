//
//  CitySelectRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/8/26.
//
//

#import "CitySelectRowView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIDataManager.h"
#import "LocalStorage.h"
#import "TouchPalDialerAppDelegate.h"
#import "NSString+Draw.h"

@interface CitySelectRowView()
{
    CGPoint startPoint;
    int pressedIndex;
}

@end

@implementation CitySelectRowView
@synthesize model;
@synthesize type;
@synthesize rowIndex;
@synthesize pressed;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:CITY_SELECT_TAG];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    if (self.type == CITY_ITEM_TYPE_TITLE) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CITY_TITLE_NORMAL_BG_COLOR andDefaultColor:nil].CGColor);
    } else if (self.type == CITY_ITEM_TYPE_CONTENT){
        //highlight
        if (self.pressed) {
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CITY_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
        } else {
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CITY_NORMAL_BG_COLOR andDefaultColor:nil].CGColor);
        }
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CITY_NORMAL_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
    
    if (self.type == CITY_ITEM_TYPE_TITLE) {
        //draw title
        NSMutableParagraphStyle *titleStyle= [[NSMutableParagraphStyle alloc] init];
        titleStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        titleStyle.alignment = NSTextAlignmentLeft;
        NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:CITY_ITEM_TITLE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:CITY_ITEM_TITLE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,titleStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize title = [model.capital sizeWithFont:[UIFont systemFontOfSize:CITY_ITEM_TITLE_SIZE] constrainedToSize:CGSizeMake(rect.size.width, CITY_TITLE_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
       
        [model.capital drawInRect:CGRectMake(CITY_ITEM_MARGIN, (CITY_TITLE_HEIGHT - title.height) / 2, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:CITY_ITEM_TITLE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:CITY_ITEM_TITLE_COLOR andDefaultColor:nil]];
        
        
        //draw line
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CITY_BORDER_COLOR andDefaultColor:nil] andFromX:0 andFromY:CITY_TITLE_HEIGHT andToX:rect.size.width andToY:CITY_TITLE_HEIGHT andWidth:1];
    } else if (self.type == CITY_ITEM_TYPE_CONTENT) {
        
        NSString* content = [self.model.value objectAtIndex:rowIndex];
        //draw title
        NSMutableParagraphStyle *contentStyle= [[NSMutableParagraphStyle alloc] init];
        contentStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        contentStyle.alignment = NSTextAlignmentLeft;
        NSDictionary* contentAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:CITY_ITEM_CONTENT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,contentStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize titleSize = [content sizeWithFont:[UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE] constrainedToSize:CGSizeMake(rect.size.width, CITY_CONTENT_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
        
       [content drawInRect:CGRectMake(CITY_ITEM_MARGIN, (CITY_CONTENT_HEIGHT - titleSize.height) / 2, titleSize.width, titleSize.height) withAttributes:contentAttr withFont:[UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:CITY_ITEM_CONTENT_COLOR andDefaultColor:nil]];
        
        //draw line
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CITY_BORDER_COLOR andDefaultColor:nil] andFromX:0 andFromY:CITY_CONTENT_HEIGHT andToX:rect.size.width andToY:CITY_CONTENT_HEIGHT andWidth:1];
    } else {
   
        int indexStart = rowIndex * 3;
        int offset = TPScreenWidth() - TPScreenWidth() / 3 * 3;
        int startX = 0;
        int width = TPScreenWidth() / 3;
        
        if (self.pressed) {
            CGRect pressRect = CGRectMake(pressedIndex * width, 0, width, CITY_CONTENT_HEIGHT);
            CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CITY_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
            CGContextFillRect(context, pressRect);
        }
        while (indexStart < self.model.value.count && indexStart < rowIndex * 3 + 3) {
            if (offset > 0) {
                width = width + 1;
            }
            NSString* content = [self.model.value objectAtIndex:indexStart];
            
            //draw title
            NSMutableParagraphStyle *contentStyle= [[NSMutableParagraphStyle alloc] init];
            contentStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            contentStyle.alignment = NSTextAlignmentCenter;
            NSDictionary* contentAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:CITY_ITEM_CONTENT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,contentStyle, NSParagraphStyleAttributeName, nil];
            
            CGSize titleSize = [content sizeWithFont:[UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE] constrainedToSize:CGSizeMake(width, CITY_CONTENT_HEIGHT) lineBreakMode:NSLineBreakByTruncatingTail];
            
            [content drawInRect:CGRectMake(startX, (CITY_CONTENT_HEIGHT - titleSize.height) / 2, width, titleSize.height) withAttributes:contentAttr withFont:[UIFont systemFontOfSize:CITY_ITEM_CONTENT_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter UIColor:[ImageUtils colorFromHexString:CITY_ITEM_CONTENT_COLOR andDefaultColor:nil]];
            
            //draw line
            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CITY_BORDER_COLOR andDefaultColor:nil] andFromX:startX andFromY:CITY_CONTENT_HEIGHT andToX:startX + width andToY:CITY_CONTENT_HEIGHT andWidth:1];
            
            //draw line
            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CITY_BORDER_COLOR andDefaultColor:nil] andFromX:width + startX andFromY:CITY_HOTKEY_MARGIN andToX:width + startX andToY:CITY_CONTENT_HEIGHT - CITY_HOTKEY_MARGIN andWidth:1];
            
            indexStart++;
            startX = startX + width;
            offset --;
        }
        
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:self];
    if (self.type == CITY_ITEM_TYPE_HOT_CITY) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        int width = TPScreenWidth() / 3;
        pressedIndex = point.x / width;
    } else {
        pressedIndex = 0;
    }
    
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        pressed = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pressed) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect rect = CGRectMake(startPoint.x - CLICK_CANCELED_OFFSET, startPoint.y - CLICK_CANCELED_OFFSET,  2 * CLICK_CANCELED_OFFSET, CLICK_CANCELED_OFFSET);
        if (!CGRectContainsPoint(rect,point)) {
            pressed = NO;
            [self setNeedsDisplay];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (pressed) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            pressed = NO;
            [self setNeedsDisplay];
            
            if ([[UIDataManager instance] checkDoubleClick]) {
                return;
            }
            [self doClick];
        });
    }
    
}

- (void) doClick {
    NSString* city = nil;
    if (self.type == CITY_ITEM_TYPE_TITLE) {
        return;
    } else if(self.type == CITY_ITEM_TYPE_HOT_CITY) {
        city = [self.model.value objectAtIndex:rowIndex * 3 + pressedIndex];
    } else {
        city = [self.model.value objectAtIndex:rowIndex];
    }
    
    //当前选择城市为huangye城市
    [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:city];
    
    int now = [[NSDate date] timeIntervalSince1970];
    [LocalStorage setItemForKey:QUERY_LAST_CACHE_TIME_CITY andValue:[NSString stringWithFormat:@"%d", now]];
    [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
    
}

- (void) resetDataWithCityModel:(CityModel*)cityModel andIndexPath:(NSIndexPath*)indexPath
{

    self.model = cityModel;
    self.type = [CitySelectRowView getType:cityModel andIndexPath:indexPath];
    self.rowIndex = indexPath.row - 1;
    self.indexPath = indexPath;
    
    if (self.type == CITY_ITEM_TYPE_HOT_CITY) {
        self.frame = CGRectMake(0, 0, TPScreenWidth(), CITY_CONTENT_HEIGHT);
    } else {
        if (self.type == CITY_ITEM_TYPE_TITLE) {
            self.frame = CGRectMake(0, 0, TPScreenWidth(), CITY_TITLE_HEIGHT);
        }else{
            self.frame = CGRectMake(0, 0, TPScreenWidth(), CITY_CONTENT_HEIGHT);
        }
    }
    [self setNeedsDisplay];

}

+ (CGFloat) getRowHeight:(CityModel*)cityModel andIndexPath:(NSIndexPath*)indexPath
{
    int rowType = [CitySelectRowView getType:cityModel andIndexPath:indexPath];
    
    if (rowType == CITY_ITEM_TYPE_TITLE) {
        return CITY_TITLE_HEIGHT;
    } else {
        return CITY_CONTENT_HEIGHT;
    }
}

+ (int) getType:(CityModel*)cityModel andIndexPath:(NSIndexPath*)indexPath
{
    int rowType = CITY_ITEM_TYPE_TITLE;
    if (indexPath.row == 0) {
        rowType = CITY_ITEM_TYPE_TITLE;
    } else if([cityModel.capital isEqualToString:@"热门城市"]){
        rowType = CITY_ITEM_TYPE_HOT_CITY;
    } else {
        rowType = CITY_ITEM_TYPE_CONTENT;
    }
    
    return rowType;
}

@end
