//
//  ENScrollViewLinearLayout.m
//  CreditCardManager
//
//  Created by junfeng.li on 2017/7/11.
//  Copyright © 2017年 Hangzhou Enniu Tech Ltd. All rights reserved.
//

#import "JLLinearLayout.h"

@interface JLLinearLayout ()

@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSMutableDictionary *viewHeightDict;
@property (nonatomic, assign, readwrite) CGFloat contentHeight;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation JLLinearLayout

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        self.viewArray = @[].mutableCopy;
        self.viewHeightDict = @{}.mutableCopy;
        self.contentHeight = 0.0;
        self.enableAnimation = YES;
        self.scrollView = scrollView;
    }
    return self;
}

- (void)addView:(UIView<JFLinearLayoutProtocol> *)view {
    [self insertView:view atIndex:self.viewArray.count];
}

- (void)insertView:(UIView<JFLinearLayoutProtocol> *)view atIndex:(NSInteger)index {
    NSAssert(index <= self.viewArray.count, @"index is greater than viewArray count.");
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    CGFloat height = [self getViewHeight:view];
    if (index == 0) {
        CGFloat yPos = [self getViewTopMargin:view];
        view.frame = CGRectMake(0, yPos, width, height);
    } else {
        UIView<JFLinearLayoutProtocol> *preView = self.viewArray[index - 1];
        CGFloat yPos = CGRectGetMaxY(preView.frame) + [self getViewTopMargin:view];
        view.frame = CGRectMake(0, yPos, width, height);
    }
    [self.scrollView addSubview:view];
    [self.viewArray insertObject:view atIndex:index];
    
    [self updateSubViewsFromIndex:(index + 1)];
}

- (void)removeView:(UIView<JFLinearLayoutProtocol> *)view {
    NSInteger index = [self indexOfView:view];
    [view removeFromSuperview];
    [self.viewArray removeObject:view];
    [self.viewHeightDict removeObjectForKey:[self keyOfView:view]];
    [self updateSubViewsFromIndex:index];
}

- (void)updateView:(UIView<JFLinearLayoutProtocol> *)view withHeight:(CGFloat)height {
    NSString *key = [self keyOfView:view];
    self.viewHeightDict[key] = @(height);
    NSInteger index = [self indexOfView:view];
    [self updateSubViewsFromIndex:index];
}

- (NSInteger)indexOfView:(UIView<JFLinearLayoutProtocol> *)view {
    NSInteger index = [self.viewArray indexOfObject:view];
    NSAssert(index != NSNotFound, @"index == NSNotFound.");
    return index;
}

- (UIView<JFLinearLayoutProtocol> *)viewAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.viewArray.count) {
        return nil;
    } else {
        return self.viewArray[index];
    }
}

- (void)reloadView {
    [self updateSubViewsFromIndex:0];
}

- (void)updateSubViewsFromIndex:(NSInteger)index {
    if (self.enableAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutSubViewsFromIndex:index];
        }];
    } else {
        [self layoutSubViewsFromIndex:index];
    }
}

- (void)layoutSubViewsFromIndex:(NSInteger)index {
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    if (index == 0) {
        UIView<JFLinearLayoutProtocol> *preView = self.viewArray.firstObject;
        CGFloat yPos = [self getViewTopMargin:preView];
        preView.frame = CGRectMake(0, yPos, width, [self getViewHeight:preView]);
        for (NSInteger i = index + 1; i < self.viewArray.count; i++) {
            UIView<JFLinearLayoutProtocol> *currentView = self.viewArray[i];
            CGFloat yPos = CGRectGetMaxY(preView.frame) + [self getViewTopMargin:currentView];
            currentView.frame = CGRectMake(0, yPos, width, [self getViewHeight:currentView]);
            preView = currentView;
        }
    } else {
        UIView<JFLinearLayoutProtocol> *preView = self.viewArray[index - 1];
        for (NSInteger i = index; i < self.viewArray.count; i++) {
            UIView<JFLinearLayoutProtocol> *currentView = self.viewArray[i];
            CGFloat yPos = CGRectGetMaxY(preView.frame) + [self getViewTopMargin:currentView];
            currentView.frame = CGRectMake(0, yPos, width, [self getViewHeight:currentView]);
            preView = currentView;
        }
    }
    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize {
    UIView<JFLinearLayoutProtocol> *lastView = self.viewArray.lastObject;
    self.contentHeight = CGRectGetMaxY(lastView.frame);
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    self.scrollView.contentSize = CGSizeMake(width, self.contentHeight);
}

#pragma mark - Helper

- (CGFloat)getViewHeight:(UIView<JFLinearLayoutProtocol> *)view {
    NSString *key = [self keyOfView:view];
    CGFloat height = 0.0;
    if (self.viewHeightDict[key]) {
        height = [self.viewHeightDict[key] floatValue];
    } else {
        if ([view respondsToSelector:@selector(linearLayoutHeight)]) {
            height = [view linearLayoutHeight];
        }
        self.viewHeightDict[key] = @(height);
    }
    
    return height;
}

- (CGFloat)getViewTopMargin:(UIView<JFLinearLayoutProtocol> *)view {
    CGFloat topMargin = 0.0;
    if ([view respondsToSelector:@selector(linearLayoutTopMargin)]) {
        topMargin = [view linearLayoutTopMargin];
    }
    return topMargin;
}

- (NSString *)keyOfView:(UIView *)view {
    return [NSString stringWithFormat:@"%p", view];
}

#pragma mark - Accessor

- (NSArray *)allViews {
    return self.viewArray.copy;
}

@end

@implementation JLLinearLayout (Subscript)

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self viewAtIndex:idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    return [self insertView:obj atIndex:idx];
}

@end
