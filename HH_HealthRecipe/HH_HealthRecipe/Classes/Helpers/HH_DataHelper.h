//
//  HH_DataHelper.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HH_DataHelper : NSObject

//菜单栏数据
@property(nonatomic,strong)NSMutableArray *dataArray;

//刷新左侧菜单栏
@property (nonatomic,copy) void(^tableViewReloadBlock)();

+(instancetype)shareDataHelper;
//分类数据
-(void)request;

@end
