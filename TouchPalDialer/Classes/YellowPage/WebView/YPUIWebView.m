//
//  YPUIWebView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/9/18.
//
//

#import "YPUIWebView.h"
#import "IndexConstant.h"

@interface YPUIWebView()
{
    CGFloat startY;
    BOOL sliding;
}

@end
@implementation YPUIWebView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y - startY;
    if (sliding && fabs(offset) > CLICK_CANCELED_OFFSET) {
        if (offset > CLICK_CANCELED_OFFSET) {
            cootek_log(@"pull down");
        } else {
            cootek_log(@"pull up");
        }
        sliding = NO;
    } else {
        cootek_log(@"not in");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    cootek_log(@" start dragg");
    sliding = YES;
    startY = scrollView.contentOffset.y;
    
}


//
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent*)event
//{
//    [super hitTest:point withEvent:event];//capture the view which actually responds to the touch events
//    return self;//pass self so that the touchesBegan,touchesMoved and other    events will be routed to this class itself
//    
//}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    cootek_log(@"touchesBegan");;
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//     cootek_log(@"touchesCancelled");
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//     cootek_log(@"touchesMoved");
//    
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    cootek_log(@"touchesEnded");
//    
//}


@end
