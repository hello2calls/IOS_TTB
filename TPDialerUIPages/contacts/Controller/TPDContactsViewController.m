//
//  TPDContactsViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/9/20.
//
//
#import "TPDialerResourceManager.h"
#import "TPDSelectViewController.h"
#import "ContactTransferGuideController.h"
#import "TPDContactsViewController.h"
#import "ContactInfoViewController.h"
#import "TPDContactSearchViewController.h"
#import "GroupOperationCommandCreatorCopy.h"
#import "GroupDeleteContactCommandCopy.h"
#import "TPABPersonActionController.h"
#import "TPDContactInfoManagerCopy.h"
#import "ContactCacheDataManager.h"
#import "ContactInfoModelUtil.h"
#import "FunctionUtility.h"
#import "ContactPropertyCacheManager.h"
#import "TPDialerResourceManager.h"
#import "AllViewController.h"
#import "Person.h"
#import "UserDefaultsManager.h"
#import "ContactTransferMainController.h"
#import <AddressBook/ABPerson.h>
#import "UITableViewCell+TPDExtension.h"
#import <Masonry.h>
#import "TPDContactGroupModel.h"
#import "ContactCacheDataModel.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "SmartGroupNode.h"
#import "AttributeModel.h"
#import "TPDIndexModel.h"
#import "ContactViewController.h"
#import "TPDContactCopyViewController.h"
#import "UIView+TPDExtension.h"
#import "UIColor+TPDExtension.h"
#import "UIButton+TPDExtension.h"
#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import "PullDownSheet.h"
#import "GroupOperationCommandBase.h"
#import "PersonDBA.h"
#import "TPSelectCopyViewController.h"
#import "CootekNotifications.h"
#import "TPScanCardViewController.h"
#import "TPDLib.h"
#import "CommandDataHelper.h"
#import "TPCallActionController.h"

#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "HighlightTip.h"
#import "UserDefaultKeys.h"
#import "UserDefaultsManager.h"
#import "NoahManager.h"
#import <UIKit/UIKit.h>
#import "UIGestureRecognizer+BlocksKit.h"
#import "DialerUsageRecord.h"
#import "TPMFMessageActionController.h"

#define kBlueColor          RGB2UIColor2(3  ,169,244)
#define kSelectedBlueColor  RGB2UIColor2(2  ,135,195)
#define kLigthBlueColor     RGB2UIColor2(164,224,251)
#define kSeparateLineColor  RGB2UIColor2(230,230,230)
#define kWhiteColor [UIColor whiteColor]
#define kBlackColor [UIColor blackColor]

#define BTN_HEIGHT 50
#define BTN_WIDTH 150

@class TPDIndexView,TPDCurrentIndexView;
@protocol  TPDIndexViewDelegate <NSObject>

@required
-(NSArray *)tpdIndexTitlesForIndexView:(TPDIndexView *)indexView;
-(NSArray *)tpdSectionTitlesForIndexView:(TPDIndexView *)indexView atIndex:(NSInteger)sectionIndex;
@optional
- (void)tpdIndexView:(TPDIndexView *)tpdIndexView didSelectAtIndex:(NSInteger)index;
@end


@protocol  TPDCurrentIndexViewDelegate <NSObject>
@required
-(void)tpdSectionTitlesForCurrentIndexView:(TPDCurrentIndexView *)indexView atIndex:(NSIndexPath *)indexPath;
@end
#pragma mark - TPDCurrentIndexView
#pragma mark  ***********
@interface TPDCurrentIndexView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) NSIndexPath   *indexPath;
@property (nonatomic, strong) NSMutableArray*currentItemArray;
@property (nonatomic, strong) UILabel       *indexTitleLabel;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, copy  ) NSString      *indexTittle;
@property (nonatomic, strong) UIView        *transitionView;
@property (nonatomic, strong) UIView        *beginBransitionView;

@property (nonatomic, copy)   NSArray       *indexArray;
@property (nonatomic, assign  ) id<TPDCurrentIndexViewDelegate> delegate;

- (void)updateViewIndex:(NSIndexPath *)indexPath DataArray:(NSArray *)dataArray;
@end

@implementation TPDCurrentIndexView

- (instancetype)init {
    if (self = [super init]) {
        self.currentItemArray = [NSMutableArray new];
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.45];
        [self setupView];
        self.hidden = YES;
    }
    return self;
}

- (void)setupView {
    
    self.transitionView = [self createPreViewWithFrame:(CGRect){0,0,60 ,40} DirectionUp:NO];
    self.beginBransitionView = [self createPreViewWithFrame:(CGRect){0,0,60 ,40} DirectionUp:YES];
    self.beginBransitionView.hidden = YES;
    NSArray *nameArray = @[@"爱",@"奥",@"敖",@"奥",@"敖",@"奥",@"敖",@"奥",@"敖"];
   
    UILabel *indexTitleLabel = [UILabel tpd_commonLabel];
    indexTitleLabel.layer.cornerRadius = 30;
    indexTitleLabel.layer.masksToBounds = indexTitleLabel.layer;
    indexTitleLabel.backgroundColor = [UIColor clearColor];//RGB2UIColor2(164, 224, 251);
    indexTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"skinSectionIndexPopupText_color"];
    indexTitleLabel.textAlignment = NSTextAlignmentCenter;
    indexTitleLabel.font = [UIFont systemFontOfSize:24];
    indexTitleLabel.text = @"A";
    self.indexTitleLabel = indexTitleLabel;

    UIView *preView = [UIView new];
    
    preView.layer.shadowColor = [UIColor grayColor].CGColor;
    preView.layer.shadowOffset = CGSizeMake(0, 2);
    preView.layer.shadowOpacity = .21;
    preView.layer.cornerRadius = 30;
    preView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"skinSectionIndexPopupBackground_color"];
    preView.layer.shadowRadius = 3.0;
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.layer.masksToBounds = YES;
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
  
    
    [self addSubview:self.transitionView];
    [self addSubview:self.beginBransitionView];
    [self addSubview:preView];
    [self addSubview:indexTitleLabel];
    [self addSubview:self.scrollView];
    
    [indexTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.height.equalTo(60);
    }];
    
    [preView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.height.equalTo(60);
    }];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(indexTitleLabel.bottom).offset(10);
        make.left.equalTo(self);
        if (nameArray.count < 5) {
            make.height.equalTo(nameArray.count * 40);
        }else {
            make.height.equalTo(4 * 40 + 20);
            
        }
        make.width.equalTo(60);
        make.bottom.equalTo(self).offset(-20);
    }];
    TPDWeakSelf
    _indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (int i = 0; i < nameArray.count; i++) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeSystem];
        item.backgroundColor = [UIColor clearColor];
        item.tag = i;
        [item tpd_withBlock:^(id sender) {
            NSLog(@"luhui %d",((UIButton *)sender).tag);
            [self.delegate tpdSectionTitlesForCurrentIndexView:self atIndex:[NSIndexPath indexPathForRow:i inSection:_indexPath.section]];
            
            [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:1 animations:^{
                _self.alpha = 0;
            } completion:^(BOOL finished) {
                _self.hidden = YES;
                _self.alpha = 1;
                
            }];
        }];
        [item setTitle:nameArray[i] forState:UIControlStateNormal] ;
        [item setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinSectionIndexCharacterText_color"]forState:UIControlStateNormal];
        //        [item setTitleColor:kSelectedBlueColor forState:UIControlStateHighlighted];
        
        
        item.titleLabel.font = [UIFont systemFontOfSize:24];
        [scrollView addSubview:item];
        
        [item makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo( i * 40);
            make.left.width.equalTo(scrollView);
            make.height.equalTo(40);
            if (nameArray.count - 1 == i) {
                make.bottom.equalTo(scrollView);
                make.right.equalTo(scrollView);
            }
        }];
        [_currentItemArray addObject:item];
        
    }
    if (nameArray.count < 5) {
        self.transitionView.hidden = YES;
    }else {
        self.transitionView.hidden = NO;
    }
    [self.transitionView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo( 40);
        make.width.equalTo( 60);
        make.top.equalTo(scrollView.bottom).offset(-40);
        make.left.equalTo(scrollView);
        [self bringSubviewToFront:self.transitionView];
    }];
    
    [self.beginBransitionView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo( 40);
        make.width.equalTo( 60);
        make.top.equalTo(scrollView);
        make.left.equalTo(scrollView);
        [self bringSubviewToFront:self.beginBransitionView];
    }];
    
}

