//
//  HH_CollectionViewCell.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_CollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "HH_ContentModel.h"

@implementation HH_CollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
    [self.contentView addSubview:self.imageView];
    
    self.labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(self.imageView.frame))];
    self.labelTitle.font = [UIFont systemFontOfSize:15];
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.labelTitle];
}


-(void)setModel:(HH_ContentModel *)model{
    if (_model != model) {
        _model = model;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:model.img]];
        _labelTitle.text = model.name;
    }
}





@end
