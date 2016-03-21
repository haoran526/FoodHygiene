//
//  HomeCell.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HomeCell.h"
#import "HomeModel.h"
#import "UIImageView+WebCache.h"
@interface HomeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
@implementation HomeCell


- (void)awakeFromNib {
    // Initialization code
}

-(void)setHomeData:(HomeModel *)homeData{
    if (_homeData != homeData) {
        _homeData = nil;
        _homeData = homeData;
        [self setHomeDataContent];
    }
}
-(void)setHomeDataContent{
    self.title.text = self.homeData.title;
    NSString *str = @"http://tnfs.tngou.net/img";
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[str stringByAppendingString:self.homeData.img]]];
    self.headerImage.layer.cornerRadius = 45.f;
    self.headerImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
