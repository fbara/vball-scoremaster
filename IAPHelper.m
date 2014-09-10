//
//  IAPHelper.m
//  IAPExample
//
//  Created by AppleAir on 5/14/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//

#import "IAPHelper.h"
@import StoreKit;

NSString *const IAPHelperProductPurchaseNotification = @"IAPHelperProductPurchaseNotification";

@interface IAPHelper () <SKProductsRequestDelegate,SKPaymentTransactionObserver>


@end
@implementation IAPHelper
{
    //Create and instance variable to store the SKProductRequest
    //I will issue this variable to retrieve a list of products
    SKProductsRequest *_productsRequest;
    
    //Variable to keep track of the completion handler for the outstanding products
    RequestProductsCompletionHandler _completionHandler;
    
    //List of product identifiers to pass in and
    //list of purchased products
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init])) {
        //Store the product identifiers
        _productIdentifiers = productIdentifiers;
        
        //Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults]
                                     boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@/n", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@/n", productIdentifier);
            }
        }
        //Add self as the transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    //Put a copy of the completion handler block inside an instance variable so
    //it can notify the caller when the product request asynchronously completes
    _completionHandler = [completionHandler copy];
    
    //Create new instance of SKProductsRequest (this pulls the info from iTunes Connect)
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    
    //Identify the delegate and call to get started
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifiers
{
    return [_purchasedProductIdentifiers containsObject:productIdentifiers];
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying product %@.....", product.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products....\n");
    _productsRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"\nFailed to load a list of products with error: %@", error.localizedDescription);
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
             case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    invc = [[InAppPurchaseViewController alloc] init];
    [invc.view setNeedsDisplay];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Completed"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"\nFailed transaction....");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"\nRestoring transaction....");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseNotification
                                                        object:productIdentifier
                                                      userInfo:nil];
}

@end

