//
//  DataBase.h
//  SQLite
//
//  Created by 惠浩 on 15/12/21.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HH_detailModel;
@class HomeModel;

typedef void(^ResultBlock)(NSString *str);
typedef void (^HealthBlock)(NSString *);
@interface DataBase : NSObject

@property (nonatomic,copy)ResultBlock resultBlock;
@property (nonatomic,copy)HealthBlock hBlock;

+(DataBase *)shareDataBase;
- (void)open;
- (void)close;
- (void)remove:(NSString *)IDstr fromDB:(NSString *)db_Name;
- (void)removeAllfromDB:(NSString *)db_Name;
//判断是否有
-(BOOL)selectWithModelID:(NSString *)ID fromDB:(NSString *)db_Name;

#pragma mark ----- 食谱收藏

- (void)create;
- (void)insert:(HH_detailModel *)myModel block:(ResultBlock)resultBlock;
- (NSArray *)select;

#pragma mark ----- 知识收藏

- (void)createHealthDB;
- (void)insertHealth:(HomeModel *)myModel block:(HealthBlock)healtBlock;
- (NSArray *)selectHealth;


@end
