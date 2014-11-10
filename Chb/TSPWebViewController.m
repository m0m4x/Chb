//
//  TSPWebViewController.m
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPWebViewController.h"
#import "FindUIViewController.h"
#import "TSPViewController.h"
#import "TSPPageViewController.h"
#import "GetData.h"


#import "PageViewController.h"

@interface TSPWebViewController ()

@property GetData *dataObj;
@property NSString *currentFilename;

@end


@implementation TSPWebViewController

@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Oggetti
    self.dataObj = [GetData alloc];
    self.dataObj.loading = (UIView*) [self.view viewWithTag:50];
    self.dataObj.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    
    UIImageView *bg = (UIImageView*) [self.view viewWithTag:3];
    UILabel *label_title = (UILabel *)[self.view viewWithTag:30];
    UIButton *button_back = (UIButton *)[self.view viewWithTag:5];
    
    //Set Delegate
    self.webView.delegate = self;
    //UIWebView *webview = (UIWebView*) [self.view viewWithTag:50];
    //[webview setDelegate:self];
    
    //Title
    self.title=self.info_title;
    label_title.text = self.info_title;
    
    //Back Button
    [button_back setImage:[UIImage imageNamed:@"icon-back.png"] forState:UIControlStateNormal];
    
    //BackGround
    /*
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImage setImage:[UIImage imageNamed:@"noise"]];
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view insertSubview:backgroundImage atIndex:0];
     */
    
    //WebView Get Resource to Visualize
    switch (self.type) {
        case 0: //btn
            switch (self.info) {
                case 100:
                    self.title= @"numeri";
                    label_title.text = @"numeri";
                    self.currentFilename = @"numeri.htm";
                    [bg setImage:[UIImage imageNamed:@"bg_numeri.png"]];
                    break;
                case 200:
                    self.title= @"governance";
                    label_title.text = @"governance";
                    self.currentFilename = @"governance.html";
                    [bg setImage:[UIImage imageNamed:@"bg_governance.png"]];
                    break;
                case 300:
                    self.title= @"bilancio";
                    label_title.text = @"bilancio";
                    self.currentFilename = @"bilancio.htm";
                    [bg setImage:[UIImage imageNamed:@"bg_bilancio.png"]];
                    break;
                case 400:
                    self.title= @"sociale";
                    label_title.text = @"sociale";
                    self.currentFilename = @"sociale.htm";
                    [bg setImage:[UIImage imageNamed:@"bg_sociale.png"]];
                    break;
                case 600:
                    self.title= @"notizie";
                    label_title.text = @"notizie";
                    self.currentFilename = @"notizie.htm";
                    [bg setImage:[UIImage imageNamed:@"bg_notizie.png"]];
                    break;
                default:
                    break;
            }
            break;
        case 1: //fil
            //self.title= self.info_title;
            //label_title.text = self.info_title;
            self.currentFilename = [self.info_file stringByAppendingString:@".html"];
            [bg setImage:[UIImage imageNamed:@"bg_vuoto.png"]];
            break;
        default:
            break;
    }

    
    //Favorite Btn (solo con type 1)
    [self prepareFavBtn];
    
    
    //Carica Risorse
    NSString *localizeFileName = self.currentFilename;
    [self.dataObj loadResources:^{
        
        NSArray* chunk = [localizeFileName componentsSeparatedByString:@"." ];
        NSString *file = [self.dataObj getPathFor:[chunk objectAtIndex:0] fileType:[chunk objectAtIndex:1] checkOnline:YES];
        [self loadView:file];
        
    }];
    
    //Trash
    /*
     [self.dataObj loadResources:[NSArray arrayWithObjects:self.currentFilename, nil] completion:^{
     */
    //Poi il percorso delle risorse si otterrà con:
    //[self.dataObj getPathFor:@"filiali" fileType:@"txt" checkOnline:NO];
    
    
    
}

- (IBAction)handleBackBtn:(id)sender {
    if([self.webView canGoBack]){
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}



/*WEBVIEW*/

- (void)loadView:(NSString*)resource{
    
    UIWebView *webView = (UIWebView*)[self.view viewWithTag:800];
    NSString* resString = [NSString stringWithContentsOfFile:resource encoding:NSUTF8StringEncoding error:nil];
    NSURL* resPath = [NSURL fileURLWithPath:resource];
    
    [webView loadHTMLString:resString baseURL:resPath];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Load Finished");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = [request.URL absoluteString];
    
    //Check PDF
    NSRange range = [url rangeOfString:@".pdf" options:NSCaseInsensitiveSearch];
    if ( range.location != NSNotFound &&
        range.location + range.length == [url length] )
    {
        //se risorsa esterna
        
        //Scarica PDF
        [self.dataObj loadResources:^{
            
            NSString *file_req;
            
            //Controlla URL
            NSArray* chunk1 = [url componentsSeparatedByString:@"/" ];
            if([chunk1[0] isEqual:@"http:"]){
                //per url esterni lascia url
                file_req=url;
            }else{
                //per url interni prendi solo ultimo tratto url (evita protocollo applewebdata e simili)
                file_req=[chunk1 lastObject];
            }
            
            //Scarica risorsa
            NSString *file = [self.dataObj getPathFor:[file_req stringByDeletingPathExtension] fileType:[file_req pathExtension] checkOnline:YES];
            
            //Apri PDF
            [self vediPDF:file];
            
        }];

        return NO;
    }
    
    return YES;
    
}

-(void) vediPDF:(NSString*) path{
   
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"BILANCIO_WEB4_1536" ofType:@"pdf"];
    
    //Inizializza Page Controller
    TSPPageViewController *page =
        [[TSPPageViewController alloc] initWithPDFAtPath:path];
    
    [self.navigationController pushViewController:page animated:YES];

    //[self presentViewController:page animated:YES completion:NULL];
    
}



/*FAVORITI*/

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"-viewWillAppear");
    [super viewWillAppear:animated];
    [self prepareFavBtn]; // to refresh
}

- (void) prepareFavBtn{
    
    if(self.type == 1){
        
        UIImage* image3 ;
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"fav_file"] == self.info_file) {
            image3 = [UIImage imageNamed:@"star_full"];
        }else{
            image3 = [UIImage imageNamed:@"star_line"];
        }
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [UIButton buttonWithType:UIButtonTypeCustom];
        someButton.frame = frameimg;
        [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(addFav)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        
        UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem=mailbutton;
        
    }
    
}

- (void)addFav {
    
    NSLog(@"Pressed Fav");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"fav_file"] == self.info_file) {
        //Remove from fav
        [userDefaults removeObjectForKey:@"fav_title"];
        [userDefaults removeObjectForKey:@"fav_file"];
        
        //Change Image
        UIImage* image3 = [UIImage imageNamed:@"star_line"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        someButton.frame = frameimg;
        [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(addFav)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem=mailbutton;
        
    }else{
        //Add to fav
        
        //Change Image
        UIImage* image3 = [UIImage imageNamed:@"star_full"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        someButton.frame = frameimg;
        [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(addFav)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem=mailbutton;
        
        //Save Setting
        [userDefaults setObject:self.title
                         forKey:@"fav_title"];
        [userDefaults setObject:self.info_file
                         forKey:@"fav_file"];
        
        
    }
    [userDefaults synchronize];
    
}















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
