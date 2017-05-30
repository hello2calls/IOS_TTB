//
//  WebPageSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"
#import "ActionableSettingItemModel.h"

@interface WebPageSettingItemModel : ActionableSettingItemModel

@property (nonatomic, copy) NSString* url;
@property (nonatomic, assign) BOOL isURLLocalized;

+(WebPageSettingItemModel*) itemWithTitle:(NSString*) title url:(NSString*) url;

@end
