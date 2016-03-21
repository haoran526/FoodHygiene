//
//  AppDelegate.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "AppDelegate.h"
#import "HH_ViewController.h"
#import "YYClipImageTool.h"
#import "UMSocial.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    UIStoryboard *health = [UIStoryboard storyboardWithName:@"Health" bundle:nil];
    UINavigationController *znvc = [health instantiateViewControllerWithIdentifier:@"home"];
    znvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"健康知识" image:[UIImage imageNamed:@"zhishikuGray"] selectedImage:[UIImage imageNamed:@"zhishikuBlue"]];
    
    
    UIStoryboard *mine = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    UINavigationController *hnvc = [mine instantiateViewControllerWithIdentifier:@"mineStoryBoard"];
    hnvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"个人设置" image:[UIImage imageNamed:@"wodeGray"] selectedImage:[UIImage imageNamed:@"wodeBlue"]];
    
    
    HH_ViewController *jrvc = [[HH_ViewController alloc]init];
    UINavigationController *jnvc = [[UINavigationController alloc]initWithRootViewController:jrvc];

    UITabBarController *tbc = [[UITabBarController alloc]init];
    tbc.viewControllers = @[znvc,jnvc,hnvc];
    
    jnvc.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"健康食谱" image:[UIImage imageNamed:@"iconfont-shipin" ] tag:102];
    
    self.window.rootViewController = tbc;
    
    [YYClipImageTool addToCurrentView:self.window clipImage:[UIImage imageNamed:@"BeginImg.png"]];
    
    [UMSocialData setAppKey:@"567bf86fe0f55a8d0f004a5d"];
    return YES;
}
/*就是牛逼!*/


@end