/**
 渐变半透明遮罩
 
 @param frame 位置
 @param isUp 渐变方向
 @return 渐变遮罩view
 */
- (UIView *)createPreViewWithFrame:(CGRect)frame DirectionUp:(BOOL)isUp{
    
    UIView *view = [UIView new];
    view.frame = frame;//(CGRect){ 100,100,100,100 };
    view.backgroundColor = [UIColor clearColor];
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame    = (CGRect){CGPointZero, view.frame.size};
    [view.layer addSublayer:colorLayer];
    
    // 颜色分配
    colorLayer.colors = isUp ? @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:.45].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0].CGColor]:@[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:.45].CGColor];
    
    // 颜色分割线
    colorLayer.locations  = @[@(0.25),  @(1.f)];
    
    // 起始点
    colorLayer.startPoint = CGPointMake(0, 0);
    
    // 结束点
    colorLayer.endPoint   = CGPointMake(0, 1);
    return  view;
}

static MASConstraint* bottomConstraint = nil;
- (void)updateViewIndex:(NSIndexPath *)indexPath DataArray:(NSArray *)dataArray {
    
    if ([dataArray[0][@"name"] isEqualToString:@""]) {
        return;
    }
    
    //    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:1 animations:^{
    self.alpha = 1;
    //    } completion:^(BOOL finished) {
    self.hidden = NO;
    //    }];
    TPDWeakSelf
    _indexPath = indexPath;
    _indexTitleLabel.text = _indexTittle;
    _scrollView.contentOffset = CGPointMake(0, 0);
    int dataCount = dataArray.count;
    int currentCount = _currentItemArray.count;
    
    if (dataCount > currentCount) {
        [[_currentItemArray lastObject] removeFromSuperview];
        [_currentItemArray removeLastObject];
        
        for (int i = currentCount - 1 ; i < dataCount; i ++) {
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            item.tag = i;
            [item setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinSectionIndexCharacterText_color"]forState:UIControlStateNormal];
            //        [item setTitleColor:kSelectedBlueColor forState:UIControlStateHighlighted];
            [item tpd_withBlock:^(id sender) {
                NSLog(@"luhui %d",((UIButton *)sender).tag);
                [self.delegate tpdSectionTitlesForCurrentIndexView:self atIndex:dataArray[i][@"indexPath"]];
                
                
                [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:1 animations:^{
                    _self.alpha = 0;
                } completion:^(BOOL finished) {
                    _self.hidden = YES;
                    _self.alpha = 1;
                    
                }];
                
            }];
            
            item.titleLabel.font = [UIFont systemFontOfSize:24];
            [self.scrollView addSubview:item];
            [item updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo( i * 40);
                make.left.width.equalTo(self.scrollView);
                make.height.equalTo(40);
                if (dataArray.count - 1 == i) {
                    bottomConstraint = make.bottom.equalTo(self.scrollView);
                    make.right.equalTo(self.scrollView);
                }
            }];
            
            
            [_currentItemArray addObject:item];
            
        }
        //        NSLog(@"luhui  count = %@ increase  %@", @(_currentItemArray.count),NSStringFromCGSize(self.scrollView.contentSize));
        
    } else {
        for (int i = dataCount; i < currentCount; i ++) {
            [_currentItemArray[i] removeFromSuperview];
        }
        [_currentItemArray removeObjectsInRange:NSMakeRange(dataCount, currentCount - dataCount)];
        UIButton *item = [_currentItemArray lastObject];
        [item makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.scrollView);
        }];
        //        NSLog(@"luhui count = %@ decrease %@",@(_currentItemArray.count),NSStringFromCGSize(self.scrollView.contentSize));
        
    }
    
    
    [_currentItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [((UIButton *)_currentItemArray[idx]) setTitle:dataArray[idx][@"name"] forState:UIControlStateNormal];
        [((UIButton *)_currentItemArray[idx]) tpd_withBlock:^(id sender) {
            [self.delegate tpdSectionTitlesForCurrentIndexView:self atIndex:dataArray[idx][@"indexPath"]];
            
            [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:1 animations:^{
                _self.alpha = 0;
            } completion:^(BOOL finished) {
                _self.hidden = YES;
                _self.alpha = 1;
                
            }];
        }];
    }];
    
    [_scrollView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.indexTitleLabel.bottom).offset(10);
        make.left.equalTo(self);
        if (dataArray.count < 5) {
            make.height.equalTo(dataArray.count * 40);
        }else {
            make.height.equalTo(4 * 40 + 20);
            
        }
        make.width.equalTo(60);
        make.bottom.equalTo(self).offset(-20);
    }];
    
    [self bringSubviewToFront:self.transitionView];
    [self bringSubviewToFront:self.beginBransitionView];
    [self.superview bringSubviewToFront:self];
    if (dataArray.count < 5) {
        self.transitionView.hidden = YES;
    }else {
        self.transitionView.hidden = NO;
        
    }
    self.beginBransitionView.hidden = YES;
    
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat currentOffset = offset.y + bounds.size.height - inset.bottom;
    CGFloat maximumOffset = size.height;
    BOOL transitonHidden ;
    if(currentOffset==maximumOffset) {
        transitonHidden = YES;
    }else {
        transitonHidden = NO;
    }
    
    
    [UIView animateKeyframesWithDuration:.1 delay:0 options:2 animations:^{
        self.beginBransitionView.hidden = scrollView.contentOffset.y <= 0;
        self.transitionView.hidden = transitonHidden;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) {
        self.beginBransitionView.hidden = scrollView.contentOffset.y <= 0;
    }
}

@end
#pragma mark ***********
#pragma mark - dataModel
#pragma mark  ***********
@interface DataModel : NSObject

@property (readwrite) CGFloat height;
@property (readwrite) NSInteger count;
@property (readwrite) CGFloat originY;
@property (readwrite) CGFloat font;
@property (readwrite) CGFloat rate;
@end
@implementation DataModel
@end
#pragma mark  ***********
#pragma mark - TPDIndexView
#pragma mark  ***********

@interface TPDIndexView : UIView

@property (nonatomic, weak)     id<TPDIndexViewDelegate> delegate;
@property (nonatomic, strong)   NSArray *indexTitles;
@property (nonatomic, weak)     UILabel *indexTitleLabel;
@property (nonatomic, assign)   NSInteger selectIndex;
@property (readwrite)           DataModel *dataModel;
- (void)tpdReloadData;
- (void)tpdScrollIndex:(NSInteger)sectionIndex ;

@end

@implementation TPDIndexView

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)tpdReloadData {
    [self setupIndexTitles];
    [self.superview bringSubviewToFront:self];
}

- (void)tpdClearSectionTittle {
    
}
//目录 index
- (void)setupIndexTitles {
    
    
    self.indexTitles = [self.delegate tpdIndexTitlesForIndexView:self];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    DataModel *data =  [self caculateByCount:self.indexTitles.count Height:[UIScreen mainScreen].bounds.size.height - 159.f] ;
    
    for (int i = 0; i < self.indexTitles.count ; i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        titleLabel.text = self.indexTitles[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        UIColor *color = [TPDialerResourceManager getColorForStyle:@"skinSectionIndexCharacterText_color"];
        titleLabel.textColor = [color colorWithAlphaComponent:0.86];
        titleLabel.font = [UIFont boldSystemFontOfSize:data.font];
        
        CGFloat offset = data.originY + (data.rate + 1) * (data.height) * i;
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.height.equalTo(data.height);
            make.width.equalTo(self);
            make.top.equalTo(self).offset(offset);
        }];
    }
}


