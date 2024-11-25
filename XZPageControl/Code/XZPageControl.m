//
//  XZPageControl.m
//  XZKit
//
//  Created by Xezun on 2021/9/13.
//

#import "XZPageControl.h"
#import "XZPageControlAttributes.h"
#import "XZPageControlIndicatorItem.h"

@interface XZPageControl ()
@end

@implementation XZPageControl {
    /// 记录指示器默认样式的对象。
    XZPageControlAttributes *_defaultAttributes;
    NSMutableArray<XZPageControlIndicatorItem *> *_indicatorItems;
}

- (instancetype)initWithFrame:(CGRect)frame orientation:(XZPageControlOrientation)orientation {
    self = [self initWithFrame:frame];
    if (self) {
        _orientation = orientation;
    }
    return self;
}

- (instancetype)initWithOrientation:(XZPageControlOrientation)orientation {
    return [self initWithFrame:(CGRectZero) orientation:orientation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self XZPageControlDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZPageControlDidInitialize];
    }
    return self;
}

- (void)XZPageControlDidInitialize {
    super.hidden = YES;
    super.contentMode = UIViewContentModeCenter;
    
    _hidesForSinglePage      = YES;
    _maximumIndicatorSpacing = 30.0;
    _indicatorItems          = [NSMutableArray array];
    _defaultAttributes       = nil;
    _currentPage             = 0;
}

- (XZPageControlAttributes *)defaultAttributes {
    if (_defaultAttributes == nil) {
        _defaultAttributes = [[XZPageControlAttributes alloc] init];
    }
    return _defaultAttributes;
}

@dynamic contentMode;

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self setNeedsLayout];
}

