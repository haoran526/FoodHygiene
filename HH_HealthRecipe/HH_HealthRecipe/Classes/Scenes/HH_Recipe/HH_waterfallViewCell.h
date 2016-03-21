//
//  HH_waterfallViewCell.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/15.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HH_detailModel;

@interface HH_waterfallViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UILabel *keyLabel;
@property (nonatomic,strong) HH_detailModel *model;

@end
