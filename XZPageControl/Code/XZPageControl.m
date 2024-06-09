//
//  XZPageControl.m
//  XZKit
//
//  Created by Xezun on 2021/9/13.
//

#import "XZPageControl.h"
#import <XZShapeView/XZShapeView.h>

@interface XZPageControlAttributes : NSObject <NSCopying, XZPageControlIndicator>
@end

@interface XZPageControlItem : NSObject <XZPageControlIndicator>
@property (nonatomic) CGRect frame;
@property (nonatomic, setter=setCurrent:) BOOL isCurrent;
// XZPageControl 应避免操作此视图。
@property (nonatomic, strong) UIView<XZPageControlIndicator> *view;
@property (nonatomic, strong, readonly) XZPageControlAttributes *attributes;
+ (XZPageControlItem *)itemForPageControl:(XZPageControl *)pageControl attributes:(XZPageControlAttributes *)attributes;
@end

@interface XZPageControl ()
@end

@implementation XZPageControl {
    XZPageControlAttributes *_defaultAttributes;
    NSMutableArray<XZPageControlItem *> *_items;
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
    
    _hidesForSinglePage = YES;
    _maximumIndicatorSpacing = 30.0;

    _items = [NSMutableArray array];
    _defaultAttributes = nil;
    _numberOfPages = 0;
    _currentPage   = 0;
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
    
    if (!self.isTouchInside || _numberOfPages < 2) {
        return;
    }
    
    BOOL       const isLeftLayout = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGPoint    const point        = [touch locationInView:self];
    NSUInteger const count        = _items.count;
    
    // 点击左边减小页数
    if ( (isLeftLayout && point.x < CGRectGetMinX(_items.firstObject.frame)) || (!isLeftLayout && point.x > CGRectGetMinX(_items.firstObject.frame)) ) {
        if (_currentPage > 0) {
            [self XZPageControlSetCurrentPage:_currentPage - 1 sendsEvents:YES];
        }
        return;
    }
    
    // 点击右边增加页数
    if ( (isLeftLayout && point.x > CGRectGetMaxX(_items.lastObject.frame)) || (!isLeftLayout && point.x < CGRectGetMaxX(_items.lastObject.frame)) ) {
        if (_currentPage < _numberOfPages - 1) {
            [self XZPageControlSetCurrentPage:_currentPage + 1 sendsEvents:YES];
        }
        return;
    }
    
    // 点击了指定页面
    for (NSInteger i = 0; i < count; i++) {
        if (CGRectContainsPoint(_items[i].frame, point)) {
            [self XZPageControlSetCurrentPage:i sendsEvents:YES];
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

    NSUInteger const count = _items.count;
    if (count == 0) {
        return;
    }
    
    CGRect  const bounds = UIEdgeInsetsInsetRect(self.bounds, self.layoutMargins);
    CGFloat const width  = MIN(_maximumIndicatorSpacing, bounds.size.width / count);
    CGFloat __block x    = 0;
    
    // 根据 contentMode 确定布局起点。
    switch (self.contentMode) {
        case UIViewContentModeLeft:
            x = CGRectGetMinX(bounds);
            break;
        case UIViewContentModeRight:
            x = CGRectGetMaxX(bounds) - width * count;
            break;
        default:
            x = CGRectGetMinX(bounds) + (bounds.size.width - width * count) * 0.5;
            break;
    }
    
    // 根据布局方向，逐个排列指示器。
    switch (self.effectiveUserInterfaceLayoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            [_items enumerateObjectsUsingBlock:^(XZPageControlItem *indicator, NSUInteger idx, BOOL *stop) {
                indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                x += width;
            }];
            break;
            
        case UIUserInterfaceLayoutDirectionRightToLeft:
            [_items enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZPageControlItem *indicator, NSUInteger idx, BOOL *stop) {
                indicator.frame = CGRectMake(x, bounds.origin.y, width, bounds.size.height);
                x += width;
            }];
            break;
        default:
            break;
    }
}

#pragma mark - Public Methods

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        
        if (_numberOfPages == 0) {
            [self XZPageControlSetCurrentPage:0 sendsEvents:NO];
            [_items removeAllObjects];
        } else {
            // 同步数量
            for (NSInteger i = _items.count; i < _numberOfPages; i++) {
                XZPageControlItem *item = [XZPageControlItem itemForPageControl:self attributes:_defaultAttributes.copy];
                item.isCurrent = (i == _currentPage);
                [_items addObject:item];
            }
            for (NSInteger i = _items.count - 1; i >= _numberOfPages; i--) {
                [_items removeObjectAtIndex:i];
            }
            
            // 修正当前指示器
            if (_currentPage >= _numberOfPages) {
                [self XZPageControlSetCurrentPage:_numberOfPages - 1 sendsEvents:NO];
            }
        }
        
        self.hidden = (_hidesForSinglePage && _numberOfPages <= 1);
        
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    NSParameterAssert(currentPage >= 0 && currentPage < _numberOfPages);
    [self XZPageControlSetCurrentPage:currentPage sendsEvents:NO];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        _hidesForSinglePage = hidesForSinglePage;
        
        self.hidden = (_hidesForSinglePage && _numberOfPages <= 1);
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
    for (XZPageControlItem *indicator in _items) {
        indicator.strokeColor = indicatorStrokeColor;
    }
}

