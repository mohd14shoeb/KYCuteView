//
//  ViewController.m
//  KYCuteViewDemo
//
//  Created by Kitten Yang on 2/26/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//

#define BubbleWidth  40
#define BubbleColor  [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];


#import "ViewController.h"
#import "KYCuteView.h"

@interface ViewController (){
    UIBezierPath *cutePath;
    UIColor *fillColorForCute;
    UIDynamicAnimator *animator;
    UISnapBehavior  *snap;
    
    CADisplayLink *displayLink;
    
    UILabel *number;//更新数字
    UIView *frontView;
    UIView *backView;
    CGFloat r1; // backView
    CGFloat r2; // frontView
    CGFloat x1;
    CGFloat y1;
    CGFloat x2;
    CGFloat y2;
    CGFloat centerDistance;
    CGFloat cosDigree;
    CGFloat sinDigree;
    
    CGPoint pointA; //A
    CGPoint pointB; //B
    CGPoint pointD; //D
    CGPoint pointC; //C
    CGPoint pointO; //O
    CGPoint pointP; //P
    
    CGRect oldBackViewFrame;
    CGPoint oldBackViewCenter;
    CAShapeLayer *shapeLayer;
}

@end

@implementation ViewController

-(id)init{
    self = [super init];
    if (self) {
        [self setUp];
        [self addGesture];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    [self addGesture];
    
//    KYCuteView *kycuteview = [[KYCuteView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [self.view addSubview:kycuteview];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark  - KYCuteView

//每隔一帧刷新屏幕的定时器
-(void)displayLinkAction:(CADisplayLink *)dis{
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = frontView.center.x;
    y2 = frontView.center.y;
    
    centerDistance = sqrtf((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    if (centerDistance == 0) {
        cosDigree = 1;
        sinDigree = 0;
    }else{
        cosDigree = (y2-y1)/centerDistance;
        sinDigree = (x2-x1)/centerDistance;
    }
    r1 = oldBackViewFrame.size.width / 2 - centerDistance/10;
    
    pointA = CGPointMake(x1-r1*cosDigree, y1+r1*sinDigree);  // A
    pointB = CGPointMake(x1+r1*cosDigree, y1-r1*sinDigree); // B
    pointD = CGPointMake(x2-r2*cosDigree, y2+r2*sinDigree); // D
    pointC = CGPointMake(x2+r2*cosDigree, y2-r2*sinDigree);// C
    pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree);
    pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree);
    
    [self drawRect];
}

-(void)drawRect{
    
    backView.center = oldBackViewCenter;
    backView.bounds = CGRectMake(0, 0, r1*2, r1*2);
    backView.layer.cornerRadius = r1;
    
    cutePath = [UIBezierPath bezierPath];
    [cutePath moveToPoint:pointA];
    [cutePath addQuadCurveToPoint:pointD controlPoint:pointO];
    [cutePath addLineToPoint:pointC];
    [cutePath addQuadCurveToPoint:pointB controlPoint:pointP];
    [cutePath moveToPoint:pointA];
    
    
    if (backView.hidden == NO) {
        shapeLayer.path = [cutePath CGPath];
        shapeLayer.fillColor = [fillColorForCute CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
}


-(void)setUp{
    shapeLayer = [CAShapeLayer layer];
    

    
    self.view.backgroundColor = [UIColor clearColor];
    frontView = [[UIView alloc]initWithFrame:CGRectMake(25,505, BubbleWidth, BubbleWidth)];
    
    r2 = frontView.bounds.size.width / 2;
    frontView.layer.cornerRadius = r2;
    frontView.backgroundColor = BubbleColor;
    
    backView = [[UIView alloc]initWithFrame:frontView.frame];
    r1 = backView.bounds.size.width / 2;
    backView.layer.cornerRadius = r1;
    backView.backgroundColor = BubbleColor;
    
    number = [[UILabel alloc]init];
    number.frame = CGRectMake(0, 0, frontView.bounds.size.width, frontView.bounds.size.height);
    number.text = @"11";
    number.textColor = [UIColor whiteColor];
    number.textAlignment = NSTextAlignmentCenter;
    
    [frontView insertSubview:number atIndex:0];
    [self.view addSubview:backView];
    [self.view addSubview:frontView];
    
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = frontView.center.x;
    y2 = frontView.center.y;
    
    
    pointA = CGPointMake(x1-r1,y1);   // A
    pointB = CGPointMake(x1+r1, y1);  // B
    pointD = CGPointMake(x2-r2, y2);  // D
    pointC = CGPointMake(x2+r2, y2);  // C
    pointO = CGPointMake(x1-r1,y1);
    pointP = CGPointMake(x2+r2, y2);
    
    oldBackViewFrame = backView.frame;
    oldBackViewCenter = backView.center;
    
    backView.hidden = YES;//为了看到frontView的气泡晃动效果，需要展示隐藏backView
    [self AddAniamtionLikeGameCenterBubble];
}


-(void)addGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragMe:)];
    [frontView addGestureRecognizer:pan];
    
}


-(void)dragMe:(UIPanGestureRecognizer *)ges{
    CGPoint dragPoint = [ges locationInView:self.view];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        backView.hidden = NO;
        fillColorForCute = BubbleColor;
        [self RemoveAniamtionLikeGameCenterBubble];
        if (displayLink == nil) {
            displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        
    }else if (ges.state == UIGestureRecognizerStateChanged){
        frontView.center = dragPoint;

        if (r1 <= 6) {
            
            fillColorForCute = [UIColor clearColor];
            backView.hidden = YES;
            [shapeLayer removeFromSuperlayer];
            [displayLink invalidate];
            displayLink = nil;
        }
        
    }else if (ges.state == UIGestureRecognizerStateEnded || ges.state ==UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateFailed){
        
        backView.hidden = YES;
        fillColorForCute = [UIColor clearColor];
        [shapeLayer removeFromSuperlayer];
        [UIView animateWithDuration:0.5 delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            frontView.center = oldBackViewCenter;

        } completion:^(BOOL finished) {
            
            if (finished) {
                [self AddAniamtionLikeGameCenterBubble];
                [displayLink invalidate];
                displayLink = nil;
            }
            
        }];
        
    }
    
}


//----类似GameCenter的气泡晃动动画------
-(void)AddAniamtionLikeGameCenterBubble{
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0;
    
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(frontView.frame, frontView.bounds.size.width / 2 - 3, frontView.bounds.size.width / 2 - 3);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [frontView.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.duration = 1;
    scaleX.values = @[@1.0, @1.1, @1.0];
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    scaleX.repeatCount = INFINITY;
    scaleX.autoreverses = YES;
    
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [frontView.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.1, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [frontView.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
}

-(void)RemoveAniamtionLikeGameCenterBubble{
    [frontView.layer removeAllAnimations];
}

@end