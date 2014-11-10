//
//  TSPViewController.m
//  Chb
//
//  Created by Massimo on 4/13/14.
//  Copyright (c) 2014 Massimo Zanini. All rights reserved.
//

#import "TSPViewController.h"
#import "TSPWebViewController.h"
#import "TSPBilViewController.h"


@interface TSPViewController ()

@property NSInteger btn_type;

@property UIView *loading;
@property UIActivityIndicatorView *indicator;

@property TSPBilViewController *vc_b;

- (void) closeThings;

@end

@implementation TSPViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Caricamento
    self.loading = (UIView*) [self.view viewWithTag:50];
    self.indicator = (UIActivityIndicatorView*) [self.view viewWithTag:60];
    [self loadThings];
    
    // Ios 6
     if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets  = NO;
    
    //Barra superiore
        //Disabilita
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        //Testo Indietro
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //BackGround
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImage setImage:[UIImage imageNamed:@"noise"]];
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view insertSubview:backgroundImage atIndex:0];
    
    //Metti testo a label
    UILabel *label1 = (UILabel*) [self.view viewWithTag:130];
    UILabel *label2 = (UILabel*) [self.view viewWithTag:230];
    UILabel *label3 = (UILabel*) [self.view viewWithTag:330];
    UILabel *label4 = (UILabel*) [self.view viewWithTag:430];
    UILabel *label5 = (UILabel*) [self.view viewWithTag:530];
    UILabel *label6 = (UILabel*) [self.view viewWithTag:630];
    label1.numberOfLines = 1;
    label2.numberOfLines = 1;
    label3.numberOfLines = 1;
    label4.numberOfLines = 1;
    label5.numberOfLines = 1;
    label6.numberOfLines = 1;
    label1.text = @"numeri";
    label2.text = @"governance";
    label3.text = @"bilancio";
    label4.text = @"sociale";
    label5.text = @"filiali";
    label6.text = @"notizie";
    
    //Tasto Favoriti
    [self prepareFavBtn];

}


// View Caricamento
- (void) loadThings
{
    //Espandi e Avvia indicatore
    //TODO
    [self.indicator startAnimating];
    
    //Nuovo Thread
    [NSThread detachNewThreadSelector:@selector(inNewThread:) toTarget:self withObject:nil];
}
- (void) inNewThread:(id)data {
    
    //...lots of computation...
    /*NSString *stringURL = @"http://www.somewhere.com/thefile.png";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"banner.png"];

        NSError *writeError = nil;
        
        [urlData writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
        
        if (writeError) {
            NSLog(@"Error writing file: %@", writeError);
        }
 
    }*/
    
    //Chiudi
    //[self performSelector:@selector(closeThings) withObject:nil afterDelay:2];
    [self closeThings];
    
}
- (void) closeThings {
    [self.indicator stopAnimating];
    [self.loading removeFromSuperview];
}


//Tasto principale premuto
- (void)doBtnPressed:(NSInteger) type
{
    NSLog(@"-doBtnPressed");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    
    self.btn_type = type;
    switch (type) {
        case 100:
        case 200:
        case 400:
        case 600:
        {
            //webview
            TSPWebViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"view_web"];
            view.type = 0;
            view.info = self.btn_type;
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 300:
        {
            //bilanci
            if(self.vc_b == nil){
                self.vc_b = [storyboard instantiateViewControllerWithIdentifier:@"view_bilancio"];
                //[self.vc_b setModalPresentationStyle:UIModalPresentationFullScreen];
                //[self.vc_b setModalTransitionStyle:ui];
            }
            [self.navigationController pushViewController:self.vc_b animated:YES];
            // Modal
            //[self presentModalViewController:self.vc_b animated:YES ];
            //[self presentViewController:self.vc_b animated:YES completion:nil];
        }
            
            break;
        case 500:
        {
            //mappa
            TSPWebViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"view_filiali"];
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 900:
        {
            //favorito
            TSPWebViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"view_web"];
            view.type = 1;
            view.info_title= [[[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_title"]componentsSeparatedByString:@"." ] objectAtIndex:0];
            view.info_file= [[NSUserDefaults standardUserDefaults] objectForKey:@"fav_file"];
            [self.navigationController pushViewController:view animated:YES];

        }
            break;
        default:
            break;
    }
    
}
//Tasto Favoriti premuto
- (void)gotoFav{
    
    [self doBtnPressed:900];
    
}

//Prepare Segue
/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"-prepareForSegue");
    
    if([segue.identifier isEqualToString:@"btn_web"]){
        TSPWebViewController *controller = (TSPWebViewController *)segue.destinationViewController;
        if(self.btn_type == 900){
            //Favorito (Filiale)
            controller.type= 1;
            controller.info_title= [[[[NSUserDefaults standardUserDefaults] objectForKey:@"fav_title"]componentsSeparatedByString:@"." ] objectAtIndex:0];
            controller.info_file= [[NSUserDefaults standardUserDefaults] objectForKey:@"fav_file"];
        }else{
            //Bottone
            controller.type= 0;
            controller.info= self.btn_type;
        }

    }
}
*/

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"-viewWillAppear");
    [super viewWillAppear:animated];
    [self prepareFavBtn]; // to refresh
}

- (void) prepareFavBtn{
    
    //Favorite Btn (solo con type 1)
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"fav_title"] != nil){
        
        UIImage* image3 = [UIImage imageNamed:@"star_full"];
        CGRect frameimg = CGRectMake(0, 0, 20, 20);
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        someButton.frame = frameimg;
        [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(gotoFav)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem=mailbutton;
        
    } else if (self.navigationItem.rightBarButtonItem != nil){
        
        self.navigationItem.rightBarButtonItem=nil;
        
    }
    
}




//Altro
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
