//
//  CustomMenuItem.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

typedef enum tag_MenuItemId {
    MENU_ITEM_ID_MANAGE_GROUP,
    MENU_ITEM_ID_ADD_GROUP,
    MENU_ITEM_ID_ADD_MENBER
} MenuItemId;

typedef enum tag_CMIHorizontalAlignment {
    ImageHorizontalAlignmentLeft,
    ImageHorizontalAlignmentRight,
    ImageHorizontalAlignmentCenter
} CMIHorizontalAlignment;

@protocol CustomMenuItemProtocol

@required

-(void)onMenuItem:(MenuItemId)menuItemId;

@end

@interface CustomMenuItem : UIView {
    MenuItemId menu_item_id;
    NSString* menu_text;
    UIImage* normal_image;
    UIImage* highlighted_image;
    CGRect image_frame;
    TinyColor normal_text_color;
    TinyColor highlighted_text_color;
    CGRect text_frame;
    int font_size;
    BOOL is_highlighted;
    
    id<CustomMenuItemProtocol> delegate;
}

@property (nonatomic, retain) id<CustomMenuItemProtocol> delegate;
@property (nonatomic, retain) UIImage* normal_image;
@property (nonatomic, retain) UIImage* highlighted_image;
@property (nonatomic, retain) NSString* menu_text;
@property (nonatomic) TinyColor normal_text_color;
@property (nonatomic) TinyColor highlighted_text_color;
@property (nonatomic) CGRect image_frame;
@property (nonatomic) CGRect text_frame;
@property (nonatomic) BOOL is_highlighted;
@property (nonatomic) int font_size;

- (id)initWithFrame:(CGRect)frame withMenuItemId:(MenuItemId)menuItemId withDelegate:(id<CustomMenuItemProtocol>)menuItemDelegate;


@end
