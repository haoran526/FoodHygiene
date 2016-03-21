//
//  HH_waterfallViewCell.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/15.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_waterfallViewCell.h"
#import "HH_detailModel.h"
#import "UIImageView+WebCache.h"

@implementation HH_waterfallViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView{
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 5;
    self.imageView = [[UIImageView alloc]initWithFrame:self.contentView.frame];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    self.keyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.imageView.frame), CGRectGetWidth(self.contentView.frame), 50)];
    _keyLabel.numberOfLines = 0;
    _keyLabel.font = [UIFont systemFontOfSize:12.0f];
    _keyLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.keyLabel];
}

//当bounds发生改变的时候调用
- (void)layoutSubviews {
    self.contentView.frame = self.bounds;
    self.imageView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-36);
    self.keyLabel.frame = CGRectMake(0, CGRectGetHeight(self.imageView.frame), CGRectGetWidth(self.contentView.frame), 36);
}


-(void)setModel:(HH_detailModel *)model{
    if (_model != model) {
        _model = model;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"placeHolderImg"]];
        _keyLabel.text = [NSString stringWithFormat:@"关键字:%@",model.keywords];
    }
}

@end