- (DataModel *)caculateByCount:(NSInteger)count Height:(CGFloat)height {
    
    DataModel *data = [DataModel new];
    BOOL isSatisfy = NO;
    
    for (CGFloat i = 18 ; i >= 10 ; i --) {
        CGFloat fontHeight = [self HeightByFont:i];
        
        if ( fontHeight * ( count * 2 - 1 ) >  height ) {
            
            if ( fontHeight * ( count * 1.5 - .5 ) >  height) {
                
                if ( fontHeight * ( count * 1.2 - .2 ) >  height) {
                    if ( fontHeight * count >  height) {
                        
                        
                    }else {
                        
                        isSatisfy = YES;
                        
                        data.originY = ( height - fontHeight * count ) / 2.f;
                        data.height  = fontHeight;
                        data.count   = count;
                        data.font    = i ;
                        data.rate    = 0;
                        break;
                        
                    }
                    
                }else {
                    
                    isSatisfy = YES;
                    
                    data.originY = ( height - fontHeight * ( count * 1.2 - .2 ) ) / 2.f;
                    data.height  = fontHeight;
                    data.count   = count;
                    data.font    = i ;
                    data.rate    = .2;
                    break;
                    
                }
                
            }else {
                isSatisfy = YES;
                
                data.originY = ( height - fontHeight * ( count * 1.5 - .5 ) ) / 2.f;
                data.height  = fontHeight;
                data.count   = count;
                data.font    = i ;
                data.rate    = .5;
                break;
                
            }
            
        } else {
            isSatisfy = YES;
            
            data.originY = ( height - fontHeight * ( count * 2 - 1 ) ) / 2.f;
            data.height  = fontHeight;
            data.count   = count;
            data.font    = i ;
            data.rate    = 1;
            break;
            
        }
        
    }
    
    self.dataModel = data;
    return data;
    
}

- (CGFloat) HeightByFont:(CGFloat)font {
    
    CGSize resultSize = [@" " boundingRectWithSize:CGSizeMake(100, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font],NSParagraphStyleAttributeName:[NSMutableParagraphStyle new]} context:nil].size;
    return resultSize.height;
}

//当前index 以及前三项简称
- (void)setupSectionTitles {
    
    if (![self.delegate respondsToSelector:@selector(tpdSectionTitlesForIndexView:atIndex:)]) return;
    
    [self.delegate tpdSectionTitlesForIndexView:self atIndex:self.selectIndex];
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupIndexTitles];
}

- (void)tpdScrollIndex:(NSInteger)sectionIndex {
    
    if (self.indexTitles.count == 0) return;
    
    
    NSInteger index = sectionIndex;
    if (index >= self.indexTitles.count) {
        index = self.indexTitles.count - 1;
    }
    if ([self.delegate respondsToSelector:@selector(tpdIndexView:didSelectAtIndex:)]) {
        [self.delegate tpdIndexView:self didSelectAtIndex:index];
        self.selectIndex = index;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.indexTitles.count == 0) return;
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (touchPoint.x < self.tp_width - 40) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    
    //    NSInteger index = touchPoint.y / (self.tp_height / self.indexTitles.count);
    
    NSInteger index = [self getIndexByPoint:touchPoint];
    if (index == -1) {
        return;
    }
    if (index >= self.indexTitles.count) {
        index = self.indexTitles.count - 1;
    }
    if ([self.delegate respondsToSelector:@selector(tpdIndexView:didSelectAtIndex:)]) {
        [self.delegate tpdIndexView:self didSelectAtIndex:index];
        self.selectIndex = index;
        [self setupSectionTitles];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.indexTitles.count == 0) return;
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (touchPoint.x < self.tp_width - 40) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    //    NSInteger index = touchPoint.y / (self.tp_height / self.indexTitles.count);
    //    NSInteger index = touchPoint.y / (self.tp_height / self.indexTitles.count);
    
    NSInteger index = [self getIndexByPoint:touchPoint];
    if (index == -1) {
        return;
    }
    
    if (index >= self.indexTitles.count) {
        index = self.indexTitles.count - 1;
    }
    if ([self.delegate respondsToSelector:@selector(tpdIndexView:didSelectAtIndex:)]) {
        [self.delegate tpdIndexView:self didSelectAtIndex:index];
        self.selectIndex = index;
        [self setupSectionTitles];
    }
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && (point.x < self.tp_width - 40)){
        return nil;
    }
    return hitView;
}


- (NSInteger) getIndexByPoint:(CGPoint)point {
    if (point.x> 40 || point.x < 0 ) {
        return -1;
    }
    NSInteger index = 0;
    CGFloat Y = point.y;
    CGFloat top = self.dataModel.originY - self.dataModel.rate * self.dataModel.height / 2;
    CGFloat bottom = self.dataModel.originY + self.dataModel.rate * self.dataModel.height / 2 + self.indexTitles.count * (self.dataModel.height ) * (1 + self.dataModel.rate);
    CGFloat gap = self.dataModel.height * (1 + self.dataModel.rate);
    if ( Y <  top||  Y > bottom) {
        return  - 1 ;
    } else {
        
        CGFloat originIndex = ( Y - top) / gap;
        index = originIndex / 1;
    }
    
    
    
    
    return  index;
}
@end
#pragma mark ***********
#pragma mark - TPDContactsViewController
#pragma mark ***********
@interface TPDContactsViewController ()<UITableViewDelegate,UITableViewDataSource,TPDIndexViewDelegate,TPDCurrentIndexViewDelegate>
@property (nonatomic, strong) UITableView *defaultSortTableView;
@property (nonatomic, strong) UITableView *cityGroupTableView;
@property (nonatomic, strong) UITableView *companyGroupTableView;

@property (atomic, strong) NSArray *defaultGroupContacts;
@property (atomic, strong) NSArray *recentContacts;
@property (atomic, strong) NSArray *cityGroupContacts;
@property (atomic, strong) NSArray *companyGroupContacts;

@property (atomic, strong) NSMutableArray *cityGroupContactStatusArray;
@property (atomic, strong) NSMutableArray *companyGroupContactStatusArray;

@property (atomic, strong) NSMutableArray *singleIndexArray;

@property (nonatomic, weak)   UILabel               *searchBar;
@property (nonatomic, weak)   UIButton              *addButton;
@property (nonatomic, weak)   TPDIndexView          *indexView;
@property (nonatomic, strong) TPDCurrentIndexView   *currentIndexView;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UIView* maskView;
@property (nonatomic, strong) UIView* emptyView;
@property (nonatomic, strong) UIView* emptyCompanyView;
@property (nonatomic, strong) UIWindow* topWindow;
@property (nonatomic)         BOOL    skinChange;

@end

@implementation TPDContactsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadAllDataAndView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.rdv_tabBarController.tabBarHidden = NO;
    
    [FunctionUtility updateStatusBarStyle];
    
    if (self.skinChange) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIButton *b = self.contentView.tpd_horizontalTab.tpd_btnArrInGroup[1]  ;
            [b sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        self.skinChange = NO;
    }
    self.currentIndexView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.rdv_tabBarController.tabBarHidden = YES;
}

