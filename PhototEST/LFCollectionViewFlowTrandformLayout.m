//
//  LFCollectionViewFlowTrandformLayout.m
//  PhototEST
//
//  Created by macliu on 2021/4/2.
//

#import "LFCollectionViewFlowTrandformLayout.h"

@implementation LFCollectionViewFlowTrandformLayout


- (void)prepareLayout {
    [super prepareLayout];
    
   // self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
       // 修改内边距（让第一个和最后一个cell能居中）
  //  CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
  //  self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
    
    

}


// 作用:指定一段区域给你这段区域内cell的尺寸
// 可以一次性返回所有cell尺寸,也可以每隔一个距离返回cell
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
//    NSLog(@"%s",__func__);
    // 设置cell尺寸 => UICollectionViewLayoutAttributes
    // 越靠近中心点,距离越小,缩放越大
    // 求cell与中心点距离
    
    // 1.获取当前显示cell的布局
    NSArray *attrs = [super layoutAttributesForElementsInRect:self.collectionView.bounds];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        
        // 2.计算中心点距离
      CGFloat delta = fabs((attr.center.x - self.collectionView.contentOffset.x) - self.collectionView.bounds.size.width * 0.5);
        
        // 3.计算比例
        CGFloat scale = 1 - delta / (self.collectionView.bounds.size.width * 0.5) * 0.25;
        
        attr.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    return attrs;
}
//防止报错 先复制attributes
- (NSArray *)getCopyOfAttributes:(NSArray *)attributes
{
    NSMutableArray *copyArr = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [copyArr addObject:[attribute copy]];
    }
    return copyArr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

// 什么时候调用:用户手指一松开就会调用
// 作用:确定最终偏移量
// 定位:距离中心点越近,这个cell最终展示到中心点
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{

    // 拖动比较快 最终偏移量 不等于 手指离开时偏移量
    CGFloat collectionW = self.collectionView.bounds.size.width;
    
    // 最终偏移量
    CGPoint targetP = [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    
    // 0.获取最终显示的区域
    CGRect targetRect = CGRectMake(targetP.x, 0, collectionW, MAXFLOAT);
    
     // 1.获取最终显示的cell
    NSArray *attrs = [super layoutAttributesForElementsInRect:targetRect];
    
    // 获取最小间距
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        // 获取距离中心点距离:注意:应该用最终的x
        CGFloat delta = (attr.center.x - targetP.x) - self.collectionView.bounds.size.width * 0.5;
        
        if (fabs(delta) < fabs(minDelta)) {
            minDelta = delta;
        }
    }

    // 移动间距
    targetP.x += minDelta;
    
    if (targetP.x < 0) {
        targetP.x = 0;
    }
    
    return targetP;
}


@end
