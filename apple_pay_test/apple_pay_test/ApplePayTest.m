//
//  ApplePayTest.m
//  HeroCoinSDK
//
//  Created by 郑章海 on 2021/6/18.
//  Copyright © 2021 time. All rights reserved.
//

#import "ApplePayTest.h"
#import <StoreKit/StoreKit.h>


@interface ApplePayTest()<
    SKPaymentTransactionObserver,
    SKProductsRequestDelegate
//    SKRequestDelegate
>

@end

@implementation ApplePayTest

+ (instancetype)shared {
    static ApplePayTest *_payTest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _payTest = [[ApplePayTest alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_payTest];
    });
    return _payTest;
}

- (void)payWithProductID:(NSString *)productID {
    // 处理之前未完成的交易
    [self dealUnfinishedTransactions];

    if ([SKPaymentQueue canMakePayments]) {
        [self fetchProductFromApple:productID];
    } else {
        NSLog(@"不能发起支付");
    }
}

/// 从苹果获取商品详情
- (void)fetchProductFromApple:(NSString *)productID {
    NSSet *set = [NSSet setWithArray:@[productID]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

/// 处理未完成的交易
- (void)dealUnfinishedTransactions {
    // 支付失败的交易可能在[SKPaymentQueue defaultQueue].transactions中，我们需要去验证
    // 先付服务器验证，验证完成了，需要finishTransaction
    NSArray *transactions = [SKPaymentQueue defaultQueue].transactions;
    NSLog(@"未处理完的交易数量 = %lu", transactions.count);
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"---  %@ ", transaction.transactionIdentifier);
        // 验证交易订单，加入验证完成
        [self verifyTransaction:transaction];
    }
}


/// 验证交易
- (void)verifyTransaction:(SKPaymentTransaction *)transaction {
//    NSLog(@"appStoreReceiptURL = %@", [[NSBundle mainBundle] appStoreReceiptURL]);
    // 购买中的交易不能finishTransaction，否则会崩溃
    NSLog(@"verifyTransaction %ld", (long)transaction.transactionState);
    if (transaction.transactionState == SKPaymentTransactionStatePurchasing
        || transaction.transactionState == SKPaymentTransactionStateDeferred) {
        return ;
    }
    // 一般奖凭证交给服务器去验证
    // 验证通过后 finishTransaction
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark : SKProductsRequestDelegate 获取商品详情代理
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    NSLog(@"商品数量 = %lu", (unsigned long)products.count);
    if (products.count == 0) {
        return;
    }
    
    // 先请求自己服务器创建订单
    // 订单创建完成后在苹果请求支付
    
    SKProduct *product = products.firstObject;
    NSLog(@"商品ID = %@", product.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"请求商品失败");
    NSLog(@"%@", error);
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"请求商品详情完成");
}


# pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    NSLog(@"交易队列回调，交易数量 = %lu", transactions.count);
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"交易队列 %@", transaction.transactionIdentifier);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: // 购买过程中
                NSLog(@"购买过程中");
                break;
            case SKPaymentTransactionStatePurchased: // 购买完成
                // 去验证交易
                [self verifyTransaction:transaction];
                NSLog(@"购买完成");
                break;
            case SKPaymentTransactionStateFailed: // 购买失败
                // 根据服务器协商，是否用服务器去验证交易，
                // 如果失败不需要服务器验证直接finishTransaction
                [self verifyTransaction:transaction];
                NSLog(@"购买失败");
                break;
            case SKPaymentTransactionStateDeferred: // 未知状态
                NSLog(@"未知状态");
                break;
            case SKPaymentTransactionStateRestored: // 恢复订阅
                NSLog(@"恢复订阅");
                break;
            default:
                NSLog(@"未知");
                break;
        }
    }
}

#pragma mark - dealloc

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
