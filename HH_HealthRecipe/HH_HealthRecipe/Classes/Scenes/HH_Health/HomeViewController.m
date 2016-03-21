//
//  HomeViewController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCell.h"
#import "HomeHelper.h"
#import "HomeDetailController.h"
#import "HomeModel.h"
#import "MJRefresh.h"


static NSString * const httpUrl = @"http://apis.baidu.com/tngou/lore/list";

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *HomeTableView;

@property (weak, nonatomic) IBOutlet UIButton *b0;
@property (weak, nonatomic) IBOutlet UIButton *b1;
@property (weak, nonatomic) IBOutlet UIButton *b2;
@property (weak, nonatomic) IBOutlet UIButton *b3;
@property (weak, nonatomic) IBOutlet UIButton *b4;
@property (weak, nonatomic) IBOutlet UIButton *b5;
@property (weak, nonatomic) IBOutlet UIButton *b6;
@property (weak, nonatomic) IBOutlet UIButton *b7;
@property (weak, nonatomic) IBOutlet UIButton *b8;
@property (weak, nonatomic) IBOutlet UIButton *b9;
@property (weak, nonatomic) IBOutlet UIButton *b10;
@property (weak, nonatomic) IBOutlet UIButton *b11;
@property (weak, nonatomic) IBOutlet UIButton *b12;
@property (weak, nonatomic) IBOutlet UIButton *b13;
@property (nonatomic,strong) NSString *httpArg;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger urlID;
@property (weak, nonatomic) IBOutlet UIScrollView *titleScrollView;
@property (nonatomic, strong) NSString *titleBt;
@property (nonatomic,strong)UIButton *button;
@end

@implementation HomeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = self.b0;
    self.page = 1;
    NSString *httpArg = @"id=0&page=1&rows=20";
    [[HomeHelper shareHomeHelper] request:httpUrl withHttpArg:httpArg];
    [self.b0 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    
    self.titleBt = @"最新知识";
    self.HomeTableView.dataSource = self;
    self.HomeTableView.delegate = self;
    __weak typeof(self) weakSelf = self;
    [[HomeHelper shareHomeHelper] setResultBlock:^{
        [weakSelf.HomeTableView reloadData];
        [weakSelf.HomeTableView headerEndRefreshing];
        [weakSelf.HomeTableView footerEndRefreshing];
        if (![HomeHelper shareHomeHelper].flag) {
            weakSelf.HomeTableView.contentOffset = CGPointMake(0, 0);
        }
    }];
    
    //刷新控件
    [self setupRefresh];
    
    // Do any additional setup after loading the view.
}

- (void)setupRefresh {
    [self.HomeTableView addHeaderWithTarget:self action:@selector(headerBeginRefreshing)];
    
    [self.HomeTableView addFooterWithTarget:self action:@selector(footerBeginRefreshing)];
    
    self.HomeTableView.headerPullToRefreshText = @"下拉刷新";
    self.HomeTableView.headerReleaseToRefreshText = @"松开刷新";
    self.HomeTableView.headerRefreshingText = @"正在为您刷新";
    
    self.HomeTableView.footerPullToRefreshText = @"上拉加载更多";
    self.HomeTableView.footerReleaseToRefreshText = @"松开加载更多";
    self.HomeTableView.footerRefreshingText = @"正在为您加载";
}
//下拉刷新
- (void)headerBeginRefreshing {
    self.page = 1;
    [HomeHelper shareHomeHelper].flag = NO;
    NSString *httpArg = [NSString stringWithFormat:@"id=%ld&page=%ld&rows=20",self.urlID,self.page];
    [[HomeHelper shareHomeHelper] request:httpUrl withHttpArg:httpArg];
}
//上拉加载
- (void)footerBeginRefreshing {
    self.page += 1;
    [HomeHelper shareHomeHelper].flag = YES;
    NSString *httpArg = [NSString stringWithFormat:@"id=%ld&page=%ld&rows=20",self.urlID,self.page];
    [[HomeHelper shareHomeHelper] request:httpUrl withHttpArg:httpArg];
}


//导航栏按钮
- (IBAction)ScrollButton:(UIButton *)sender {
    self.titleBt = sender.titleLabel.text;
    self.urlID = sender.tag - 100;
    self.page = 1;
    NSString *httpArg = [NSString stringWithFormat:@"id=%ld&page=%ld&rows=20",self.urlID,self.page];
    [self originalButtonColor:sender];
    [HomeHelper shareHomeHelper].flag = NO;
    [[HomeHelper shareHomeHelper] request:httpUrl withHttpArg:httpArg];
    
    
    CGFloat offsetWidth = (self.titleScrollView.contentSize.width - [UIScreen mainScreen].bounds.size.width);
    CGFloat offsetPointX = offsetWidth / sender.frame.size.width;
    if (self.urlID > offsetPointX) {
        [UIView animateWithDuration:0.5 animations:^{
            self.titleScrollView.contentOffset = CGPointMake(offsetWidth, 0);
        }];
    }else if(self.urlID == 0){
        [UIView animateWithDuration:0.5 animations:^{
            self.titleScrollView.contentOffset = CGPointMake(0, 0);
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.titleScrollView.contentOffset = CGPointMake(CGRectGetWidth(sender.frame) * (self.urlID - 0.5), 0);
        }];
    }
}

-(void)originalButtonColor:(UIButton *)sender{
    [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:165/255.0 blue:76/255.0 alpha:1] forState:UIControlStateNormal];
    self.button = nil;
    self.button = sender;
}





#pragma mark --tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [HomeHelper shareHomeHelper].dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_id" forIndexPath:indexPath];
    cell.homeData = [[HomeHelper shareHomeHelper] getDataFromIndexPath:indexPath];

    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    HomeDetailController *homeDVC = segue.destinationViewController;
    NSInteger indexP = [self.HomeTableView indexPathForSelectedRow].row;
    HomeModel *model = [HomeHelper shareHomeHelper].dataArray[indexP];
    
    homeDVC.ID = model.ID;
    homeDVC.titleStr = self.titleBt;
}


@end
