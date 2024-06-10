//
//  XZPageControlDefines.h
//  XZPageControl
//
//  Created by Xezun on 2024/6/10.
//

#import <UIKit/UIKit.h>

/// 自定义指示器需要实现的协议。
@protocol XZPageControlIndicator <NSObject>
@property (nonatomic, setter=setCurrent:) BOOL isCurrent;
@optional
@property (nonatomic, strong, nullable) UIColor *strokeColor;
@property (nonatomic, strong, nullable) UIColor *currentStrokeColor;

@property (nonatomic, strong, nullable) UIColor *fillColor;
@property (nonatomic, strong, nullable) UIColor *currentFillColor;

@property (nonatomic, copy, nullable) UIBezierPath *shape;
@property (nonatomic, copy, nullable) UIBezierPath *currentShape;

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *currentImage;
@end
