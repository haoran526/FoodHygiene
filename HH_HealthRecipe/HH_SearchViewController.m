//
//  HH_SearchViewController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/12.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_SearchViewController.h"
#import "HH_detailModel.h"
#import "HH_waterfallLayout.h"
#import "HH_waterfallViewCell.h"
#import "MBProgressHUD.h"
#import "HHH_DetailViewController.h"

#define LabelWidth (CGRectGetWidth(self.view.frame)-12)/5
static NSString * const imgHeaderStr = @"http://tnfs.tngou.net/image";


@interface HH_SearchViewController ()<UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,WaterfallLayoutDelegate,MBProgressHUDDelegate,NSURLConnectionDataDelegate>

//搜索框
@property(nonatomic,strong)UISearchBar *searchBar;
//加载条
@property (strong,nonatomic) MBProgressHUD *HUD;
//搜索记录的view
@property(nonatomic,strong)UIView *searchView;
//存数据数组
@property(nonatomic,strong)NSMutableArray *detailArray;
//瀑布流collectionView
@property(nonatomic,strong)UICollectionView *waterFallView;
//设置按钮
@property(nonatomic,assign)BOOL isSetButton;
//搜索的菜名
@property(nonatomic,strong)NSString *recipeStr;
@end

@implementation HH_SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.detailArray = [NSMutableArray array];
    [self setSearchBarView];
    [self setSearchHistoryView];
    [self setWaterFallView];
    self.isSetButton = YES;
    
    self.HUD = [[MBProgressHUD alloc]init];
    self.HUD.labelText = @"加载中...";
    self.HUD.labelFont = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.HUD];
}

#pragma mark ----- 设置searchBar
//searchBar
-(void)setSearchBarView{
    //返回按钮
    UIView *searchBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 20, 80, 44);
    [button setTitle:@"健康食谱" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:230.0/255.0 alpha:0.85];
    [button addTarget:self action:@selector(returnLastView) forControlEvents:UIControlEventTouchUpInside];
    [searchBarView addSubview:button];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(CGRectGetWidth(button.frame), CGRectGetMinY(button.frame), CGRectGetWidth(self.view.frame)-CGRectGetWidth(button.frame), 44)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    [searchBarView addSubview:self.searchBar];
    searchBarView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:230.0/255.0 alpha:0.85];
    [self.view addSubview:searchBarView];
    
    for (UIView *subview in self.searchBar.subviews) {
        for(UIView* grandSonView in subview.subviews){
            if ([grandSonView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                grandSonView.alpha = 0;
            } if([grandSonView isKindOfClass:[UIButton class]]){
                UIButton *btn = (UIButton *)grandSonView;
                [btn setTitle:@"搜索" forState:UIControlStateNormal];
            }
        }
    }
}

-(void)returnLastView{
    [self.HUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//键盘搜索按钮
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchBarCancelButtonClicked:searchBar];
}

//searchBar的搜索按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    if (userDef && searchBar.text.length >= 1) {
        NSArray *arr = [userDef objectForKey:@"search"];
        NSMutableArray *searchArr = arr.mutableCopy;
        if (searchArr.count == 0) {
            searchArr = [NSMutableArray array];
            [searchArr addObject:searchBar.text];
        }else if(searchArr.count < 5 && ![searchArr containsObject:searchBar.text]) {
            [searchArr insertObject:searchBar.text atIndex:0];
        }else if(searchArr.count == 5 && ![searchArr containsObject:searchBar.text]){
            [searchArr removeObjectAtIndex:4];
            [searchArr insertObject:searchBar.text atIndex:0];
        }else if ([searchArr containsObject:searchBar.text]){
            //更新历史记录顺序
            NSInteger exchangeIndex = [searchArr indexOfObject:searchBar.text];
            for (int i = 0; i < exchangeIndex; i++) {
                [searchArr exchangeObjectAtIndex:exchangeIndex-i withObjectAtIndex:exchangeIndex-1-i];
            }
        }
        for (int i = 0; i < searchArr.count; i++) {
            if ((i+1 == searchArr.count) && self.isSetButton) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [self setHistoryButton:button index:i];
            }
            if(i == 4){
                self.isSetButton = NO;
            }
            UIButton *button = [self.searchView viewWithTag:300+i];
            [button setTitle:searchArr[i] forState:UIControlStateNormal];
        }
        [userDef setObject:searchArr forKey:@"search"];
        //中文转URLEncode
        NSString *searchStr = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:searchBar.text]];
        [self request:searchStr];
        [searchBar resignFirstResponder];
    }else{
        [self setPrompt:@"请输入菜名!"];
    }
    self.recipeStr = searchBar.text;
}

//提示 输入菜名
-(void)setPrompt:(NSString *)promtpStr{
    UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"错误" message:promtpStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alterVC addAction:alAction];
    [self presentViewController:alterVC animated:YES completion:nil];
}


#pragma mark ----- 搜索历史界面
//搜索历史
-(void)setSearchHistoryView{
    
    self.searchView = [[UIView alloc]initWithFrame:CGRectMake(2, 66, self.view.frame.size.width-4, 52)];
    UILabel *searchlabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, self.view.frame.size.width/3, 25)];
    searchlabel.text = @"搜索记录:";
    self.searchView.backgroundColor = [UIColor lightGrayColor];
    self.searchView.alpha = 0.5;
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = 8;
    [self.searchView addSubview:searchlabel];
    [self.view addSubview:self.searchView];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [NSArray array];
    if (!userDef) {
        [userDef setObject:arr forKey:@"search"];
        [userDef synchronize];
    }else{
        NSArray *searchArray = [userDef objectForKey:@"search"];
        for (int i = 0; i < searchArray.count ; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            if (button.superview) {
                break;
            }
            [self setHistoryButton:button index:i];
            [button setTitle:searchArray[i] forState:UIControlStateNormal];
        }
    }
    [self SetcleanSearchHistoryButton];
}

