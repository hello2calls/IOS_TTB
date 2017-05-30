//
//  ExpandableCell.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExpandableCell.h"
#import "ExpandableNode.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"
#import "SmartGroupNode.h"
#import "ExpandableListView.h"

@interface ExpandableCell() {
@private
    ExpandableNode* __strong cellSource_;
    UIView* __strong cellContentContainer_;
    TPUIButton* __strong expanderButton_;
    UIActivityIndicatorView* __strong loadingIndicator_;
}

typedef enum {
    ExpanderButtonStatusNoChild,
    ExpanderButtonStatusCollapse,
    ExpanderButtonStatusExpanded,
    ExpanderButtonStatusLoading
} ExpanderButtonStatus;

- (void) setExpanderButtonStatus:(ExpanderButtonStatus) status;
- (void) setExpanderButtonStatus;
- (void) notifyParentView;
- (void) showExpanderButton;

@end

@implementation ExpandableCell

const int indention = 20;
const int expanderWidth = 16;

@synthesize cellContent;
@synthesize parentTableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect frame = self.frame;
        frame.size.width = LEFT_DRAWER_WIDTH;
        self.frame = frame;
        cellContentContainer_ = [[UIView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:cellContentContainer_];
         UIView *selectedView = [[UIView alloc] initWithFrame:self.frame];
         self.selectedBackgroundView = selectedView;
    }
    return self;
}

- (void) dealloc {
    cellSource_.loadDataDelegate = nil;
    
}

#pragma mark cellSource
- (ExpandableNode*) cellSource {
    return cellSource_;
}

- (void) setCellSource:(ExpandableNode *)cellSourceItem {
    if (cellSource_ == cellSourceItem) {
        [self notifyCellSourceChanged];
        return;
    }
    if(cellSource_ != nil) {
        cellSource_.loadDataDelegate = nil;
    }
    //cootek_log(@"release last");
    cellSource_ = cellSourceItem;
    //cootek_log(@"retain current");
    //cootek_log(@"%@", cellSourceItem);
    cellSource_.loadDataDelegate = self;
    //cootek_log(@"load delegate");
    [self notifyCellSourceChanged];
}

- (void) notifyCellSourceChanged {
    if([NSThread isMainThread]) {
        [self onCellSourceChanged];
    }else {
        [self performSelectorOnMainThread:@selector(onCellSourceChanged) withObject:nil waitUntilDone:NO];
    }
}

- (void) onCellSourceChanged {
//    NSInteger leftGap = self.cellSource == nil ? 0 : indention * (self.cellSource.depth - 1);
    NSInteger leftGap = 0;
    CGRect cellContentFrame = CGRectMake(leftGap, 0, self.frame.size.width - leftGap - self.frame.size.height, self.frame.size.height);
    
    if(cellContent != nil) {
        cellContent.frame = cellContentFrame;
        [cellContentContainer_ addSubview:cellContent];
        [cellContent fillWithSource:cellSource_];
    }
    
    [self setExpanderButtonStatus];
    [self setNeedsDisplay];
}

#pragma mark expander
- (void) setExpanderButtonStatus {
    if(!cellSource_.canHaveChildren) {
        [self setExpanderButtonStatus:ExpanderButtonStatusNoChild];
        return;
    }
    
    if(cellSource_.isDataLoading) {
        [self setExpanderButtonStatus:ExpanderButtonStatusLoading];
        return;
    } 
    
    if(!cellSource_.isDataLoaded || !cellSource_.isExpanded) {
        [self setExpanderButtonStatus:ExpanderButtonStatusCollapse];
        return;
    }
    
    if(cellSource_.children != nil && cellSource_.children.count > 0) {
        [self setExpanderButtonStatus:ExpanderButtonStatusExpanded];
    } else {
        [self setExpanderButtonStatus:ExpanderButtonStatusNoChild];
    }
}

