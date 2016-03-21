//
//  HH_DataHelper.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_DataHelper.h"
#import "HH_classModel.h"
#import "HH_ContentModel.h"

@implementation HH_DataHelper

//单例
+(instancetype)shareDataHelper{

    static HH_DataHelper *datahelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datahelper = [[HH_DataHelper alloc]init];
    });
    return datahelper;
}

-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


//请求分类数据
-(void)request{
    NSString *httpUrl = @"http://apis.baidu.com/tngou/cook/classify";
    NSString *HttpArg = @"id=0";

    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"6f3a6649e10393d6193c82276fd924d4" forHTTPHeaderField: @"apikey"];
    
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
        if (error) {
            NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
        } else {
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"tngou"];
            for (NSDictionary *dic in dataArray) {
                HH_classModel *model = [[HH_classModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [_dataArray addObject:model];
            }
        }
        if (self.tableViewReloadBlock) {
            self.tableViewReloadBlock();
        }
    }];
}




@end
