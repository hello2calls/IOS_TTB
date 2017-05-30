//
//  MyTaskAnimationView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/18.
//
//

#import "MyTaskAnimationView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "PublicNumberMessageView.h"
#import "NSString+Draw.h"
#import "AccountInfoManager.h"

@implementation MyTaskAnimationView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];

    CGRect rectIcon = CGRectMake(MY_TASK_ICON_LEFT_MARGIN, MY_TASK_ICON_TOP_MARGIN, MY_TASK_ICON_WIDTH, MY_TASK_ICON_WIDTH);
    
    
    NSDictionary* attrTitle = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:MY_TASK_TITLE_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_TITLE_TEXT_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
    
    CGSize size = [self.task.title sizeWithFont:[UIFont systemFontOfSize:MY_TASK_TITLE_TEXT_SIZE]];
    CGFloat startX = MY_TASK_ICON_LEFT_MARGIN * 2 + MY_TASK_ICON_WIDTH;
    CGFloat startY = MY_TASK_TITLE_TOP_MARGIN_ONE;
    
    
    [self.icon drawInRect:rectIcon];
    
    NSString* vip = nil;
    if ([[self.task.rewards allKeys] containsObject:PROPERTY_VIP]) {
        NSNumber* value = [self.task.rewards objectForKey:PROPERTY_VIP];
        vip = [NSString stringWithFormat:@"VIP +%@天", [value stringValue]];
    }
    
    NSString* minutes = nil;
    if ([[self.task.rewards allKeys] containsObject:PROPERTY_MINUTES]) {
        NSNumber* value = [self.task.rewards objectForKey:PROPERTY_MINUTES];
        minutes = [NSString stringWithFormat:@"免费时长 +%@分钟", [value stringValue]];
    }
    
    NSString* wallet = nil;
    if ([[self.task.rewards allKeys] containsObject:PROPERTY_WALLET]) {
        NSNumber* value = [self.task.rewards objectForKey:PROPERTY_WALLET];
        wallet = [NSString stringWithFormat:@"零钱 +%.2f元", [value floatValue]];
    }
    
    NSString* traffic = nil;
    if ([[self.task.rewards allKeys] containsObject:PROPERTY_TRAFFIC]) {
        NSNumber* value = [self.task.rewards objectForKey:PROPERTY_TRAFFIC];
        traffic = [NSString stringWithFormat:@"流量 +%@M", [value stringValue]];
    }
    
    NSString* divider = @" | ";
    NSString* total = [NSString stringWithFormat:@"%@%@%@%@",vip ? [NSString stringWithFormat:@"%@ | ",vip] : @"", minutes ? [NSString stringWithFormat:@"%@ | ", minutes] : @"", wallet ? [NSString stringWithFormat:@"%@ | ", wallet] : @"", traffic ? traffic : @""];
    
    CGFloat width = rect.size.width - startX - MY_TASK_ICON_LEFT_MARGIN - MY_TASK_ICON_LEFT_MARGIN;
    CGSize textSize = [PublicNumberMessageView getSizeByText:total andUIFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] andWidth:width];
    CGFloat height = textSize.height;
    if (height > 20) {
        startY = MY_TASK_TITLE_TOP_MARGIN_TWO;
        [self.task.title drawInRect:CGRectMake(startX, startY, size.width, size.height) withAttributes:attrTitle withFont:[UIFont systemFontOfSize:MY_TASK_TITLE_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_TITLE_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
        
        startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_TWO_LINE;
    } else {
        [self.task.title drawInRect:CGRectMake(startX, startY, size.width, size.height) withAttributes:attrTitle withFont:[UIFont systemFontOfSize:MY_TASK_TITLE_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_TITLE_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
        startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_ONE_LINE;
    }
    
    CGSize sizeDivider = [divider sizeWithFont:[UIFont systemFontOfSize:MY_TASK_TITLE_TEXT_SIZE]];
    
    NSDictionary* attrDivider = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_PROPERTY_DIVIDER_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
    
    BOOL addDivider = NO;
    //draw vip
    if (vip) {
        NSDictionary* attrVip = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_PROPERTY_VIP_TEXT_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize size = [vip sizeWithFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE]];
        
        if (startX + size.width > (rect.size.width - MY_TASK_LEFT_MARGIN - 2 * MY_TASK_ICON_LEFT_MARGIN) ) {
            startX = MY_TASK_ICON_LEFT_MARGIN * 2 + MY_TASK_ICON_WIDTH;
            startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_TWO_LINE;
        }
        [vip drawInRect:CGRectMake(startX, startY, size.width + 1, size.height + 1) withAttributes:attrVip withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_VIP_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
        startX = startX + size.width;
        
        addDivider = YES;
        
    }
    
    //draw wallet
    if (wallet) {
        if (addDivider) {
            [divider drawInRect:CGRectMake(startX, startY, sizeDivider.width + 1, sizeDivider.height + 1) withAttributes:attrDivider withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_DIVIDER_COLOR andDefaultColor:[UIColor blackColor]]];
            startX = startX + sizeDivider.width;
        }
        
        NSDictionary* attrWallet = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_PROPERTY_WALLET_TEXT_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize size = [wallet sizeWithFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE]];
        
        if (startX + size.width > (rect.size.width - MY_TASK_LEFT_MARGIN - 2 * MY_TASK_ICON_LEFT_MARGIN) ) {
            startX = MY_TASK_ICON_LEFT_MARGIN * 2 + MY_TASK_ICON_WIDTH;
            startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_TWO_LINE;
        }
        [wallet drawInRect:CGRectMake(startX, startY, size.width + 1, size.height + 1) withAttributes:attrWallet withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_WALLET_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
        startX = startX + size.width;
        addDivider = YES;
    }
    
    
    //draw minutes
    if (minutes) {
        
        if (addDivider) {
            [divider drawInRect:CGRectMake(startX, startY, sizeDivider.width + 1, sizeDivider.height + 1) withAttributes:attrDivider withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_DIVIDER_COLOR andDefaultColor:[UIColor blackColor]]];
            startX = startX + sizeDivider.width;
        }
        
        NSDictionary* attrMinutes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_PROPERTY_MINUTES_TEXT_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize size = [minutes sizeWithFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE]];
        
        if (startX + size.width > (rect.size.width - MY_TASK_LEFT_MARGIN - 2 * MY_TASK_ICON_LEFT_MARGIN) ) {
            startX = MY_TASK_ICON_LEFT_MARGIN * 2 + MY_TASK_ICON_WIDTH;
            startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_TWO_LINE;
        }
        [minutes drawInRect:CGRectMake(startX, startY, size.width + 1, size.height + 1) withAttributes:attrMinutes withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_MINUTES_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
        startX = startX + size.width;
        addDivider = YES;
    }
    
    //draw traffic
    if (traffic) {
        if (addDivider) {
            [divider drawInRect:CGRectMake(startX, startY, sizeDivider.width + 1, sizeDivider.height + 1) withAttributes:attrDivider withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_DIVIDER_COLOR andDefaultColor:[UIColor blackColor]]];
            startX = startX + sizeDivider.width;
        }
        
        NSDictionary* attrTraffic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MY_TASK_PROPERTY_TRAFFIC_TEXT_COLOR andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize size = [traffic sizeWithFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE]];
        
        if (startX + size.width > (rect.size.width - MY_TASK_LEFT_MARGIN - 2 * MY_TASK_ICON_LEFT_MARGIN) ) {
            startX = MY_TASK_ICON_LEFT_MARGIN * 2 + MY_TASK_ICON_WIDTH;
            startY = startY + size.height + MY_TASK_PROPERTY_TEXT_TOP_MARGIN_TWO_LINE;
        }
        [traffic drawInRect:CGRectMake(startX, startY, size.width + 1, size.height + 1) withAttributes:attrTraffic withFont:[UIFont systemFontOfSize:MY_TASK_PROPERTY_TEXT_SIZE] UIColor:[ImageUtils colorFromHexString:MY_TASK_PROPERTY_TRAFFIC_TEXT_COLOR andDefaultColor:[UIColor blackColor]]];
    }
}

- (void) drawView
{
    [self fadeInAnimation:self];
    [self setNeedsDisplay];
    self.task.isShowing = YES;
}


-(void)fadeInAnimation:(UIView *)aView {
    self.url = self.task.iconLink;
    self.icon = [ImageUtils getImageFromLocalWithUrl:self.url];
    if (self.icon == nil) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    if (!self.task.isShowing) {
        [UIView animateWithDuration:3.5f animations:^{
            CATransition *transition = [CATransition animation];
            transition.type =kCATransitionMoveIn;
            transition.subtype = kCATransitionFade;
            transition.duration = 3.5f;
            transition.delegate = self;
            [aView.layer addAnimation:transition forKey:nil];
        } completion:^(BOOL finished) {
        }];
    }
}


- (void)downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:self.url] withUrl:self.url];
    __weak MyTaskAnimationView* view = self;
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (view) {
                view.icon = [ImageUtils getImageFromLocalWithUrl:view.url];
                [view setNeedsDisplay];
            }
        });
    }
}


@end
