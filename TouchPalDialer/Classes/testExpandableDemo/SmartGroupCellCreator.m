//
//  DemoCellCreator.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DemoCellCreator.h"
#import "DemoNode.h"
#import "LeafNode.h"


@interface ShowMessageCellView() {
    UIButton* headButton_;
}
@end

@implementation ShowMessageCellView

- (void) fillWithSource:(ExpandableNode*) sourceNode{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // TODO: the view element creation code should be moved to init function
    if(headButton_ == nil) {
        headButton_ = [[UIButton alloc] initWithFrame:rect];
        [self addSubview:headButton_];
        [headButton_ addTarget:self action:@selector(showMessage) forControlEvents:UIControlEventTouchUpInside];
    } else {
        headButton_.frame = rect;
    }
    
    headButton_.backgroundColor = [UIColor magentaColor];
    [headButton_ setTitle:[NSString stringWithFormat:@"%@ (%d)", sourceNode.data, 123] forState:UIControlStateNormal];
    
}
         
- (void) showMessage {
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Demo"
														 message:headButton_.titleLabel.text    
														delegate:nil
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:nil] autorelease];
	[alertView show];
}

- (void) dealloc {
    [headButton_ removeFromSuperview];
    [headButton_ release];
    headButton_ = nil;
    [super dealloc];
}

@end


@interface DemoCellCreator()
- (BOOL) isShowMessageNode:(ExpandableNode*) node ;
@end

@implementation DemoCellCreator

- (InnerCellContentView*) createInnerCellContentViewForNode:(ExpandableNode*) node {
    if([self isShowMessageNode:node]) {
        return [[[ShowMessageCellView alloc] init] autorelease];
    }
    
    
    return [super createInnerCellContentViewForNode:node];
}

- (NSString*) reuseIdentifierForNode:(ExpandableNode*) node {
    if([self isShowMessageNode:node]) {
        return @"ShowMessageCell";
    }
    
    return [super reuseIdentifierForNode:node];
}

- (BOOL) isShowMessageNode:(ExpandableNode*) node {
    if([node isMemberOfClass:[LeafNode class]]) {
        if([node.parent isMemberOfClass:[CompanyGroupNode class]])
        {
            return YES;
        }
    }
    
    return NO;
}

@end
