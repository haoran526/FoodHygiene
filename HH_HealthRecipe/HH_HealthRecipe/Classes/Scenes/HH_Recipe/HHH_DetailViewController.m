//
//  HH_DetailViewController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/11.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HHH_DetailViewController.h"
#import "HH_detailModel.h"
#import "DataBase.h"
#import "UMSocial.h"



@interface HHH_DetailViewController ()<UMSocialUIDelegate>

@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)HH_detailModel *model;
@property(nonatomic,strong)UIView *titleView;

@end

@implementation HHH_DetailViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpWebView];
    if (self.passController) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 20, 50, 44);
        [button setTitle:@"搜索" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:19];
        [button addTarget:self action:@selector(returnLastView) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:button];
        
        UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeSystem];
        rightbutton.frame = CGRectMake(CGRectGetWidth(self.view.frame)-CGRectGetWidth(button.frame), CGRectGetMinY(button.frame), CGRectGetWidth(button.frame), CGRectGetHeight(button.frame));
        [rightbutton setImage:[UIImage imageNamed:@"iconfont-menu"] forState:UIControlStateNormal];
        [rightbutton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:rightbutton];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(button.frame), CGRectGetMinY(button.frame), CGRectGetWidth(self.view.frame)-CGRectGetWidth(button.frame)-CGRectGetWidth(rightbutton.frame), CGRectGetHeight(button.frame))];
        label.text = self.titleStr;
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        [self.titleView addSubview:label];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 63, CGRectGetWidth(self.view.frame), 1)];
        view.backgroundColor = [UIColor grayColor];
        [self.titleView addSubview:view];
        
    }else{
        self.navigationItem.title = self.titleStr;
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"iconfont-menu"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonClick:)];
        self.navigationItem.rightBarButtonItem = rightBar;
    }
    
    [self requestData];
}

//NavigationBar左侧点击事件
-(void)returnLastView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//NavigationBar右侧点击事件
-(void)rightBarButtonClick:(UIBarButtonItem *)sender{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakS = self;
    [alter addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DataBase *dataBase = [DataBase shareDataBase];
        [dataBase create];
        [alter dismissViewControllerAnimated:YES completion:nil];
        [dataBase insert:self.model block:^(NSString *str) {
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

#pragma mark ----- 收藏

-(void)alertController:(NSString *)str{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alter addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alter animated:YES completion:nil];
}

#pragma mark ----- 数据请求
//数据请求
-(void)requestData{
    NSString *httpUrl = @"http://apis.baidu.com/tngou/cook/show";
    NSString *HttpArg = [NSString stringWithFormat:@"id=%@",self.ID];
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"6f3a6649e10393d6193c82276fd924d4" forHTTPHeaderField: @"apikey"];
    __weak typeof(self) weakS = self;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
        if (error) {
            NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            weakS.model = [[HH_detailModel alloc]init];
            [weakS.model setValuesForKeysWithDictionary:dic];
            weakS.model.img = [@"http://tnfs.tngou.net/image" stringByAppendingString:weakS.model.img];
            [weakS setWebViewContent];
        }
    }];
    
}


-(void)setUpWebView{
    if (self.passController) {
        self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        [self.view addSubview:self.titleView];
        
        self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.titleView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.titleView.frame))];
        [self.view addSubview:self.webView];
        self.webView.scrollView.bounces = NO;
    }else{
        self.webView = [[UIWebView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:self.webView];
        self.webView.scrollView.bounces = NO;
    }
}

-(void)setWebViewContent{
    NSString *keyStr = [@"<h2>关键字</h2><hr>"  stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>",self.model.keywords]];
    NSInteger width = CGRectGetWidth(self.view.frame)-16;
    
    NSString *image =[NSString stringWithFormat:@"<img src=\"%@\" width=\"%ld\" />",self.model.img,width];
    NSMutableString *htmlStr = [keyStr stringByAppendingString:self.model.message].mutableCopy;
    htmlStr = [image stringByAppendingString:htmlStr].mutableCopy;
    self.model.message = htmlStr;
    [self.webView loadHTMLString:htmlStr baseURL:nil];
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