- (UIColor *)currentIndicatorStrokeColor {
    return _defaultAttributes.currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(UIColor *)currentIndicatorStrokeColor {
    self.defaultAttributes.currentStrokeColor = currentIndicatorStrokeColor;
    for (XZPageControlItem *indicator in _items) {
        indicator.currentStrokeColor = currentIndicatorStrokeColor;
    }
}

#pragma mark - 全局样式.FillColor

- (UIColor *)indicatorFillColor {
    return _defaultAttributes.fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorFillColor {
    self.defaultAttributes.fillColor = indicatorFillColor;
    for (XZPageControlItem *indicator in _items) {
        indicator.fillColor = indicatorFillColor;
    }
}

- (UIColor *)currentIndicatorFillColor {
    return _defaultAttributes.currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorFillColor {
    self.defaultAttributes.currentFillColor = currentIndicatorFillColor;
    for (XZPageControlItem *indicator in _items) {
        indicator.currentFillColor = currentIndicatorFillColor;
    }
}

#pragma mark - 全局样式.Shape

- (UIBezierPath *)indicatorShape {
    return _defaultAttributes.shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape {
    self.defaultAttributes.shape = indicatorShape;
    for (XZPageControlItem *indicator in _items) {
        indicator.shape = indicatorShape;
    }
}

- (UIBezierPath *)currentIndicatorShape {
    return _defaultAttributes.currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape {
    self.defaultAttributes.currentShape = currentIndicatorShape;
    for (XZPageControlItem *indicator in _items) {
        indicator.currentShape = currentIndicatorShape;
    }
}

#pragma mark - 全局样式.Image

- (UIImage *)indicatorImage {
    return _defaultAttributes.image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    self.defaultAttributes.image = indicatorImage;
    for (XZPageControlItem *indicator in _items) {
        indicator.image = indicatorImage;
    }
}

- (UIImage *)currentIndicatorImage {
    return _defaultAttributes.currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage {
    self.defaultAttributes.currentImage = currentIndicatorImage;
    for (XZPageControlItem *indicator in _items) {
        indicator.currentImage = currentIndicatorImage;
    }
}

#pragma mark - 独立样式.StrokeColor

- (UIColor *)indicatorStrokeColorForPage:(NSInteger)page {
    return _items[page].strokeColor;
}

- (void)setIndicatorStrokeColor:(nullable UIColor *)indicatorColor forPage:(NSInteger)page {
    _items[page].strokeColor = indicatorColor;
}

- (UIColor *)currentIndicatorStrokeColorForPage:(NSInteger)page {
    return _items[page].currentStrokeColor;
}

- (void)setCurrentIndicatorStrokeColor:(nullable UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _items[page].currentStrokeColor = currentIndicatorColor;
}

#pragma mark - 独立样式.FillColor

- (UIColor *)indicatorFillColorForPage:(NSInteger)page {
    return _items[page].fillColor;
}

- (void)setIndicatorFillColor:(UIColor *)indicatorColor forPage:(NSInteger)page {
    _items[page].fillColor = indicatorColor;
}

- (UIColor *)currentIndicatorFillColorForPage:(NSInteger)page {
    return _items[page].currentFillColor;
}

- (void)setCurrentIndicatorFillColor:(UIColor *)currentIndicatorColor forPage:(NSInteger)page {
    _items[page].currentFillColor = currentIndicatorColor;
}

#pragma mark - 独立样式.Shape

- (UIBezierPath *)indicatorShapeForPage:(NSInteger)page {
    return _items[page].shape;
}

- (void)setIndicatorShape:(UIBezierPath *)indicatorShape forPage:(NSInteger)page {
    _items[page].shape = indicatorShape;
}

- (UIBezierPath *)currentIndicatorShapeForPage:(NSInteger)page {
    return _items[page].currentShape;
}

- (void)setCurrentIndicatorShape:(UIBezierPath *)currentIndicatorShape forPage:(NSInteger)page {
    _items[page].currentShape = currentIndicatorShape;
}

#pragma mark - 独立样式.Image

- (UIImage *)indicatorImageForPage:(NSInteger)page {
    return _items[page].image;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage forPage:(NSInteger)page {
    _items[page].image = indicatorImage;
}

- (UIImage *)currentIndicatorImageForPage:(NSInteger)page {
    return _items[page].currentImage;
}

- (void)setCurrentIndicatorImage:(UIImage *)currentIndicatorImage forPage:(NSInteger)page {
    _items[page].currentImage = currentIndicatorImage;
}

#pragma mark - 自定义样式

- (UIView<XZPageControlIndicator> *)indicatorForPage:(NSInteger)page {
    return _items[page].view;
}

- (void)setIndicator:(UIView<XZPageControlIndicator> *)indicator forPage:(NSInteger)page {
    _items[page].view = indicator;
}

#pragma mark - Private Methods

- (void)XZPageControlSetCurrentPage:(NSInteger)currentPage sendsEvents:(BOOL)sendsEvents {
    if (_currentPage != currentPage) {
        if (_currentPage < _items.count) {
            _items[_currentPage].isCurrent = NO;
        }
        _currentPage = currentPage;
        if (_currentPage < _items.count) {
            _items[_currentPage].isCurrent = YES;
        }
        if (sendsEvents) {
            [self sendActionsForControlEvents:(UIControlEventValueChanged)];
        }
    }
}

@end


@interface XZPageControlIndicator : UIView <XZPageControlIndicator>
@end

@implementation XZPageControlIndicator {
    UIImageView *_imageView;
    XZShapeView *_shapeView;
    BOOL _needsUpdate;
}

@synthesize isCurrent = _isCurrent;

@synthesize fillColor = _fillColor;
@synthesize currentFillColor = _currentFillColor;

@synthesize strokeColor = _strokeColor;
@synthesize currentStrokeColor = _currentStrokeColor;

@synthesize shape = _shape;
@synthesize currentShape = _currentShape;

@synthesize image = _image;
@synthesize currentImage = _currentImage;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _needsUpdate = NO;
        [self setNeedsUpdate];
    }
    return self;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if ([_strokeColor isEqual:strokeColor]) {
        return;
    }
    _strokeColor = strokeColor;
    if (_isCurrent) {
        return;
    }
    [self setNeedsUpdate];
}

- (void)setCurrentStrokeColor:(UIColor *)currentStrokeColor {
    if ([_currentStrokeColor isEqual:currentStrokeColor]) {
        return;
    }
    _currentStrokeColor = currentStrokeColor;
    if (_isCurrent) {
        [self setNeedsUpdate];
    }
}

- (UIColor *)fillColor {
    if (_fillColor == nil) {
        _fillColor = UIColor.grayColor;
    }
    return _fillColor;
}

- (void)setFillColor:(UIColor *)fillColor {
    if ([_fillColor isEqual:fillColor]) {
        return;
    }
    _fillColor = fillColor;
    if (_isCurrent) {
        return;
    }
    [self setNeedsUpdate];
}

- (UIColor *)currentFillColor {
    if (_currentFillColor == nil) {
        _currentFillColor = UIColor.whiteColor;
    }
    return _currentFillColor;
}

- (void)setCurrentFillColor:(UIColor *)currentColor {
    if ([_currentFillColor isEqual:currentColor]) {
        return;
    }
    _currentFillColor = currentColor;
    if (_isCurrent) {
        [self setNeedsUpdate];
    }
}

- (UIBezierPath *)shape {
    if (_shape == nil) {
        _shape = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 6.0, 6.0)];
    }
    return _shape;
}

- (void)setShape:(UIBezierPath *)shape {
    if ([_shape isEqual:shape]) {
        return;
    }
    _shape = shape.copy;
    if (_isCurrent) {
        return;
    }
    [self setNeedsUpdate];
}

- (UIBezierPath *)currentShape {
    if (_currentShape == nil) {
        _currentShape = self.shape;
    }
    return _currentShape;
}

- (void)setCurrentShape:(UIBezierPath *)currentShape {
    if ([_currentShape isEqual:currentShape]) {
        return;
    }
    _currentShape = currentShape.copy;
    if (_isCurrent) {
        [self setNeedsUpdate];
    }
}

- (void)setImage:(UIImage *)image {
    if ([_image isEqual:image]) {
        return;
    }
    _image = image;
    if (_isCurrent) {
        return;
    }
    [self setNeedsUpdate];
}

- (void)setCurrent:(BOOL)isCurrent {
    if (_isCurrent != isCurrent) {
        _isCurrent = isCurrent;
        [self setNeedsUpdate];
    }
}

- (void)setNeedsUpdate {
    if (_needsUpdate) {
        return;
    }
    _needsUpdate = YES;
    
    typeof(self) __weak wself = self;
    [NSRunLoop.mainRunLoop performBlock:^{
        [wself updateIfNeeded];
    }];
}

- (void)updateIfNeeded {
    if (!_needsUpdate) {
        return;
    }
    _needsUpdate = NO;
    
    if (self.isCurrent) {
        if (self.currentImage == nil) {
            [self reloadShape:self.currentShape fillColor:self.currentFillColor strokeColor:self.currentStrokeColor];
        } else {
            [self reloadImage:self.currentImage];
        }
    } else {
        if (self.image == nil) {
            [self reloadShape:self.shape fillColor:self.fillColor strokeColor:self.strokeColor];
        } else {
            [self reloadImage:self.image];
        }
    }
}

- (void)reloadImage:(UIImage *)image {
    _shapeView.hidden = YES;
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_imageView];
    }
    _imageView.image = image;
    
    CGSize const size = [self intrinsicContentSizeForImage:image];
    _imageView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)reloadShape:(UIBezierPath *)shape fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    _imageView.hidden = YES;
    
    if (_shapeView == nil) {
        _shapeView = [[XZShapeView alloc] initWithFrame:self.bounds];
        _shapeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_shapeView];
    }
    
    CGPathRef const path = shape.CGPath;
    
    _shapeView.path = path;
    _shapeView.fillColor = fillColor.CGColor;
    _shapeView.strokeColor = strokeColor.CGColor;
    
    CGSize const size = [self intrinsicContentSizeForShape:path];
    _shapeView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (CGSize)intrinsicContentSizeForImage:(UIImage *)image {
    CGSize size = image.size;
    
    CGFloat const screenScale = UIScreen.mainScreen.scale;
    CGFloat const imageScale = image.scale;
    
    if (imageScale == screenScale || imageScale <= 0) {
        return size;
    }
    
    CGFloat const scale = imageScale / screenScale;
    return CGSizeMake(size.width * scale, size.height * scale);
}

