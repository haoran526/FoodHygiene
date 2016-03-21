//
//  HH_DetailViewController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/22.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_DetailViewController.h"
#import "DataBase.h"
@interface HH_DetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation HH_DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
    [self.webView loadHTMLString:self.messageStr baseURL:nil];

}
- (IBAction)leftBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBarButtonClick:(UIBarButtonItem *)sender {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"删除" message:@"是否删除" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakS = self;
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //删除数据库里的
        [[DataBase shareDataBase] remove:weakS.strID fromDB:weakS.strDB];
        [alter dismissViewControllerAnimated:YES completion:nil];
        [weakS alertController];
    }]];
    [alter addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alter animated:YES completion:nil];
}


-(void)alertController{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"删除" message:@"删除成功" preferredStyle:UIAlertControllerStyleAlert];
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alter animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
