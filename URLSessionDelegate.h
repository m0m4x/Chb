//
//  TSPURLSessionDelegate.h
//  Chb
//
//  Created by max on 05/11/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol definition starts here
@protocol ProtocolDelegate <NSObject>
@required
- (void) updateProgress;
@end
// Protocol Definition ends here

@interface URLSessionDelegate : NSObject
<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

{
    // Delegate to respond back
    id <ProtocolDelegate> _delegate;
    
}
@property (nonatomic,strong) id delegate;


//- (void)setNewDelegate:(id *)BilVC;

@property (nonatomic, strong) NSURLSession *session;

//@property (nonatomic, assign) TSPBilViewController* vcontroller;

@end

