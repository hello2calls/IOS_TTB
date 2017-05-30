//
//  CategoryExtendViewController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-3.
//
//

#import <Foundation/Foundation.h>
#import "CategoryExtendViewController.h"
#import "TPHeaderButton.h"
#import "IndexConstant.h"
#import "UIDataManager.h"
#import "NewCategoryRowView.h"
#import "SectionNewCategory.h"
#import "CategoryItem.h"
#import "SubCategoryItem.h"
#import "CategorySectionRowView.h"

@interface CategoryExtendViewController()
{
    TPHeaderButton* gobackBtn;
}

@end
@implementation CategoryExtendViewController

- (void) loadView
{
    [super loadView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    self.scrollView.scrollEnabled = YES;
    
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = YES;
    self.scrollView.delegate = self;
    
    int scrollHeight = self.scrollView.frame.size.height;
    int screenWidth = TPScreenWidth();
    if ([self.item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMMORE]) {
        NSMutableArray* items = [[UIDataManager instance] categoryExtendData];
        SectionNewCategory* section = [[SectionNewCategory alloc]init];
        section.items = items;
        section.count = [NSNumber numberWithInteger:section.items.count];
        section.title = NEW_CATEGORY_MORE_TITLE;
        int rowCount = (section.items.count + NEW_CATEGORY_COLUMN_COUNT - 1) / NEW_CATEGORY_COLUMN_COUNT;
        for (int i = 0; i < rowCount; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NewCategoryRowView* categoryView = [[NewCategoryRowView alloc] initWithFrame:CGRectMake(self.scrollView.frame.origin.x, i * INDEX_ROW_HEIGHT_NEW_CATEGORY, screenWidth, INDEX_ROW_HEIGHT_NEW_CATEGORY) andData:section andIndexPath:indexPath andHeader:NO];
            [self.scrollView addSubview:categoryView];
        }
       
        scrollHeight = rowCount * INDEX_ROW_HEIGHT_NEW_CATEGORY;
        [self setHeaderTitle:NEW_CATEGORY_MORE_TITLE];
    } else if ([self.item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMCATEGORY]) {
        [self setHeaderTitle:self.item.title];
        
        int startY = 0;
        int offsetY = 0;
        for (SubCategoryItem* subItem in self.item.subItems) {
            if (subItem.cellCategories.count > 0) {
                int rowCount = (subItem.cellCategories.count + CATEGORY_ITEM_CONTENT_COLUMN_COUNT - 1) / CATEGORY_ITEM_CONTENT_COLUMN_COUNT;
                offsetY = NEW_CATEGORY_SECTION_HEADER_HEIGHT + rowCount * NEW_CATEGORY_SECTION_CONTENT_HEIGHT;
                CategorySectionRowView* sectionView = [[CategorySectionRowView alloc]initWithFrame:CGRectMake(0, startY, self.scrollView.frame.size.width, offsetY) andData:subItem];
                [self.scrollView addSubview:sectionView];
                startY = startY + offsetY + NEW_CATEGORY_SECTION_CONTENT_MARGIN;
            }
            
        }
        scrollHeight = startY - NEW_CATEGORY_SECTION_CONTENT_MARGIN;
    } else if ([self.item.type isEqualToString:NEW_CATEGORY_TYPE_ITEMRECOMMEND]) {
        [self setHeaderTitle:self.item.title];
        SectionNewCategory* section = [[SectionNewCategory alloc]init];
        for (SubCategoryItem* item in self.item.subItems) {
            NSMutableArray* categories = item.cellCategories;
            for (CategoryItem* categoryItem in categories) {
                NewCategoryItem* item = [item mutableCopy];
                item.type = NEW_CATEGORY_TYPE_ITEMRECOMMEND;
                SubCategoryItem* subItem = [[SubCategoryItem alloc]init];
                subItem.type = NEW_CATEGORY_TYPE_ITEMRECOMMEND;
                subItem.cellCategories = [[NSMutableArray alloc]init];
                [subItem.cellCategories addObject:categoryItem];
                [item.subItems addObject:subItem];
                [section.items addObject:item];
            }
            section.count = [NSNumber numberWithInteger:section.items.count];
            
            int rowCount = (section.items.count + NEW_CATEGORY_COLUMN_COUNT - 1) / NEW_CATEGORY_COLUMN_COUNT;
            for (int i = 0; i < rowCount; i++) {
                if (section.items.count > 0) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    NewCategoryRowView* categoryView = [[NewCategoryRowView alloc] initWithFrame:CGRectMake(self.scrollView.frame.origin.x, i * INDEX_ROW_HEIGHT_NEW_CATEGORY, screenWidth, INDEX_ROW_HEIGHT_NEW_CATEGORY) andData:section andIndexPath:indexPath andHeader:NO];
                    [self.scrollView addSubview:categoryView];
                    
                }
            }
        }
        
        scrollHeight = ((self.scrollView.subviews.count + NEW_CATEGORY_COLUMN_COUNT - 1) / NEW_CATEGORY_COLUMN_COUNT) * INDEX_ROW_HEIGHT_NEW_CATEGORY;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, scrollHeight);
    
 
    [self.view addSubview:self.scrollView];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{

}

@end