//清理记录按钮
-(void)SetcleanSearchHistoryButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(CGRectGetWidth(self.view.frame)/4*3, 2, 80, 21);
    [button setTitle:@"清理记录" forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];//边框颜色
    button.tintColor = [UIColor blackColor];
    [self.searchView addSubview:button];
    [button addTarget:self action:@selector(cleanButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

//清理记录按钮
-(void)cleanButtonClick{
     self.isSetButton = YES;
    for (int i = 0; i < 5; i++) {
        UIButton * button = [self.searchView viewWithTag:300+i];
        [button removeFromSuperview];
    }
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef removeObjectForKey:@"search"];

    
}

//历史记录按钮
-(void)setHistoryButton:(UIButton *)button index:(NSInteger)i{
    button.frame =  CGRectMake(2+(LabelWidth+2) * ( i%5 ), 25 + (i / 5) * 27, LabelWidth, 25);
    button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    button.tag = 300 + i;
    button.tintColor = [UIColor blackColor];
    [button addTarget:self action:@selector(historyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
    [self.searchView addSubview:button];
    
}

//点击历史记录按钮
-(void)historyButtonClick:(UIButton *)sender{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSInteger exchangeIndex = sender.tag -300;
    if (userDef){
        //请求数据,转码
        NSString *searchStr = [sender.titleLabel.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:sender.titleLabel.text]];
        [self request:searchStr];
        //更新搜索历史按钮
        NSArray *arr = [userDef objectForKey:@"search"];
        NSMutableArray *searchArr = arr.mutableCopy;
        for (int i = 0; i < exchangeIndex; i++) {
            [searchArr exchangeObjectAtIndex:exchangeIndex-i withObjectAtIndex:exchangeIndex-1-i];
        }
        for (int i = 0; i < searchArr.count; i++) {
            UIButton *button = [self.searchView viewWithTag:300+i];
            [button setTitle:searchArr[i] forState:UIControlStateNormal];
        }
        [userDef setObject:searchArr forKey:@"search"];
    }
    self.recipeStr = sender.titleLabel.text;
    [self.searchBar resignFirstResponder];

}


//数据请求
-(void)request:(NSString *)dishName{

    NSString *httpUrl = @"http://apis.baidu.com/tngou/cook/name";
    NSString *HttpArg = [NSString stringWithFormat:@"name=%@",dishName];
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"6f3a6649e10393d6193c82276fd924d4" forHTTPHeaderField: @"apikey"];
    
    //缓存条
    [self setChrysanthemum];
    __weak typeof(self) weakSelf = self;
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
            if (data.length > 300) {
                [weakSelf.detailArray removeAllObjects];
            }
            NSArray *DataArr = [NSArray array];
            if (error) {
                NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
            } else {
                DataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"tngou"];
                int dataCount = 1;
                for (NSDictionary *dic in DataArr) {
                    if (data.length < 300 || dataCount >=30) {
                        break;
                    }
                    dataCount++;
                    HH_detailModel *model = [[HH_detailModel alloc]init];
                    [model setValuesForKeysWithDictionary:dic];
                    if ([model.img isEqualToString:@"/cook/default.jpg"]) {
                        continue;
                    }
                    model.img = [imgHeaderStr stringByAppendingString:model.img];
                    [weakSelf.detailArray addObject:model];
                }
            }
        [weakSelf.HUD hide:YES];
        [weakSelf.waterFallView reloadData];
        
        if (data.length < 300) {
            [weakSelf setPrompt:@"没有此菜名"];
        }
    }];
}

//缓冲条
-(void)setChrysanthemum{
    [self.HUD show:YES];
}

#pragma mark ----- 瀑布流

-(void)setWaterFallView{
    //layout设置
    HH_waterfallLayout *layout = [[HH_waterfallLayout alloc]init];
    layout.delegate = self;
    CGFloat width = (CGRectGetWidth([UIScreen mainScreen].bounds) - 40) / 3;
    layout.itemSize = CGSizeMake(width, width);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.numberOfColumns = 3;
    layout.lineSpacing = 10;
    
    self.waterFallView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.searchView.frame)) collectionViewLayout:layout];
    self.waterFallView.delegate = self;
    self.waterFallView.dataSource = self;
    
    self.waterFallView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waterFallView];
    [self.waterFallView registerClass:[HH_waterfallViewCell class] forCellWithReuseIdentifier:@"waterfall_cell"];
}

//实现计算高度方法
- (CGFloat)heightForItemByIndexPath:(NSIndexPath *)indexPath {
    
    HH_detailModel *model = self.detailArray[indexPath.row];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 40) / 3;
    //计算图片的实际高度
    
    NSURL *url = [NSURL URLWithString:model.img];// 获取的图片地址
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]]; // 根据地址取出图片
    model.imgHeight = image.size.height;
    model.imgWidth = image.size.width;
    CGFloat height = (width * model.imgHeight) / model.imgWidth;
    return height;
}

//指定一共有多少个Item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.detailArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//指定返回用的cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HH_waterfallViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"waterfall_cell" forIndexPath:indexPath];
    HH_detailModel *model = self.detailArray[indexPath.row];

    cell.model = model;
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HHH_DetailViewController *detailVC = [[HHH_DetailViewController alloc]init];
    HH_detailModel *model = _detailArray[indexPath.row];
    detailVC.ID = model.ID;
    detailVC.passController = YES;
    detailVC.titleStr = self.recipeStr;
    detailVC.modalTransitionStyle = 3;
    [self presentViewController:detailVC animated:YES completion:nil];
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


