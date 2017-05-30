//
//  FavoPersonView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "Person.h"
#import "FavoPersonView.h"
#import "FavoriteModel.h"
#import "NumberPersonMappingModel.h"
#import "PhoneNumber.h"
#import "FunctionUtility.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
#import "AttributeModel.h"
#import "FunctionUtility.h"
#import "UIImageCutUtils.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation FavoPersonView

@synthesize person_fav;
@synthesize index;
@synthesize isEnableTouch;
@synthesize person_opera_delegate;
@synthesize item_current_page;

-(id)initWithFavoPerson:(FavoriteDataModel *)person WithFrame:(CGRect)frame_person Index:(NSInteger)index_temp withPage:(NSInteger)page
{
	self = [super initWithFrame:frame_person];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        [self.layer setMasksToBounds:YES];
		self.person_fav = person;
		self.index = index_temp;
		item_current_page = page;
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(move:) 
													 name:N_FAVORITE_DATA_DELETE_MODEL 
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(refreshMySelf:) 
                                                     name:N_PERSON_DATA_CHANGED 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(deleteMySelf:) 
													 name:N_FAVORITE_DATA_DELETE_ID 
												   object:nil];
        
        
        
        
    }
    return self;
}
-(void)refreshMySelf:(id)person
{
	NotiPersonChangeData *changeData = (NotiPersonChangeData *)[[person userInfo] objectForKey:KEY_PERSON_CHANGED];
	if (changeData.change_type == ContactChangeTypeModify) {
		NSInteger personID = changeData.person_id;
		if (person_fav.personID == personID) {
			[self performSelectorOnMainThread:@selector(refreshMyView:) withObject:[NSNumber numberWithInt:personID] waitUntilDone:NO];
		}		
	}
}

-(void)refreshMyView:(NSNumber *)ID{
    @autoreleasepool {
        NSInteger personID = [ID intValue];
        ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personID];
        if (person) {
            FavoriteDataModel *favorite=[[FavoriteDataModel alloc] init];
            favorite.personID = personID;
            favorite.personName = [person displayName];
            favorite.photoData = [person image];
            favorite.mainPhone = [person mainPhone];
            self.person_fav = favorite;
            [self setNeedsDisplay];
        }
    }
}

-(void)deleteMySelf:(id)person
{
	NSInteger personID=[[[person userInfo] objectForKey:KEY_FAVORITE_DElETE_PERSON_ID] intValue];
	if (person_fav.personID==personID) {
		int pre_page_number=[FavoriteModel Instance].page_number;
		int fav_count=[[FavoriteModel Instance].current_fav_list count];
		if (index < fav_count) {
            [[FavoriteModel Instance].current_fav_list removeObjectAtIndex:index];
        }
		[[FavoriteModel Instance] refreshPageNumber];
		int current_page = item_current_page;
		int page_number=[FavoriteModel Instance].page_number;
		int start=index%6+1;
		if (start==6) {
			current_page++;
			start=0;
		}
		while(current_page<=page_number) {
            cootek_log(@"start current pages =%d start = %d",current_page,start);
			for (int i=start; i<6; i++) {
				int nextPosition=current_page*6+i;
                cootek_log(@"start current from =%d to = %d",i,nextPosition);
				if (i==5||nextPosition==fav_count) {
					current_page++;
					start=0;
				}
			    if (nextPosition<fav_count) {
					[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DATA_DELETE_MODEL 
																		object:nil
																	  userInfo:[NSDictionary 
                                                                                dictionaryWithObject:[NSNumber numberWithInt:nextPosition]
                                                                                              forKey:KEY_FAVORITE_DATA_ONE]];
				}
	
			}
		}
        if (self) {
            cootek_log(@"remove my self from parents");
			[self removeFromSuperview];	
		}
		if (pre_page_number!=page_number) {
             cootek_log(@"delete change pages =%d",current_page);
			[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_PAGE_CHANGED 
																object:nil];
		}
	}
}

