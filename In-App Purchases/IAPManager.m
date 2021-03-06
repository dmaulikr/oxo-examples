//
//  IAPManager.m
//  TTT
//
//  Created by Hans Yelek on 9/12/14.
//  Copyright (c) 2014 Hans Yelek. All rights reserved.
//

//#import <StoreKit/StoreKit.h>

#import "IAPManager.h"
#import "IAPConstants.h"

#import "HYReceiptValidationManager.h"


#include <openssl/bio.h>
#include <openssl/pkcs7.h>
#include <openssl/x509_vfy.h>
#include <openssl/err.h>


@implementation IAPManager


+ (id)sharedIAPManager
{
    static IAPManager * sharedIAPManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedIAPManager = [[self alloc] init];
    });
    
    return sharedIAPManager;
}


- (void)requestProductsFromAppStore
{
    /*
     
     When key[i] ^ encryptedProductID[i] is performed for each of the item pairs in the array,
     the resulting string is the product id for the Rainbow Theme Pack product: "OXO_Rainbow" .
     
     */
    const char key[] = { 0x3d, 0x79, 0x10, 0x62, 0x4c, 0x22, 0x1b, 0x66, 0x54, 0x1d, 0x1e, '\0' };
    const char encryptedProductID[] = { 0x72, 0x21, 0x5f, 0x3d, 0x1e, 0x43, 0x72, 0x08, 0x36, 0x72, 0x69 };
    char productID[12];
    for ( int i = 0; i < sizeof(encryptedProductID); ++i )
    {
        productID[i] = key[i] ^ encryptedProductID[i];
    }
    productID[11] = '\0';
    
    
    
    SKProductsRequest * productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[[[NSString alloc] initWithUTF8String:productID]]]];
    productsRequest.delegate = self;
    
    [productsRequest start];
}

#pragma mark - SKProductsRequestDelegate Protocol


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    // check for invalid product identifiers
    //    for (NSString * invalidID in response.invalidProductIdentifiers) {
    //        //NSLog(@"WARNING - INVALID PRODUCT ID: %@", invalidID);
    //    }
    
    _products = response.products;
    
    if ([_products count]) {
        _didFetchProducts = YES;
    }
    else {
        _didFetchProducts = NO;
        //NSLog(@"No products were received from the App Store");
    }
    
    // post notification herex
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPProductRequestCompleteNotification
                                                        object:self];
}

#pragma mark - SKPaymentTransactionObserver Protocol

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [self processCompletedTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateFailed:
            {
                [self processFailedTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateRestored:
            {
                [self processRestoredTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStatePurchasing:
            {
                [self processInProgressTransaction:transaction];
                break;
            }
                
            case SKPaymentTransactionStateDeferred:
            {
                [self processDeferredTransaction:transaction];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Transaction Processing

- (void)processCompletedTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionDidCompleteNotification
                                                        object:self
                                                      userInfo:@{@"transaction":transaction}];
    
    
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)processFailedTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionDidFailNotification
                                                        object:self
                                                      userInfo:@{@"transaction":transaction}];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)processRestoredTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionRestoredNotification
                                                        object:self
                                                      userInfo:@{@"transaction":transaction}];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)processInProgressTransaction:(SKPaymentTransaction *)transaction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionInProgressNotification
                                                        object:self
                                                      userInfo:@{@"transaction":transaction}];
}

- (void)processDeferredTransaction:(SKPaymentTransaction *)transaction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIAPTransactionDeferredNotification
                                                        object:self
                                                      userInfo:@{@"transaction":transaction}];
}

#pragma mark - Transaction Verification

- (BOOL)receiptIsValid
{
    HYReceiptValidationManager * receiptValidationManager = [HYReceiptValidationManager sharedReceiptValidationManager];
    
    
    return [receiptValidationManager receiptIsValid];
}

@end