- (void)setupHeaderView {
    
    UIImageView *headView = [[UIImageView alloc] init];
    headView.userInteractionEnabled = YES;
    headView.image = [TPDialerResourceManager getImage:@"common_header_bg@2x.png"];
    headView.backgroundColor = RGB2UIColor2(3,169,244);
    [self.view addSubview:headView];
    
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.view);
        make.height.equalTo(64);
    }];
    
    UIView *viewContainer = [UIView new];
    viewContainer.userInteractionEnabled = NO;
    
    UILabel *searchImageLabel = [UILabel new];
    searchImageLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:14];
    searchImageLabel.text = @"L";
    UIColor *color = [TPDialerResourceManager getColorForStyle:@"skinSearchBarHintText_color"];
    searchImageLabel.textColor = color;
    [viewContainer addSubview:searchImageLabel];
    
    
    [searchImageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(viewContainer);
        //        make.top.height.equalTo(28);
    }];
    
    UILabel *searchLabel = [UILabel new];
    searchLabel.font = [UIFont systemFontOfSize:12];
    searchLabel.layer.cornerRadius = 5.3;
    searchLabel.text = @"共111个联系人";
    self.searchBar = searchLabel;
    searchLabel.textColor = color;
    [viewContainer addSubview:searchLabel];
    
    
    [searchLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchImageLabel.right).offset(16);
        make.right.equalTo(viewContainer);
        make.centerY.equalTo(searchImageLabel);
    }];
    
    
    
    UIButton *searchBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBar setTitleColor:kBlueColor forState:UIControlStateNormal];
    searchBar.titleLabel.font = [UIFont systemFontOfSize:12];
    searchBar.layer.cornerRadius = 14;
    searchBar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"skinSearchBarTextFieldBackground_color"];
    [searchBar addTarget:self action:@selector(pushContactSearchVc) forControlEvents:UIControlEventTouchDown];
    [headView addSubview:searchBar];
    [headView addSubview:viewContainer];
    
    
    [searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(54);
        make.top.height.equalTo(28);
    }];
    
    [viewContainer makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(searchBar);
        make.height.equalTo(searchImageLabel);
    }];
    
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [addButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal];
    //    [addButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_ht_color"] forState:UIControlStateHighlighted];
    [addButton setSkinStyleWithHost:self forStyle:@""];
    addButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:28];
    [addButton setTitle:@"w" forState:UIControlStateNormal];
    addButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addButton.selected = NO;
    [addButton addTarget:self action:@selector(showSheetOnNavigation) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:addButton];
    self.addButton = addButton;
    [addButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar);
        make.width.equalTo(54);
        make.height.equalTo(searchBar);
        make.left.equalTo(searchBar.right);
        make.right.equalTo(self.view);
    }];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [scanButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal];
    [scanButton setSkinStyleWithHost:self forStyle:@""];
    scanButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:28];
    [scanButton setTitle:@"v" forState:UIControlStateNormal];
    scanButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    scanButton.selected = NO;
    [scanButton addTarget:self action:@selector(pushToScanClick) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:scanButton];
    [scanButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar);
        make.width.equalTo(54);
        make.height.equalTo(searchBar);
        make.left.equalTo(headView);
    }];
    
    
    self.topWindow = [UIView tpd_topWindow];
    
    
}

- (void)loadAllContactsData {
    
    [self reloadDefaultTableView];
    [self reloadCityTableView];
    [self reloadCompanyTableView];
    
}
- (void)loadAllContactsView {
    
    //默认排序
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchBar.text = [NSString stringWithFormat:@"搜索 | 共%d位联系人",[[ContactCacheDataManager instance] getAllCacheContact].count];
        [self.defaultSortTableView reloadData];
        [self.indexView tpdReloadData];
        if (self.defaultGroupContacts.count == 0) {
            self.emptyView.hidden = NO;
        }else {
            self.emptyView.hidden = YES;
        }
    });
    
    //城市排序
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cityGroupTableView reloadData];
    });
    
    //公司排序
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.companyGroupContacts.count == 0) {
            self.emptyCompanyView.hidden = NO;
        }else {
            self.emptyCompanyView.hidden = YES;
        }
        
        [self.companyGroupTableView reloadData];
    });

    
}


- (void)reloadDefaultTableView {
    //异步准备数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        NSMutableArray *defaultTempArray = [[[ContactCacheDataManager instance] getAllCacheContactGroups] mutableCopy];
        
        //        self.defaultGroupContacts = [[ContactCacheDataManager instance] getAllCacheContactGroups];
        
        TPDContactGroupModel *contactGroupModel = defaultTempArray[0];
        
        
        //名字乱码
        if ([contactGroupModel.candidateKey isEqualToString:@"#"]  )  {
            [defaultTempArray removeObjectAtIndex:0];
            [defaultTempArray addObject:contactGroupModel];
        }
        
        contactGroupModel = defaultTempArray[0];
        
        //名字为空有号码
        if ( [contactGroupModel.candidateKey isEqualToString:@"*"]) {
            [defaultTempArray removeObjectAtIndex:0];
            [defaultTempArray addObject:contactGroupModel];
        }
        
        
        NSMutableArray *tempDataArray = [NSMutableArray new];
        
        
        NSMutableArray * tempSingleIndexArray = [NSMutableArray new];
        // 去空
        NSMutableArray *temp = [NSMutableArray new];
        for (int  i = 0 ; i < defaultTempArray.count; i ++) {
            NSMutableArray *tem = [NSMutableArray new];
            
            for ( int j = 0 ; j < ((TPDContactGroupModel *)defaultTempArray[i]).contacts.count; j ++) {
                
                ContactCacheDataModel *contact = ((TPDContactGroupModel *)defaultTempArray[i]).contacts[j];
                if (contact.phones.count == 0) {
                    
                }else {
                    [tem addObject:contact];
                }
                
            }
            if (tem.count > 0 ) {
                TPDContactGroupModel *new  = [TPDContactGroupModel new];
                new.candidateKey = ((TPDContactGroupModel *)defaultTempArray[i]).candidateKey;
                new.contacts = [tem mutableCopy];
                [temp addObject:new];
            }
            
        }
        defaultTempArray = temp;
        
        
        
        
        //联系人索引数组
        for (int  i = 0 ; i < defaultTempArray.count; i ++) {
            
            NSMutableArray *temp = [NSMutableArray new];//
            NSMutableArray *tempCurrentArray = [NSMutableArray new];
            
            //(TPDContactGroupModel *)self.defaultGroupContacts[i]) 第i个section
            for ( int j = 0 ; j < ((TPDContactGroupModel *)defaultTempArray[i]).contacts.count; j ++) {
                
                
                ContactCacheDataModel *contact = ((TPDContactGroupModel *)defaultTempArray[i]).contacts[j];
                if (contact.phones.count == 0) {
                    continue ;
                }else {
                    [tempCurrentArray addObject:contact];
                }
                if (contact.fullName.length == 0) {
                    NSDictionary * tempDic =[NSDictionary dictionaryWithObjectsAndKeys:@"",@"name",[NSIndexPath indexPathForRow:tempCurrentArray.count - 1 inSection:tempDataArray.count],@"indexPath", nil];
                    [temp addObject:tempDic];
                    continue ;
                }
                NSString *tempString = [contact.fullName substringToIndex:1];
                if (temp.count == 0) {
                    NSDictionary * tempDic =[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"name",[NSIndexPath indexPathForRow:tempCurrentArray.count - 1 inSection:tempDataArray.count],@"indexPath", nil];
                    [temp addObject:tempDic];
                }else {
                    if (![tempString isEqualToString:[temp lastObject][@"name"]]) {
                        NSDictionary * tempDic =[NSDictionary dictionaryWithObjectsAndKeys:tempString,@"name",[NSIndexPath indexPathForRow:tempCurrentArray.count  - 1 inSection:tempDataArray.count],@"indexPath", nil];
                        [temp addObject:tempDic];
                    }
                }
                NSLog(@"luhuicontact \n%@\n",contact.fullName);
            }
            
            
            if (temp.count > 0) {
                [tempSingleIndexArray addObject:temp];
                
            }
            if (tempCurrentArray.count > 0 ) {
                TPDContactGroupModel *contact = [TPDContactGroupModel new];
                contact.candidateKey =((TPDContactGroupModel *)defaultTempArray[i]).candidateKey;
                contact.contacts = tempCurrentArray;
                [tempDataArray addObject:contact];
            }
            
        }
        
        self.defaultGroupContacts = defaultTempArray;
        self.singleIndexArray =     tempSingleIndexArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchBar.text = [NSString stringWithFormat:@"搜索 | 共%d位联系人",[[ContactCacheDataManager instance] getAllCacheContact].count];
            [self.defaultSortTableView reloadData];
            [self.indexView tpdReloadData];
            if (self.defaultGroupContacts.count == 0) {
                self.emptyView.hidden = NO;
            }else {
                self.emptyView.hidden = YES;
            }
        });
        
    });
    
}