- (CGSize)intrinsicContentSizeForShape:(CGPathRef)shape {
    CGRect const bounds = CGPathGetPathBoundingBox(shape);
    CGFloat const width = bounds.size.width + bounds.origin.x * 2.0;
    CGFloat const height = bounds.size.height + bounds.origin.y * 2.0;
    return CGSizeMake(width, height);
}

@end

@interface XZPageControlItem ()
//@property (nonatomic, strong) UIView<XZPageControlIndicator> *view;
@end

@implementation XZPageControlItem {
    XZPageControl * __unsafe_unretained _pageControl;
}

+ (XZPageControlItem *)itemForPageControl:(XZPageControl *)pageControl attributes:(XZPageControlAttributes *)attributes {
    return [[self alloc] initWithPageControl:pageControl attributes:attributes];
}

- (void)dealloc {
    [_view removeFromSuperview];
}

- (instancetype)initWithPageControl:(XZPageControl *)pageControl attributes:(XZPageControlAttributes *)attributes {
    self = [super init];
    if (self) {
        _isCurrent = NO;
        _attributes = attributes;
        _pageControl = pageControl;
    }
    return self;
}

@synthesize attributes = _attributes;

- (XZPageControlAttributes *)attributes {
    if (_attributes == nil) {
        _attributes = [[XZPageControlAttributes alloc] init];
    }
    return _attributes;
}

