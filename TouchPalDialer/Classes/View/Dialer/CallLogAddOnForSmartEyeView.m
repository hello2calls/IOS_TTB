//
//  CallLogAddOnForSmartEyeView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/24/12.
//
//

#import "CallLogAddOnForSmartEyeView.h"
#import "TPDialerResourceManager.h"
#import "AdvancedCalllog.h"

#define MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW ([AdvancedCalllog isShowLogsType] ? 165 : 220)
@implementation CallLogAddOnForSmartEyeView
@synthesize attrLabel_;
@synthesize attr = attr_;
@synthesize callerType = callerType_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        callerTypeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        attrLabel_ = [[HighLightLabel alloc] initWithFrame:CGRectZero];
        //smartEyeView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:callerTypeLabel_];
        [self addSubview:attrLabel_];
        //[self addSubview:smartEyeView_];
        [callerTypeLabel_ release];
        [attrLabel_ release];
        //[smartEyeView_ release];
    }
    return self;
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *properDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"backgroundColor"]];
    callerTypeLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeLabel_text_color"]];
    callerTypeLabel_.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
    callerTypeLabel_.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"callerTypeLabel_background_color"]];
    attrLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"attrLabel_text_color"]];
    
    attrLabel_.highLightColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"attrLabel_highLightText_color"]];
    attrLabel_.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[properDic objectForKey:@"attrLabel_background_color"]];
//    UIImage *smartEyeViewImage = [[TPDialerResourceManager sharedManager] getImageByName:[properDic objectForKey:@"smartEyeView_image"]];
//    smartEyeView_.image = smartEyeViewImage;
//    smartEyeView_.frame = CGRectMake(0, 3, smartEyeViewImage.size.width,smartEyeViewImage.size.height);
    
    return [NSNumber numberWithBool:NO];
}
- (void)setCallerType:(NSString *)callerType{
    if (callerType_) {
        [callerType_ release];
        callerType_ = nil ;
    }
    callerType_ = [callerType retain];
    if([callerType isEqualToString:@""]){
        callerTypeLabel_.hidden = YES;
        attrLabel_.frame = CGRectMake(0, 3, attrLabel_.frame.size.width, attrLabel_.frame.size.height);
    }else{
        callerTypeLabel_.hidden = NO;
        CGSize size = [callerType sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SMALL] constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        CGFloat width = size.width > MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW ? MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW : size.width;
        callerTypeLabel_.frame = CGRectMake(0, 3,width, size.height-2);
        callerTypeLabel_.textAlignment = UITextAlignmentRight;
        callerTypeLabel_.text = callerType;
        CGFloat attrLabelWidth = attrLabel_.frame.size.width;
        CGFloat callerTypeLabelWidth = callerTypeLabel_.frame.size.width;
        attrLabelWidth = attrLabelWidth + callerTypeLabelWidth > MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW ? MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW - callerTypeLabelWidth : attrLabelWidth;
        attrLabel_.frame = CGRectMake(callerTypeLabel_.frame.size.width+5+callerTypeLabel_.frame.origin.x, 3, attrLabelWidth, attrLabel_.frame.size.height);
    }
}
- (void)setAttr:(NSString *)attr{
    if (attr_) {
        [attr_ release];
        attr_ = nil ;
    }
    attr_ = [attr retain];
    CGSize size = [attr sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SMALL] constrainedToSize:CGSizeMake(260, 30)];
    
    CGFloat attrLabelWidth = size.width+50;
    CGFloat attrLabelOriginX = attrLabel_.frame.origin.x;
    attrLabelWidth = attrLabelWidth > MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW ? MAX_LABEL_WIDTH_FOR_SMART_EYE_VIEW : attrLabelWidth;    attrLabel_.frame = CGRectMake(attrLabelOriginX, 3, attrLabelWidth, size.height);
    attrLabel_.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
}
-(void)dealloc{
    [callerType_ release];
    [attr_ release];
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