- (void)reloadCityTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //city
        [[PhonePadModel getSharedPhonePadModel] queryCallLogList];
        
        //将@"Foreigners" 和 @"Others" 置后
        NSArray *cityGroups = [[OrlandoEngine instance] getCityGroup];
        NSMutableArray *cityTempArray = [cityGroups mutableCopy];
        NSMutableArray *tempNewArray = [NSMutableArray new];
        
        for (int i = 0 ; i < cityGroups.count; i ++ ) {
            CityGroupModel * tem = cityGroups[i];
            if ([tem.cityName isEqualToString:@"Foreigners"] || [tem.cityName isEqualToString:@"Others"]) {
                [tempNewArray addObjectsFromArray:tem.contactIDs];
                [cityTempArray removeObject:tem];
            }
            
        }
        cityGroups = [cityTempArray sortedArrayUsingFunction:sortCityGroupByFirstChar context:nil];
        if (tempNewArray.count > 0) {
            CityGroupModel * temModel = [CityGroupModel new];
            temModel.cityName = @"其他";
            temModel.contactIDs = tempNewArray;
            [cityTempArray addObject:temModel];
        }
        cityGroups = cityTempArray;
        
        
        
        _cityGroupContactStatusArray = [NSMutableArray new];
        
        for (int i = 0 ; i < cityGroups.count ; i ++) {
            [_cityGroupContactStatusArray addObject:@0];
        }
        self.cityGroupContacts = cityGroups;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cityGroupTableView reloadData];
        });
    });
    
}
- (void)reloadCompanyTableView {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.companyGroupContacts = [TPDContactGroupModel loadCompaniesContactGroupModel];
        _companyGroupContactStatusArray = [NSMutableArray new];
        
        for (int i = 0 ; i < _companyGroupContacts.count ; i ++) {
            [_companyGroupContactStatusArray addObject:@0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.companyGroupContacts.count == 0) {
                self.emptyCompanyView.hidden = NO;
            }else {
                self.emptyCompanyView.hidden = YES;
            }
            
            [self.companyGroupTableView reloadData];
        });
    });
}

- (void)reloadView {
    
    [self.cityGroupTableView reloadData];
    self.searchBar.text = [NSString stringWithFormat:@"搜索 | 共%d位联系人",[[ContactCacheDataManager instance] getAllCacheContact].count];
    [self.defaultSortTableView reloadData];
    [self.companyGroupTableView reloadData];
    [self.indexView tpdReloadData];
    if (self.defaultGroupContacts.count == 0) {
        self.emptyView.hidden = NO;
    }else {
        self.emptyView.hidden = YES;
    }
    
}



- (void)setupListView {
    
    UIColor* color = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
    UILabel* defaultSortLabel = [[UILabel tpd_commonLabel] tpd_withText:@"默认排序" color:color  font:14].cast2UILabel;
    UILabel* ciryGroupLabel = [[UILabel tpd_commonLabel] tpd_withText:@"城市分组" color:color  font:14].cast2UILabel;
    UILabel* companyGroupLabel = [[UILabel tpd_commonLabel] tpd_withText:@"公司分组" color:color font:14].cast2UILabel;
    
    self.defaultSortTableView = [self setupTableView];
    self.cityGroupTableView = [self setupTableView];
    self.companyGroupTableView = [self setupTableView];
    UIView *defaultSortTableViewWrapper = [[UIView alloc] init];
    
    TPDIndexView *indexView = [[TPDIndexView alloc] init];
    indexView.delegate = self;
    self.indexView = indexView;
    
    TPDCurrentIndexView *currentIndexView = [TPDCurrentIndexView new];
    currentIndexView.delegate = self;
    [currentIndexView setNeedsUpdateConstraints];
    currentIndexView.layer.borderColor = [[TPDialerResourceManager getColorForStyle:@"skinSectionIndexPopupBackground_color"]colorWithAlphaComponent:.7].CGColor;
    currentIndexView.layer.cornerRadius = 30;
    currentIndexView.layer.borderWidth = .3;
    currentIndexView.layer.shadowOffset = CGSizeMake(0, 1);
    currentIndexView.layer.shadowColor = [[TPDialerResourceManager getColorForStyle:@"skinSectionIndexPopupBackground_color"] colorWithAlphaComponent:.7].CGColor;;
    currentIndexView.layer.shadowRadius = 10;
    currentIndexView.layer.shadowOpacity = .3;
    currentIndexView.hidden = YES;
    self.currentIndexView = currentIndexView;
    
    NSArray* labelArr = @[ciryGroupLabel,defaultSortLabel,companyGroupLabel];
    NSArray* pageArr = @[self.cityGroupTableView,defaultSortTableViewWrapper,self.companyGroupTableView];
    UIView* contentView = [UIView tpd_horizontalTabsPagesSuite:labelArr pages:pageArr tabSelectBlock:^(UIButton *btn) {
        if (btn.selected) {
            if (self.currentIndexView.hidden == NO) {
                self.currentIndexView.hidden = YES;
            }
            
            UILabel* label = labelArr[btn.tag];
            label.alpha = 1.f;
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                label.layer.transform = CATransform3DMakeScale(1.25,1.25,1.0);
            } completion:^(BOOL finished){
                switch (btn.tag) {
                    case 0:
                        [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                                                  kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_CITYCLICK, @(1)), nil];
                        
                        break;
                    case 2:
                        [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                                                  kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_COMPANYCLICK, @(1)), nil];
                        
                        break;
                        
                    default:
                        break;
                }
            }];
            
            
        }else{
            UILabel* label = labelArr[btn.tag];
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                label.layer.transform = CATransform3DMakeScale(1,1,1.0);
                
            } completion:^(BOOL finished){
                
            }];
            label.alpha = .8f;
            
        }
    }];
    
    contentView.tpd_horizontalPages.scrollEnabled = NO;
    UIView* tabWrapper = [[contentView.tpd_horizontalTab tpd_withHeight:36] tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(0, 0,0,0)];
    
    self.contentView = contentView;
    
    UIImageView*companyImageView = [UIImageView new];
    companyImageView.image = [UIImage imageNamed:@"contact_empty_icon"];
    companyImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //添加子view
    [defaultSortTableViewWrapper addSubview:indexView];
    [defaultSortTableViewWrapper addSubview:self.defaultSortTableView];
    [defaultSortTableViewWrapper addSubview:currentIndexView];
    [defaultSortTableViewWrapper addSubview:[self loadEmptyView]];
    
    [contentView addSubview:tabWrapper];
    [contentView addSubview:contentView.tpd_horizontalPages];
    [self.view addSubview:contentView];
    [self.companyGroupTableView addSubview:[self loadEmptyCompanyView]];
    
    
    
    //约束
    [self.defaultSortTableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(defaultSortTableViewWrapper);
    }];
    
    [indexView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultSortTableViewWrapper).offset(10);
        make.right.equalTo(defaultSortTableViewWrapper);
        make.width.equalTo(40);
        make.bottom.equalTo(defaultSortTableViewWrapper).offset(-10);
    }];
    
    [currentIndexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultSortTableViewWrapper).offset(10 + 36);
        make.width.equalTo(60);
        make.right.equalTo(defaultSortTableViewWrapper).offset(-80);
        //        make.height.equalTo(200);
        
    }];
    [tabWrapper updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(contentView);
    }];
    
    [contentView.tpd_horizontalPages updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tabWrapper.bottom);
        make.left.right.bottom.equalTo(contentView);
    }];
    
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
    }];
    
    [self.emptyView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(defaultSortTableViewWrapper);
    }];
    
    [self.emptyCompanyView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(self.companyGroupTableView);
    }];
    
    
    
    //皮肤化图片配置
    UIImageView *backImage = [UIImageView new];
    [ciryGroupLabel.superview.superview.superview.superview.superview insertSubview:backImage belowSubview:ciryGroupLabel.superview.superview.superview.superview];
    
    backImage.image = [TPDialerResourceManager getImage:@"contact_group_header_section_bg@2x.png"];
    [backImage makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ciryGroupLabel.superview.superview.superview.superview.superview);
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *b = self.contentView.tpd_horizontalTab.tpd_btnArrInGroup[1]  ;
        [b sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
    
    
    
}

