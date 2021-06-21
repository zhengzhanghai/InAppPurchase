//
//  ApplePayTest.h
//  apple_pay_test
//
//  Created by 郑章海 on 2021/6/18.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplePayTest : NSObject

+ (instancetype)shared;

- (void)payWithProductID:(NSString *)productID;

@end

NS_ASSUME_NONNULL_END
