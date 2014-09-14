//
//  GetData.m
//  Chb
//
//  Created by Massimo on 4/20/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "GetData.h"
#import "Reachability.h"

@implementation GetData
    
const NSString *serverURI = @"http://shap.no-ip.biz:50026/chb/";

// Gestisci UI

// View Caricamento
- (void) loadResources:(NSArray*)resources completion:(void (^)(void))completionBlock
{
    
    //Espandi e Avvia indicatore
    // border radius
    [self.loading.layer setCornerRadius:5.0f];
    // border
    /*[self.loading.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loading.layer setBorderWidth:1.0f];*/
    // drop shadow
    /*[self.loading.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loading.layer setShadowOpacity:0.8];
    [self.loading.layer setShadowRadius:3.0];
    [self.loading.layer setShadowOffset:CGSizeMake(2.0, 2.0)];*/
    //indicatore
    [self.indicator startAnimating];
    
    //Create Execution Block
    void (^exeBlock)(void);
    exeBlock = ^{
        
        //Scarica Risorse
        for (NSString *res in resources) {
            NSArray* chunk = [res componentsSeparatedByString:@"." ];
            [self getPathFor:[chunk objectAtIndex:0] fileType:[chunk objectAtIndex:1] initRes:YES];
        }
        
        //Completa
        completionBlock();
        
    };
    
    //Nuovo Thread
    [NSThread detachNewThreadSelector:@selector(inNewThread:) toTarget:self withObject:exeBlock];
}
- (void) inNewThread:(void (^)(void))executionBlock {
    
    //Run
    executionBlock();
    
    //Chiudi
    //[self performSelector:@selector(closeThings) withObject:nil afterDelay:2];
    [self.indicator stopAnimating];
    [self.loading setHidden:YES];
    
}



// Gestisci richieste DATI
- (NSString*) getPathFor:(NSString*)file fileType:(NSString*)file_type initRes:(bool)onlineUpdate {
    
    NSString *filename = [[file stringByAppendingString:@"."] stringByAppendingString:file_type];
    
    //Check Internet
    BOOL doOffiline = false;
    if(onlineUpdate){
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus != NotReachable) {
            NSLog(@"There IS internet connection");
            
            //1 Download new
            NSURL *url = [NSURL URLWithString:[serverURI stringByAppendingString:filename]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setTimeoutInterval: 3.0]; // Will timeout after 2 seconds
            request.cachePolicy=NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            //Check Error
            BOOL isInvalid = NO;
            if ([response respondsToSelector:@selector(statusCode)])
            {
                NSLog(@"didReceiveResponse statusCode with %@",
                      [NSHTTPURLResponse localizedStringForStatusCode: [response statusCode]]);
                if ([response statusCode] == 404)
                {
                    isInvalid = YES;
                }
            }else{
                if(urlData == nil)
                    isInvalid = YES;
                if(error!=nil)
                    isInvalid = YES;
            }
            
            if (!isInvalid)
            {
                NSArray   *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString  *myPath = [myPathList objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", myPath,filename];
                [urlData writeToFile:filePath atomically:YES];
                
                return filePath;
            }
            else
            {
                NSLog(@"ERROR DOWNLOADING DATA");
                doOffiline = true;
            }
            
            //Trash
            /*
             NSString *stringURL = @"http://www.somewhere.com/thefile.png";
             NSURL  *url = [NSURL URLWithString:stringURL];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             if ( urlData )
             {
             NSArray   *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
             NSString  *myPath = [myPathList objectAtIndex:0];
             
             NSString  *filePath = [NSString stringWithFormat:@"%@/%@", myPath,@"filename.png"];
             [urlData writeToFile:filePath atomically:YES];
             
             return filePath;
             }
             */
            
        } else {
            doOffiline = true;
        }
    } else {
        doOffiline = true;
    }
    
    if (doOffiline) {
        NSLog(@"There IS NO internet connection");
        
        //Check Cached
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        
        myPath = [myPath stringByAppendingPathComponent:filename];
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            //2 Return Cached
            return myPath;
        }
        else
        {
            //3 Prendi Offline
            return [[NSBundle mainBundle] pathForResource:file ofType:file_type];
        }
        
    }
    
    //not reached code
    return nil;
    
}

@end
