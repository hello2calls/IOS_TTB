//
//  AnnouncementCellView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "AnnouncementCellView.h"
#import "SectionGroup.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"
#import "SectionAnnouncement.h"
#import "CTUrl.h"
#import "ImageUtils.h"
#import "NSTimer+Addition.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "UIDataManager.h"

@interface AnnouncementCellView()
{
    CGPoint startPoint;
    CGFloat frameHeight;
    VerticallyAlignedLabel* targetLabel;
}

@property(nonatomic, retain) NSTimer* repeatingTimer;
@property(nonatomic, assign) double animationDuration;
@end

@implementation AnnouncementCellView

- (id) initWithFrame:(CGRect)frame andData:(id)data
{
    self = [super initWithFrame:frame];
    
    self.item = data;
    [self initSubViews:self.bounds];
    
    self.showsVerticalScrollIndicator = false;
    self.bounces = NO;
    frameHeight = frame.size.height;
    CGFloat height = frameHeight;
    self.scrollEnabled = NO;
    self.animationDuration = INDEX_ANIMATION_INTERVAL_TIME;
    
    if (self.item.sectionArray.count <= 1) {
        self.pagingEnabled = NO;
    } else {
        self.pagingEnabled = YES;
        height = frameHeight * 2;
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(automaticScrollView:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
    }
    
    self.contentSize = CGSizeMake(frame.size.width, height);
    self.contentOffset = CGPointZero;

    return self;
}


- (void) initSubViews:(CGRect)frame
{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGRect topFrame = CGRectMake(0, 0, width, height);
    VerticallyAlignedLabel* topl = [[VerticallyAlignedLabel alloc]initWithFrame:topFrame];
    topl.textColor = [ImageUtils colorFromHexString:ANNOUNCEMENT_TEXT_COLOR andDefaultColor:nil];
    topl.font = [UIFont fontWithName:@"Helvetica-Light" size:ANNOUNCEMENT_TEXT_SIZE];
    topl.numberOfLines = 1;
    topl.lineBreakMode = NSLineBreakByTruncatingTail;
    self.topLabel = topl;
    [self addSubview:topl];
    
    CGRect centerFrame = CGRectMake(0, height, width, height);
    VerticallyAlignedLabel* centerl = [[VerticallyAlignedLabel alloc]initWithFrame: centerFrame];
    self.centerLabel = centerl;
    centerl.textColor = [ImageUtils colorFromHexString:ANNOUNCEMENT_TEXT_COLOR andDefaultColor:nil];
    centerl.font = [UIFont fontWithName:@"Helvetica-Light" size:ANNOUNCEMENT_TEXT_SIZE];
    centerl.numberOfLines = 1;
    centerl.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:centerl];
    
    [self.topLabel setVerticalAlignment:VerticalAlignmentMiddle];
    [self.centerLabel setVerticalAlignment:VerticalAlignmentMiddle];
    
    self.contentOffset = CGPointZero;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void) startWebView
{
    if (self.item.sectionArray.count > 0) {
        SectionAnnouncement* sectionAnnouncement = [self.item.sectionArray objectAtIndex:self.item.current];
        [sectionAnnouncement.ctUrl startWebView];
        NSString* txt = [sectionAnnouncement text];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_ANNOUNCEMENT_ITEM kvs:Pair(@"action", @"selected"), Pair(@"text", txt), nil];
    }
}

- (void)automaticScrollView:(NSTimer *)timer
{
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.contentOffset = CGPointMake(0, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self scrollViewDidEndDecelerating: self];
    }];
}

- (NSString*) nextItemStringByIndex:(int)itemIndex
{
    SectionAnnouncement* announcement = nil;
    if(itemIndex == self.item.sectionArray.count - 1) {
        announcement = [self.item.sectionArray objectAtIndex:0];
    } else {
        announcement = [self.item.sectionArray objectAtIndex:itemIndex + 1];
    }
    return [announcement text];
}

- (void) drawViewWithData:(SectionGroup *)data andPressed:(BOOL)isPressed
{
    
    if (self.item.sectionArray.count <= 1) {
        self.pagingEnabled = NO;
        if (self.repeatingTimer) {
            [self.repeatingTimer pauseTimer];
        }
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        self.contentOffset = CGPointZero;
    } else {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 2);
        self.contentOffset = CGPointZero;
        self.pagingEnabled = YES;
        if (!self.repeatingTimer) {
            self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(automaticScrollView:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
        } else {
            [self.repeatingTimer resumeTimerAfterTimeInterval:self.animationDuration];
        }
    }
    
    UIColor *color = nil;
    if (data.sectionArray.count > 0 && isPressed) {
        color = [ImageUtils colorFromHexString:ANNOUNCEMENT_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
    } else {
        color = [ImageUtils colorFromHexString:ANNOUNCEMENT_TEXT_COLOR andDefaultColor:nil];
    }
    self.pressed = isPressed;
    self.centerLabel.textColor = color;
    self.topLabel.textColor = color;
    if (self.item.sectionArray.count > 0) {
        SectionAnnouncement* sectionAnnouncement = [self.item.sectionArray objectAtIndex:self.item.current];
        NSString* txt = [sectionAnnouncement text];
        [self.topLabel setText:txt];
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        self.topLabel.frame = CGRectMake(0, 0, width, height);
        [self.centerLabel setText:[self nextItemStringByIndex:self.item.current]];
        self.centerLabel.frame = CGRectMake(0, height, width, height);
    }
}

- (void) stop
{
    if (_repeatingTimer) {
        [_repeatingTimer pauseTimer];
    }
    
}

- (void) resume
{
    if (_repeatingTimer) {
        [_repeatingTimer resumeTimer];
    }
}


#pragma mark -
#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if(self.item.current == self.item.sectionArray.count - 1) {
        self.item.current = 0;
    } else {
        self.item.current += 1;
    }
    SectionAnnouncement* sectionAnnouncement = [self.item.sectionArray objectAtIndex:self.item.current];
    self.topLabel.text = [sectionAnnouncement text];
    self.centerLabel.text = [self nextItemStringByIndex:self.item.current];
    
    if (self.topLabel.hidden == NO) {
        self.topLabel.hidden = YES;
    }
    
    self.contentOffset = CGPointZero;
}
@end
