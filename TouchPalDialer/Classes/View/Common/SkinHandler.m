//
//  SkinHandler.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SkinHandler.h"
#import "UIView+WithSkin.h"
#import "BasicUtil.h"
#import "CommonHeaderBar.h"

@interface SkinHandler () { 
    // <viewHash value / style name> dict
    NSMutableDictionary *view_style_dict;
}

+(UIView*) getRootView:(id) host;
-(void) applySkinRecursivelyForView:(UIView*) rootView useDefault:(BOOL)useDefault;
+(void) findAllHandlersNeedRemove:(NSMutableArray*)handlerKeysToRemove forView:(UIView*) rootView;
-(void) setSkinStyle:(NSString *)style forView:(UIView*) viewElement;
-(NSString*) getSkinStyleForView:(UIView*) viewElement;

@end

@implementation SkinHandler

// the <view-hash value/skin handler> dict
static NSMutableDictionary* view_handler_dict;

+ (void) initialize {
    if (self == [SkinHandler class]) {
        view_handler_dict = [[NSMutableDictionary alloc] init];
    }
}

-(id) init {
    self = [super init];
    view_style_dict = [[NSMutableDictionary alloc] init];
    return self;
}

+(UIView*) getRootView:(id) host {
    if([host isKindOfClass:[UIView class]]) {
        return host;
    } 
    
    if([host isKindOfClass:[UIViewController class]]) {
        return [((UIViewController*)host) view];
    }
    
    cootek_log(@"Error: rootView should not be nil. THe host is %@", host);
    
    return nil;
}

+(void) applySkinRecursivelyForView:(UIView*) rootView {
    SkinHandler* handler = [view_handler_dict objectForKey:[rootView hashValue]];
    if(handler != nil) {
        [handler applySkinRecursivelyForView:rootView useDefault:YES];
    }
}

-(void) applySkinRecursivelyForView:(UIView*) rootView useDefault:(BOOL)useDefault{
    NSString* style = [self getSkinStyleForView:rootView];
    if(style!=nil || useDefault) {
        [rootView applySkinWithStyle:style];
    }
    
    NSArray *subViews =  [rootView subviews];
    for(int i=0;i<subViews.count;i++){
        UIView *subView = [subViews objectAtIndex:i];
        
        SkinHandler* handler = [view_handler_dict objectForKey:[subView hashValue]];
        if(handler != nil) {
            [self applySkinRecursivelyForView:subView useDefault:NO];
            [handler applySkinRecursivelyForView:subView useDefault:YES];
        } else {
            [self applySkinRecursivelyForView:subView useDefault:YES];
        }
    }
}

+(void) removeRecursively:(id)host {
    UIView* rootView = [SkinHandler getRootView:host];
    if(rootView == nil) {
        return;
    }
    
    NSMutableArray* handlerKeysToRemove = [[NSMutableArray alloc] init];
    [SkinHandler findAllHandlersNeedRemove:handlerKeysToRemove forView:rootView];
    
    for(int i=0; i<[handlerKeysToRemove count]; i++) {
        [view_handler_dict removeObjectForKey:[handlerKeysToRemove objectAtIndex:i]];
    }
}

+(void) findAllHandlersNeedRemove:(NSMutableArray*)handlerKeysToRemove forView:(UIView*) rootView  {
    if(rootView == nil) {
        return;
    }
    
    NSNumber* key = [rootView hashValue];
    [handlerKeysToRemove addObject:key];
     
    NSArray *subViews = [rootView subviews];
    for(int i=0; i<subViews.count; i++) {
        [SkinHandler findAllHandlersNeedRemove:handlerKeysToRemove forView:[subViews objectAtIndex:i]];
    }
}

+(void) setSkinStyle:(NSString*)style forView:(UIView*) viewElement withHost:(id)host {
    NSNumber* key = [[SkinHandler getRootView:host] hashValue];
    if(key == nil) {
        return;
    }
    
    SkinHandler* handler = [view_handler_dict objectForKey:key];
    if(handler == nil) {
        handler = [[SkinHandler alloc] init];
        [view_handler_dict  setObject:handler forKey:key];
    }
    
    [handler setSkinStyle:style forView:viewElement];
    
}

-(void) setSkinStyle:(NSString *)style forView:(UIView*) viewElement {
    [view_style_dict setObject:style forKey:[viewElement hashValue]];
} 

-(NSString*) getSkinStyleForView:(UIView*) viewElement {
    return [view_style_dict objectForKey:[viewElement hashValue]];
}
@end
