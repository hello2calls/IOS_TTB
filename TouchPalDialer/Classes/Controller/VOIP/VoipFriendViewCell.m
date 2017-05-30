//
//  VoipFriendViewCell.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-11.
//
//

#import "VoipFriendViewCell.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"

@interface VoipFriendViewCell(){
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
}
@end

@implementation VoipFriendViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           personId:(NSInteger)personId
               size:(CGSize)size
              image:(UIImage*)image
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, size.width - 80 , 20)];
        _nameLabel.text = personData.fullName;
        [self addSubview:_nameLabel];
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, size.width - 80 , 20)];
        _phoneLabel.text = [personData mainPhone].number;
        [self addSubview:_phoneLabel];
        
        UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
        UILabel *partLine = [[UILabel alloc]initWithFrame:CGRectMake(0, size.height-1, size.width, 1)];
        partLine.backgroundColor = lineColor;
        [self addSubview:partLine];
        
        UIImageView *rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(size.width - 80, (size.height - image.size.height)/2, image.size.width, image.size.height)];
        rightImageView.image = image;
        [self addSubview:rightImageView];
    }

    return self;
}


- (void)setData:(NSInteger)personID{
    ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personID];
    _nameLabel.text = personData.fullName;
    _phoneLabel.text = [personData mainPhone].number;

}

@end