@synthesize view = _view;

- (void)setView:(UIView<XZPageControlIndicator> *)view {
    if (_view != view) {
        [_view removeFromSuperview];
        _view = view;
        if (_view) {
            [self viewDidLoad];
        }
    }
}

- (UIView<XZPageControlIndicator> *)view {
    if (!_view) {
        _view = [[XZPageControlIndicator alloc] init];
        [self viewDidLoad];
    }
    return _view;
}

- (void)viewDidLoad {
    [_pageControl addSubview:_view];
    _view.isCurrent = _isCurrent;
    
    // 复制属性
    if (_attributes.strokeColor) {
        if ([_view respondsToSelector:@selector(setStrokeColor:)]) {
            _view.strokeColor = _attributes.strokeColor;
        }
    }
    if (_attributes.currentStrokeColor) {
        if ([_view respondsToSelector:@selector(setCurrentStrokeColor:)]) {
            _view.currentStrokeColor = _attributes.currentStrokeColor;
        }
    }
    if (_attributes.fillColor) {
        if ([_view respondsToSelector:@selector(setFillColor:)]) {
            _view.fillColor = _attributes.fillColor;
        }
    }
    if (_attributes.currentFillColor) {
        if ([_view respondsToSelector:@selector(setCurrentFillColor:)]) {
            _view.currentFillColor = _attributes.currentFillColor;
        }
    }
    if (_attributes.shape) {
        if ([_view respondsToSelector:@selector(setShape:)]) {
            _view.shape = _attributes.shape;
        }
    }
    if (_attributes.currentShape) {
        if ([_view respondsToSelector:@selector(setCurrentShape:)]) {
            _view.currentShape = _attributes.currentShape;
        }
    }
    if (_attributes.image) {
        if ([_view respondsToSelector:@selector(setImage:)]) {
            _view.image = _attributes.image;
        }
    }
    if (_attributes.currentImage) {
        if ([_view respondsToSelector:@selector(setCurrentImage:)]) {
            _view.currentImage = _attributes.currentImage;
        }
    }
}

