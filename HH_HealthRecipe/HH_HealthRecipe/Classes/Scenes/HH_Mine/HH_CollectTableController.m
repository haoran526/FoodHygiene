//
//  HH_CollectTableController.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/22.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_CollectTableController.h"
#import "HomeModel.h"
#import "HH_detailModel.h"
#import "HH_DetailViewController.h"
#import "DataBase.h"
@interface HH_CollectTableController ()

@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation HH_CollectTableController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.indexRow == 0) {
        self.dataArr = [[DataBase shareDataBase] selectHealth].mutableCopy;
    }else{
        self.dataArr = [[DataBase shareDataBase] select].mutableCopy;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.indexRow == 0) {
        self.navigationItem.title = @"知识收藏";
    }else if(self.indexRow == 1){
        self.navigationItem.title = @"食谱收藏";
    }
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell_id"];
}

- (IBAction)leftBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_id" forIndexPath:indexPath];
    if (self.indexRow ==0) {
        HomeModel *model = self.dataArr[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = model.title;
    }else if(self.indexRow == 1){
        HH_detailModel *model = self.dataArr[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = model.name;
    }
    return cell;
}

//左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据库里的
        NSString *strID = [self.dataArr[indexPath.row] ID];
        NSString *strDB = [NSString string];
        if (self.indexRow == 0) {
            strDB = @"health";
        }else{
            strDB = @"mine";
        }
        [[DataBase shareDataBase] remove:strID fromDB:strDB];
        
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HH_DetailViewController *DVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (self.indexRow == 0) {
        HomeModel *model = self.dataArr[indexPath.row];
        DVC.strID = model.ID;
        DVC.strDB = @"health";
        DVC.messageStr = model.message;
    }else if (self.indexRow == 1){
        HH_detailModel *model = self.dataArr[indexPath.row];
        DVC.strID = model.ID;
        DVC.strDB = @"mine";
        DVC.messageStr = model.message;
    }
}


@end
