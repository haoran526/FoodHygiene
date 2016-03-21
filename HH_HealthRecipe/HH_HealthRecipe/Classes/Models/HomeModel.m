//
//  HomeModel.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel

-(void)dealloc{
    self.count = nil;
    self.descrip = nil;
    self.fcount = nil;
    self.ID = nil;
    self.img = nil;
    self.keywords = nil;
    self.message = nil;
    self.rcount = nil;
    self.time = nil;
    self.title = nil;
    self.topclass = nil;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
-(void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"id"] ) {
        _ID = value;
    }
    if ([key isEqualToString:@"description"]) {
        _descrip = value;
    }
}



@end
