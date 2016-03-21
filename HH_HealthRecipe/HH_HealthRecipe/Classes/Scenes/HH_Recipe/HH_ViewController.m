//
//  HH_ViewController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 16/3/17.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_ViewController.h"
#import "HH_DataHelper.h"
#import "HH_classModel.h"
#import "HH_CollectionViewCell.h"
#import "HH_ContentModel.h"
#import "HHH_DetailViewController.h"
#import "HH_SearchViewController.h"
#import "MJRefresh.h"

#define LeftOriginX CGRectGetWidth(self.view.frame)/3
//图片网址前半部
static NSString * const imgHeaderStr = @"http://tnfs.tngou.net/image";


@interface HH_ViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//左菜单栏
@property (nonatomic ,strong) UITableView *leftTableView;
//内容界面
@property (nonatomic ,strong) UICollectionView *contentCollecView;
//判断左侧是否弹出
@property (nonatomic,assign) BOOL isLeftViewOut;
//内容数据
@property(nonatomic,strong)NSMutableArray *contentArray;
//滑动手势
@property(nonatomic,strong)UISwipeGestureRecognizer *swip;
//清空数组数据
@property(nonatomic,assign)BOOL cleanData;

//刷新标识：编号、页数
@property(nonatomic,assign)NSInteger classID;
@property(nonatomic,assign)NSInteger classPage;

@end

@implementation HH_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"美容";
    self.contentArray = [NSMutableArray array];
    self.classID = 1;
    self.classPage =1;
    
    [self requset];
    [self setContentView];
    [self setLeftView];
    [self setBarButtonItem];
    
    //集成刷新控件
    [self addHeader];
    [self addFooter];
}

//数据请求 刷新
-(void)requset{
    HH_DataHelper *dataHelper = [HH_DataHelper shareDataHelper];
    
    //请求菜单栏数据
    [dataHelper request];
    //刷新菜单栏
    __weak typeof(self) weakSelf = self;
    [dataHelper setTableViewReloadBlock:^{
        [weakSelf.leftTableView reloadData];
    }];
    self.cleanData = YES;
    [self requestClassID:1 withPage:1];
    
}

#pragma mark ----- contentCollectionView

-(void)setContentView{
    //创建布局文件 ,流水布局 
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((CGRectGetWidth(self.view.frame)-16)/3.5, CGRectGetHeight(self.view.frame)/5);
    layout.sectionInset = UIEdgeInsetsMake(10, 8, 10, 8);

    self.contentCollecView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    self.contentCollecView.backgroundColor = [UIColor whiteColor];
    //指定代理
    self.contentCollecView.dataSource = self;
    self.contentCollecView.delegate = self;
    
    //注册UICollectionViewCell
    [self.contentCollecView registerClass:[HH_CollectionViewCell class] forCellWithReuseIdentifier:@"Content_Cell"];
    
    [self.view addSubview:self.contentCollecView];
    //添加手势
    [self addGestureRecognizer];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _contentArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *collecID = @"Content_Cell";
    HH_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collecID forIndexPath:indexPath];
    
    HH_ContentModel *model = _contentArray[indexPath.row];
    
    cell.model = model;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HHH_DetailViewController *detailVC = [[HHH_DetailViewController alloc]init];
    HH_ContentModel *model = _contentArray[indexPath.row];
    detailVC.ID = model.ID;
    detailVC.titleStr = model.name;
    [self.navigationController pushViewController:detailVC animated:YES];
    [self leftTableViewMoveLeft];
}


#pragma mark ------ 添加手势

-(void)addGestureRecognizer{
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.contentCollecView addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.contentCollecView addGestureRecognizer:rightSwipeGestureRecognizer];
}

//手势控制弹出弹回
-(void)handleSwipes:(UISwipeGestureRecognizer *)sender{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self leftTableViewMoveRight];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self leftTableViewMoveLeft];
    }
}

#pragma mark ----- UIBarButtonItem

- (void)setBarButtonItem{
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithTitle:@"分类" style:UIBarButtonItemStyleDone target:self action:@selector(barButtonClick:)];
    leftBar.tag = 200;
    self.navigationItem.leftBarButtonItem = leftBar;
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(barButtonClick:)];
    rightBar.tag = 201;
    self.navigationItem.rightBarButtonItem = rightBar;
}

