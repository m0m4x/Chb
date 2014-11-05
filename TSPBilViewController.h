//
//  TSPBilViewController.h
//  Chb
//
//  Created by max on 31/10/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "URLSessionDelegate.h" 

@interface TSPBilViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource,
NSURLSessionDelegate, NSURLSessionDownloadDelegate,
ProtocolDelegate >

@property (weak, nonatomic) IBOutlet UITableView *tblFiles;


- (IBAction)startOrPauseDownloadingSingleFile:(id)sender;

- (IBAction)stopDownloading:(id)sender;

- (IBAction)startAllDownloads:(id)sender;

- (IBAction)stopAllDownloads:(id)sender;

- (IBAction)initializeAll:(id)sender;

- (IBAction)OpenFile:(id)sender;

@end
