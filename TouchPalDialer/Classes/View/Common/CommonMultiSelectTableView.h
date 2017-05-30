//
//  CommonMultiSelectTableView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/9/12.
//
//

#import <UIKit/UIKit.h>

@interface MultiSelectItemData : NSObject
{
    BOOL is_checked;
    int data;
    NSString* text;
}

@property(nonatomic) BOOL is_checked;
@property(nonatomic) int data;
@property(nonatomic, retain) NSString* text;

- (id)initWithData:(int)paraData withText:(NSString*)paraText isChecked:(int)isChecked;

@end

@protocol CommonMultiSelectProtocol

- (void)checkFinish:(NSArray*)dataList;

@end

@interface MultiSelectSectionData : NSObject
{
    int data;
    NSString* text;
    NSArray * items;
}

@property(nonatomic) int data;
@property(nonatomic, retain) NSString* text;
@property(nonatomic, retain) NSArray * items;

- (id)initWithData:(int)paraData withText:(NSString*)paraText withItems:(NSArray*)paraItems;

@end


@interface CommonMultiSelectTableView : UIView <UITableViewDataSource,UITableViewDelegate>
- (id)initWithFrame:(CGRect)frame andDataList:(NSArray *)dataList needAnimateIn:(BOOL)animate;
@end
