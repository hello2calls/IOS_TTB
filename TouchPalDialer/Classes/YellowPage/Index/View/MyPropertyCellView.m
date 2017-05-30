//
//  MyPropertyCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "MyPropertyCellView.h"

#import <Foundation/Foundation.h>
#import "CategoryCellView.h"
#import "TPDialerResourceManager.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIDataManager.h"
#import "CTUrl.h"
#import "YellowPageWebViewController.h"
#import "YellowPageMainTabController.h"
#import "HighLightView.h"
#import "HighLightItem.h"
#import "UpdateService.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"
#import "PersonInfoDescViewController.h"
#import "IndexJsonUtils.h"
#import "AccountInfoManager.h"
#import "NSDictionary+Default.h"
#import "MarketLoginController.h"
#import "FunctionUtility.h"
@interface MyPropertyCellView(){
    NSInteger itemType;
    NSInteger rowIndex;
    NSInteger columnIndex;
    HighLightView* highLightView;
    NSInteger contentType;
    NSString* categoryType;
    BOOL isLogin;
    CategoryItem* categoryItem;
}
@property(nonatomic,retain) SectionMyProperty* propertyData;
@property(nonatomic,retain) VerticallyAlignedLabel* numberLabel;
@property(nonatomic,retain) VerticallyAlignedLabel* titleLabel;
@end
@implementation MyPropertyCellView

- (id)initWithFrame:(CGRect)frame andContentType:(NSInteger) type
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    contentType = type;
    
    VerticallyAlignedLabel* labelTop = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, MY_PROPERTY_TOP_MARGIN, frame.size.width, frame.size.height / 2 - MY_PROPERTY_TOP_MARGIN)];
    labelTop.textColor = [self drawLabelColor];
    labelTop.textAlignment = NSTextAlignmentCenter;
    labelTop.verticalAlignment = VerticalAlignmentTop;
    labelTop.userInteractionEnabled = YES;
    [self addSubview:labelTop];
    self.numberLabel = labelTop;
    self.numberLabel.font = [UIFont systemFontOfSize:MY_PROPERTY_TEXT_TOP_SIZE];
    
    VerticallyAlignedLabel* labelBottom = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, frame.size.height / 2, frame.size.width, frame.size.height / 2 - MY_PROPERTY_BOTTOM_MARGIN)];
    if ([self checkUserLoginState]) {
        labelBottom.textColor = [ImageUtils colorFromHexString:MY_PROPERTY_TEXT_COLOR andDefaultColor:nil];
    } else {
        labelBottom.textColor = [ImageUtils colorFromHexString:MY_PROPERTY_TEXT_ERROR_COLOR andDefaultColor:nil];
    }
    labelBottom.textAlignment = NSTextAlignmentCenter;
    labelBottom.verticalAlignment = VerticalAlignmentBottom;
    labelBottom.userInteractionEnabled = YES;
    [self addSubview:labelBottom];
    self.titleLabel = labelBottom;
    self.titleLabel.font = [UIFont systemFontOfSize:MY_PROPERTY_TEXT_BOTTOM_SIZE];
    
    
    highLightView = [[HighLightView alloc]initWithFrame:self.bounds];
    [self addSubview:highLightView];
    
    return self;
}

- (UIColor* )drawLabelColor {
    if (![self checkUserLoginState]) {
        return [ImageUtils colorFromHexString:MY_PROPERTY_TEXT_ERROR_COLOR andDefaultColor:nil];
    }
    
    switch (contentType) {
        case MY_VIP_INFO:
            return [ImageUtils colorFromHexString:MY_VIP_INFO_COLOR andDefaultColor:nil];
        case MY_WALLET_INFO:
            return [ImageUtils colorFromHexString:MY_WALLET_INFO_COLOR andDefaultColor:nil];
        case MY_FREE_MINUTES_INFO:
            return [ImageUtils colorFromHexString:MY_FREE_MINUTES_INFO_COLOR andDefaultColor:nil];
        case MY_TRAFFIC_INFO:
            return [ImageUtils colorFromHexString:MY_TRAFFIC_INFO_COLOR andDefaultColor:nil];
        case MY_CARD_INFO:
            return [ImageUtils colorFromHexString:MY_CARD_INFO_COLOR andDefaultColor:nil];
        default:
            return [ImageUtils colorFromHexString:MY_PROPERTY_TEXT_COLOR andDefaultColor:nil];
    }
}

- (BOOL)checkUserLoginState {
    if ( [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN ]) {
        return YES;
    }
    return NO;
}

- (NSString *) getShowNumber:(int) realNum {
    if (realNum >= 10000) {
        return @"9999+";
    }
    
    return [NSString stringWithFormat:@"%d", realNum];
}

