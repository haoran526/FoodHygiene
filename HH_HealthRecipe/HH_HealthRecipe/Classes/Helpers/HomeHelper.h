//
//  HomeHelper.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HomeModel;

@interface HomeHelper : NSObject

@property(nonatomic,assign)BOOL flag;

//数据个数
@property(nonatomic,assign) NSInteger count;
//存数据
@property(nonatomic,strong)NSMutableArray *dataArray;
//数据加载完回调
@property(nonatomic,copy) void(^ResultBlock)();
//单例:
+(instancetype)shareHomeHelper;
//数据解析
-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg;
//根据下标取数据
-(HomeModel *)getDataFromIndex:(NSInteger)index;
-(HomeModel *)getDataFromIndexPath:(NSIndexPath *)indexPath;

@end
