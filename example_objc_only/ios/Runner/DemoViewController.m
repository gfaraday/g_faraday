//
//  DemoViewController.m
//  Runner
//
//  Created by gix on 2021/2/26.
//

#import "DemoViewController.h"

@import g_faraday;

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onTapShowFlutter:(UIButton *)sender {
    
    FFViewController *fvc = [[FFViewController alloc] init:@"home" arguments:nil backgroundClear:NO engine:nil callback:^(id _Nullable result) {
        
    }];
    
    [self presentViewController:fvc animated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