- (CGRect)frame {
    return _view.frame;
}

- (void)setFrame:(CGRect)frame {
    self.view.frame = frame;
}

@synthesize isCurrent = _isCurrent;

- (void)setCurrent:(BOOL)isCurrent {
    if (_isCurrent != isCurrent) {
        _isCurrent = isCurrent;
        _view.isCurrent = isCurrent;
    }
}

- (BOOL)isCurrent {
    return _isCurrent;
}

- (UIColor *)strokeColor {
    return _attributes.strokeColor;
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    self.attributes.strokeColor = strokeColor;
    if ([_view respondsToSelector:@selector(setStrokeColor:)]) {
        _view.strokeColor = strokeColor;
    }
}
- (UIColor *)currentStrokeColor {
    return _attributes.currentStrokeColor;
}
- (void)setCurrentStrokeColor:(UIColor *)currentStrokeColor {
    self.attributes.currentStrokeColor = currentStrokeColor;
    if ([_view respondsToSelector:@selector(setCurrentStrokeColor:)]) {
        _view.currentStrokeColor = currentStrokeColor;
    }
}

- (UIColor *)fillColor {
    return _attributes.fillColor;
}
- (void)setFillColor:(UIColor *)fillColor {
    self.attributes.fillColor = fillColor;
    if ([_view respondsToSelector:@selector(setFillColor:)]) {
        _view.fillColor = fillColor;
    }
}
- (UIColor *)currentFillColor {
    return _attributes.currentFillColor;
}
- (void)setCurrentFillColor:(UIColor *)currentFillColor {
    self.attributes.currentFillColor = currentFillColor;
    if ([_view respondsToSelector:@selector(setCurrentFillColor:)]) {
        _view.currentFillColor = currentFillColor;
    }
}

