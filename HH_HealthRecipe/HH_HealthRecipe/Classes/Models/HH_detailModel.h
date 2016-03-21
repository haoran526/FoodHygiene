//
//  HH_detailModel.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/11.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HH_detailModel : NSObject
//名字
@property(nonatomic,strong)NSString *name;

//食谱标识
@property(nonatomic,strong)NSString *ID;
//img
@property(nonatomic,strong)NSString *img;
//关键字
@property(nonatomic,strong)NSString *keywords;
//内容
@property(nonatomic,strong)NSString *message;
//图片宽高
@property(nonatomic,assign)CGFloat imgWidth;
@property(nonatomic,assign)CGFloat imgHeight;

@end
