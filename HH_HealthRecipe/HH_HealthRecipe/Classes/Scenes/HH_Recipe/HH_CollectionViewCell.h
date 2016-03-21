//
//  HH_CollectionViewCell.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HH_ContentModel;

@interface HH_CollectionViewCell : UICollectionViewCell
//标题
@property (strong,nonatomic) UILabel *labelTitle;
//图片
@property (strong,nonatomic) UIImageView *imageView;
//model
@property (nonatomic,strong) HH_ContentModel *model;

@end
