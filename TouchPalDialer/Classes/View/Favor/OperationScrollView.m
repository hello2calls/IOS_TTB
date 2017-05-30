//
//  OpertionScrollView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//
#import "consts.h"
#import "OperationScrollView.h"
#import "Person.h"
#import "Favorites.h"
#import "LabelDataModel.h"
#import "CallLogDataModel.h"
#import "NumberPersonMappingModel.h"
#import "HighLightLabel.h"
#import "FunctionUtility.h"
#import "UIImageCutUtils.h"
#import "TouchPalDialerAppDelegate.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "NSString+PhoneNumber.h"
#import "TPMFMailActionController.h"
#import "TPMFMessageActionController.h"
#import "TPCallActionController.h"
#import "CootekNotifications.h"
#import "PersonDBA.h"
#import "FunctionUtility.h"
#import "AllViewController.h"

#define PHOTO_HEIGHT 160

@implementation OperationScrollView

@synthesize fav_person;
@synthesize phones_list;
@synthesize contentView;

-(id)initWithPersonID:(FavoriteDataModel *)fav withArray:(NSMutableArray *)array{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(),TPScreenHeight())];
    if (self) {
        fav_person = fav;
        
        self.backgroundColor = [UIColor clearColor];
        
        // background view
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        if (array !=nil) {
            self.phones_list = array;
        } else {
            self.phones_list = [PersonDBA getPhonesByRecordID: self.fav_person.personID];
        }
        int height = [self allCellHeight] + PHOTO_HEIGHT;
        UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(FAV_ITEM_LENGTH_GAP, (TPScreenHeight()-height)*0.5, TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP, height)];
        cView.backgroundColor = [UIColor clearColor];
        self.contentView = cView;
        

        // avatar image view
        int name_margin = 14;
        UIButton *head = [UIButton buttonWithType:UIButtonTypeCustom];
        head.contentMode = UIViewContentModeScaleAspectFit;
        head.frame = CGRectMake(0, 0, self.contentView.frame.size.width, PHOTO_HEIGHT);
        head.adjustsImageWhenHighlighted = YES;
        head.backgroundColor = [UIColor clearColor];
        [head addTarget:self action:@selector(viewDetail) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:head.frame];
        
        [FunctionUtility setOrigin:CGPointZero forView:headImageView];
        UIImage *photo = fav.photoData;
        if (photo == nil) {
            headImageView.contentMode = UIViewContentModeBottom;
            photo = [[TPDialerResourceManager sharedManager] getImageByName:@"fav_unknow_person_photo_iphone5@2x.png"];
            [head setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_popup_head_bg_color"] withFrame:CGRectMake(0, 0, 45, CELL_HEIGHT)] forState:UIControlStateNormal];
            [head setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_popup_head_bg_ht_color"] withFrame:CGRectMake(0, 0, 45, CELL_HEIGHT)] forState:UIControlStateHighlighted];
        }else {
            headImageView.contentMode = UIViewContentModeScaleAspectFill;
            float tmpHeight = fav.photoData.size.height;
            float tmpWidth = fav.photoData.size.width;
            UIImageCutUtils *imageUtils = [[UIImageCutUtils alloc] initWithCGImage:photo.CGImage];
            photo = [imageUtils croppedImageWithRect:CGRectMake(0, (tmpHeight - tmpWidth * PHOTO_HEIGHT / self.contentView.frame.size.width)/2, tmpWidth, tmpWidth * PHOTO_HEIGHT / self.contentView.frame.size.width)];
        }
        headImageView.backgroundColor = [UIColor clearColor];
        headImageView.image = photo;
        
        [head addSubview:headImageView];
        
        //
        UIImageView *headcover = [[UIImageView alloc] initWithFrame:CGRectMake(0, PHOTO_HEIGHT - 40,  self.contentView.frame.size.width, 40 )];
        UIImage *coverImage = [FunctionUtility getGradientImageFromStartColor:[UIColor clearColor] endColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"blackWith_0.1_alpha_color"] forSize:CGSizeMake(self.contentView.frame.size.width, 40)];
        headcover.image = coverImage;
        NSString * field_name = fav_person.personName;
        if (!field_name || [field_name length] == 0) {
			field_name = NSLocalizedString(@"(No name)",@"(No name)");
		}
        
        // name label on the left
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(name_margin, 0, 256, 50)];
        [nameLabel setText:field_name];
        [nameLabel setFont:[UIFont systemFontOfSize:16]];
        nameLabel.textColor = [[TPDialerResourceManager sharedManager]
                          getResourceByStyle:@"OperationScrollView_nameLabel_text_color" needCache:NO];
        nameLabel.backgroundColor = [UIColor clearColor];
        
        // detail arrow label on the right
        UILabel *detailArrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(headcover.frame.size.width-34, 13, 24, 24)];
        detailArrowLabel.textColor = [TPDialerResourceManager getColorForStyle:@"fav_popup_cell_arrow_color"];
        detailArrowLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
        detailArrowLabel.text = @"n";
        detailArrowLabel.backgroundColor = [UIColor clearColor];
        
        // table view
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, PHOTO_HEIGHT, TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP, [self allCellHeight]) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = CELL_HEIGHT;
        tableView.separatorColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *view =[ [UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        [tableView setTableFooterView:view];
        [tableView setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        
        // actions
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        [self addGestureRecognizer:tapRecognizer];
        
        // view settings
        [headcover addSubview:detailArrowLabel];
        [headcover addSubview:nameLabel];
        
        [self.contentView.layer setCornerRadius:6];
        self.contentView.layer.masksToBounds = YES;
        
        // view tree
        [self addSubview:backgroundView];
        [self addSubview:cView];
        
        [self.contentView addSubview:head];
        [self.contentView addSubview:headcover];
        [self.contentView addSubview:tableView];
        
        // view debug
//        [FunctionUtility setBorderForViewArray:@[head, head.imageView, headcover, detailArrowLabel, nameLabel]];
    }
    return self;
}

- (NSInteger)allCellHeight
{
    int height = [self.phones_list count] * CELL_HEIGHT;
    if ([self.phones_list count] > 3) {
        height = 3 * CELL_HEIGHT;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.phones_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] init];
    int row = [indexPath row];
    NSString *number = ((PhoneDataModel *)[self.phones_list objectAtIndex:row]).number;
    
    UIImage *normalImage = [FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_popup_cell_bg_color"] withFrame:CGRectMake(0, 0, 45, CELL_HEIGHT)];
    UIImage *htImage = [FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_popup_cell_bg_ht_color"] withFrame:CGRectMake(0, 0, 45, CELL_HEIGHT)];
    TPUIButton *call_but = [TPUIButton buttonWithType:UIButtonTypeCustom];
    call_but.tag = row;
    call_but.frame = CGRectMake(0, 0, TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP-50, CELL_HEIGHT);
    [call_but setBackgroundImage:normalImage forState:UIControlStateNormal];
    [call_but setBackgroundImage:htImage forState:UIControlStateHighlighted];
    [call_but addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [call_but setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP-105)];
    [call_but setTitle:@"z" forState:UIControlStateNormal];
    [call_but setTitleColor:[TPDialerResourceManager getColorForStyle:@"fav_popup_cell_call_icon_color"] forState:UIControlStateNormal];
    call_but.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];

    
    UILabel *call=[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 180, CELL_HEIGHT)];
    call.backgroundColor=[UIColor clearColor];
    call.font=[UIFont systemFontOfSize:CELL_FONT_LARGE];
    call.textColor = [[TPDialerResourceManager sharedManager]
                      getResourceByStyle:@"fav_popup_cell_text_color" needCache:NO];
    call.text=number;
    call.textAlignment=NSTextAlignmentLeft;
    [call_but addSubview:call];
    [cell addSubview:call_but];
    
    TPUIButton *im_but = [TPUIButton buttonWithType:UIButtonTypeCustom];
    im_but.frame = CGRectMake(TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP-50, 0, 50, CELL_HEIGHT);
    im_but.tag = row;
    [im_but addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [im_but setTitle:@"i" forState:UIControlStateNormal];
    [im_but setTitleColor:[TPDialerResourceManager getColorForStyle:@"fav_popup_cell_call_icon_color"] forState:UIControlStateNormal];
    im_but.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    [im_but setBackgroundImage:normalImage forState:UIControlStateNormal];
    [im_but setBackgroundImage:htImage forState:UIControlStateHighlighted];
    [cell addSubview:im_but];
    UILabel * imLine = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()-2*FAV_ITEM_LENGTH_GAP-50, 12, 0.5, CELL_HEIGHT-24)];
    imLine.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_downSeparateLine_color"];
    [cell addSubview:imLine];
    if (row != 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth()-FAV_ITEM_LENGTH_GAP*2, 0.5)];
        label.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"fav_downSeparateLine_color"];
        [cell addSubview:label];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)sendMessage:(UIButton *)btn{
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [TPMFMessageActionController sendMessageToNumber:((PhoneDataModel *)[self.phones_list objectAtIndex:btn.tag]).number
                                                      withMessage:@""
                                                      presentedBy:aViewController];
    [self removeFromSuperview];
}

