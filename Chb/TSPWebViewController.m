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
#import "GetData.h"


@interface TSPWebViewController ()

@property GetData *dataObj;

@property NSString *currentFilename;

@end

@implementation TSPWebViewController

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
    
    //Title
    self.title= self.info_title;
    
    //BackGround
    UIImage *bg = [UIImage imageNamed:@"noise"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    //WebView Get Resource to Visualize
    switch (self.type) {
        case 0: //btn
            switch (self.info) {
                case 100:
                    self.title= @"ChiantiBanca";
                    self.currentFilename = @"chb.htm";
                    
                    break;
                case 200:
                    self.title= @"Bilancio";
                    self.currentFilename = @"bilancio.htm";
                    
                    break;
                case 400:
                    self.title= @"Iniziative Sociali";
                    self.currentFilename = @"iniziative.htm";
                    
                    break;
                case 500:
                    self.title= @"Governance";
                    self.currentFilename = @"governance.htm";
                    
                    break;
                case 600:
                    self.title= @"Notizie";
                    self.currentFilename = @"notizie.htm";
                    
                    break;
                default:
                    break;
            }
            break;
        case 1: //fil
            self.currentFilename = [self.info_file stringByAppendingString:@".html"];
            break;
        default:
            break;
    }

    
    //Favorite Btn (solo con type 1)
    [self prepareFavBtn];
    
    
    //Caricamento Risorse
    self.dataObj = [GetData alloc];
    self.dataObj.loading = (UIView*) [self.view viewWithTag:50];
    self.dataObj.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    
    NSString *localizeFileName = self.currentFilename;
    [self.dataObj loadResources:[NSArray arrayWithObjects:self.currentFilename, nil] completion:^{
        
        NSArray* chunk = [localizeFileName componentsSeparatedByString:@"." ];
        NSString *file = [self.dataObj getPathFor:[chunk objectAtIndex:0] fileType:[chunk objectAtIndex:1] initRes:NO];
        [self loadView:file];
        
    }];
    
    //Poi il percorso delle risorse si otterrà con:
    //[self.dataObj getPathFor:@"filiali" fileType:@"txt" checkOnline:NO];
    
    
}


- (void)loadView:(NSString*)resource{
    
    UIWebView *webView = (UIWebView*)[self.view viewWithTag:800];
    
    NSString* htmlString = [NSString stringWithContentsOfFile:resource encoding:NSUTF8StringEncoding error:nil];
    
    [webView loadHTMLString:htmlString baseURL:nil];
    
}



//Prepare Btn Fav

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
