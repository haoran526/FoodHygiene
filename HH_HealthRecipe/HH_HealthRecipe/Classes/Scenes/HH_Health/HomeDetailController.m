//
//  HomeDetailController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HomeDetailController.h"
#import "UIImageView+WebCache.h"
#import "DataBase.h"
#import "HomeModel.h"
#import "UMSocial.h"

static NSString * const detailUrl = @"http://apis.baidu.com/tngou/lore/show";

@interface HomeDetailController ()<UMSocialUIDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *HomeDetailWebView;

@property(nonatomic,strong)HomeModel *model;

@end

@implementation HomeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.HomeDetailWebView.scrollView.bounces = NO;
    self.navigationItem.title = self.titleStr;
    [self request];
    self.model = [[HomeModel alloc]init];
    
}

-(void)request{
    NSString *HttpArg = [NSString stringWithFormat:@"id=%@",self.ID];
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", detailUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"05ef16b16d11cb70e78a1df2f8c66722" forHTTPHeaderField: @"apikey"];
    __weak typeof (self) weakS = self;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
        if (error) {
            NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *str = [NSString stringWithFormat:@"<div style=\"text-align:center;\"><h3>%@</h3></div>",dic[@"title"]];
            NSString *message = [weakS setWebImageSize:dic[@"message"]];
            NSString *htmlStr = [str stringByAppendingString:message];
            weakS.model.ID = dic[@"id"];
            weakS.model.title = dic[@"title"];
            weakS.model.message = htmlStr;
            [weakS.HomeDetailWebView loadHTMLString:htmlStr baseURL:nil];
        }
    }];
}


-(NSString *)setWebImageSize:(NSString *)message{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width-20;
    if ([message containsString:@"png"]) {
        NSArray *arr = [message componentsSeparatedByString:@"png\""];
        NSString *size = [NSString stringWithFormat:@"width=\"%.2f\" ",width];
        NSMutableString *messageS = [NSMutableString string];
        for (int i = 0; i < arr.count; i++) {
            NSString *s = arr[i];
            if ([s containsString:@"width"]) {
                NSInteger indexP = [message rangeOfString:@"width"].location;
                NSRange range = {indexP,24};
                NSString *s1 = [s stringByReplacingCharactersInRange:range withString:size];
                [messageS appendString:s1];
                continue;
            }
            if (i == arr.count - 1) {
                [messageS appendString:s];
                continue;
            }
            [messageS appendFormat:@"%@png\" %@",s,size];
        }
        return messageS;
    }else{
        NSArray *arr = [message componentsSeparatedByString:@"jpg\""];
        NSString *size = [NSString stringWithFormat:@"width=\"%.2f\" ",width];
        NSMutableString *messageS = [NSMutableString string];
        for (int i = 0; i < arr.count; i++) {
            NSString *s = arr[i];
            if ([s containsString:@"width"]) {
                NSInteger indexW = [s rangeOfString:@"width"].location;
                NSInteger indexH = [s rangeOfString:@"height"].location;
                NSRange range = NSMakeRange(0, 0);
                if (indexW < indexH) {
                    range = NSMakeRange(indexW, 24);
                }else{
                    range = NSMakeRange(indexH, 24);
                }
                NSString *s1 = [s stringByReplacingCharactersInRange:range withString:size];
                [messageS appendFormat:@"%@jpg\"",s1];
                continue;
            }
            if (i == arr.count - 1) {
                [messageS appendString:s];
                continue;
            }
            [messageS appendFormat:@"%@jpg\" %@",s,size];
        }
        return messageS;
    }
}





//返回按钮
- (IBAction)ClickBack:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)ClickCollect:(UIBarButtonItem *)sender {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakS = self;
    [alter addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DataBase *dataBase = [DataBase shareDataBase];
        [dataBase createHealthDB];
        [alter dismissViewControllerAnimated:YES completion:nil];
        [dataBase insertHealth:self.model block:^(NSString *str) {
            [weakS alertController:str];
        }];
    }]];
    
    
    [alter addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:weakS.model.img];
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        [UMSocialSnsService presentSnsIconSheetView:weakS
                                             appKey:nil
                                          shareText:[NSString stringWithFormat:@"http://www.tngou.net/lore/show/%@",weakS.model.ID]
                                         shareImage:image
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,nil]
                                           delegate:weakS];
    }]];
    [alter addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alter animated:YES completion:nil];
}

-(void)alertController:(NSString *)str{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alter animated:YES completion:nil];
}



#pragma mark ----- 分享

//分享回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    NSDictionary *dic = response.data[@"sina"];
    NSInteger result = [dic[@"st"] integerValue];
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess){
        [self delayAlert:@"分享成功"];
    }else if(result == UMSResponseCodeShareRepeated){
        [self delayAlert:@"分享失败:内容重复"];
    }else if (response.responseCode == UMSResponseCodeNetworkError){
        [self delayAlert:@"分享失败:网络错误"];
    }else{
        [self delayAlert:@"分享失败"];
    }
}

//分享完成提示信息
-(void)delayAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
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
