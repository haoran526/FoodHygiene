//
//  HH_DetailViewController.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/11.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HHH_DetailViewController : UIViewController
@property(nonatomic,strong)NSString *ID;
@property(nonatomic,strong)NSString *titleStr;
@property(nonatomic,assign)BOOL passController;
@end
