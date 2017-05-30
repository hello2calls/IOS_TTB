//
//  FavouriteRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#import <Foundation/Foundation.h>
#import "FindRowView.h"
#import "FindCellView.h"
#import "IndexConstant.h"
#import "FindHeaderView.h"

@interface FindRowView(){
    FindHeaderView* rowHeader;
}
@end

@implementation FindRowView
@synthesize findData;
@synthesize findSubViews;
@synthesize rowIndexPath;

- (id)initWithFrame:(CGRect)frame andData:(SectionFind*)data andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    self.findData = data;
    self.rowIndexPath = indexPath;
    FindHeaderView* header = [[FindHeaderView alloc]initWithFrame:CGRectMake(self.bounds.origin.x + FIND_TITLE_MARGIN_LEFT, self.bounds.origin.y, self.bounds.size.width- FIND_TITLE_MARGIN_LEFT, FIND_ROW_HEIGHT_HEADER)];
    rowHeader = header;
    
    [self addSubview:header];
    [self addSubview:[self createViewItemWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + header.frame.size.height, frame.size.width, self.bounds.size.height - FIND_ROW_HEIGHT_HEADER)]];
    [self resetDataWithFindItem:data andIndexPath:indexPath];
    [self setTag:FIND_TAG + (indexPath.section * 100)];
    
    return self;
}

- (void) resetDataWithFindItem:(SectionFind*)item andIndexPath:(NSIndexPath*)indexPath
{

    if (indexPath.row == 0) {
        rowHeader.hidden = NO;
    } else {
        rowHeader.hidden = YES;
        for (FindCellView* view in findSubViews) {
            view.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
    }
    
    self.findData = item;
    self.rowIndexPath = indexPath;
    
    [rowHeader drawViewWithTitle:item.title withColor:item.titleColor andRightTopItem:item.rightTopItem];
    int i = 0;
    for (FindCellView* view in findSubViews) {
        [view resetWithFindData:findData andRowIndex:self.rowIndexPath.row andColumnIndex:i++];
        
    }
    [self drawView];
}

-(UIView *) createViewItemWithFrame:(CGRect)frame
{
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    SectionFind* item = self.findData;
    self.findSubViews = [[NSMutableArray alloc]initWithCapacity:item.items.count];
    if([item.items count] > 0) {
        int width = frame.size.width / FIND_COLUMN_COUNT;
        int offset = frame.size.width - width * FIND_COLUMN_COUNT;
        int startX = frame.origin.x;
        int rowCount = ([item.items count] + FIND_COLUMN_COUNT - 1) / FIND_COLUMN_COUNT;
        for (int j = 0; j < rowCount; j++) {
            int startY = j * INDEX_ROW_HEIGHT_FIND;
            for(int i = 0; i < FIND_COLUMN_COUNT; i++) {
                int cellwidth = width + (offset-- > 0 ? 1 : 0);
                FindCellView* cellView = [[FindCellView alloc] initWithFrame:CGRectMake(startX, startY, cellwidth, INDEX_ROW_HEIGHT_FIND)];
                startX = startX + cellwidth;
                [view addSubview:cellView];
                [self.findSubViews addObject:cellView];
            }
        }
        
    }
    
    return view;
}

-(void) drawView
{
    SectionFind* item = self.findData;
    
    int i = 0;
    
    for (FindCellView* view in findSubViews) {
        if(item.items.count > rowIndexPath.row * FIND_COLUMN_COUNT + i){
            [view drawView:[item.items objectAtIndex:rowIndexPath.row * FIND_COLUMN_COUNT + i]];
        } else {
            [view drawView: nil];
        }
        i++;
    }
}


@end