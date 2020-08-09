//
//  AlertSignChooseView.m
//  QukanTool
//
//  Created by yang on 2018/2/28.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "AlertSignChooseView.h"
#import "AlertSignCell.h"

@interface AlertSignChooseView()

@property(copy,nonatomic)chooseCallBack callBack;
@property(strong,nonatomic) UITableView *tab_list;
@property(strong,nonatomic) NSMutableArray *dataArray;

@end

@implementation AlertSignChooseView
//-(instancetype)initWithObjects:(NSArray*)array  callBack:(chooseCallBack)callBack{
//    NSMutableArray *array_lists = [[NSMutableArray alloc] init];
//    for(BaseBean *object in array){
//        AlertSignChooseBean *bean = [AlertSignChooseBean new];
//        bean.name = object.base_name;
//        bean.data = object;
//        [array_lists addObject:bean];
//    }
//    return [self init:array_lists frame:webpubs.window.bounds callBack:callBack];
//}


-(instancetype)init:(NSArray*)array frame:(CGRect)frame callBack:(chooseCallBack)callBack{
    
    if(self = [super initWithFrame:frame]){
        int width = frame.size.width;
        int height = frame.size.height;
        self.dataArray = [[NSMutableArray alloc] initWithArray:array];
        self.callBack = callBack;
        NSInteger maxHeight = width - 74 - 64;
        NSInteger tabHeight = array.count * 50;
        if(tabHeight > maxHeight){
            tabHeight = maxHeight;
        }
        [self initList:CGRectMake(20, height - tabHeight - 74, width - 40, tabHeight)];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, height - 62, width - 40, 50);
        btn.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [btn setTitleColor:[UIColor colorWithRed:255/255.0 green:70/255.0 blue:58/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self addSubview:btn];
        [btn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4.0;
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        close.frame = self.bounds;
        [self insertSubview:close atIndex:0];
        [close addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

-(void)closeView{
    [self removeFromSuperview];
}


-(void)initList:(CGRect)rect{
    self.tab_list = [[UITableView alloc] initWithFrame:rect];
    self.tab_list.delegate = self;
    self.tab_list.dataSource = self;
    self.tab_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tab_list.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tab_list];
    self.tab_list.layer.cornerRadius = 4.0;
    self.tab_list.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.dataArray == nil){
        return 0;
    }

    return self.dataArray.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"cell";
    
    AlertSignCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AlertSignCell" owner:nil options:nil];
        cell = [array objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    AlertSignChooseBean *bean = [self.dataArray objectAtIndex:indexPath.row];
    cell.lbl_name.text = bean.name;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count==0){
        return self.tab_list.frame.size.height;
    }
    return 50.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count==0){
        return;
    }
    AlertSignChooseBean *bean = [self.dataArray objectAtIndex:indexPath.row];

    if(self.callBack){
        self.callBack(bean);
        [self closeView];
    }
}


@end