- (void) setExpanderButtonStatus:(ExpanderButtonStatus) status {
    [self showExpanderButton];
    
    //NSString* buttonText;
    NSString *text = nil;
    NSString *textColor = nil;;
    switch (status) {
        case ExpanderButtonStatusCollapse:
            //buttonText = @">";
            text = @"p";
            textColor = @"expandableCell_more_normal_color";
            [loadingIndicator_ stopAnimating];
            break;
        case ExpanderButtonStatusExpanded:
            [loadingIndicator_ stopAnimating];
            text = @"o";
            textColor = @"expandableCell_more_active_color";
            break;
        case ExpanderButtonStatusLoading:
            [loadingIndicator_ startAnimating];
            break;
        default:
        {
            //if ([[self.lastSelectedCell returnLastSelected]isKindOfClass:[self.cellSource class]]) {
            if ([self.container returnLastSelected] == nil) {
                if ([self.cellSource isKindOfClass:[AllContactsNode class]]) {
                    text = @"r";
                    textColor = @"expandableCell_select_press_color";
                } else {
                    text = @"q";
                    textColor = @"expandableCell_select_normal_color";
                }
            } else {
                if ([self.cellSource respondsToSelector:@selector(nodeDescription)] && (((LeafNodeWithContactIds *)self.cellSource).nodeDescription) != nil) {
                    if ([self.container returnLastSelected].nodeDescription == ((LeafNodeWithContactIds *)self.cellSource).nodeDescription) {
                        text = @"r";
                        textColor = @"expandableCell_select_press_color";
                    } else {
                        text = @"q";
                        textColor = @"expandableCell_select_normal_color";
                    }
                } else {
                    text = @"q";
                    textColor = @"expandableCell_select_normal_color";
                }   
            }
            [loadingIndicator_ stopAnimating];
        }
            break;
    }
    [expanderButton_ setTitle:text forState:UIControlStateNormal];
    [expanderButton_ setTitle:text forState:UIControlStateDisabled];
    [expanderButton_ setTitleColor:[TPDialerResourceManager getColorForStyle:textColor] forState:UIControlStateNormal];
    [expanderButton_ setTitleColor:[TPDialerResourceManager getColorForStyle:textColor] forState:UIControlStateDisabled];
}

- (void) showExpanderButton {
    if(expanderButton_ == nil) {
        NSInteger indicatorSize = 24;
        CGRect frame = CGRectMake(LEFT_DRAWER_WIDTH - (self.frame.size.height + expanderWidth) / 2, (self.frame.size.height - expanderWidth) / 2 + 2, expanderWidth, expanderWidth);
        expanderButton_ = [[TPUIButton alloc] initWithFrame:frame];
        expanderButton_.backgroundColor = [UIColor clearColor];
        [expanderButton_.titleLabel setFont:[UIFont fontWithName:@"iPhoneIcon2" size:16]];
        
        [expanderButton_ addTarget:self action:@selector(onExpanderClicked) forControlEvents:UIControlEventTouchUpInside];
        
        loadingIndicator_ = [UIActivityIndicatorView alloc];
        loadingIndicator_ = [loadingIndicator_ initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingIndicator_.hidesWhenStopped = YES;
        loadingIndicator_.frame = CGRectMake((frame.size.width - indicatorSize)/2, (frame.size.height - indicatorSize)/2, indicatorSize, indicatorSize);
        [expanderButton_ addSubview:loadingIndicator_];
        expanderButton_.enabled = NO;
        
        [self.contentView addSubview:expanderButton_];
    }
}

- (void) onExpanderClicked {
    if(!cellSource_.canHaveChildren) {
        return;
    }
    
    if(!cellSource_.isDataLoaded) {
        if(!cellSource_.isDataLoading) {
            [cellSource_ loadDataAsync];
        }
        cellSource_.isExpanded = YES;
    } else {
        cellSource_.isExpanded = !cellSource_.isExpanded;
        [self setExpanderButtonStatus];
        [self notifyParentView];
    }
}

#pragma mark loading data
- (void) onBeginLoadData {
    if(![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(onBeginLoadData) withObject:nil waitUntilDone:YES];
        return;
    }
    
    [self setExpanderButtonStatus:ExpanderButtonStatusLoading];
}

- (void) onEndLoadData:(ExpandableNode *)node {
    if(![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(onEndLoadData:) withObject:node waitUntilDone:YES];
        return;
    }
    
    [self setExpanderButtonStatus];
    [self notifyParentView];
}

- (void) notifyParentView {
    if(parentTableView != nil) {
        [parentTableView refreshParentTable];
    }
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    NSDictionary *operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"expandableListView_table_style"];
    //下分割线 (深色分隔线）
    UIColor *deepColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"downSeperateLine_color"]];
    CGContextSetStrokeColorWithColor(context, deepColor.CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height-0.5, rect.size.width,0.5));
    
    //上分割线，（浅色分隔线）
    UIColor *lightColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"upSeperateLine_color"]];
    CGContextSetStrokeColorWithColor(context, lightColor.CGColor);
    //CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 0.5));
    if ([self.cellSource isKindOfClass:[AllContactsNode class]]) {
        CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));
        CGContextSetStrokeColorWithColor(context, deepColor.CGColor);
        CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    }
    self.selectedBackgroundView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selected_color"]];
    
}

@end
