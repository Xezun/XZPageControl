//
//  XZPageControlIndicator.m
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import "XZPageControlIndicator.h"
#import <XZShapeView/XZShapeView.h>

@implementation XZPageControlIndicator {
    // _imageView 与 _shapeView 并非完全互斥，
    // 因为可以在 isCurrent 两种状态之间分别选择其中一种样式，用来展示。
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
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
        [self setNeedsUpdate];
    }
}

- (void)setCurrentStrokeColor:(UIColor *)currentStrokeColor {
    if (_currentStrokeColor != currentStrokeColor) {
        _currentStrokeColor = currentStrokeColor;
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
    if (_fillColor != fillColor) {
        _fillColor = fillColor;
        [self setNeedsUpdate];
    }
}

- (UIColor *)currentFillColor {
    if (_currentFillColor == nil) {
        _currentFillColor = UIColor.whiteColor;
    }
    return _currentFillColor;
}

- (void)setCurrentFillColor:(UIColor *)currentFillColor {
    if (_currentFillColor != currentFillColor) {
        _currentFillColor = currentFillColor;
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
    if (_shape != shape) {
        _shape = shape.copy;
        [self setNeedsUpdate];
    }
}

- (UIBezierPath *)currentShape {
    if (_currentShape == nil) {
        _currentShape = self.shape;
    }
    return _currentShape;
}

- (void)setCurrentShape:(UIBezierPath *)currentShape {
    if (_currentShape != currentShape) {
        _currentShape = currentShape.copy;
        [self setNeedsUpdate];
    }
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self setNeedsUpdate];
    }
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
            [self updateAppearanceByUsingShape:self.currentShape fillColor:self.currentFillColor strokeColor:self.currentStrokeColor];
        } else {
            [self updateAppearanceByUsingImage:self.currentImage];
        }
    } else {
        if (self.image == nil) {
            [self updateAppearanceByUsingShape:self.shape fillColor:self.fillColor strokeColor:self.strokeColor];
        } else {
            [self updateAppearanceByUsingImage:self.image];
        }
    }
}

- (void)updateAppearanceByUsingImage:(UIImage *)image {
    _shapeView.hidden = YES;
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_imageView];
    } else {
        _imageView.hidden = NO;
    }
    _imageView.image = image;
    
    CGSize const size = [self intrinsicContentSizeForImage:image];
    _imageView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (void)updateAppearanceByUsingShape:(UIBezierPath *)shape fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    _imageView.hidden = YES;
    
    if (_shapeView == nil) {
        _shapeView = [[XZShapeView alloc] initWithFrame:self.bounds];
        _shapeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_shapeView];
    } else {
        _shapeView.hidden = NO;
    }
    
    CGPathRef const path = shape.CGPath;
    _shapeView.path        = path;
    _shapeView.fillColor   = fillColor.CGColor;
    _shapeView.strokeColor = strokeColor.CGColor;
    
    CGSize const size = [self intrinsicContentSizeForShape:path];
    _shapeView.bounds = CGRectMake(0, 0, size.width, size.height);
}

- (CGSize)intrinsicContentSizeForImage:(UIImage *)image {
    CGSize  const size        = image.size;
    CGFloat const screenScale = UIScreen.mainScreen.scale;
    CGFloat const imageScale  = image.scale;
    
    if (imageScale == screenScale || imageScale <= 0) {
        return size;
    }
    
    CGFloat const scale = imageScale / screenScale;
    return CGSizeMake(size.width * scale, size.height * scale);
}

- (CGSize)intrinsicContentSizeForShape:(CGPathRef)shape {
    CGRect  const bounds = CGPathGetPathBoundingBox(shape);
    CGFloat const width  = bounds.size.width + bounds.origin.x * 2.0;
    CGFloat const height = bounds.size.height + bounds.origin.y * 2.0;
    return CGSizeMake(width, height);
}

@end

