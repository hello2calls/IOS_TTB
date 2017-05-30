//
//  CategorySectionRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#import <Foundation/Foundation.h>
#import "CategorySectionRowView.h"
#import "SubCategoryItem.h"
#import "IndexConstant.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "CategoryContentRowView.h"

@implementation CategorySectionRowView

- (id)initWithFrame:(CGRect)frame andData:(SubCategoryItem*)data
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    
    //LOGO
    int logoStartX = NEW_CATEGORY_SECTION_TITLE_LOGO_MARGIN_LEFT;
    int logoStartY = NEW_CATEGORY_SECTION_HEADER_HEIGHT / 4;
    UIImageView* logoView = [[UIImageView alloc] initWithFrame:CGRectMake(logoStartX, logoStartY, NEW_CATEGORY_SECTION_HEADER_HEIGHT / 2, NEW_CATEGORY_SECTION_HEADER_HEIGHT / 2)];
 
    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    NSString* workSpacePath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];
    NSString* filePath = [NSString stringWithFormat:@"%@%@",workSpacePath,data.iconPath];
    logoView.image = [UIImage imageWithContentsOfFile:filePath];
    [self addSubview:logoView];
    
    //title
    VerticallyAlignedLabel* label = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(logoStartX + NEW_CATEGORY_SECTION_TITLE_TEXT_MARGIN_LEFT + NEW_CATEGORY_SECTION_HEADER_HEIGHT / 2, 0, frame.size.width - logoStartX + NEW_CATEGORY_SECTION_HEADER_HEIGHT / 2, NEW_CATEGORY_SECTION_HEADER_HEIGHT)];
    label.textColor = [ImageUtils colorFromHexString:FIND_CELL_TITLE_TEXT_COLOR andDefaultColor:nil];
    label.textAlignment = NSTextAlignmentLeft;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:NEW_CATEGORY_SECTION_TITLE_SIZE];
    label.text = data.title;
    [self addSubview:label];
    
    if (data.cellCategories.count > 0) {
        int rowCount = (data.cellCategories.count + CATEGORY_ITEM_CONTENT_COLUMN_COUNT - 1) / CATEGORY_ITEM_CONTENT_COLUMN_COUNT;
        int startY = NEW_CATEGORY_SECTION_HEADER_HEIGHT;
        for (int i = 0; i < rowCount; i++) {
            CategoryContentRowView* view = [[CategoryContentRowView alloc]initWithFrame:CGRectMake(0, startY + i * NEW_CATEGORY_SECTION_CONTENT_HEIGHT, frame.size.width, NEW_CATEGORY_SECTION_CONTENT_HEIGHT) andData:data andRowIndex:i];
            [self addSubview:view];
        }
    }
    
    return self;
}
@end