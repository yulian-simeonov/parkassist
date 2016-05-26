//
//  CircularGestureRecognizer.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@protocol OneFingerRotationGestureRecognizerDelegate <NSObject>
@optional
- (void) rotation: (CGFloat) angle;
- (void) AdjustStep;
@end

@interface OneFingerRotationGestureRecognizer : UIGestureRecognizer
{
    CGPoint midPoint;
    CGFloat cumulatedAngle;
    id <OneFingerRotationGestureRecognizerDelegate> target;
}

- (id) initWithMidPoint:(CGPoint)_midPoint target:(id <OneFingerRotationGestureRecognizerDelegate>) _target;
@end