- (NSString *) getShowFloatNumber:(float) realNum {
    NSString *stringValue = nil;
    if (realNum <= 9999.99) {
        if (realNum>99.99) {
            float pointFloat = realNum-(int)realNum;
            if (pointFloat==0) {
                stringValue = [NSString stringWithFormat:@"%d", (int)realNum];
            } else {
                stringValue = [NSString stringWithFormat:@"%d+", (int)realNum];
            }
        } else {
            stringValue =  [NSString stringWithFormat:@"%.2f", realNum];
        }
    } else {
        stringValue = @"9999+";
    }
    
    return stringValue;
}

- (void)jumpToCard {
    NSString *url = [NSString stringWithFormat:@"http://search.cootekservice.com/page_v3/activity_recharge_price.html?_token=%@", [SeattleFeatureExecutor getToken]];
    MarketLoginController *market = [MarketLoginController withOrigin:@"personal_center_wallet_card"];
    market.url = url;
    market.title = @"我的卡券";
    [LoginController checkLoginWithDelegate:market];
}

- (void)drawLabelText {
    
    switch (contentType) {
        case MY_VIP_INFO:
            if (isLogin) {
                self.numberLabel.text = [self getShowNumber:[UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY]];
            } else {
                self.numberLabel.font = [UIFont fontWithName:IPHONE_ICON_2 size:MY_PROPERTY_TEXT_TOP_SIZE];
                self.numberLabel.text = @"S";
            }
            self.titleLabel.text = @"VIP";
            categoryType = PROPERTY_VIP;
            break;
        case MY_WALLET_INFO:
            if (isLogin) {
                self.numberLabel.text = [self getShowFloatNumber:[[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"coins"] floatValue]];
            } else {
                self.numberLabel.font = [UIFont fontWithName:IPHONE_ICON_1 size:MY_PROPERTY_TEXT_TOP_SIZE];
                self.numberLabel.text = @"j";
            }
            self.titleLabel.text = @"零钱";
            categoryType = PROPERTY_WALLET;
            break;
        case MY_FREE_MINUTES_INFO:
            if (isLogin) {
                self.numberLabel.text = [self getShowNumber:[[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"minutes"] intValue]];
            } else {
                self.numberLabel.font = [UIFont fontWithName:IPHONE_ICON_3 size:MY_PROPERTY_TEXT_TOP_SIZE];
                self.numberLabel.text = @"D";
            }
            self.titleLabel.text = @"免费时长";
            categoryType = PROPERTY_MINUTES;
            break;
        case MY_TRAFFIC_INFO:
            if (isLogin) {
                self.numberLabel.text = [self getShowFloatNumber:[[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"bytes_f"] floatValue]];
            } else {
                self.numberLabel.font = [UIFont fontWithName:IPHONE_ICON_1 size:MY_PROPERTY_TEXT_TOP_SIZE];
                self.numberLabel.text = @"m";
            }
            self.titleLabel.text = @"流量";
            categoryType = PROPERTY_TRAFFIC;
            break;
        case MY_CARD_INFO:
            if (isLogin) {
                self.numberLabel.text = [self getShowNumber:[[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"cards"] intValue]];
            } else {
                self.numberLabel.font = [UIFont fontWithName:IPHONE_ICON_1 size:MY_PROPERTY_TEXT_TOP_SIZE];
                self.numberLabel.text = @"o";
            }
            self.titleLabel.text = @"卡券";
            categoryType = PROPERTY_CARDS;
            break;
        default:
            break;
    }
}

-(NSString *)notRounding:(float)price afterPoint:(int)position{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
    
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed && isLogin) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MY_PROPERTY_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    CGFloat fromX = 0;
    CGFloat fromY = 0;
    CGFloat toY = rect.size.height;
    CGFloat toX = rect.size.width;
    

    
    //draw top line
//    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:toX andToY:fromY andWidth:MY_PROPERTY_BORDER_WIDTH];
    
    //draw bottom line
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:toY andToX:toX andToY:toY andWidth:MY_PROPERTY_BORDER_WIDTH];
    
    switch (itemType) {
        case CATEGORY_ITEM_TYPE_END:
        {
            //draw right line
//            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:toX andFromY:fromY andToX:toX andToY:toY andWidth:MY_PROPERTY_BORDER_WIDTH];
            //draw left line
            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY + COMMON_MARGIN_LINE_SIZE andToX:fromX andToY:toY - COMMON_MARGIN_LINE_SIZE andWidth:MY_PROPERTY_BORDER_WIDTH];
            break;
        }
        case CATEGORY_ITEM_TYPE_START:
            //draw left line
//            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:fromX andToY:toY andWidth:MY_PROPERTY_BORDER_WIDTH];
            break;
        case CATEGORY_ITEM_TYPE_NORMAL:
        {
            //draw left line
            [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY + COMMON_MARGIN_LINE_SIZE andToX:fromX andToY:toY - COMMON_MARGIN_LINE_SIZE andWidth:MY_PROPERTY_BORDER_WIDTH];
            break;
        }
        default:
            break;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (itemType == CATEGORY_ITEM_TYPE_NONE) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void) resetWithMyProperty:(SectionMyProperty *)myProperty andRowIndex:(NSInteger)rowIdx andColumnIndex:(NSInteger)columnIdx
{
    self.propertyData = myProperty;
    rowIndex = rowIdx;
    columnIndex = columnIdx;
}