- (UIView *)loadEmptyView {
    
        self.emptyView = [UIView new];
        self.emptyView.hidden = YES;
        
        UILabel *mentionLabel = [[UILabel new] tpd_withText:@"手机没有联系人？去开启通讯录权限，或试试通讯录迁移。" color:[TPDialerResourceManager getColorForStyle:@"skinSearchResultBlankMainText_color"] font:16];
        mentionLabel.numberOfLines = 2;
        mentionLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *imageView = [[[UIImageView new] tpd_withSize:CGSizeMake(130, 130)] tpd_withBackgroundColor:[UIColor clearColor]].cast2UIImageView;
        imageView.image = [UIImage imageNamed:@"contact_empty_icon.png"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSArray *nameArray = @[@"开启权限",@"立即迁移"];
        
        UIButton *setLimitButton = [[[[[UIButton buttonWithType:UIButtonTypeSystem] tpd_withSize:CGSizeMake(160, 50)]tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withCornerRadius:25] tpd_withBorderWidth:1 color:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]].cast2UIButton;
        [setLimitButton setTitle:nameArray[0] forState:UIControlStateNormal];
        [setLimitButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"] forState:UIControlStateNormal];
        [setLimitButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }];
        //        [setLimitButton addTarget:self action:@selector(say) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *transferButton = [[[[[UIButton buttonWithType:UIButtonTypeSystem] tpd_withSize:CGSizeMake(160, 50)]tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withCornerRadius:25] tpd_withBorderWidth:1 color:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]].cast2UIButton;
        [transferButton setTitle:nameArray[1] forState:UIControlStateNormal];
        [transferButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"] forState:UIControlStateNormal];
        [transferButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            [self gotoScan];
        }];
        UIView* wrapper = [UIView new];
        [[wrapper tpd_addSubviewsWithVerticalLayout:@[[imageView  tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                      [mentionLabel tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                      [setLimitButton tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                      [transferButton tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment]]
                                            offsets:@[@0,@23,@37,@16]]
         tpd_withBackgroundColor:[UIColor clearColor]];
        setLimitButton.superview.userInteractionEnabled = YES;
        transferButton.superview.userInteractionEnabled = YES;
        
        [self.emptyView addSubview:wrapper];
        
        
        [mentionLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(260);
        }];
        [wrapper makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.emptyView);
            make.width.equalTo(self.emptyView);
        }];
    return self.emptyView;
}

- (UIView *)loadEmptyCompanyView {
    
        self.emptyCompanyView = [UIView new];
        self.emptyCompanyView.hidden = YES;
        
        UIImageView *imageView = [[[UIImageView new] tpd_withSize:CGSizeMake(130, 130)] tpd_withBackgroundColor:[UIColor clearColor]].cast2UIImageView;
        imageView.image = [UIImage imageNamed:@"contact_empty_icon.png"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *mentionLabel = [[UILabel new] tpd_withText:@"还没有公司分组联系人？\n可以尝试在联系人详情中添加公司信息" color:[TPDialerResourceManager getColorForStyle:@"skinSearchResultBlankMainText_color"] font:16];
        mentionLabel.numberOfLines = 2;
        mentionLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView* wrapper = [UIView new];
        [[wrapper tpd_addSubviewsWithVerticalLayout:@[[imageView  tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                      [mentionLabel tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment]]
                                            offsets:@[@0,@23]]
         tpd_withBackgroundColor:[UIColor clearColor]];
        
        [self.emptyCompanyView addSubview:wrapper];
        
        [mentionLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(300);
        }];
        [wrapper makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.emptyCompanyView);
            make.width.equalTo(self.emptyCompanyView);
        }];
        return self.emptyCompanyView;
}

- (UITableView *)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [UIView new];
    return tableView;
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAllContactsData) name:N_PERSON_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAllContactsData) name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAllViewSkin) name:N_SKIN_SHOULD_CHANGE object:nil];
}

#pragma mark - Event
- (void)loadAllViewSkin {
    
    [self loadAllView];
    self.skinChange = YES;
    
}
//init
- (void)loadAllDataAndView {
    
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setupHeaderView];
    
    [self setupListView];
    
    [self loadAllContactsData];
    
    [self setupNotification];
}

//reload
- (void)loadAllView{
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setupHeaderView];
    
    [self setupListView];
    
    [self loadAllContactsView];
    
}

- (void)pushContactSearchVc {
    [self rdv_tabBarController].tabBarHidden = YES;
    
    TPDContactSearchViewController *searchVc = [[TPDContactSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVc/*[TPDContactCopyViewController new]*/ animated:NO];
    [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                              kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_SEARCHVIEWCLICK, @(1)), nil];
    
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.cityGroupTableView) {
        if ( [_cityGroupContactStatusArray[section] intValue] == 0 ) {
            return 1;
        }else {
            CityGroupModel *cityGroupModel = self.cityGroupContacts[section];
            return cityGroupModel.contactIDs.count + 1;
        }
        
    }
    
    if (tableView == self.companyGroupTableView) {
        
        if ( [_companyGroupContactStatusArray[section] intValue] == 0 ) {
            return 1;
        }else {
            TPDContactGroupModel *companyGroupModel = self.companyGroupContacts[section];
            return companyGroupModel.contacts.count + 1;
        }
        
    }
    
    TPDContactGroupModel *contactGroupModel = self.defaultGroupContacts[section];
    return contactGroupModel.contacts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.cityGroupTableView) {
        return self.cityGroupContacts.count;
    }
    
    if (tableView == self.companyGroupTableView) {
        return self.companyGroupContacts.count;
    }
    
    return self.defaultGroupContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakself = self;
    NSString *name = @""; NSInteger personID = 0;BOOL showSeparateLine = YES;
    UIView *separateLine = [[UIView alloc] init];
    separateLine.tag = 100;
    separateLine.backgroundColor = kSeparateLineColor;
    ContactCacheDataModel *contact;
    if (tableView == self.defaultSortTableView) {
        TPDContactGroupModel *contactGroupModel = self.defaultGroupContacts[indexPath.section];
        contact = contactGroupModel.contacts[indexPath.row];
        name = contact.fullName;
        personID = contact.personID;
        if (indexPath.row == contactGroupModel.contacts.count - 1) {
            showSeparateLine = NO;
        }
    }
    if (tableView == self.companyGroupTableView) {
        
        if (indexPath.row == 0 ) {
            TPDContactGroupModel *contactGroupModel = self.companyGroupContacts[indexPath.section];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            int isOpen = [_companyGroupContactStatusArray[indexPath.section] intValue];
            cell = [UITableViewCell tpd_tableViewCellStyle1:@[@"",@"",@"",@""] action:^(id action) {
                if ( isOpen == 0 ) {
                    [_companyGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@1];
                }else {
                    [_companyGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@0];
                }
                
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            } reuseId:@"Cell"];
            cell.tpd_label1.text =  isOpen ? @"M" : @"N";
            cell.tpd_container.userInteractionEnabled = NO;
            cell.textLabel.text = contactGroupModel.candidateKey;
            cell.tpd_label1.text = isOpen ? @"M" : @"N";
            cell.tpd_label1.font = [UIFont fontWithName:@"iPhoneIcon4" size:24];
            cell.tpd_label1.backgroundColor = [UIColor clearColor];
            cell.tpd_label1.textColor = [UIColor lightGrayColor];//[TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
            
            [cell addSubview:separateLine];
            
            [separateLine makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.textLabel);
                make.bottom.right.equalTo(cell);
                make.height.equalTo(1 / [UIScreen mainScreen].scale);
            }];
            [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.textLabel);
                make.left.equalTo(cell.right).offset(-35);
                make.width.height.equalTo(30);
            }];
            cell.selectionStyle=UITableViewCellSelectionStyleGray;
            return cell;
        } else {
            TPDContactGroupModel *contactGroupModel = self.companyGroupContacts[indexPath.section];
            contact = contactGroupModel.contacts[indexPath.row - 1];
            name = contact.fullName;
            personID = contact.personID;
            if (indexPath.row == contactGroupModel.contacts.count - 1) {
                showSeparateLine = NO;
            }
        }
    }
    if (tableView == self.cityGroupTableView) {
        CityGroupModel *cityGroupModel = self.cityGroupContacts[indexPath.section];
        if (indexPath.row == 0) {
            int isOpen = [_cityGroupContactStatusArray[indexPath.section] intValue];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell = [UITableViewCell tpd_tableViewCellStyle1:@[@"",@"",@"",@""] action:^(id action) {
                if ( isOpen == 0 ) {
                    [_cityGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@1];
                }else {
                    [_cityGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@0];
                }
                ((UITableViewCell *)action).tpd_label1.text =  isOpen ? @"M" : @"N";
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            } reuseId:@"Cell"];
            cell.tpd_container.userInteractionEnabled = NO;
            cell.tpd_label1.text =  isOpen ? @"M" : @"N";
            cell.textLabel.text =  [NSString stringWithFormat:@"%@  (%@)",cityGroupModel.cityName,@(cityGroupModel.contactIDs.count)];
            cell.tpd_label1.text = isOpen ? @"M" : @"N";
            cell.tpd_label1.font = [UIFont fontWithName:@"iPhoneIcon4" size:24];
            cell.tpd_label1.backgroundColor = [UIColor clearColor];
            cell.tpd_label1.textColor = [UIColor lightGrayColor];//[TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
            
            [cell addSubview:separateLine];
            
            [separateLine makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.textLabel).offset(0);
                make.bottom.right.equalTo(cell);
                make.height.equalTo(1 / [UIScreen mainScreen].scale);
            }];
            [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.textLabel);
                make.left.equalTo(cell.right).offset(-35);
                make.width.height.equalTo(30);
            }];
            
            cell.selectionStyle=UITableViewCellSelectionStyleGray;
            return cell;
            
        }else {
            NSNumber *personId = cityGroupModel.contactIDs[indexPath.row -1 ];
            contact = [[ContactCacheDataManager instance] contactCacheItem:personId.integerValue];
            name = contact.fullName;
            personID = contact.personID;
            if (indexPath.row == cityGroupModel.contactIDs.count - 1) {
                showSeparateLine = NO;
            }
            
        }
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell = [UITableViewCell tpd_tableViewCellStyle1:@[@"",@"",@"",@""] action:^(id action) {
        
    } reuseId:@"Cell"];
    cell.tpd_container.userInteractionEnabled = NO;
    cell.tpd_label1.font = [UIFont boldSystemFontOfSize:17];
    cell.tpd_label1.numberOfLines = 1;
    cell.tpd_img1.contentMode = UIViewContentModeScaleAspectFit;
    cell.tpd_img1.layer.masksToBounds = YES;
    cell.tpd_img1.layer.cornerRadius = 18;
    
    [cell addSubview:separateLine];
    
    [cell.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(36);
        make.height.equalTo(36);
    }];
    [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.tpd_img1).offset(66);
        make.right.equalTo(cell).offset(-80);
    }];
    [separateLine makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.tpd_label1);
        make.bottom.right.equalTo(cell);
        make.height.equalTo(1 / [UIScreen mainScreen].scale);
    }];
    
    cell.tpd_img1.cast2UIImageView.image =  contact.image != nil ? contact.image : [PersonDBA getDefaultColorImageWithoutPersonID];
    cell.tpd_img1.backgroundColor = [UIColor redColor];
    cell.tpd_label1.text = name;
    cell.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;
    [cell addGestureRecognizer:[UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateBegan) {
            [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                                      kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_LONGGESTURE, @(1)), nil];
            NSArray *array  = [ContactInfoModelUtil getPhoneNumberArrayByPersonId:personID];
            [weakself showSheetNumber:((ContactInfoCellModel *)array[0]).mainStr Name:name Image:cell.tpd_img1.cast2UIImageView.image PersonId:personID] ;
        }
    }]];
    [cell viewWithTag:100].hidden = !showSeparateLine;
    return cell;
}


