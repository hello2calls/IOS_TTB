//
//  TPAlipayActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/19/12.
//
//

#import "TPAlipayActionController.h"
#import "AlipayUtil.h"
#import "CooTekPopUpSheet.h"
#import "Person.h"
#import "TouchPalDialerAppDelegate.h"
#import "SmartDailerSettingModel.h"
#import "ContactCacheDataManager.h"

@interface TPAlipayActionController (){
    CooTekPopUpSheet *numberChoosePopUp_;
}

@property (nonatomic, copy) NSString* name;

@end

static TPAlipayActionController *instance;

@implementation TPAlipayActionController

@synthesize name = name_;

+ (void)initialize{
    instance = [[TPAlipayActionController alloc]init];
}

+(TPAlipayActionController *)controller
{
    return instance;
}

+(BOOL) canDoAlipayActionByPersonId:(NSInteger)personId
{
    if (![SmartDailerSettingModel isChinaSim]) {
        return NO;
    }

    if (personId <= 0) {
        return NO;
    }
    NSArray *labelDataModels = [Person getPhonesByRecordID:personId];
    for (LabelDataModel *model in labelDataModels) {
        NSString* alipayNumber = [AlipayUtil extractAlipayPhoneNumber:[model labelValue]];
        if (alipayNumber) {
            return YES;
        }
    }
    return NO;
}

-(void) doAlipayActionByPersonId:(NSInteger)personId
{
    if (numberChoosePopUp_ != nil) {
        return;
    }
    
    if (personId <= 0 ) {
        return;
    }
    self.name = [[[ContactCacheDataManager instance] contactCacheItem:personId] displayName];
    if ([AlipayUtil checkAndInstallAlipayWithName:name_]) {
        return;
    }
    NSArray *labelDataModels = [Person getPhonesByRecordID:personId];
    if (labelDataModels) {
        int validNumberCount = 0;
        NSString *aValidNumber = nil;
        for (int i = 0; i < [labelDataModels count]; i++) {
            LabelDataModel *model = [labelDataModels objectAtIndex:i];
            // AlipayNumber is nil if the raw number cannot be converted to a valid alipayNumber
            NSString* alipayNumber = [AlipayUtil extractAlipayPhoneNumber:[model labelValue]];
            if (alipayNumber) {
                validNumberCount ++;
                aValidNumber = alipayNumber;
            }
            // Set the related number as alipayNumber for later usage
            [model setLabelValue:alipayNumber];
        }
        if (validNumberCount == 1) {
            [AlipayUtil jumpToAlipayWithAlipayPhoneNumber:aValidNumber name:name_];
        } else if (validNumberCount > 1) {
            // Let user choose the number
            NSMutableArray *numbersOfKeyAndValue = [NSMutableArray array];
            for (int i = 0; i < [labelDataModels count]; i++) {
                LabelDataModel *model = [labelDataModels objectAtIndex:i];
                // if the model has a valid alipayNumber
                if (model.labelValue) {
                    [numbersOfKeyAndValue addObject:model.labelValue];
                    [numbersOfKeyAndValue addObject:model.labelKey];
                }
            }
            numberChoosePopUp_ = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Choose the number", @"") content:numbersOfKeyAndValue type:PopUpSheetTypenumbersPay];
            numberChoosePopUp_.delegate = self;
            UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
            [navigationController.topViewController.view addSubview:numberChoosePopUp_];
        }
    }
}

#pragma mark CooTekPopUpSheet delegate
- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info
{
    if ([info count] == 2) {
        NSString *number = [info objectAtIndex:0];
        NSString *name = name_;
        [AlipayUtil jumpToAlipayWithAlipayPhoneNumber:number name:name];
    }
    numberChoosePopUp_.delegate = nil;
    numberChoosePopUp_ = nil;
}

-(void)doClickOnCancelButtonWithTag:(int)tag
{
    numberChoosePopUp_.delegate = nil;
    numberChoosePopUp_ = nil;
}


@end
