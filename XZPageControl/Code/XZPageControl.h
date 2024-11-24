//
//  XZPageControl.h
//  XZKit
//
//  Created by Xezun on 2021/9/13.
//

#import <UIKit/UIKit.h>
#import <XZPageControl/XZPageControlDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XZPageControlOrientation) {
    XZPageControlOrientationHorizontal = 0,
    XZPageControlOrientationVertical = 1
} API_UNAVAILABLE(watchos);

/// 翻页指示控件。
@interface XZPageControl : UIControl

/// 排列方向。
@property (nonatomic) IBInspectable XZPageControlOrientation orientation;

- (instancetype)initWithFrame:(CGRect)frame orientation:(XZPageControlOrientation)orientation;
- (instancetype)initWithOrientation:(XZPageControlOrientation)orientation;

/// 页面总数。
@property (nonatomic, assign) NSInteger numberOfPages;
/// 当前页，默认值 0 。
@property (nonatomic, assign) NSInteger currentPage;
/// 单页时是否隐藏，默认 YES 。
@property (nonatomic) BOOL hidesForSinglePage;

/// 指示器中心点之间的最大距离，默认 30 点。
/// @discussion 如果此值足够大，指示器最多会平分整个视图宽度，此值将约束指示器之间的最大距离。
/// @discussion 如果指示器视图不够宽或者此属性值不够大，指示器之间可能会发生重叠。
/// @discussion 在允许的情况下，可通过 layoutMargins 属性限制可放置指示器的区域。
@property (nonatomic) CGFloat maximumIndicatorSpacing;

/// 指示器排列方式。
/// @discussion 支持以下三种模式：
/// @discussion @b UIViewContentModeCenter @c 指示器居中排列，默认
/// @discussion @b UIViewContentModeLeft @c 指示器居左排列
/// @discussion @b UIViewContentModeRight @c 指示器居右排列
@property (nonatomic) UIViewContentMode contentMode;

// 默认样式。
// 设置以下属性，会同时修改所有指示器的样式，包括自定义指示器（如果支持的话）。
// 新指示器被添加到 UIControl 时，以下属性值都会被复制到新指示器中。

/// 指示器线条颜色。
@property (nonatomic, strong, nullable) UIColor *indicatorStrokeColor;
/// 当前页面的指示器线条颜色。
@property (nonatomic, strong, nullable) UIColor *currentIndicatorStrokeColor;

/// 指示器填充颜色，默认白色。
@property (nonatomic, strong, nullable) UIColor *indicatorFillColor;
/// 当前页面的指示器填充颜色，默认灰色。
@property (nonatomic, strong, nullable) UIColor *currentIndicatorFillColor;

/// 指示器形状，默认为直径为 6.0 的圆点。
@property (nonatomic, copy, nullable) UIBezierPath *indicatorShape;
/// 当前页面的指示器形状，默认与非当前页一致。
@property (nonatomic, copy, nullable) UIBezierPath *currentIndicatorShape;

/// 指示器图片。如果设置，则忽略颜色和形状。
@property (nonatomic, strong, nullable) UIImage *indicatorImage;
/// 当前页面指示器图片。如果设置，则忽略颜色和形状。
@property (nonatomic, strong, nullable) UIImage *currentIndicatorImage;

// 独立样式
// 只能为已存在的指示器指定独立样式，且样式不会保存。

- (UIColor *)indicatorStrokeColorForPage:(NSInteger)page;
- (void)setIndicatorStrokeColor:(nullable UIColor *)indicatorColor forPage:(NSInteger)page;
- (UIColor *)currentIndicatorStrokeColorForPage:(NSInteger)page;
- (void)setCurrentIndicatorStrokeColor:(nullable UIColor *)currentIndicatorColor forPage:(NSInteger)page;

- (UIColor *)indicatorFillColorForPage:(NSInteger)page;
- (void)setIndicatorFillColor:(nullable UIColor *)indicatorColor forPage:(NSInteger)page;
- (UIColor *)currentIndicatorFillColorForPage:(NSInteger)page;
- (void)setCurrentIndicatorFillColor:(nullable UIColor *)currentIndicatorColor forPage:(NSInteger)page;

- (UIBezierPath *)indicatorShapeForPage:(NSInteger)page;
- (void)setIndicatorShape:(nullable UIBezierPath *)indicatorShape forPage:(NSInteger)page;
- (UIBezierPath *)currentIndicatorShapeForPage:(NSInteger)page;
- (void)setCurrentIndicatorShape:(nullable UIBezierPath *)currentIndicatorShape forPage:(NSInteger)page;

- (nullable UIImage *)indicatorImageForPage:(NSInteger)page;
- (void)setIndicatorImage:(nullable UIImage *)indicatorImage forPage:(NSInteger)page;
- (nullable UIImage *)currentIndicatorImageForPage:(NSInteger)page;
- (void)setCurrentIndicatorImage:(nullable UIImage *)currentIndicatorImage forPage:(NSInteger)page;

// 自定义指示器。
// 只能为已存在的指示器配置自定义指示器。

- (UIView<XZPageControlIndicator> *)indicatorForPage:(NSInteger)page;
- (void)setIndicator:(nullable UIView<XZPageControlIndicator> *)indicator forPage:(NSInteger)page;

@end

NS_ASSUME_NONNULL_END
