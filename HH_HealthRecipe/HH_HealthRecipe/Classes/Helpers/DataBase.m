//
//  DataBase.m
//  SQLite
//
//  Created by 惠浩 on 15/12/21.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "DataBase.h"
#import <sqlite3.h>
#import "HH_detailModel.h"
#import "HomeModel.h"
#import <UIKit/UIKit.h>

static sqlite3 *db = nil;
static DataBase *dataBase = nil;

@implementation DataBase

+(DataBase *)shareDataBase{
    if (dataBase == nil) {
        dataBase = [[DataBase alloc]init];
    }
    return dataBase;
}

- (void)open{
    if (db) {
        return;
    }
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"collection.sqlite"];
    NSLog(@"%@", path);
    int result = sqlite3_open(path.UTF8String, &db);
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }else{
        NSLog(@"打开失败");
    }
}

- (void)close{
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        NSLog(@"关闭成功");
        db = nil;
    }else{
        NSLog(@"关闭失败");
    }
}

- (void)remove:(NSString *)IDstr fromDB:(NSString *)db_Name{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where ID = '%@'",db_Name,IDstr];
    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败:%d",result);
    }
    [self close];
}

- (void)removeAllfromDB:(NSString *)db_Name{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@",db_Name];
    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败:%d",result);
    }
    [self close];
}


//查数据
-(BOOL)selectWithModelID:(NSString *)ID fromDB:(NSString *)db_Name{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ID = '%@'",db_Name,ID];
    sqlite3_stmt *stmt = nil;
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_step(stmt) != SQLITE_ROW) {
            sqlite3_finalize(stmt);
            NSLog(@"没有");
            return YES;
        }else{
            sqlite3_finalize(stmt);
            NSLog(@"有");
            return NO;
        }
    }else{
        NSLog(@"sql语句错误");
        return NO;
    }
}

#pragma mark ----- 食谱

- (void)create{
    [self open];
    //create table if not exists user (title text, name text, image text, id text)
    NSString *sql = @"create table mine (name text, ID text, img text, keywords text, message text)";
    int result =  sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"创建成功");
    }else{
        NSLog(@"创建失败:%d",result);
    }
    [self close];
}


- (void)insert:(HH_detailModel *)myModel block:(ResultBlock)resultBlock{
    [self open];
    if ([self selectWithModelID:myModel.ID fromDB:@"mine"]) {
        //INSERT INTO user (userName,password,flag) VALUES ('%@','%@','%d')
        NSString *sql = [NSString stringWithFormat:@"insert into mine values ('%@','%@','%@','%@','%@')", myModel.name ,myModel.ID, myModel.img,myModel.keywords,myModel.message];
        int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
        if (result == SQLITE_OK) {
            resultBlock(@"收藏成功");
        }else{
            resultBlock([NSString stringWithFormat:@"收藏失败:%d",result]);
        }
    }else{
        resultBlock(@"已收藏过");
    }
    [self close];
}

- (NSArray *)select{
    [self open];
    //创建数据库替身
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"select * from mine";
    //执行语句
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    //判断是否成功
    if (result == SQLITE_OK) {
        //创建数组用来保存查询的数据
        NSMutableArray *arr = [NSMutableArray array];
        //如果还有下一行
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            //获取数据
            const unsigned char * name = sqlite3_column_text(stmt, 0);
            const unsigned char * ID = sqlite3_column_text(stmt, 1);
            const unsigned char * img = sqlite3_column_text(stmt, 2);
            const unsigned char * keywords = sqlite3_column_text(stmt, 3);
            const unsigned char * message = sqlite3_column_text(stmt, 4);
            
            //封装成model
            HH_detailModel *myModel = [[HH_detailModel alloc] init];
            myModel.name = [ NSString stringWithUTF8String:(const char *) name];
            myModel.ID = [NSString stringWithUTF8String:(const char *) ID];
            myModel.img = [NSString stringWithUTF8String:(const char *) img];
            myModel.keywords = [NSString stringWithUTF8String:(const char *) keywords];
            myModel.message = [NSString stringWithUTF8String:(const char *) message];
            
            [arr addObject:myModel];
        }
        //释放数据库替身
        sqlite3_finalize(stmt);
        return arr;
    }
    sqlite3_finalize(stmt);
    [self close];
    return [NSMutableArray array];
}




#pragma mark ----- 知识

- (void)createHealthDB{
    [self open];
    //create table if not exists user (title text, name text, image text, id text)
    NSString *sql = @"create table health (ID text, title text, message text)";
    int result =  sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"创建成功");
    }else{
        NSLog(@"创建失败:%d",result);
    }
    [self close];
}

- (void)insertHealth:(HomeModel *)myModel block:(HealthBlock)healtBlock{
    [self open];
    if ([self selectWithModelID:myModel.ID fromDB:@"health"]) {
        //INSERT INTO user (userName,password,flag) VALUES ('%@','%@','%d')
        NSString *sql = [NSString stringWithFormat:@"insert into health values ('%@','%@','%@')", myModel.ID ,myModel.title, myModel.message];
        int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
        if (result == SQLITE_OK) {
            healtBlock(@"收藏成功");
        }else{
            healtBlock(@"收藏失败");
        }
    }else{
        healtBlock(@"已收藏过");
    }
    [self close];
}


- (NSArray *)selectHealth{
    [self open];
    //创建数据库替身
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"select * from health";
    //执行语句
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    //判断是否成功
    if (result == SQLITE_OK) {
        //创建数组用来保存查询的数据
        NSMutableArray *arr = [NSMutableArray array];
        //如果还有下一行
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            //获取数据
            const unsigned char * ID = sqlite3_column_text(stmt, 0);
            const unsigned char * title = sqlite3_column_text(stmt, 1);
            const unsigned char * message = sqlite3_column_text(stmt, 2);
            
            //封装成model
            HomeModel *myModel = [[HomeModel alloc] init];
            myModel.ID = [ NSString stringWithUTF8String:(const char *) ID];
            myModel.title = [NSString stringWithUTF8String:(const char *) title];
            myModel.message = [NSString stringWithUTF8String:(const char *) message];
            
            [arr addObject:myModel];
        }
        //释放数据库替身
        sqlite3_finalize(stmt);
        return arr;
    }
    sqlite3_finalize(stmt);
    [self close];
    return [NSMutableArray array];
}

                  
@end