// MARK: - Tracking

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    if (!self.isTouchInside || _indicatorItems.count < 2) {
        return;
    }
    
    CGPoint    const point = [touch locationInView:self];
    NSUInteger const count = _indicatorItems.count;
    
    switch (self.orientation) {
        case XZPageControlOrientationHorizontal: {
            BOOL const isLTR = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
            
            // 点击左边减小页数
            if ( (isLTR && point.x < CGRectGetMinX(_indicatorItems.firstObject.frame)) || (!isLTR && point.x > CGRectGetMaxX(_indicatorItems.firstObject.frame)) ) {
                if (_currentPage > 0) {
                    [self XZPageControlSetCurrentPage:_currentPage - 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            
            // 点击右边增加页数
            if ( (isLTR && point.x > CGRectGetMaxX(_indicatorItems.lastObject.frame)) || (!isLTR && point.x < CGRectGetMinX(_indicatorItems.lastObject.frame)) ) {
                if (_currentPage < _indicatorItems.count - 1) {
                    [self XZPageControlSetCurrentPage:_currentPage + 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            break;
        }
        case XZPageControlOrientationVertical: {
            // 点击上边减小页数
            if ( point.y < CGRectGetMinY(_indicatorItems.firstObject.frame) ) {
                if (_currentPage > 0) {
                    [self XZPageControlSetCurrentPage:_currentPage - 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            
            // 点击下边增加页数
            if ( point.y > CGRectGetMaxY(_indicatorItems.lastObject.frame) ) {
                if (_currentPage < _indicatorItems.count - 1) {
                    [self XZPageControlSetCurrentPage:_currentPage + 1 animated:YES sendsEvents:YES];
                }
                return;
            }
            break;
        }
    }
    
    // 点击了指定页面
    for (NSInteger i = 0; i < count; i++) {
        if (CGRectContainsPoint(_indicatorItems[i].frame, point)) {
            [self XZPageControlSetCurrentPage:i animated:YES sendsEvents:YES];
            break;
        }
    }
}

- (void)layoutMarginsDidChange {
    [super layoutMarginsDidChange];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSUInteger const count = _indicatorItems.count;
    if (count == 0) {
        return;
    }
    
    switch (self.orientation) {
        case XZPageControlOrientationHorizontal: {
            CGRect  const bounds = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
            CGFloat const width  = MIN(_maximumIndicatorSpacing, bounds.size.width / count);
            CGFloat __block x    = 0;
            
            // 根据 contentMode 确定布局起点。
            switch (self.contentMode) {
                case UIViewContentModeLeft:
                case UIViewContentModeTop:
                    x = CGRectGetMinX(bounds);
                    break;
                case UIViewContentModeRight:
                case UIViewContentModeBottom:
                    x = CGRectGetMaxX(bounds) - width * count;
                    break;
                default:
                    x = CGRectGetMinX(bounds) + (bounds.size.width - width * count) * 0.5;
                    break;
            }
            
            // 根据布局方向，逐个排列指示器。
            switch (self.effectiveUserInterfaceLayoutDirection) {
                case UIUserInterfaceLayoutDirectionLeftToRight:
                    [_indicatorItems enumerateObjectsUsingBlock:^(XZPageControlIndicatorItem *indicator, NSUInteger idx, BOOL *stop) {
                        indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                        x += width;
                    }];
                    break;
                    
                case UIUserInterfaceLayoutDirectionRightToLeft:
                    [_indicatorItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZPageControlIndicatorItem *indicator, NSUInteger idx, BOOL *stop) {
                        indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                        x += width;
                    }];
                    break;
            }
            break;
        }
            
        case XZPageControlOrientationVertical: {
            CGRect  const bounds = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
            CGFloat const height = MIN(_maximumIndicatorSpacing, bounds.size.height / count);
            CGFloat __block y    = 0;
            
            // 根据 contentMode 确定布局起点。
            switch (self.contentMode) {
                case UIViewContentModeLeft:
                case UIViewContentModeTop:
                    y = CGRectGetMinY(bounds);
                    break;
                case UIViewContentModeRight:
                case UIViewContentModeBottom:
                    y = CGRectGetMaxY(bounds) - height * count;
                    break;
                default:
                    y = CGRectGetMinY(bounds) + (bounds.size.height - height * count) * 0.5;
                    break;
            }
            
            // 根据布局方向，逐个排列指示器。
            [_indicatorItems enumerateObjectsUsingBlock:^(XZPageControlIndicatorItem *indicator, NSUInteger idx, BOOL *stop) {
                indicator.frame = CGRectMake(bounds.origin.x, y, bounds.size.width, height);
                y += height;
            }];
            break;
        }
    }
}

#pragma mark - Public Methods

- (void)setOrientation:(XZPageControlOrientation)orientation {
    if (_orientation != orientation) {
        _orientation = orientation;
        [self setNeedsLayout];
    }
}

- (NSInteger)numberOfPages {
    return _indicatorItems.count;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_indicatorItems.count != numberOfPages) {
        if (numberOfPages == 0) {
            [self XZPageControlSetCurrentPage:0 animated:NO sendsEvents:NO];
            [_indicatorItems removeAllObjects];
        } else {
            // 同步数量
            for (NSInteger i = _indicatorItems.count; i < numberOfPages; i++) {
                XZPageControlIndicatorItem *item = [XZPageControlIndicatorItem itemForPageControl:self attributes:_defaultAttributes.copy];
                [item setCurrent:(i == _currentPage) animated:NO];
                [_indicatorItems addObject:item];
            }
            for (NSInteger i = _indicatorItems.count - 1; i >= numberOfPages; i--) {
                [_indicatorItems removeObjectAtIndex:i];
            }
            
            // 修正当前指示器
            if (_currentPage >= numberOfPages) {
                [self XZPageControlSetCurrentPage:numberOfPages - 1 animated:NO sendsEvents:NO];
            }
        }
        
        self.hidden = (_hidesForSinglePage && numberOfPages <= 1);
        
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSParameterAssert(currentPage >= 0 && currentPage < _indicatorItems.count);
    [self XZPageControlSetCurrentPage:currentPage animated:animated sendsEvents:NO];
}

- (void)setTransition:(CGFloat)transition {
    [self setTransition:transition isLooped:NO];
}

- (void)setTransition:(CGFloat)transition isLooped:(BOOL)isLooped {
    NSUInteger const numberOfPages = _indicatorItems.count;
    if (transition > 0) {
        _indicatorItems[_currentPage].transition = transition;
        if (_currentPage < numberOfPages - 1) {
            _indicatorItems[_currentPage + 1].transition = transition;
        } else if (isLooped) {
            _indicatorItems[0].transition = transition;
        }
    } else if (transition < 0) {
        _indicatorItems[_currentPage].transition = -transition;
        if (_currentPage > 0) {
            _indicatorItems[_currentPage - 1].transition = -transition;
        } else if (isLooped) {
            _indicatorItems[numberOfPages - 1].transition = -transition;
        }
    }
}

- (CGFloat)transition {
    if (_currentPage < _indicatorItems.count - 1) {
        return _indicatorItems[_currentPage].transition;
    }
    return 0;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        _hidesForSinglePage = hidesForSinglePage;
        
        self.hidden = (_hidesForSinglePage && _indicatorItems.count <= 1);
    }
}

- (void)setMaximumIndicatorSpacing:(CGFloat)maximumIndicatorSpacing {
    if (_maximumIndicatorSpacing != maximumIndicatorSpacing) {
        _maximumIndicatorSpacing = MAX(0, maximumIndicatorSpacing);
        [self setNeedsLayout];
    }
}

#pragma mark - 全局样式.StrokeColor

- (UIColor *)indicatorStrokeColor {
    return _defaultAttributes.strokeColor;
}

- (void)setIndicatorStrokeColor:(UIColor *)indicatorStrokeColor {
    self.defaultAttributes.strokeColor = indicatorStrokeColor;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.strokeColor = indicatorStrokeColor;
    }
}

- (UIColor *)currentIndicatorStrokeColor {
    return _defaultAttributes.currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(UIColor *)currentIndicatorStrokeColor {
    self.defaultAttributes.currentStrokeColor = currentIndicatorStrokeColor;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.currentStrokeColor = currentIndicatorStrokeColor;
    }
}

#pragma mark - 全局样式.FillColor

- (UIColor *)indicatorFillColor {
    return _defaultAttributes.fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorFillColor {
    self.defaultAttributes.fillColor = indicatorFillColor;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.fillColor = indicatorFillColor;
    }
}

- (UIColor *)currentIndicatorFillColor {
    return _defaultAttributes.currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorFillColor {
    self.defaultAttributes.currentFillColor = currentIndicatorFillColor;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.currentFillColor = currentIndicatorFillColor;
    }
}

#pragma mark - 全局样式.Shape

- (UIBezierPath *)indicatorShape {
    return _defaultAttributes.shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape {
    self.defaultAttributes.shape = indicatorShape;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.shape = indicatorShape;
    }
}

- (UIBezierPath *)currentIndicatorShape {
    return _defaultAttributes.currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape {
    self.defaultAttributes.currentShape = currentIndicatorShape;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.currentShape = currentIndicatorShape;
    }
}

#pragma mark - 全局样式.Image

- (UIImage *)indicatorImage {
    return _defaultAttributes.image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    self.defaultAttributes.image = indicatorImage;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.image = indicatorImage;
    }
}

- (UIImage *)currentIndicatorImage {
    return _defaultAttributes.currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage {
    self.defaultAttributes.currentImage = currentIndicatorImage;
    for (XZPageControlIndicatorItem *indicator in _indicatorItems) {
        indicator.currentImage = currentIndicatorImage;
    }
}

#pragma mark - 独立样式.StrokeColor

- (UIColor *)indicatorStrokeColorForPage:(NSInteger)page {
    return _indicatorItems[page].strokeColor;
}

- (void)setIndicatorStrokeColor:(nullable UIColor *)indicatorColor forPage:(NSInteger)page {
    _indicatorItems[page].strokeColor = indicatorColor;
}

- (UIColor *)currentIndicatorStrokeColorForPage:(NSInteger)page {
    return _indicatorItems[page].currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(nullable UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _indicatorItems[page].currentStrokeColor = currentIndicatorColor;
}

#pragma mark - 独立样式.FillColor

- (UIColor *)indicatorFillColorForPage:(NSInteger)page {
    return _indicatorItems[page].fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorColor forPage:(NSInteger)page {
    _indicatorItems[page].fillColor = indicatorColor;
}

- (UIColor *)currentIndicatorFillColorForPage:(NSInteger)page {
    return _indicatorItems[page].currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _indicatorItems[page].currentFillColor = currentIndicatorColor;
}

#pragma mark - 独立样式.Shape

- (UIBezierPath *)indicatorShapeForPage:(NSInteger)page {
    return _indicatorItems[page].shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape forPage:(NSInteger)page {
    _indicatorItems[page].shape = indicatorShape;
}

- (UIBezierPath *)currentIndicatorShapeForPage:(NSInteger)page {
    return _indicatorItems[page].currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape forPage:(NSInteger)page {
    _indicatorItems[page].currentShape = currentIndicatorShape;
}

#pragma mark - 独立样式.Image

- (UIImage *)indicatorImageForPage:(NSInteger)page {
    return _indicatorItems[page].image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage forPage:(NSInteger)page {
    _indicatorItems[page].image = indicatorImage;
}

- (UIImage *)currentIndicatorImageForPage:(NSInteger)page {
    return _indicatorItems[page].currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage forPage:(NSInteger)page {
    _indicatorItems[page].currentImage = currentIndicatorImage;
}

#pragma mark - 自定义样式

- (UIView<XZPageControlIndicator> *)indicatorForPage:(NSInteger)page {
    return _indicatorItems[page].view;
}

- (void)setIndicator:(UIView<XZPageControlIndicator> *)indicator forPage:(NSInteger)page {
    _indicatorItems[page].view = indicator;
}

#pragma mark - Private Methods

- (void)XZPageControlSetCurrentPage:(NSInteger)currentPage animated:(BOOL)animated sendsEvents:(BOOL)sendsEvents {
    if (_currentPage != currentPage) {
        if (_currentPage < _indicatorItems.count) {
            [_indicatorItems[_currentPage] setCurrent:NO animated:animated];
        }
        _currentPage = currentPage;
        if (_currentPage < _indicatorItems.count) {
            [_indicatorItems[_currentPage] setCurrent:YES animated:animated];
        }
        if (sendsEvents) {
            [self sendActionsForControlEvents:(UIControlEventValueChanged)];
        }
    }
}

@end
