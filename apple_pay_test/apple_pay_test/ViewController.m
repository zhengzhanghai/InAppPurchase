//
//  ViewController.m
//  apple_pay_test
//
//  Created by 郑章海 on 2021/6/18.
//

#import "ViewController.h"
#import "ApplePayTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self applePayTest];
}

- (void)applePayTest {
//    com.vivi.6.r.m.b
//    test.six
//    com.subscribed.auto
//    com.vivi.con.week.not.auto
//    com.vivi.vip.week.auto
    [[ApplePayTest shared] payWithProductID:@"com.subscribed.auto"];
    
//    [ApplePayTest shared];
}

@end
