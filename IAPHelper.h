//
//  IAPHelper.h
//  IAPExample
//
//  Created by AppleAir on 5/14/14.
//  Copyright (c) 2014 BaraTech. All rights reserved.
//


UIKIT_EXTERN NSString *const IAPHelperProductPurchaseNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);
@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifiers;
- (void)restoreCompletedTransactions;

@end
