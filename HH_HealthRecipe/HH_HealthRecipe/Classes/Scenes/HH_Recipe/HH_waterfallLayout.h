//
//  HH_waterfallLayout.h
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/14.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WaterfallLayoutDelegate <NSObject>

//计算元素的高度
- (CGFloat)heightForItemByIndexPath:(NSIndexPath *)indexPath;

@end


@interface HH_waterfallLayout : UICollectionViewLayout


//元素大小,主要获取宽度
@property (nonatomic,assign) CGSize itemSize;
//section内边距
@property (nonatomic,assign) UIEdgeInsets sectionInset;
//行距
@property (nonatomic,assign) CGFloat lineSpacing;
//列数
@property (nonatomic,assign) NSInteger numberOfColumns;
//代理
@property (nonatomic,weak) id<WaterfallLayoutDelegate> delegate;


@end
