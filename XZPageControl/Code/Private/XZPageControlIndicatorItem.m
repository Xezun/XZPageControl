//
//  XZPageControlIndicatorItem.m
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import "XZPageControlIndicatorItem.h"
#import "XZPageControl.h"
#import "XZPageControlIndicator.h"

@interface XZPageControlIndicatorItem () {
    XZPageControl * __unsafe_unretained _pageControl;
}
@end

@implementation XZPageControlIndicatorItem

+ (XZPageControlIndicatorItem *)itemForPageControl:(XZPageControl *)pageControl attributes:(XZPageControlAttributes *)attributes {
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
