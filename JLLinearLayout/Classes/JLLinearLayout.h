//
//  ENScrollViewLinearLayout.h
//  CreditCardManager
//
//  Created by junfeng.li on 2017/7/11.
//  Copyright © 2017年 Hangzhou Enniu Tech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFLinearLayoutProtocol <NSObject>

@required

// 用来设置视图的高度
- (CGFloat)linearLayoutHeight;

@optional

// 用来设置视图顶部离上面视图底部的距离
- (CGFloat)linearLayoutTopMargin;

@end

@interface JLLinearLayout : NSObject

@property (nonatomic, assign) BOOL enableAnimation;
@property (readonly, copy) NSArray *allViews;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

- (void)addView:(UIView<JFLinearLayoutProtocol> *)view;
- (void)insertView:(UIView<JFLinearLayoutProtocol> *)view atIndex:(NSInteger)index;

- (void)removeView:(UIView<JFLinearLayoutProtocol> *)view;

- (void)updateView:(UIView<JFLinearLayoutProtocol> *)view withHeight:(CGFloat)height;

- (NSInteger)indexOfView:(UIView<JFLinearLayoutProtocol> *)view;
- (UIView<JFLinearLayoutProtocol> *)viewAtIndex:(NSInteger)index;

- (void)reloadView;

@end

@interface JLLinearLayout (Subscript)

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end
