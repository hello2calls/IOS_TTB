//
//  ContactGroupModel.h
//  TouchPalDialer
//
//  Created by ALEX on 16/9/20.
//
//

#import <Foundation/Foundation.h>

@interface TPDContactGroupModel : NSObject
@property (nonatomic,copy) NSString *candidateKey;
@property (nonatomic,strong) NSArray *contacts;

+ (NSArray *)loadCompaniesContactGroupModel;

@end
