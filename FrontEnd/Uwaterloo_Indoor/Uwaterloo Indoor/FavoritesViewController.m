//
//  FavoritesViewController.m
//  Uwaterloo Indoor
//
//  Created by Owner on 2017-11-15.
//  Copyright © 2017 Owner. All rights reserved.
//
#import "ImageViewController.h"
#import "ImageNaviController.h"
#import "FavoritesViewController.h"
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
//long sendCoordsIndex;

@interface FavoritesViewController ()<UITableViewDataSource, UITableViewDelegate>{
    UIAlertController *pending;
}

@property (nonatomic ,strong) UITableView* savedTableView;
@property NSMutableArray *savedList;
@property NSUserDefaults *userDefaults;
@property NSString *sendCoords;

//@property NSMutableArray *savedListDetails;

@end

@implementation FavoritesViewController

- (void) serverRequest:(NSDictionary *)sendDict function:(NSString*) operationName completion:(void (^)(id responseObject, NSError *error))completion
{
    
    NSURL *url = [NSURL URLWithString:[@"http://18.216.78.130/UserInfo.svc/" stringByAppendingString:operationName]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    //  NSData *dataIn = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
    //   request.HTTPBody = dataIn;
    
    //[request setHTTPBody:dataIn];
    
    
    // 3
    //  NSDictionary *dictionary = @{@"username": @"chenyu",@"password": @"1234567890"};
    NSLog (@"%@", sendDict);
    
    
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendDict options:kNilOptions error:&error];
    //NSData *data = [@"12" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataIn = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:nil];
    // NSData *dataIn = [@"hgghhh" dataUsingEncoding:NSUTF8StringEncoding];
    //  NSString *string = @"123";
    //  NSData *dataIn = [NSJSONSerialization dataWithJSONObject:string options:0 error:nil];
    
    request.HTTPBody = dataIn;
    
    if (!error) {
        // 4
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       
                                                                       if (!data) {
                                                                           if (completion) {
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(nil, error);
                                                                               });
                                                                           }
                                                                           return;
                                                                       }
                                                                       
                                                                       // report any errors parsing the JSON
                                                                       
                                                                       NSError *parseError = nil;
                                                                       NSData *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                       
                                                                       if (!returnedData) {
                                                                           if (completion) {
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   completion(nil, parseError);
                                                                               });
                                                                           }
                                                                           return;
                                                                       }
                                                                       
                                                                       // if everything is ok, then just return the JSON object
                                                                       
                                                                       if (completion) {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               completion(returnedData, nil);
                                                                           });
                                                                       }
                                                                   }];
        
        [uploadTask resume];
    }
}


- (void)configureTableView:(NSArray*)array
{
//    _userDefaults = [NSUserDefaults standardUserDefaults];
//   _savedList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Name"]];
  //  _savedList = [[NSMutableArray alloc] initWithArray:@[@"Apple",@"HP",@"IBM",@"Facebook"]];
 //   _savedListDetails = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"savedListDetails"]];
    
    _savedList = [[NSMutableArray alloc]initWithArray:array];
    _savedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _savedTableView.delegate = self;
    _savedTableView.dataSource = self;
    _savedTableView.backgroundColor = [UIColor whiteColor];
    _savedTableView.backgroundView = nil;
    _savedTableView.allowsMultipleSelectionDuringEditing = NO;
    _savedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    _savedTableView.autoresizingMask = UIViewAutoresizingNone;
    _savedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_savedTableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleIdentifier=@"SimpleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SimpleIdentifier];
    }
    cell.textLabel.text = [[_savedList objectAtIndex:indexPath.row] objectAtIndex:0];
  //  cell.detailTextLabel.text = [_savedListDetails objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Saved List"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _savedList.count;
}

//删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delate";
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从数据源中删除
    [_savedList removeObjectAtIndex:indexPath.row];
    // 从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
    
//    NSMutableArray *list = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Name"]];
//    [list removeObjectAtIndex: indexPath.row];
//    [_userDefaults setObject:list forKey:@"Name"];
//    
//    NSMutableArray *list2 = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Latitude"]];
//    [list2 removeObjectAtIndex: indexPath.row];
//    [_userDefaults setObject:list2 forKey:@"Latitude"];
//    
//    NSMutableArray *list3 = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Longitude"]];
//    [list3 removeObjectAtIndex: indexPath.row];
//    [_userDefaults setObject:list3 forKey:@"Longitude"];
    
    [_userDefaults synchronize];
      [tableView reloadData];
    
}

//选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self updateFavoriteList];
//    NSMutableArray *laList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Latitude"]];
//    NSString *laData = laList[indexPath.row];
//    NSMutableArray *loList = [[NSMutableArray alloc] initWithArray: [_userDefaults objectForKey:@"Longitude"]];
//    NSString *loData = loList[indexPath.row];
    NSString* coords = [[_savedList objectAtIndex:indexPath.row] objectAtIndex:1];
    NSArray *coordArray = [coords componentsSeparatedByString:@","];
    _sendCoords = [NSString stringWithFormat:@"%@,%@", coordArray[0], coordArray[1]];
    
    [self performSegueWithIdentifier:@"gotoImage" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoImage"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        ImageNaviController* nav = segue.destinationViewController;
        ImageViewController *receive = (ImageViewController *)nav.topViewController;
        receive.savedCoords = _sendCoords;
        receive.login = true;
        receive.userName = _userName;
        
    }
}
- (IBAction)gotoImage:(id)sender {
    [self performSegueWithIdentifier:@"gotoImage" sender:self];
    [self updateFavoriteList];
   //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dictionary = @{@"username": _userName};
    [self serverRequest:dictionary function:@"GetFavorite" completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            // do what you want with the response object here
            NSLog(@"get %@",responseObject);
            NSArray* array = responseObject;
            [self configureTableView:array];
            //  NSDictionary* result2 = responseObject;
            // NSLog(@"%@",result2 [@"GetCoordResult"]);
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
        }
    }];
    
   // [self configureTableView];
    // Do any additional setup after loading the view.
   // NSLog(@"%d",a);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateFavoriteList{
    NSDictionary *dictionary = @{@"username": _userName,@"idList":_savedList, @"isAdd": [NSNumber numberWithInt:0]};
    [self serverRequest:dictionary function:@"SetFavorite" completion:^(id responseObject, NSError *error) {
        if (responseObject) {
            // do what you want with the response object here
            NSLog(@"get %@",responseObject);
        //    NSArray* array = responseObject;
            //  NSDictionary* result2 = responseObject;
            // NSLog(@"%@",result2 [@"GetCoordResult"]);
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
        }
    }];
}
//- (IBAction)goBack:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
