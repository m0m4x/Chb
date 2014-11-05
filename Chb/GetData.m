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
- (void) loadResources:(void (^)(void))completionBlock
{
    
    //Espandi e Avvia indicatore
    [self.loading setHidden:NO];
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
        
        //Il lavoro viene fatto all'interno della completionBlock
        //in definizione funzione: (NSArray*)resources
        /*
        //Scarica Risorse
        for (NSString *res in resources) {
            NSArray* chunk = [res componentsSeparatedByString:@"." ];
            [self getPathFor:[chunk objectAtIndex:0] fileType:[chunk objectAtIndex:1] initRes:YES];
        }
        */
        
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
- (NSString*) getPathFor:(NSString*)file fileType:(NSString*)file_type checkOnline:(bool)onlineUpdate {
    
    NSString *filename = [[file stringByAppendingString:@"."] stringByAppendingString:file_type];
    
    NSLog(@"getPathFor: %@", filename);
    
    //Check Internet
    BOOL doOffiline = false;
    if(onlineUpdate){
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus != NotReachable) {
            //NSLog(@"getPathFor: test connection ok");
            
            //Controlla URL
            NSString *url_req;
            NSArray* test = [filename componentsSeparatedByString:@"/" ];
            if([test[0] isEqual:@"http:"]){
                url_req=filename;
            }else{
                url_req=[serverURI stringByAppendingString:filename];
            }
            
            //Download
            NSURL *url = [NSURL URLWithString:url_req];
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
                //NSLog(@"getPathFor: downloading resource statusCode %@",[NSHTTPURLResponse localizedStringForStatusCode: [response statusCode]]);
                
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
                //NSLog(@"getPathFor: res found online!");
                
                //Componi nome in Cache
                NSArray   *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString  *myPath = [myPathList objectAtIndex:0];
                
                NSArray* chunk = [filename componentsSeparatedByString:@"/" ];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@",
                                       myPath,[chunk lastObject]];
                
                [urlData writeToFile:filePath atomically:YES];
                
                //NSLog(@"getPathFor: res online cached to: %@", filePath);
                return filePath;
            }
            else
            {
                //NSLog(@"getPathFor: res not available online!");
                
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
            //NSLog(@"getPathFor: test connection fail");
            doOffiline = true;
        }
    } else {
        doOffiline = true;
    }
    
    if (doOffiline) {
        //NSLog(@"getPathFor: reverting to offline...");
        
        //Controllo in Cache
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        
        myPath = [myPath stringByAppendingPathComponent:filename];
        if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            //2 Prendi quella in Cache
            //NSLog(@"getPathFor: res offline cached: %@",myPath);
            return myPath;
        }
        else
        {
            //3 Prendi versione Bundle (se esiste)
            NSString *local_path = [[NSBundle mainBundle] pathForResource:file ofType:file_type];
            if([[NSFileManager defaultManager] fileExistsAtPath:local_path] == TRUE)
            {
                //NSLog(@"getPathFor: res offline local: %@",local_path);
                return local_path;
            }
            else
            {
                //NSLog(@"getPathFor: Error: res not found!");
                return nil;
            }
            
        }
        
    }
    
    //not reached code
    return nil;
    
}

@end
