//
//  UIView+WithSkin.m
//
//  Created by Liangxiu on 6/29/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"

#define TO_TOP @"toTop"

@implementation UIView (WithSkin)

-(BOOL) setSkinStyleWithHost:(id)host forStyle:(NSString*) style {
    [SkinHandler setSkinStyle:style forView:self withHost:host];
    return [self applySkinWithStyle:style];
}


-(BOOL) applySkinWithStyle:(NSString*) style {
    BOOL toTop = NO;
    
    if([self respondsToSelector:@selector(selfSkinChange:)]){
        if(style!=nil){
            NSNumber *goOn = [self performSelector:@selector(selfSkinChange:) withObject:style];
            toTop = [goOn boolValue];
        }
        return toTop;
    }
    
    if(style==nil){
        return toTop;
        //NSString *className = NSStringFromClass([self class]);
        //style = [NSString stringWithFormat:@"%@%@%@",@"default",className,@"_style"];
    }

     if([style isEqualToString:NO_STYLE]){
          return toTop;
     }     
     if([style isEqualToString:DRAW_RECT_STYLE]){
          [self setNeedsDisplay];
          return toTop;
     }
     if([style hasSuffix:STYLE_SUFFIX]){
          NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
          if(propertyDic==nil)
               return toTop;
          if([self isKindOfClass:[UIButton class]]){
               UIButton *selfChange = (UIButton *)self;
               if([propertyDic objectForKey:BACK_GROUND_IMAGE]!=nil){
                    [selfChange setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE]] forState:UIControlStateNormal];
               }
               if([propertyDic objectForKey:BACK_GROUND_IMAGE_HT]!=nil){
                    [selfChange setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_HT]] forState:UIControlStateHighlighted];
               }
               if([propertyDic objectForKey:BACK_GROUND_IMAGE_SELECTED]!=nil){
                    [selfChange setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_SELECTED]] forState:UIControlStateSelected];
               }
               if([propertyDic objectForKey:FONT]!=nil){
                    selfChange.titleLabel.font = [TPDialerResourceManager getFontFromNumberString:[propertyDic objectForKey:FONT]];
               }
               if([propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]!=nil){
                    [selfChange setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]] forState:UIControlStateNormal];
               }
              if([propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]!=nil){
                  [selfChange setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]] forState:UIControlStateHighlighted];
              }
               if([propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]!=nil){
                    [selfChange setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]] forState:UIControlStateSelected];
               }
              if([propertyDic objectForKey:DISABLED_TEXT_COLOR_FOR_STYLE]!=nil){
                  [selfChange setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:DISABLED_TEXT_COLOR_FOR_STYLE]] forState:UIControlStateDisabled];
              }
               if([propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]!=nil){
                    [selfChange setImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]] forState:UIControlStateNormal];
               }
               if([propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]){
                    [selfChange setImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:IMAGE_FOR_SELECTED_STATE]] forState:UIControlStateSelected];
               }
               if([propertyDic objectForKey:IMAGE_FOR_DISABLED_STATE]){
                    [selfChange setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:IMAGE_FOR_DISABLED_STATE]] forState:UIControlStateDisabled];
               }
               return YES;
          }
          //UITableView
          if([self isKindOfClass:[UITableView class]]){
               UITableView *selfChange = (UITableView *)self;
               [selfChange setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:BACK_GROUND_COLOR]]];
               [selfChange setSeparatorColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:SEPERATOR_COLOR]]];
               //[selfChange ]
               return NO;
          }
          
          //UITableViewCell
          if([self isKindOfClass:[UITableViewCell class]]){
               UITableViewCell *selfChange = (UITableViewCell *)self;
               if([propertyDic objectForKey:BACK_GROUND_COLOR]){
                    selfChange.textLabel.backgroundColor = [UIColor clearColor];
                    NSString *colorString = [propertyDic objectForKey:BACK_GROUND_COLOR];
                    if([colorString hasSuffix:@"2x.png"]){
                         UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[TPDialerResourceManager sharedManager] getImageByName:colorString]];
                         selfChange.backgroundView = backgroundView;
                    }else{
                         UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
                         backgroundView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:colorString];
                         selfChange.backgroundView = backgroundView;
                    }
               }
               if([propertyDic objectForKey:SELECTED_BACKGROUND_COLOR]){
                    NSString *colorString = [propertyDic objectForKey:SELECTED_BACKGROUND_COLOR];
                    if([colorString hasSuffix:@"2x.png"]){
                         UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[TPDialerResourceManager sharedManager] getImageByName:colorString]];
                         selfChange.selectedBackgroundView = backgroundView;
                    }else{
                         UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
                         backgroundView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:colorString];
                         selfChange.selectedBackgroundView = backgroundView;
                    }

                }
               if([propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]){
                    selfChange.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
               }
              if ([propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]) {
                  selfChange.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]];
              }
               if([propertyDic objectForKey:DETAIL_LABEIL_TEXT_COLOR]){
                    selfChange.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:DETAIL_LABEIL_TEXT_COLOR]];
               }
               return NO;
          }
          NSArray *keysArray = [propertyDic allKeys];
          for(NSString *property in keysArray){
               if([property hasSuffix:FONT_SUFFIX]){
                    
                    NSRange range = [property rangeOfString:FONT_SUFFIX];
                    NSString *propertyKey = [property stringByReplacingCharactersInRange:range withString:@""];
                    [self setValue:[TPDialerResourceManager getFontFromNumberString:[propertyDic objectForKey:property]] forKey:propertyKey];
               }
               if([property hasSuffix:COLOR_SUFFIX]){
                    NSRange range = [property rangeOfString:COLOR_SUFFIX];
                    NSString *propertyKey = [property stringByReplacingCharactersInRange:range withString:@""];
                    if([self respondsToSelector:NSSelectorFromString(propertyKey)]){
                        [self setValue:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:property]] forKey:propertyKey];
                    }else {
                         cootek_log(@"error with style %@: not response to %@", style, propertyKey);
                    }
               }
               if([property hasSuffix:IMAGE_SUFFIX]){
                    NSRange range = [property rangeOfString:IMAGE_SUFFIX];
                    NSString *propertyKey = [property stringByReplacingCharactersInRange:range withString:@""];
                    if([self respondsToSelector:NSSelectorFromString(propertyKey)]) {
                      [self setValue:[[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:property]] forKey:propertyKey];
                    } else {
                         cootek_log(@"error with style %@: not response to %@", style, propertyKey);
                    }
               }
               if([property isEqualToString:TO_TOP]){
                    NSNumber *top = [propertyDic objectForKey:property];
                    if([top boolValue])
                         toTop = YES;
               }
          } 
     }
     //only image style
     if ([style hasSuffix:IMAGE_SUFFIX]){
          if([self isKindOfClass:[UIImageView class]]){
               UIImageView *selfchange = (UIImageView *)self;
               selfchange.image = [[TPDialerResourceManager sharedManager] getResourceByStyle:style];
               toTop = YES;
          }else if([self isKindOfClass:[UIButton class]]){
               UIButton *selfchange = (UIButton *)self;
               [selfchange setImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:style] forState:UIControlStateNormal];
          }
          else{
            if([self respondsToSelector:NSSelectorFromString(BACK_GROUND_IMAGE)]) {  
                [self setValue:[[TPDialerResourceManager sharedManager] getResourceByStyle:style needCache:NO] forKey:BACK_GROUND_IMAGE];
            }
          }
     }
     //only color style
     if ([style hasSuffix:COLOR_SUFFIX]){
          if([self respondsToSelector:NSSelectorFromString(BACK_GROUND_COLOR)]) {
             [self setValue:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:style] forKey:BACK_GROUND_COLOR];
          }
     } 
     return toTop;
}

- (BOOL) applyDefaultSkinWithStyle:(NSString *)style {
    return NO;
}
    
@end