- (void) drawView
{
//    self.numberLabel.text = categoryItem.subTitle;
//    self.titleLabel.text = categoryItem.title;
   
    isLogin = [self checkUserLoginState];
    [self drawLabelText];
   
    categoryItem = [CategoryItem new];
    categoryItem.identifier = [NSString stringWithFormat:@"%@_%@" ,@"asset", categoryType];
    categoryItem.highlightItem = [[HighLightItem alloc]initWithJson:[[UIDataManager instance].assetDic objectForKey:categoryType]];
    if (categoryItem.highlightItem.hiddenOnclick) {
        [IndexJsonUtils addClickHiddenInfo:[NSString stringWithFormat:@"%@_%@",categoryItem.identifier, categoryItem.highlightItem.highlightStart.stringValue]];
    }
    
    if (isLogin) {
        if ([categoryItem shouldShowHighLight] && [highLightView checkIfExpriedWithItem:categoryItem.highlightItem]) {
            [self drawHighLightView:categoryItem.highlightItem];
        } else {
            BOOL isUpdate = [[UserDefaultsManager dictionaryForKey:ACCOUNTINFOUPDATEFLAGS] objectForKey:categoryType withDefaultBoolValue:NO];
            if (isUpdate ) {
                categoryItem.highlightItem.type = STYLE_HIGHLIGHT_TYPE_REDPOINT;
                [self drawHighLightView:categoryItem.highlightItem];
            } else {
                [self drawHighLightView:nil];
            }
    }
    }else {
        [self drawHighLightView:nil];
    }
    [self setType];
    [self setNeedsDisplay];
}

- (void) drawHighLightView:(HighLightItem*)highLightItem
{
    if (highLightItem && highLightItem.type.length > 0) {
        if ([STYLE_HIGHLIGHT_TYPE_REDPOINT isEqualToString:highLightItem.type]) {
            
            CGPoint* points = (CGPoint*)malloc(1*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width * 5 / 6, self.bounds.size.height * 1 / 5);
            [highLightView drawView:highLightItem andPoints:points withLine:NO];
        } else if ([STYLE_HIGHLIGHT_TYPE_NORMAL isEqualToString:highLightItem.type]
                   || [STYLE_HIGHLIGHT_TYPE_RECTANGLE isEqualToString:highLightItem.type]) {
            CGPoint* points = (CGPoint*)malloc(4*sizeof(CGPoint));
            points[0] = CGPointMake(self.bounds.size.width / 4, 0);
            [highLightView drawView:highLightItem andPoints:points withLine:YES];
        } else {
            [highLightView drawView:nil andPoints:nil withLine:NO];
        }
        
    } else {
        [highLightView drawView:nil andPoints:nil withLine:NO];
    }
}

- (void) setType
{
    
    if (columnIndex == 0) {
        itemType = CATEGORY_ITEM_TYPE_START;
    } else if (columnIndex <  MY_PROPERTY_COLUMN_COUNT - 1) {
        itemType = CATEGORY_ITEM_TYPE_NORMAL;
    } else {
        itemType = CATEGORY_ITEM_TYPE_END;
    }
    
}

- (void) doClick
{
    if (isLogin) {
        [categoryItem hideClickHiddenInfo];
        [FunctionUtility setDicInUserManageWithObject:@0 withObjectKey:categoryType withDicKey:ACCOUNTINFOUPDATEFLAGS];
        switch (contentType) {
            case MY_VIP_INFO:
            {
                UIViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel PrivilegaModel] andPageType:FIND_WALLET_PROPERTY_VIP_KEY];
                [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
                dispatch_async([SeattleFeatureExecutor getQueue], ^{
                    [SeattleFeatureExecutor getAccountNumbersInfo];
                    [SeattleFeatureExecutor queryVOIPAccountInfo];
                });
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_VIP kvs:Pair(@"action", @"selected"), nil];
                break;
            }
            case MY_WALLET_INFO:
            {
                PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel backFeeModel] andPageType:FIND_WALLET_PROPERTY_WALLET_KEY];
                [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_COIN kvs:Pair(@"action", @"selected"), nil];
                break;
            }
            case MY_FREE_MINUTES_INFO:
            {
                PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel freeFeeModel] andPageType:FIND_WALLET_PROPERTY_MINUTES_KEY];
                [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_MINUTES kvs:Pair(@"action", @"selected"), nil];
                break;
            }
            case MY_TRAFFIC_INFO:
            {
                PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel trafficModel] andPageType:FIND_WALLET_PROPERTY_TRAFFIC_KEY];
                [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_TRAFFIC kvs:Pair(@"action", @"selected"), nil];
                break;
            }
            case MY_CARD_INFO:
            {
                [self jumpToCard];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_CARD kvs:Pair(@"action", @"selected"), nil];
                break;
            }
            default:
                break;
        }

    }
}

@end
