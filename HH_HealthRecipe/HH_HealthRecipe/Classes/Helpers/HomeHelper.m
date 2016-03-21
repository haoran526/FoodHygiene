//
//  HomeHelper.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HomeHelper.h"
#import "HomeModel.h"


@interface HomeHelper()


@end

@implementation HomeHelper

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

//单例:
+(instancetype)shareHomeHelper{
    static HomeHelper *homeHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        homeHelper = [[HomeHelper alloc]init];
    });
    return homeHelper;
}

//获取信息
-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"05ef16b16d11cb70e78a1df2f8c66722" forHTTPHeaderField: @"apikey"];
    __weak typeof(self) weakS = self;
    [NSURLConnection sendAsynchronousRequest: request
    queue: [NSOperationQueue mainQueue]
    completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
    if (error) {
     NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
    } else {
     if (!weakS.flag) {
    [weakS.dataArray removeAllObjects];
    }
        
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray *arr = dict[@"tngou"];
        
    for (NSDictionary *dic in arr) {
    HomeModel *home = [[HomeModel alloc]init];
    [home setValuesForKeysWithDictionary:dic];
    BOOL flag = YES;
        
    for (int j = 0; j < weakS.dataArray.count; j++) {
    HomeModel *home1 = weakS.dataArray[j];
        
    if ([home.title isEqualToString:home1.title]) {
    flag = NO;
    break;
      }
    }
        
    if (!flag) {
    continue;
    }
        
    [weakS.dataArray addObject:home];
  }
    if (weakS.ResultBlock) {
    weakS.ResultBlock();
        }
      }
    }];
}

-(HomeModel *)getDataFromIndex:(NSInteger)index{
    return self.dataArray[index];
}

-(HomeModel *)getDataFromIndexPath:(NSIndexPath *)indexPath{
    return [self getDataFromIndex:indexPath.row];
}


@end
