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
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
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

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    //NSLog(@"Buying product %@.....", product.productIdentifier);
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
    
    NSString *alertTitle = NSLocalizedString(@"Communications Error", nil);
    NSString *alertMsg = NSLocalizedString(@"I can't load a list of available products for purchase.\nUnable to communicate with the iTunes server.\nPlease try again later.", nil);
    
    if ([UIAlertController class]) {
        //iOS 8 and newer
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                       message:alertMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                       [self dismissViewControllerAnimated:YES
                                                                                completion:nil];
                                                   }];
        [alert addAction:ok];
        //Need to get a handle to the active VC, otherwise the error msg won't be seen
        UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([activeVC isKindOfClass:[UINavigationController class]]) {
            activeVC = [(UINavigationController *)activeVC visibleViewController];
        }
        [activeVC presentViewController:alert animated:YES completion:nil];
        
    } else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    //Gets a list of transactions that have been updated
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
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //NSLog(@"Complete transaction...");

}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"\nFailed transaction: %@", transaction.error.localizedDescription);
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    NSString *alertTitle = NSLocalizedString(@"Purchase Error", nil);
    NSString *alertMsg;
    
    switch (transaction.error.code) {
        case SKErrorPaymentNotAllowed:
            alertMsg = NSLocalizedString(@"Parental settings prevent purchases for this iTunes user account", nil);
            break;
        case SKErrorClientInvalid:
            alertMsg = NSLocalizedString(@"Purchases not allowed for this iTunes user account", nil);
            break;
        case SKErrorPaymentInvalid:
            alertMsg = NSLocalizedString(@"There was an error completing this purchase.\nContact iTunes support for more info", nil);
            break;
        case SKErrorUnknown:
            alertMsg = NSLocalizedString(@"The purchase could not be completed at this time.\nPlease try again later or contact iTunes support.", nil);
            break;
        default:
            break;
         }
    
    if ([UIAlertController class]) {
        //iOS 8 and newer
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                       message:alertMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                       [self dismissViewControllerAnimated:YES
                                                                                completion:nil];
                                                   }];
        [alert addAction:ok];
        //Need to get a handle to the active VC, otherwise the error msg won't be seen
        UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([activeVC isKindOfClass:[UINavigationController class]]) {
            activeVC = [(UINavigationController *)activeVC visibleViewController];
        }
        [activeVC presentViewController:alert animated:YES completion:nil];
        
    } else {
        //iOS 7 and older
        [[alert initWithTitle:alertTitle
                message:alertMsg
                delegate:nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles:nil] show];
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

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    //NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
    NSLog(@"%@", queue);
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    NSUInteger trans = queue.transactions.count;
    NSLog(@"received restored transactions: %ld", (unsigned long)trans);
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        //NSLog (@"product id is %@" , productID);
        // here put an if/then statement to write files based on previously purchased items
        // example if ([productID isEqualToString: @"youruniqueproductidentifier]){write files} else { nslog sorry}
    }
    if (queue.transactions.count < 1) {
        NSString *alertTitle = NSLocalizedString(@"Purchase Error", nil);
        NSString *alertMsg = NSLocalizedString(@"Unable to restore or complete the purchase at this time.", nil);
        
        if ([UIAlertController class]) {
            //iOS 8 and newer
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                           message:alertMsg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action){
                                                           [self dismissViewControllerAnimated:YES
                                                                                    completion:nil];
                                                       }];
            [alert addAction:ok];
            //Need to get a handle to the active VC, otherwise the error msg won't be seen
            UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([activeVC isKindOfClass:[UINavigationController class]]) {
                activeVC = [(UINavigationController *)activeVC visibleViewController];
            }
            [activeVC presentViewController:alert animated:YES completion:nil];
            
        } else {
            //iOS 7 and older
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restore failed: %@", error.localizedDescription);

    NSString *alertTitle = NSLocalizedString(error.localizedDescription, nil);
    NSString *alertMsg = NSLocalizedString(@"Unable to connect to the iTunes store.\n\nPlease try your purchase again later.", nil);
    
    if ([UIAlertController class]) {
        //iOS 8 and newer
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                       message:alertMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                       [self dismissViewControllerAnimated:YES
                                                                                completion:nil];
                                                   }];
        [alert addAction:ok];
        UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([activeVC isKindOfClass:[UINavigationController class]]) {
            activeVC = [(UINavigationController *)activeVC visibleViewController];
        }
        [activeVC presentViewController:alert animated:YES completion:nil];
    } else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
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

