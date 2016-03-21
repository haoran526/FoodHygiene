//
//  HH_waterfallLayout.m
//  HH_HealthRecipe
//
//  Created by 惠浩 on 15/12/14.
//  Copyright © 2016年 惠浩. All rights reserved.
//

#import "HH_waterfallLayout.h"

@interface HH_waterfallLayout ()

//用来保存每一列的最小高度
@property (nonatomic,strong) NSMutableArray *columnsHeight;
//共有几个Item
@property (nonatomic,assign) NSInteger numberOfItems;
//保存创建好的Item
@property (nonatomic,strong) NSMutableArray *itemArrtibutes;
//返回最长的那一列的索引
- (NSInteger)indexForLongestColumn;
//返回最短的那一列的索引
- (NSInteger)indexForShortestColumn;

@end

@implementation HH_waterfallLayout

- (NSMutableArray *)columnsHeight {
    if (_columnsHeight == nil) {
        _columnsHeight = [NSMutableArray array];
    }
    return _columnsHeight;
}

- (NSMutableArray *)itemArrtibutes {
    if (!_itemArrtibutes) {
        _itemArrtibutes = [NSMutableArray array];
    }
    return _itemArrtibutes;
}


//返回最长的那一列的索引
- (NSInteger)indexForLongestColumn{
    //默认最长的索引是第0列
    NSInteger index = 0;
    //默认的最长列的长度是0
    CGFloat length = 0;
    for (int i = 0; i < self.numberOfColumns; i++) {
        if ([self.columnsHeight[i] floatValue] > length) {
            length = [self.columnsHeight[i] floatValue];
            index = i;
        }
    }
    return index;
}
//返回最短的那一列的索引
- (NSInteger)indexForShortestColumn{
    NSInteger index = 0;
    CGFloat length = CGFLOAT_MAX;
    for (int i = 0; i < self.numberOfColumns; i++) {
        if ([self.columnsHeight[i] floatValue] < length) {
            length = [self.columnsHeight[i] floatValue];
            index = i;
        }
    }
    return index;
}

//计算Item的大小和位置
- (void)prepareLayout {
    [super prepareLayout];
    //存放高度的数组，给每列初始一个高度
    for (int i = 0; i < self.numberOfColumns; i++) {
        self.columnsHeight[i] = @(self.sectionInset.top);
    }
    //获取所有的Item的数量
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
    //遍历Item,为每一个Item计算大小和位置
    for (int i = 0; i < self.numberOfItems; i++) {
        //Y坐标 = 列高度 + 行间距
        NSInteger shortIndex = [self indexForShortestColumn];
        CGFloat pointY = [self.columnsHeight[shortIndex] floatValue] + self.lineSpacing;
        //X坐标 = 左边距 + 列索引 * (列宽 + 列间距)
        CGFloat pointX = self.sectionInset.left + shortIndex * (self.itemSize.width + self.lineSpacing);
        //创建对应的indexPath
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //创建Item属性对象,用来保存所有计算出来的信息
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        //设置属性信息
        //通过代理计算Item的高度
        CGFloat itemHeight = 0;
        //判断代理是否为空,给代理的对应的方法发送消息看是否有回应
        if (_delegate && [_delegate respondsToSelector:@selector(heightForItemByIndexPath:)]) {
            itemHeight = [_delegate heightForItemByIndexPath:indexPath]+36;
        }
        //设置frame
        attribute.frame = CGRectMake(pointX, pointY, self.itemSize.width, itemHeight);
        //把计算好的Item放入到数组中,备用
        [self.itemArrtibutes addObject:attribute];
        //更新对应column的高度
        self.columnsHeight[shortIndex] = @(pointY + itemHeight);
    }
}

//2.设置contentView的大小
- (CGSize)collectionViewContentSize {
    //找到最长列的索引
    NSInteger longestIndex = self.indexForLongestColumn;
    //根据索引找到最长列的高度
    CGFloat height = [self.columnsHeight[longestIndex] floatValue] + self.sectionInset.bottom;
    CGSize contentSize = self.collectionView.frame.size;
    contentSize.height = height;
    return contentSize;
}

//3.求取所有的Attribute
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    //返回所有的Item属性
    return self.itemArrtibutes;
}



@end
