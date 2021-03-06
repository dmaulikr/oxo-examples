//
//  IAPManager.h
//  TTT
//
//  Created by Hans Yelek on 9/12/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSArray * _productIdentifiers;
}

@property (nonatomic, assign, readonly) BOOL didFetchProducts;

@property (nonatomic, strong, readonly) NSArray * products; // holds a collection of SKProduct objects

+ (IAPManager *)sharedIAPManager;

- (void)requestProductsFromAppStore;

@end
