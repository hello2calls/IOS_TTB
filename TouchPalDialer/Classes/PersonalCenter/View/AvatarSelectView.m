//
//  AvatarSelectView.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "AvatarSelectView.h"
#import "TPDialerResourceManager.h"
#import "TPButton.h"
#import "AvatarCell.h"
#import "PersonalCenterUtility.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "DefaultUIAlertViewHandler.h"


#define WIDTH_ADAPT TPScreenWidth()/360

static NSString *const kCell = @"kCell";

@interface AvatarSelectView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) NSIndexPath *selectIndexPath;
@property (nonatomic,weak) TPButton *okButton;
@end

@implementation AvatarSelectView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    self.backgroundColor = [UIColor clearColor];
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self addSubview:backgroundView];
    
    CGFloat bgWidth = TPScreenWidth() - 20 * WIDTH_ADAPT * 2;
    CGFloat itemW = (bgWidth - 24 * 4) / 3;
    CGFloat bgHeight = 30  + FONT_SIZE_3 + 24 + 2 * itemW + 24 + 24 + 46 + 30;

    UIView *dialogBgView = [[UIView alloc] init];
    dialogBgView.frame = CGRectMake(20, (TPScreenHeight() - bgHeight) / 2, bgWidth, bgHeight);
    dialogBgView.layer.masksToBounds = YES;
    dialogBgView.layer.cornerRadius = 4 * WIDTH_ADAPT;
    dialogBgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"personal_center_photo_choose_bg_color"];
    [self addSubview:dialogBgView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30 ,bgWidth, FONT_SIZE_3)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:FONT_SIZE_3];
    titleLabel.text = @"设置头像";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"personal_center_photo_choose_title_color"];
    [dialogBgView addSubview:titleLabel];
    
    CGFloat collectionViewX = 24;
    CGFloat collectionViewY = 54+ FONT_SIZE_3;
    CGFloat collectionViewW = bgWidth - 48;
    CGFloat collectionViewH = bgHeight - collectionViewY - 54 - 46;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 24;
    layout.itemSize = (CGSize){itemW,itemW};
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(collectionViewX, collectionViewY, collectionViewW, collectionViewH) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [dialogBgView addSubview:collectionView];
    
    [collectionView registerClass:[AvatarCell class] forCellWithReuseIdentifier:kCell];
    
    CGFloat buttonY = collectionViewY + collectionViewH + 24;
    CGFloat buttonWidth = (bgWidth - 60 - 24 ) / 2;
    TPButton *cancelButton = [[TPButton alloc]initWithFrame:CGRectMake(30, buttonY, buttonWidth, 46) withType:GRAY_LINE withFirstLineText:@"取消" withSecondLineText:nil];
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [dialogBgView addSubview:cancelButton];
    
    TPButton *okButton = [[TPButton alloc]initWithFrame:CGRectMake(24 + buttonWidth + 30, buttonY, buttonWidth, 46) withType:BLUE_LINE withFirstLineText:@"确定" withSecondLineText:nil];
    [okButton addTarget:self action:@selector(okClicked) forControlEvents:UIControlEventTouchUpInside];
    self.okButton = okButton;
    [dialogBgView addSubview:okButton];

}
#pragma mark - Event

- (void)cancelClicked{
    [self removeFromSuperview];
}

- (void)okClicked{
    NSString *imageName = [PersonalCenterUtility getHeadViewPhotoNameFromIndex:_selectIndexPath.item];
    NSInteger type = LOCAL_PHOTO;
    NSInteger gender =  [UserDefaultsManager intValueForKey:PERSON_PROFILE_GENDER];
;
    [_okButton setFirstLineText:@"正在设置"];
    [_okButton setEnabled:false];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        if (![SeattleFeatureExecutor setPersonProfile:imageName withType:type withGender:gender]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:@"上传联系人头像失败" message:nil];
                [self removeFromSuperview];
                
            });
        } else {
            [UserDefaultsManager setObject:imageName forKey:PERSON_PROFILE_URL];
            [UserDefaultsManager setIntValue:type forKey:PERSON_PROFILE_TYPE];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_completeHandle) {
                    _completeHandle();
                }
                [self removeFromSuperview];
            });
        }
    });

}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AvatarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    NSString* imageName = [PersonalCenterUtility getHeadViewPhotoNameFromIndex:indexPath.item];
    cell.avatarImageView.image = [PersonalCenterUtility getHeadViewPhotoWithName:imageName];
;
    if (self.selectIndexPath == nil) {
        if ([PersonalCenterUtility getHeadViewPhotoIndex:[UserDefaultsManager stringForKey:PERSON_PROFILE_URL]] == indexPath.item) {
            cell.selected = YES;
            self.selectIndexPath = indexPath;
        }
    }
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:_selectIndexPath];
    cell.selected = NO;
    _selectIndexPath = indexPath;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
@end