-(void)showSheetNumber:(NSString *)number Name:(NSString *)name Image:(UIImage *)image PersonId:(NSInteger) personId{
    WEAK(self);
    
    //初始化
    UITableViewCell* topCell  = [[[[UITableViewCell tpd_tableViewCellStyle1:@[@"",@"",@"",@""] action:^(id action) { } reuseId:@"Cell"] tpd_withHeight:66] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]].cast2UITableViewCell;
    topCell.tpd_img1.cast2UIImageView.image =  image;
    topCell.tpd_img1.backgroundColor = RGB2UIColor2(217,217,217);
    [topCell.tpd_img1 tpd_withCornerRadius:18];
    topCell.tpd_label1.font = [UIFont boldSystemFontOfSize:17];
    topCell.tpd_label1.text = name;
    topCell.tpd_label1.numberOfLines = 1;
    topCell.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;
    topCell.tpd_label1.font = [UIFont boldSystemFontOfSize:18];
    
    UITableViewCell* callCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:j:30:tp_color_grey_600",@"呼叫",@"",@""] action:^(id sender) {
        [weakself makeCall:personId Numer:number];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [callCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* smsCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:B:30:tp_color_grey_600",@"短信",@"",@""] action:^(id sender) {
        [weakself sendMessage:number];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [smsCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    NSArray* displayedCells = @[[callCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[smsCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)]];
    UIView* wrapper = [[[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:displayedCells offsets:@[@0,@0,@0]] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]];
    UIView* wrapper2 = [[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[topCell, wrapper] offsets:@[@0,@15]] tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    self.maskView = [wrapper2 tpd_maskViewContainer:^(id sender) {
    }];
    
    //添加子视图
    [self.topWindow addSubview:self.maskView];
    
    //约束
    [topCell.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(36);
        make.height.equalTo(36);
    }];
    [topCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topCell.tpd_img1).offset(50);
        make.right.equalTo(topCell).offset(-20);
    }];
    [callCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(callCell.tpd_img1).offset(50);
    }];
    [smsCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(smsCell.tpd_img1).offset(50);
    }];
    [self.maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topWindow);
    }];
    [wrapper2 remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.maskView);
    }];
    
    
}


-(void)showSheetOnNavigation {
    WEAK(self);
    self.currentIndexView.hidden = YES;
    //初始化
    UIView* wrapper = [UIView new];
    self.maskView = [wrapper tpd_maskViewContainer:^(id sender) {
    }];
    
    UITableViewCell* createCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:i:24:tp_color_grey_600",@"新建联系人",@"",@""] action:^(id sender) {
        self.maskView.hidden = YES;
        [self.maskView removeFromSuperview];
        [[TPABPersonActionController controller] addNewPersonPresentedBy:self];
    }] tpd_withHeight:50].cast2UITableViewCell;
    [createCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* scanCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:6:24:tp_color_grey_600",@"扫描名片",@"",@""] action:^(id sender) {
        self.maskView.hidden = YES;
        [self.maskView removeFromSuperview];
        [DialerUsageRecord recordpath:PATH_SCANCARD
                                  kvs:Pair(CONTACT_SCANCARD_ENTRANCE_CLICK, @(1)), nil];
        [self.navigationController pushViewController:[TPScanCardViewController new] animated:YES];
    }] tpd_withHeight:50].cast2UITableViewCell;
    [scanCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* inviteCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:J:24:tp_color_grey_600",@"邀请有奖",@"",@""]action:^(id sender) {
        self.maskView.hidden = YES;
        [self.maskView removeFromSuperview];
        [[GroupOperationCommandCreatorCopy commandForType:CommandTypeInviting withData:nil] onClickedWithPageNode:[LeafNodeWithContactIds new] withPersonArray:[NSMutableArray new] ];
    }] tpd_withHeight:50].cast2UITableViewCell;
    [inviteCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* transferCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:P:24:tp_color_grey_600",@"通讯录迁移",@"",@""] action:^(id sender) {
        self.maskView.hidden = YES;
        [self.maskView removeFromSuperview];
        [weakself gotoScan];
    }] tpd_withHeight:50].cast2UITableViewCell;
    [transferCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* deleteCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:v:24:tp_color_grey_600",@"批量删除",@"",@""] action:^(id sender) {
        self.maskView.hidden = YES;
        [self.maskView removeFromSuperview];
        TPDSelectViewController *deleteViewController = [TPDSelectViewController new];
        deleteViewController.type = 0;
        [self.navigationController pushViewController:deleteViewController animated:YES];
        self.rdv_tabBarController.tabBarHidden = YES;
    }] tpd_withHeight:50].cast2UITableViewCell;
    [deleteCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    //other
    NSArray* displayedCells = @[[createCell     tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)],
                                [scanCell       tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)],
                                [inviteCell     tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)],
                                [transferCell   tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)],
                                [deleteCell     tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)]];
    
    [[[wrapper tpd_addSubviewsWithVerticalLayout:displayedCells offsets:@[@0,@0,@0,@0,@0]] tpd_withCornerRadius:7.f] tpd_withBackgroundColor:[UIColor whiteColor]];
    
    
    
    //添加子视图
    [self.topWindow addSubview:self.maskView];
    
    //约束
    [self.maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topWindow);
    }];
    [wrapper remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.maskView).offset(-8);
        make.top.equalTo(65);
        make.width.equalTo(150);
    }];
    
    
}


