#import <Foundation/Foundation.h>

@import StoreKit;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// An array of product identifier NSStrings. This is set when we're first constructed.
@property NSArray *productIdentifiers;

// A map from a product identifier NSString to the corresponding project.
@property NSMutableDictionary *products;

// 1 if an operation is in progress. 0 if no operation is in progress.
@property int finished;

// The set of identifiers for purchased products.
@property NSMutableSet *purchased;

// The set of identifiers for deferred products.
@property NSMutableSet *deferred;

- (id) init;
- (BOOL) canMakePayments;
- (void) validateProductIdentifiers;
- (void) beginPurchase: (NSString *) identifier;
- (BOOL) hasPurchased: (NSString *) identifier;
- (BOOL) isDeferred: (NSString *) identifier;
@end;


@implementation IAPHelper

- (id) init {
    self = [ super init ];
    self.products = [ [ NSMutableDictionary alloc] init];
    self.purchased = [ [ NSMutableSet alloc ] init ];
    self.deferred = [ [ NSMutableSet alloc ] init ];
    self.finished = 1;

    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    return self;
}

- (BOOL) canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (void) validateProductIdentifiers {
 
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray: self.productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *prod in response.products) {
        [ self.products setObject: prod forKey: prod.productIdentifier ];
    }
}


- (void) beginPurchase: (NSString *) identifier {
    
    SKProduct *product = [ self.products objectForKey: identifier ];
    
    if (product == nil) {
        return;
    }

    self.finished = 0;
    
    SKMutablePayment *payment = [ SKMutablePayment paymentWithProduct: product ];
    payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
}

- (void) restorePurchases {
    self.finished = 0;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions ];
    printf("Restore started.\n");
}

- (void) paymentQueue: (SKPaymentQueue *) queue updatedTransactions: (NSArray *) transactions {
    for (SKPaymentTransaction *t in transactions) {
        NSString *identifier = t.payment.productIdentifier;
        
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchased:
                printf("Purchased %s\n", [ identifier UTF8String ]);
                [ self.deferred removeObject: identifier ];
                [ self.purchased addObject: identifier ];
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                self.finished = 1;
                break;

            case SKPaymentTransactionStateFailed:
                printf("Failed %s\n", [ identifier UTF8String ]);
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                self.finished = 1;
                break;

            case SKPaymentTransactionStateRestored:
                printf("Restored %s\n", [ identifier UTF8String ]);
                [ self.deferred removeObject: identifier ];
                [ self.purchased addObject: identifier ];
                [ [ SKPaymentQueue defaultQueue] finishTransaction: t ];
                break;
            
            case SKPaymentTransactionStatePurchasing:
                printf("Purchasing %s\n", [ identifier UTF8String ]);
                break;
                
            case SKPaymentTransactionStateDeferred:
                printf("Deferred %s\n", [ identifier UTF8String ]);
                [ self.deferred addObject: identifier ];
                self.finished = 1;
                break;
        }
    }
}

- (void) paymentQueue: (SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError: (NSError *) error {
    printf("Restore failed with error.\n");
    self.finished = 1;
}

- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue *) queue {
    printf("Restore completed.\n");
    self.finished = 1;
}


- (BOOL) hasPurchased: (NSString *) identifier {
    return [ self.purchased member: identifier ] != nil;
}

- (BOOL) isDeferred: (NSString *) identifier {
    return [ self.deferred member: identifier ] != nil;
}


@end