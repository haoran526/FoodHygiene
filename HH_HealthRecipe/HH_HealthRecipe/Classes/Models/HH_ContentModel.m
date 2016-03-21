//
//  HH_ContentModel.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/11.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_ContentModel.h"

@implementation HH_ContentModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

-(void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"id"]) {
        _ID = [NSString stringWithFormat:@"%@",value];
    }
}

-(void)dealloc{
    _img = nil;
    _name = nil;
    _ID = nil;
}





@end
