//
//  ViewController.m
//  ZPSearchBar_customized
//
//  Created by 赵鹏 on 2018/10/18.
//  Copyright © 2018 赵鹏. All rights reserved.
//

/**
 在本Demo中，原始数据呈现页、搜索页（点击搜索框之后键入搜索内容之前的页面）、搜索结果呈现页（在搜索框键入搜索内容以后的页面）这三个页面共用同一个本视图控制器；
 */
#import "ViewController.h"
#import "Model.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *modelsMulArray;  //存储原始对象的可变数组
@property (nonatomic, strong) NSMutableArray *resultsMulArray;  //存储搜索结果的可变数组
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;  //搜索控制器

@end

@implementation ViewController

#pragma mark ————— 懒加载 —————
- (NSMutableArray *)modelsMulArray
{
    if (_modelsMulArray == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tempMulArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray)
        {
            Model *model = [Model modelWithDict:dict];
            [tempMulArray addObject:model];
        }
        
        _modelsMulArray = tempMulArray;
    }
    
    return _modelsMulArray;
}

- (NSMutableArray *)resultsMulArray
{
    if (_resultsMulArray == nil)
    {
        _resultsMulArray = [NSMutableArray array];
    }
    
    return _resultsMulArray;
}

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    //创建UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;  //当搜索框激活时是否添加一个透明的视图
    self.searchController.hidesNavigationBarDuringPresentation = NO;  //当搜索框激活时不隐藏导航栏
    self.searchController.searchResultsUpdater = self;  //设置搜索结果更新的代理(UISearchResultsUpdating)
    
    //设置搜索框
    self.navigationItem.titleView = self.searchController.searchBar;  //把搜索框设置在导航栏上
    [self.searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"bg.jpg"] forState:UIControlStateNormal];  //设置搜索框中的文本框的背景图片
    self.searchController.searchBar.placeholder = @"请输入搜索内容";  //设置搜索框中的文本框的placeholder
    self.searchController.searchBar.delegate = self;  //设置UISearchBar的代理(UISearchBarDelegate)
    
    /**
     想要把搜索框上的取消按钮的标题由英文的"cancel"改为中文的“取消”有如下的几种方法。
     方法1：
     */
    [self.searchController.searchBar setValue:@"取消" forKey:@"cancelButtonText"];
    
    /**
     方法2：
     */
//    [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = @"取消";
    
    /**
     方法3：
     */
//    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:[NSArray arrayWithObject:[UISearchBar class]]] setTitle:@"取消"];
}

#pragma mark ————— UITableViewDataSource —————
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    /**
     通过active属性的BOOL值来判断用户是否已经点击了搜索框。
     */
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        count = 0;
    }else if (self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        count = self.resultsMulArray.count;
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        count = self.modelsMulArray.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        cell = nil;
    }else if (self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        Model *resultModel = [self.resultsMulArray objectAtIndex:indexPath.row];
        cell.textLabel.text = resultModel.name;
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        Model *model = [self.modelsMulArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.name;
    }
    
    return cell;
}

#pragma mark ————— UITableViewDelegate —————
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        return;
    }else if(self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        Model *resultModel = [self.resultsMulArray objectAtIndex:indexPath.row];
        NSLog(@"您点击了搜索结果中的%@", resultModel.name);
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        Model *model = [self.modelsMulArray objectAtIndex:indexPath.row];
        NSLog(@"您点击了原始数据中的%@", model.name);
    }
}

#pragma mark ————— UISearchResultsUpdating —————
/**
 用户在搜索框中输入一次内容，系统就会自动调用一次这个代理方法；
 在实际项目中，用户在搜索框输入内容后就会与后台进行交互，向后台发起请求并解析后台返回的数据，然后把数据显示在搜索结果呈现页面上。
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *inputStr = searchController.searchBar.text;
    NSLog(@"搜索框输入的文字为：%@", inputStr);
    
    if (self.resultsMulArray.count > 0)
    {
        [self.resultsMulArray removeAllObjects];
    }
    
    //假定跟后台交互后获取到的搜索结果是原始对象数组里面的前三个
    NSArray *modelsArray = (NSArray *)self.modelsMulArray;
    NSArray *resultsArray = [modelsArray subarrayWithRange:NSMakeRange(0, 3)];
    self.resultsMulArray = [resultsArray mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark ————— UISearchBarDelegate —————
/**
 把搜索框上的取消按钮的标题由英文的"cancel"改为中文的“取消”的方法4：
 已经开始编辑搜索框中的文本内容的时候会调用这个方法。
 */
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    self.searchController.searchBar.showsCancelButton = YES;  //这句话必须要写，不然不能把英文的"cancel"改成中文的“取消”。
//
//    for (id cencelButton in [self.searchController.searchBar.subviews[0] subviews])
//    {
//        if([cencelButton isKindOfClass:[UIButton class]])
//        {
//            UIButton *btn = (UIButton *)cencelButton;
//            [btn setTitle:@"取消"  forState:UIControlStateNormal];
//        }
//    }
//}

@end
