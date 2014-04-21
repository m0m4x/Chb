//
//  TSPWebViewController.h
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSPWebViewController : UIViewController
@property NSInteger type;       // 0: btn
                                // 1: fil
@property NSInteger info; //0 - tag btn
@property NSString* info_title; //1 - titolo
@property NSString* info_file;  //1 - file da aprire
@end
