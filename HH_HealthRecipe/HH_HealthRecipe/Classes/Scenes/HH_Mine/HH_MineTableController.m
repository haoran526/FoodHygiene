//
//  HH_MineTableController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/22.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_MineTableController.h"
#import "HH_ClearCell.h"
#import "HH_CollectCell.h"
#import "HH_NightCell.h"
#import "AppDelegate.h"
#import "SDImageCache.h"
#import "HH_CollectTableController.h"
#import "DataBase.h"

@interface HH_MineTableController ()
@property(nonatomic,strong)NSArray *dataArr;
@end

@implementation HH_MineTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = @[@"资讯收藏",@"食谱收藏",@"夜间模式",@"清除缓存"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 2) {
        HH_CollectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collect_cell" forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArr[indexPath.row];
        return cell;
    }if (indexPath.row == 2) {
        HH_NightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"night_cell" forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArr[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.nightButton addTarget:self action:@selector(nightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        HH_ClearCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clear_cell" forIndexPath:indexPath];
        cell.titleLabel.text = self.dataArr[indexPath.row];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 3){
        CGFloat fileSize = [self folderSizeAtPath]/1024;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理缓存" message:[NSString stringWithFormat:@"%.2fM",fileSize] preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakS = self;
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [weakS clearCaches];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//计算缓存
- (float)folderSizeAtPath{
    __block NSUInteger size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *diskCachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    dispatch_sync(dispatch_queue_create("caches", NULL), ^{
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
        [[DataBase shareDataBase] removeAllfromDB:@"health"];
        [[DataBase shareDataBase] removeAllfromDB:@"mine"];
    });
    return size/1024;
}

//清理缓存
- (void)clearCaches{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
        [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
}

-(void)clearCacheSuccess{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)nightButtonClick:(UISwitch *)sender{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;
    if (!sender.isOn) {
        window.alpha = 1;
    }else{
        window.alpha = 0.5;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HH_CollectTableController *CTC = segue.destinationViewController;
    NSInteger indexRow = [self.tableView indexPathForSelectedRow].row;
    if (indexRow == 0) {
        CTC.indexRow = 0;
    }else if(indexRow == 1){
        CTC.indexRow = 1;
    }
    
    
}


@end
