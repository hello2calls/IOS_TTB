//
//  BYBSearchBar.m
//  Patient
//
//  Created by weyl on 15/4/27.
//  Copyright (c) 2015年 GePingTech. All rights reserved.
//

#import "TPDSearchBar.h"
#import "Masonry.h"
#import "TPDLib.h"


@interface TPDSearchBar()<UITextFieldDelegate>
@property (nonatomic, strong)UIButton* searchButton;
@property (nonatomic,copy) void (^workerBlock)(NSString* keyword) ;
@end


@implementation TPDSearchBar
-(TPDSearchBar*)tpd_withPlaceholder:(NSString *)placeholder color:(UIColor*)color{
    self.searchEdit.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:color}];
    return self;
}

+(TPDSearchBar*)tpd_searchBarStyle1:(void (^)(NSString* keyword))workerBlock{
    TPDSearchBar* ret = [[TPDSearchBar alloc] init];
    ret.workerBlock = workerBlock;
    
    ret.backgroundColor = RGB2UIColor(0xe9e9e9);
    //    ret.layer.borderWidth = .5f;
    ret.layer.cornerRadius = 5.f;
    ret.clipsToBounds = YES;
    
    
    UIImageView* icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon_white"]];
    
    [ret addSubview:ret.searchEdit];
    [ret addSubview:icon];
    
    [ret.searchEdit makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ret);
        //        make.height.equalTo(14);
        make.left.equalTo(icon.right).offset(5);
        make.right.equalTo(ret).offset(-10);
    }];
    
    [icon makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ret);
        make.left.equalTo(ret).offset(10);
        make.height.equalTo(ret).offset(-10);
        make.width.equalTo(18);
        make.height.equalTo(18);
    }];
    
    [ret.searchEdit addTarget:ret
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    return ret;
    
}

- (id)init{
    self = [super init];
    if (self) {
        self.searchEdit = [[UITextField alloc] init];
        self.searchEdit.delegate = self;
        self.searchEdit.returnKeyType = UIReturnKeySearch;
        self.searchEdit.backgroundColor = [UIColor clearColor];
        self.searchEdit.textColor = RGB2UIColor(0x666666);
        self.searchEdit.font = [UIFont systemFontOfSize:16];
        [self.searchEdit becomeFirstResponder];
        
        self.searchButton = [UIButton tpd_buttonStyleCommon];
        __weak TPDSearchBar *weakSelf = self;
        [self.searchButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
            [weakSelf.searchEdit resignFirstResponder];
            [weakSelf searchDone];
        }];
        
    }
    return self;
    
}

- (void)dealloc
{
    NSLog(@"[--dealloc: %@--]", NSStringFromClass(self.class));
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchEdit resignFirstResponder];
    [self searchDone];
    return YES;
}


-(void)textFieldDidChange:(id)sender{
    NSLog(@"%@",self.searchEdit.text);
    self.workerBlock(self.searchEdit.text);
}
#pragma mark - private methods
- (void)searchDone
{
    if (!self.searchEdit.text.length) {
        return ;
    }
    
    self.workerBlock(self.searchEdit.text);
    
}

@end
