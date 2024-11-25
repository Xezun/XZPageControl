//
//  ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "ViewController.h"
@import XZPageControl;
@import XZPageView;
@import SDWebImage;

@interface ViewController () <XZPageViewDelegate, XZPageViewDataSource>
@property (weak, nonatomic) IBOutlet XZPageView *pageView;
@property (weak, nonatomic) IBOutlet XZPageControl *pageControl;

@property (nonatomic, copy) NSArray *imageURLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageURLs = @[
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/df38e2b4-31bb-447f-9987-ce04368696c5.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/3b1ef5df-f143-44dd-9d36-c93867b2529c.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/108363a8-ff04-4784-9640-981183e81066.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/4677eadf-99bf-4112-8bc6-68a487a427eb.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/dd138b93-a114-4c27-b96d-e9853319907f.jpg"]
    ];
    
    self.pageView.isLooped = YES;
    self.pageView.autoPagingInterval = 5.0;
    
    self.pageControl.indicatorFillColor = UIColor.whiteColor;
    self.pageControl.indicatorStrokeColor = UIColor.whiteColor;
    self.pageControl.currentIndicatorFillColor = UIColor.redColor;
    self.pageControl.currentIndicatorStrokeColor = UIColor.redColor;
    
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    
    self.pageControl.numberOfPages = self.imageURLs.count;
    [self.pageControl addTarget:self action:@selector(pageControlDidChangeValue:) forControlEvents:(UIControlEventValueChanged)];
}

- (IBAction)isLoopedSwitchValueChanged:(UISwitch *)sender {
    self.pageView.isLooped = sender.isOn;
}

- (IBAction)alignLeftButtonAction:(id)sender {
    self.pageControl.contentMode = UIViewContentModeLeft;
}

- (IBAction)alignCenterButtonAction:(id)sender {
    self.pageControl.contentMode = UIViewContentModeCenter;
}

- (IBAction)alignRightButtonAction:(id)sender {
    self.pageControl.contentMode = UIViewContentModeRight;
}

- (IBAction)defautStyleButtonAction:(id)sender {
    _pageControl.indicatorImage = nil;
    _pageControl.currentIndicatorImage = nil;
    _pageControl.indicatorShape = nil;
    _pageControl.currentIndicatorShape = nil;
}

- (IBAction)shapStyleButtonAction:(id)sender {
    _pageControl.indicatorImage            = nil;
    _pageControl.currentIndicatorImage     = nil;
    
    switch (self.pageControl.orientation) {
        case XZPageControlOrientationHorizontal: {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:CGPointMake(0.0, 0.0)];
            [path addLineToPoint:CGPointMake(6.0, 0.0)];
            [path addLineToPoint:CGPointMake(3.0, 6.0)];
            [path closePath];
            _pageControl.indicatorShape = path;
            
            path = [[UIBezierPath alloc] init];
            [path moveToPoint:CGPointMake(3.0, 0.0)];
            [path addLineToPoint:CGPointMake(6.0, 6.0)];
            [path addLineToPoint:CGPointMake(0.0, 6.0)];
            [path closePath];
            _pageControl.currentIndicatorShape = path;
            break;
        }
        case XZPageControlOrientationVertical: {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:CGPointMake(0.0, 0.0)];
            [path addLineToPoint:CGPointMake(6.0, 3.0)];
            [path addLineToPoint:CGPointMake(0.0, 6.0)];
            [path closePath];
            _pageControl.indicatorShape = path;
            
            path = [[UIBezierPath alloc] init];
            [path moveToPoint:CGPointMake(0.0, 3.0)];
            [path addLineToPoint:CGPointMake(6.0, 0.0)];
            [path addLineToPoint:CGPointMake(6.0, 6.0)];
            [path closePath];
            _pageControl.currentIndicatorShape = path;
            break;
        }
    }

}

- (IBAction)imageStyleButtonAction:(id)sender {
    _pageControl.indicatorImage        = [UIImage imageNamed:@"icon-star"];
    _pageControl.currentIndicatorImage = [UIImage imageNamed:@"icon-star-selected"];
}

- (IBAction)spacingSliderValueChanged:(UISlider *)sender {
    _pageControl.maximumIndicatorSpacing = sender.value;
}

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return self.imageURLs.count;
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(UIImageView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[UIImageView alloc] initWithFrame:pageView.bounds];
    }
    [reusingView sd_setImageWithURL:self.imageURLs[index]];
    return reusingView;
}

- (nullable UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(UIImageView *)reusingView {
    reusingView.image = nil;
    return reusingView;
}

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    NSLog(@"didShowPage: %ld", index);
    [self.pageControl setCurrentPage:index animated:YES];
}

- (void)pageView:(XZPageView *)pageView didTurnPageWithTransition:(CGFloat)transition {
    NSLog(@"didTurnPage: %lf", transition);
    [self.pageControl setTransition:transition isLooped:pageView.isLooped];
}

- (void)pageControlDidChangeValue:(XZPageControl *)pageControl {
    [self.pageView setCurrentPage:pageControl.currentPage animated:YES];
}

@end
