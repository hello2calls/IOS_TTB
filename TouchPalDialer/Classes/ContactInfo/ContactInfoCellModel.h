//
//  ContactInfoCellModel.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/22.
//
//

#import <Foundation/Foundation.h>

typedef enum{
    CellPhone,
    CellFaceTime,
    CellEmail,
    CellData,
    CellGroup,
    CellNote,
    CellUrl,
    CellAddress,
    CellSNS,
    CellIM,
    CellInviting,
    CellOther
}CellType;

@interface ContactInfoCellModel : NSObject

@property (nonatomic,strong) NSString *mainStr;
@property (nonatomic,strong) NSString *subStr;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,assign) CellType cellType;

@end