-(void)callClick:(UIButton *)btn
{
    CallLogDataModel  *call_log=[[CallLogDataModel alloc] initWithPersonId:fav_person.personID
                                                                 phoneNumber:((PhoneDataModel *)[self.phones_list objectAtIndex:btn.tag]).number
                                                              loadExtraInfo:NO];
    [TPCallActionController logCallFromSource:@"Favor"];
    [[TPCallActionController controller] makeCall:call_log];
    [self removeFromSuperview];
}

-(void)viewDetail{
	NSDictionary *info_dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:fav_person.personID] forKey:@"fav_person_id"];
	[[NSNotificationCenter defaultCenter] postNotificationName:N_FAV_TO_PERSON_DETAIL 
														object:nil 
													  userInfo:info_dic];
    [self removeFromSuperview];
}

-(void)close{
    [self removeFromSuperview];
}

-(void)removeOutFavorite{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure to remove the person from the favorite?",@"")
                                                    message:nil
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Cancel",@"" )
                                          otherButtonTitles:NSLocalizedString(@"Ok",@"" ), nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) {
        [self removeFromSuperview];
        [Favorites removeFavoriteByRecordId:fav_person.personID];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    if(CGRectContainsPoint(self.contentView.frame, location))
    {
        return NO;
    }
    return YES;
}

- (void)viewTapped
{
    [self removeFromSuperview];
}

@end