-(void)cancelLongPress{
    [self.maskView removeFromSuperview];
}

-(void)copyPhoneNumber:(NSString*)data{
    if ([data isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"copy"), nil];
    }
    NSString *phoneNumber = data;
    if(phoneNumber!=nil){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        pasteBoard.string = phoneNumber;
        [pasteBoard setPersistent:YES];
    }
}

- (void)makeCall:(NSInteger)personID Numer:(NSString *)number {
    [self cancelLongPress];
    CallLogDataModel *callog = [[CallLogDataModel alloc] initWithPersonId:personID phoneNumber:number loadExtraInfo:NO];
    [TPCallActionController logCallFromSource:@"CustomizeAction"];
    [[TPCallActionController controller] makeCall:callog appear:^(){
        NSLog(@"1");
    } disappear:^(){
        NSLog(@"2");
    }];
    
}

- (void)sendMessage:(NSString*)number
{
    NSString *numStr = number;
    [self cancelLongPress];
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(1)), nil];
        }
    }
    UIViewController *aViewController = [UIViewController tpd_topViewController];
    [TPMFMessageActionController sendMessageToNumber:numStr
                                         withMessage:@""
                                         presentedBy:aViewController];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView == self.companyGroupTableView) {
        if (indexPath.row == 0 ) {
            int isOpen = [_companyGroupContactStatusArray[indexPath.section] intValue];
            if ( isOpen == 0 ) {
                [_companyGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@1];
            }else {
                [_companyGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@0];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            return;
            
        }
    }
    
    if (tableView == self.cityGroupTableView) {
        if (indexPath.row == 0) {
            int isOpen = [_cityGroupContactStatusArray[indexPath.section] intValue];
            if ( isOpen == 0 ) {
                [_cityGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@1];
            }else {
                [_cityGroupContactStatusArray replaceObjectAtIndex:indexPath.section  withObject:@0];
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            return;
            
            
        }
    }
    
    
    
    NSInteger personID = [self getPersonIdByTableview:tableView Index:indexPath];
    [[TPDContactInfoManagerCopy instance] showContactInfoByPersonId:personID inNav:self.navigationController];
    
    
}

- (NSInteger )getPersonIdByTableview:(UITableView *)tableView Index:(NSIndexPath *)indexPath {
    
    NSString *name = @""; NSInteger personID = 0;
    
    ContactCacheDataModel *contact;
    if (tableView == self.defaultSortTableView) {
        TPDContactGroupModel *contactGroupModel = self.defaultGroupContacts[indexPath.section];
        contact = contactGroupModel.contacts[indexPath.row];
        name = contact.fullName;
        personID = contact.personID;
    }
    
    if (tableView == self.companyGroupTableView) {
        TPDContactGroupModel *contactGroupModel = self.companyGroupContacts[indexPath.section];
        {
            contact = contactGroupModel.contacts[indexPath.row - 1];
            name = contact.fullName;
            personID = contact.personID;
        }
    }
    
    if (tableView == self.cityGroupTableView) {
        CityGroupModel *cityGroupModel = self.cityGroupContacts[indexPath.section];
        {
            NSNumber *personId = cityGroupModel.contactIDs[indexPath.row -1 ];
            contact = [[ContactCacheDataManager instance] contactCacheItem:personId.integerValue];
            name = contact.fullName;
            personID = contact.personID;
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    return personID;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ( tableView == self.cityGroupTableView || tableView == self.companyGroupTableView)  return CGFLOAT_MIN;
    
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.defaultSortTableView) {}
    else {
        return [[UIView alloc]initWithFrame:CGRectZero];
    }
    
    NSString *sectionText = nil;
    
    if (tableView == self.cityGroupTableView) {
        CityGroupModel *cityGroupModel = self.cityGroupContacts[section];
        sectionText = cityGroupModel.cityName;
        if ([sectionText isEqualToString:@"Foreigners"]) {
            sectionText = @"国际";
        }
        if ([sectionText isEqualToString:@"Others"]) {
            sectionText = @"其他";
        }
    }
    
    if (tableView == self.defaultSortTableView) {
        TPDContactGroupModel *contactGroupModel = self.defaultGroupContacts[section];
        sectionText = contactGroupModel.candidateKey;
    }
    
    if (tableView == self.companyGroupTableView) {
        TPDContactGroupModel *contactGroupModel = self.companyGroupContacts[section];
        sectionText = contactGroupModel.candidateKey;
    }
    
    UIView *bg = [[UIView alloc] init];
    bg.backgroundColor = RGB2UIColor2(246,246,246);
    UILabel *textLabel = [UILabel tpd_commonLabel];
    textLabel.text = sectionText;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = RGB2UIColor2(102,102,102);
    textLabel.backgroundColor = [UIColor clearColor];
    [bg addSubview:textLabel];
    [textLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(bg);
        make.left.equalTo(bg).offset(13.7);
    }];
    
    return bg;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:1 animations:^{
        self.currentIndexView.alpha = 0;
    } completion:^(BOOL finished) {
        self.currentIndexView.hidden = YES;
        self.currentIndexView.alpha = 1;
    }];
}
#pragma mark - TPDIndexViewDelegate


-(NSArray *)tpdIndexTitlesForIndexView:(TPDIndexView *)indexView {
    NSMutableArray *titles = [NSMutableArray array];
    for (TPDContactGroupModel *contactGroupModel in self.defaultGroupContacts) {
        [titles addObject:contactGroupModel.candidateKey];
    }
    return titles;
}

- (void)tpdIndexView:(TPDIndexView *)tpdIndexView didSelectAtIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
    [self.defaultSortTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

-(NSArray *)tpdSectionTitlesForIndexView:(TPDIndexView *)indexView atIndex:(NSInteger)sectionIndex {
    TPDContactGroupModel *contactGroupModel = self.defaultGroupContacts[sectionIndex];
    NSMutableArray *titles = [NSMutableArray array];
    for (ContactCacheDataModel *contact in contactGroupModel.contacts) {
        if ([contact.fullName isKindOfClass:[NSString class]]) {
            if (contact.fullName.length > 0 ) {
                [titles addObject:[[contact.fullName copy] substringToIndex:1]];
            } else {
                [titles addObject:@" "];
            }
        }else {
            [titles addObject:@" "];
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
    self.currentIndexView.indexTittle = self.indexView.indexTitles[sectionIndex];
    [self.currentIndexView updateViewIndex:indexPath DataArray:_singleIndexArray[sectionIndex]];
    
    return titles;
}

-(void)tpdSectionTitlesForCurrentIndexView:(TPDCurrentIndexView *)indexView atIndex:(NSIndexPath *)indexPath {
    [self.defaultSortTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)gotoScan {
    BOOL guideClicked = [UserDefaultsManager boolValueForKey:CONTACT_TRANSFER_GUIDE_CLICKED defaultValue:NO];
    if (!guideClicked) {
        [self.navigationController pushViewController:[ContactTransferGuideController new] animated:YES];
        
    }else {
        [UserDefaultsManager setBoolValue:YES forKey:CONTACT_TRANSFER_GUIDE_CLICKED];
        ContactTransferMainController *mainController = [[ContactTransferMainController alloc] init];
        [self.navigationController pushViewController:mainController animated:YES];
    }
    
}

- (void)pushToScanClick {
    [DialerUsageRecord recordpath:PATH_SCANCARD
                              kvs:Pair(CONTACT_SCANCARD_ENTRANCE_CLICK, @(1)), nil];
    [self.navigationController pushViewController:[TPScanCardViewController new] animated:YES];
}
@end
#pragma mark ***********
