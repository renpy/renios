#import <Foundation/Foundation.h>

@import StoreKit;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property NSArray *productIdentifiers;
@property NSMutableDictionary *products;
@property int status;

- (id) init;
- (BOOL) canMakePayments;
- (void) validateProductIdentifiers;
- (void) beginPurchase: (NSString *) identifier;
@end;


@implementation IAPHelper

- (id) init {
    self = [ super init ];
    self.products = [[ NSMutableDictionary alloc] init];
    self.status = 2;

    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    return self;
}

- (BOOL) canMakePayments {
    // printf("Can make payments: %d\n", [SKPaymentQueue canMakePayments]);
    
    return [SKPaymentQueue canMakePayments];
}

- (void) validateProductIdentifiers {
 
    for (NSString *i in self.productIdentifiers) {
        printf("%s\n", [i UTF8String]);
    }
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray: self.productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void) beginPurchase: (NSString *) identifier {
    self.status = 0;
    
    printf("Begin purchase of %s\n", [ identifier UTF8String ]);
    
    SKProduct *product = [ self.products objectForKey: identifier ];
    if (product == nil) {
        printf("Product not found.\n");
        self.status = 2;
        return;
    }
    
    printf("Product found.\n");
    SKMutablePayment *payment = [ SKMutablePayment paymentWithProduct: product ];
    payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    for (SKProduct *prod in response.products) {
        printf("OK %s %f\n", [ prod.productIdentifier UTF8String ], prod.price.doubleValue);

        [ self.products setObject: prod forKey: prod.productIdentifier ];
    }
    
//    for (NSString *s in response.invalidProductIdentifiers) {
//        printf("INVALID %s\n", [ s UTF8String ]);
//    }
}


- (void) paymentQueue: (SKPaymentQueue *) queue updatedTransactions: (NSArray *) transactions {
    for (SKPaymentTransaction *t in transactions) {
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchased:
                printf("Purchased %s\n", [t.payment.productIdentifier UTF8String ]);
                self.status = 1;
                break;

            case SKPaymentTransactionStateFailed:
                printf("Failed %s\n", [t.payment.productIdentifier UTF8String ]);
                self.status = 1;
                break;

            case SKPaymentTransactionStateRestored:
                printf("Restored %s\n", [t.payment.productIdentifier UTF8String ]);
                self.status = 1;
                break;
            
            case SKPaymentTransactionStatePurchasing:
                printf("Purchasing %s\n", [t.payment.productIdentifier UTF8String ]);
                self.status = 1;
                break;
                
            case SKPaymentTransactionStateDeferred:
                printf("Deferred %s\n", [t.payment.productIdentifier UTF8String ]);
                self.status = 1;
                break;
        }
    }
}

@end