//BarButton点击事件
-(void)barButtonClick:(UIBarButtonItem *)sender{
    if (sender.tag == 200) {
        if (!self.isLeftViewOut) {
            [self leftTableViewMoveRight];
        }else{
            [self leftTableViewMoveLeft];
        }
    }else{
        HH_SearchViewController *SVC = [[HH_SearchViewController alloc]init];
        self.modalTransitionStyle = 2;
        [self presentViewController:SVC animated:YES completion:nil];
    }

}

//弹出
-(void)leftTableViewMoveRight{
    CGRect leftRect =  self.leftTableView.frame;
    leftRect.origin.x = 0;
    
    //左侧界面弹出
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.leftTableView.frame = leftRect;
    }];
    self.isLeftViewOut = YES;
}

//弹回
-(void)leftTableViewMoveLeft{
    CGRect leftRect = self.leftTableView.frame;
    leftRect.origin.x = - LeftOriginX;
    
    //左侧界面弹回
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.leftTableView.frame = leftRect;
    }];
    self.isLeftViewOut = NO;
}





#pragma mark ----- LeftTableView

- (void)setLeftView{
    self.leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(-LeftOriginX, 64, LeftOriginX, CGRectGetHeight(self.view.frame)-64-49) style:UITableViewStylePlain];
    
    self.leftTableView.dataSource = self;
    self.leftTableView.delegate = self;
    
    [self.view addSubview:self.leftTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[HH_DataHelper shareDataHelper] dataArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseID = @"tableView_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    HH_classModel *model = [[HH_DataHelper shareDataHelper] dataArray][indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = model.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_contentArray removeAllObjects];
    NSArray * arr = [[HH_DataHelper shareDataHelper] dataArray];
    HH_classModel *model = arr[indexPath.row];
    self.navigationItem.title = model.title;
    self.classID = model.ID.integerValue;
    self.classPage = 1;
    self.cleanData = YES;
    [self requestClassID:model.ID.integerValue withPage:1];
}

#pragma mark ----- 请求内容数据

//请求分类列表的数据 classID分类数据 page请求页数
-(void)requestClassID: (NSInteger)classID withPage: (NSInteger)page{
    NSString *httpUrl = @"http://apis.baidu.com/tngou/cook/list";
    NSString *HttpArg = [NSString stringWithFormat:@"id=%ld&page=%ld&rows=20",classID,page];
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    
    [request setHTTPMethod: @"GET"];
    [request addValue: @"6f3a6649e10393d6193c82276fd924d4" forHTTPHeaderField: @"apikey"];
    __weak typeof(self) weakSelf = self;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
        if (error) {
            NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
        } else {
            if (weakSelf.cleanData) {
                [weakSelf.contentArray removeAllObjects];
            }
            //获取数据
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"tngou"];
            for (NSDictionary *d in dataArray) {
                HH_ContentModel *model = [[HH_ContentModel alloc]init];
                [model setValuesForKeysWithDictionary:d];
                model.img = [imgHeaderStr stringByAppendingString:model.img];
                [_contentArray addObject:model];
            }
            weakSelf.classPage++;
            [weakSelf.contentCollecView reloadData];
        }
        [weakSelf.contentCollecView headerEndRefreshing];
        [weakSelf.contentCollecView footerEndRefreshing];
    }];
}

#pragma mark -----刷新
//下拉
- (void)addHeader
{
    __weak typeof(self) weakSelf = self;
    // 添加下拉刷新头部控件
    [self.contentCollecView addHeaderWithCallback:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            weakSelf.cleanData = YES;
            weakSelf.classPage = 1;
            [weakSelf requestClassID:weakSelf.classID withPage:1];
        });
    }];
}

//上拉
- (void)addFooter
{
    __weak typeof(self) weakSelf = self;
    // 添加上拉刷新尾部控件
    [self.contentCollecView addFooterWithCallback:^{
        weakSelf.cleanData = NO;
        [weakSelf requestClassID:weakSelf.classID withPage:weakSelf.classPage];
    }];
}

//滚动左视图弹回
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.contentCollecView ) {
        [self leftTableViewMoveLeft];
    }
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