- (UIBezierPath *)shape {
    return _attributes.shape;
}
- (void)setShape:(UIBezierPath *)shape {
    self.attributes.shape = shape;
    if ([_view respondsToSelector:@selector(setShape:)]) {
        _view.shape = shape;
    }
}
- (UIBezierPath *)currentShape {
    return _attributes.currentShape;
}
- (void)setCurrentShape:(UIBezierPath *)currentShape {
    self.attributes.currentShape = currentShape;
    if ([_view respondsToSelector:@selector(setCurrentShape:)]) {
        _view.currentShape = currentShape;
    }
}

- (UIImage *)image {
    return _attributes.image;
}
- (void)setImage:(UIImage *)image {
    self.attributes.image = image;
    if ([_view respondsToSelector:@selector(setImage:)]) {
        _view.image = image;
    }
}
- (UIImage *)currentImage {
    return _attributes.currentImage;
}
- (void)setCurrentImage:(UIImage *)currentImage {
    self.attributes.currentImage = currentImage;
    if ([_view respondsToSelector:@selector(setCurrentImage:)]) {
        _view.currentImage = currentImage;
    }
}

@end


@implementation XZPageControlAttributes

@synthesize strokeColor = _strokeColor;
@synthesize currentStrokeColor = _currentStrokeColor;

@synthesize fillColor = _fillColor;
@synthesize currentFillColor = _currentFillColor;

@synthesize shape = _shape;
@synthesize currentShape = _currentShape;

@synthesize image = _image;
@synthesize currentImage = _currentImage;

- (BOOL)isCurrent {
    @throw [NSException exceptionWithName:NSGenericException reason:@"方法未实现" userInfo:nil];
}

- (void)setCurrent:(BOOL)isCurrent {
    @throw [NSException exceptionWithName:NSGenericException reason:@"方法未实现" userInfo:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    XZPageControlAttributes *attributes = [[self.class alloc] init];
    attributes->_strokeColor = _strokeColor;
    attributes->_currentStrokeColor = _currentStrokeColor;
    
    attributes->_fillColor = _fillColor;
    attributes->_currentFillColor = _currentFillColor;
    
    attributes->_shape = _shape;
    attributes->_currentShape = _currentShape;
    
    attributes->_image = _image;
    attributes->_currentImage = _currentImage;
    return attributes;
}

@end