- (void)move:(id)Index{
	NSInteger nextIndex=[[[Index userInfo] objectForKey:KEY_FAVORITE_DATA_ONE] intValue];
	if (nextIndex==index) {
		nextIndex=nextIndex-1;
        
        int padding = 10;
        int rows = 3;
        int columns = 2;
        int size = rows * columns;
        
		int page=nextIndex/size;
		int page_index=nextIndex%size;
		int i=page_index/columns;
		int j=page_index%columns;
        
        CGRect frame = self.frame;
        frame.origin = CGPointMake((frame.size.width+padding)*j+padding, i*(frame.size.height+padding)+padding);
        self.frame = frame;

		if (page_index == size -1) {
            cootek_log(@"move from pages change pages");
			[FavoriteModel Instance].change_page_fav=self;	
			[[NSNotificationCenter defaultCenter] postNotificationName:N_FAVORITE_DELETE_PAGE_CHANGE 
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:page]
																								   forKey:KEY_FAVORITE_DATA_ONE]];
		}
		self.index=nextIndex;
	}
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = 145;
    CGFloat height = self.frame.size.height;
    
	UIImage *photo = person_fav.photoData;
	if (photo == nil) {
		photo = [[TPDialerResourceManager sharedManager] getImageByName:@"fav_unknow_person_photo@2x.png"];
        if (TPScreenHeight() > 500) {
            photo = [[TPDialerResourceManager sharedManager] getImageByName:@"fav_unknow_person_photo_iphone5@2x.png"];
        }
	}else {
		CGSize targetSize = CGSizeMake(width, height);
		UIImageCutUtils *imageUtils = [[UIImageCutUtils alloc] initWithCGImage:photo.CGImage];
		photo = [imageUtils croppedToMaxImageSize:targetSize];
	}
    
	[photo drawInRect:CGRectMake(0, 0, width, height)];
    
    //on the photo
    UIColor *bgColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"FavoriteViewController_FavPerson_addOnBackground_color" needCache:NO];
	UIImage *photo_bg = [FunctionUtility imageWithColor:bgColor withFrame:CGRectMake(0, 0, width, 25)];
    
	[photo_bg drawInRect:CGRectMake(0, 0, width, 25)];
    
    //name
    UIColor *textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"FavoriteViewController_FavPerson_addOnText_color" needCache:YES];
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [textColor CGColor]);
	if (!person_fav.personName) {
		person_fav.personName=NSLocalizedString(@"(No name)",@"(No name)");
	}
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    paragraphStyle.alignment = NSTextAlignmentLeft;
//    NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:CELL_FONT_SMALL], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:textColor};
//    [person_fav.personName drawInRect:CGRectMake(5, 4, width - 10, 20) withAttributes:tdic];
 	[person_fav.personName drawInRect:CGRectMake(5, 4, width - 10, 20)
							 withFont:[UIFont systemFontOfSize:CELL_FONT_SMALL]
						lineBreakMode:NSLineBreakByTruncatingMiddle
							alignment:NSTextAlignmentLeft];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (![FavoriteModel Instance].isTouchEnable) {
		[FavoriteModel Instance].isTouchEnable=![FavoriteModel Instance].isTouchEnable;
	}
}

-(BOOL)isMultipleTouchEnabled{
    return NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([FavoriteModel Instance].isTouchEnable) {
		NSInteger current=index%6;
		PersonOperationView *oper = [[PersonOperationView alloc] initWithPerson:self.person_fav Index:current];
		oper.person_opera_delegate = self;
		[person_opera_delegate showOperationView:oper];
		[FavoriteModel Instance].isTouchEnable=![FavoriteModel Instance].isTouchEnable;
	}
}

#pragma mark FavoPersonViewProtocoldelegate
- (void)closeOperationView:(UIView *)op_view{
	[person_opera_delegate closeOperationView:op_view];
}

- (void)showOperationView:(UIView *)op_view{
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
