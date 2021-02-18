//
//  YRequireAddressView.m
//  CoinID
//
//  Created by MWTECH on 2019/10/30.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "YRequireAddressView.h"
#import "zhPopupController.h"
#import "Enum.h"
#import "YCommonMethods.h"
#import "Masonry.h"
#import "UIView+Additions.h"
#import "UIFont+Size.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ChannelDapp.h"


#define HeaderViewHeight 106

@implementation YRequireAddressViewCellModel


@end


@interface YRequireSignView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView * headView ;
@property (nonatomic,strong) UITableView * tableView ;

@property (nonatomic,strong) zhPopupController * zhp ;
@property (nonatomic,assign) VDATYPE daiType ;
@property (nonatomic,copy)  ActionBlock actionBlock ;
@property (nonatomic,strong) UILabel * titleLabel ;
@property (nonatomic,strong) UIButton * confirmBtn  ;


@end

@implementation YRequireSignView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [ super initWithFrame:frame]) {
        
        [self buildWithView];
    }
    return self ;
}

-(void)buildWithView{
    
    self.layer.masksToBounds  = YES ;
    self.layer.cornerRadius = 10.f ;
    self.backgroundColor = UIColor.whiteColor ;
    self.headView.backgroundColor = UIColor.clearColor ;
   
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self  addSubview:self.tableView];
    
    UIView * tabFooter = ({
       
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 16)];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(ADAPTATIONIPHWidth(83), 0, KSCREEN_WIDTH - ADAPTATIONIPHWidth(83) - 20, 16)];
        label.textColor = NewTextColor;
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 10] ;
        label.text = @"推荐矿工费 (根据区块链网络波动)";
        label.textAlignment = NSTextAlignmentLeft ;
        [view addSubview:label];
        view ;
    });
    self.tableView.tableFooterView = tabFooter ;

    UIView * footerView = [[UIView alloc] init];
    [self addSubview:footerView];

    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(popNext) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:[YCommonMethods colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"dapp_confirm"] forState:UIControlStateNormal];
    [footerView addSubview:confirmBtn];
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(122);
    }];
    self.confirmBtn = confirmBtn ;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.left.mas_equalTo(self);
        make.top.mas_equalTo(self.headView.mas_bottom);
        make.bottom.mas_equalTo(footerView.mas_top) ;
    }];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(162);
        make.top.mas_equalTo(31);
        make.centerX.mas_equalTo(footerView.mas_centerX);;
    }];
}

+(instancetype)showWithAcitonBlock:(ActionBlock)acitonBlock type:(VDATYPE)type  {

    CGFloat height = 473 ;
    if (type == VDATYPE_Trans) {
        height = 473 ;
    }
    
    YRequireSignView * popView = [[YRequireSignView alloc] init];
    popView.size = CGSizeMake(KSCREEN_WIDTH, height );
    popView.zhp = [zhPopupController new];
    popView.zhp.allowPan = NO;
    popView.zhp.dismissOnMaskTouched = YES;
    popView.actionBlock = acitonBlock ;
    popView.daiType = type ;
    WEAK(popView)
    [ popView.zhp setMaskTouched:^(zhPopupController * _Nonnull popupController) {
      
        [weakObject  popDissMiss];
    }];
    popView.zhp.layoutType = zhPopupLayoutTypeBottom;
    popView.zhp.maskAlpha = 0.3;//黑色背景透明度
    [popView.zhp presentContentView: popView];
    return popView ;
}

-(void)popNext{
    
    [self.zhp dismiss];
    if (_actionBlock) {
        _actionBlock(1);
    }
}

-(void)popDissMiss{
    
    [self.zhp dismiss];
    if (_actionBlock) {
        _actionBlock(0);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  self.datas.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CELL0";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = ClearBackColor;
    }
    [cell.contentView removeAllSubviews];
    NSDictionary * infos = self.datas[indexPath.row];
    NSString * left = infos[kLeftText];
    NSString * right = infos[kContent];
    
    UIImageView * backImage = [[UIImageView alloc] init];
    backImage.cornerRadius = 10;
    [cell.contentView addSubview:backImage];
    UILabel * leftLabel = [[UILabel alloc] init];
    leftLabel.textColor = [YCommonMethods colorWithHexString:@"#586883"];
    leftLabel.font = [UIFont fontWithName:Font_Medium size:12];
    leftLabel.text = @"";
    leftLabel.textAlignment = NSTextAlignmentCenter ;
    leftLabel.lineBreakMode = NSLineBreakByCharWrapping ;
    leftLabel.numberOfLines = 0 ;
    [cell.contentView addSubview:leftLabel];
    UILabel * rightLabel = [[UILabel alloc] init];
    rightLabel.textColor = [YCommonMethods colorWithHexString:@"#ACBBCF"];
    rightLabel.font = [UIFont fontWithName:Font_Medium size:12];
    [cell.contentView addSubview:rightLabel];
    rightLabel.text = @"";
    rightLabel.numberOfLines = 0 ;
    if (_daiType == VDATYPE_Trans && [left isEqualToString:@"金额"]) {
        
        backImage.backgroundColor = [UIColor colorWithRed:255/255.0 green:251/255.0 blue:200/255.0 alpha:1];
        rightLabel.textColor = [YCommonMethods colorWithHexString:@"#586883"];
    }else {
        
        rightLabel.textColor = [YCommonMethods colorWithHexString:@"#ACBBCF"];
        backImage.backgroundColor = NewBackColor;
    }
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(ADAPTATIONIPHWidth(83));
        make.right.mas_equalTo(cell.contentView.mas_right).mas_offset(-20);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(0);
    }];

    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(backImage.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(backImage.centerY);
    }];
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(backImage.mas_left).mas_offset(15);
        make.right.mas_equalTo(backImage.mas_right);
        make.centerY.mas_equalTo(leftLabel.centerY);
    }];
    leftLabel.text =  left ;
    NSMutableAttributedString * attstring = [[NSMutableAttributedString alloc] initWithString:right];
    NSArray * arrs = [right componentsSeparatedByString:@"\n"] ;
    if (arrs.count > 1 ) {
        
        NSString * fee1 = [arrs firstObject];
        NSString * fee2 = [arrs lastObject];
        NSRange range1 = [right rangeOfString:fee1];
        NSRange range2 = [right rangeOfString:fee2];
        [attstring addAttribute:NSForegroundColorAttributeName value:[YCommonMethods colorWithHexString:@"#586883"] range:range1];
        [attstring addAttribute:NSFontAttributeName value:[UIFont fontWithNameV2:Font_Medium size:12] range:range1];
        [attstring addAttribute:NSForegroundColorAttributeName value:[YCommonMethods colorWithHexString:@"#ACBBCF"] range:range2];
        [attstring addAttribute:NSFontAttributeName value:[UIFont fontWithNameV2:Font_Medium size:10] range:range2];
        rightLabel.attributedText = attstring ;
    }
    else {
        
        rightLabel.attributedText = attstring ;
    }
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 54.f;
}


-(void)setDatas:(NSMutableArray *)datas{
    
    _datas = datas ;
    [self.tableView reloadData];
    
}

-(void)setDaiType:(VDATYPE)daiType{
    
    //biaoti
    _daiType = daiType ;
    if (daiType == VDATYPE_Trans) {
        
        _titleLabel.text = @"信息";
        _titleLabel.font = [UIFont fontWithNameV2:Font_Semibold size:18 ];
        _titleLabel.textColor = [YCommonMethods colorWithHexString:@"#586883"] ;
        _tableView.tableFooterView = nil ;
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
    
}


-(UIView *)headView{
    
    if (!_headView) {
        
        _headView = [[UIView alloc] init];
        [self addSubview:_headView];
        [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.right.top.mas_equalTo(self);
            make.height.mas_equalTo(71);
        }];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"支付信息";
        titleLabel.textColor = [YCommonMethods colorWithHexString:@"#586883"];
        titleLabel.font = [UIFont systemFontOfSize:18];
        [_headView addSubview:titleLabel];
        self.titleLabel = titleLabel ;
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.mas_equalTo(self.headView.mas_centerY);
            make.centerX.mas_equalTo(self.headView.centerX);
        }];
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"menu_close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(popDissMiss) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.mas_equalTo(self.headView.mas_right).mas_offset(-22);
            make.centerY.mas_equalTo(self.headView.mas_centerY);
            make.size.mas_equalTo(45);
        }];
    
    }
    return _headView ;
}


@end

@implementation  YRequireAddressViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.backImage];
        [self.backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 20, 10, 20));
        }];
        
        self.image = [[UIImageView alloc] init];
        [self.contentView addSubview:self.image];
        [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backImage.mas_centerY);
            make.left.mas_equalTo(35);
            make.size.mas_equalTo(33);
        }];
        
        //币种名称
        self.name = [[UILabel alloc] init];
        self.name.textColor = fontWhiteColor;
        self.name.font = [UIFont systemFontOfSize:10];
        self.name.textAlignment = NSTextAlignmentLeft ;
        [self.contentView addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.image.mas_top).mas_offset(0);
            make.left.mas_equalTo(self.image.mas_right).mas_offset(14);
            make.width.mas_equalTo(KSCREEN_WIDTH/2);
        }];
        
        //地址
        self.address = [[UILabel alloc] init];
        self.address.textColor = fontWhiteColor;
        self.address.font = [UIFont systemFontOfSize:12];
        self.address.textAlignment = NSTextAlignmentLeft ;
        self.address.lineBreakMode = NSLineBreakByTruncatingMiddle ;
        [self.contentView addSubview:self.address];
        
        [self.address mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.name);
            make.bottom.mas_equalTo(self.backImage.mas_bottom).mas_offset(-5);
            make.right.mas_equalTo(self.backImage.mas_right).mas_offset(-49);
        }];
        
        self.balanceLabel = [[UILabel alloc] init];
        self.balanceLabel.textColor = fontWhiteColor;
        self.balanceLabel.font = [UIFont fontWithName:Font_Regular size:12];
        self.balanceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.balanceLabel];
        
        [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(self.name.mas_top).mas_offset(0);
            make.right.mas_equalTo(self.address.mas_right);
        }];
        
        self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString * imgName = @"da_select" ;
        if ([reuseIdentifier isEqualToString:@"MultisignID"]) {
            imgName = @"multi_more" ;
            self.checkBtn.selected = YES ;
        }
        [self.checkBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateSelected];
        [self.checkBtn setImage:nil forState:UIControlStateNormal];
        [self.contentView addSubview:self.checkBtn];
        [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.mas_equalTo(self.backImage.mas_centerY);
            make.right.mas_equalTo(self.backImage.mas_right).mas_offset(-15);
        }];
    }
    return self;
}

-(void)setModel:(YRequireAddressViewCellModel *)model{
    
    _model = model ;
    NSString * coin = @"VNS";
    NSString * balance = [NSString stringWithFormat:@"%.4f %@",model.balanceStr.doubleValue,coin ];
    if (model.isSecurity) {
        
        balance = @"***";
    }
    self.balanceLabel.text = balance ;
    
    self.address.text = model.addressStr ;
    self.name.text = model.nameStr ;
    NSString * groupimg = @"walletmanager_default";
    self.image.image = [UIImage imageNamed:model.fromImg] ;
    self.backImage.image = [UIImage imageNamed:groupimg];
    
    if (model.isSelect) {
        self.checkBtn.selected = YES ;
    }else{
        self.checkBtn.selected = NO ;
    }
    
}


@end


@interface YRequireAddressView ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic,strong) UIView * headView ;
@property (nonatomic,strong) UITableView * tableView ;
@property (nonatomic,strong) zhPopupController * zhp ;
@property (nonatomic,assign) VDATYPE daiType ;
@property (nonatomic,strong) UIImageView * dappIcon ;
@property (nonatomic,strong) UILabel * dappName ;
@property (nonatomic,copy) ActionBlock actionBlock ;
@property (nonatomic,assign) BOOL isSecurity ;
@property (nonatomic,copy) NSString *  chooseWalletID ;
@property (nonatomic,strong) UIButton * confirmBtn  ;

@end

@implementation YRequireAddressView


-(void)setDaiType:(VDATYPE)daiType{
    
    _daiType = daiType ;
    
    if (daiType == VDATYPE_Bancor) {
        
        _dappIcon.image = [UIImage imageNamed:@"DA_BANCOR"];
        _dappName.text = YLOCALIZED_UserVC(@"bancormanager_dabancorname");
    }
    if (daiType == VDATYPE_Vdns) {
        
        _dappIcon.image = [UIImage imageNamed:@"DA_VDNS_big"];
        _dappName.text = YLOCALIZED_UserVC(@"bancormanager_vdnsbancorname");
    }
    if (daiType == VDATYPE_Vuds) {
        
        _dappIcon.image = [UIImage imageNamed:@"DA_BANCOR_DAI"];
        _dappName.text = YLOCALIZED_UserVC(@"bancormanager_dabancorname_vdai");
    }
}

- (void)setDatas:(NSArray *)datas{
    
    if (datas.count == 0) {
        _confirmBtn.enabled = false;
    }else{
        _datas = datas;
        _confirmBtn.enabled = true;
        NSMutableArray * arrs = [NSMutableArray array];
        
        for (id re in _datas) {
            if([re isKindOfClass:[NSDictionary class]]){
                YRequireAddressViewCellModel * model = [[YRequireAddressViewCellModel alloc] init];
                MOriginType from = (MOriginType)[re[@"originType"] integerValue];
                NSString * fromimg = @"";
                if (from == MOriginType_Create || from == MOriginType_Restore) {
                    
                    fromimg = @"fromtype_appwallet";
                }
                else if (from == MOriginType_LeadIn){
                    
                    fromimg = @"fromtype_leadin";
                }
                model.fromImg = fromimg ;
                //                    model.balanceStr = re.balance ;
                model.addressStr = re[@"address"] ;
                //                    model.nameStr = [re fetchGroupWalletName];
                model.walletID = re[@"walletID"] ;
                if ([_defaultChooseWalletID isEqualToString:re[@"walletID"]]) {
                    model.isSelect = YES ;
                }
                [arrs addObject:model];
            }
            else{
                YRequireAddressViewCellModel * model = re ;
                if ([_defaultChooseWalletID isEqualToString:model.walletID]) {
                    model.isSelect = YES ;
                }
                [arrs addObject:model];
            }
        }
        _datas = arrs ;
    }
    [self.tableView reloadData];
}



-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [ super initWithFrame:frame]) {
        
        [self buildWithView];
    }
    return self ;
}

-(void)buildWithView{
    
    _isSecurity = YES ;
    
    self.layer.masksToBounds  = YES ;
    self.layer.cornerRadius = 10.f ;
    self.backgroundColor = UIColor.whiteColor ;
    self.headView.backgroundColor = UIColor.clearColor ;
   
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.emptyDataSetSource = self ;
    self.tableView.emptyDataSetDelegate = self ;
    [self  addSubview:self.tableView];
        
    
    UIView * footerView = [[UIView alloc] init];
    [self addSubview:footerView];
    UIButton * cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(popDismiss) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitleColor:[YCommonMethods colorWithHexString:@"#586883"] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [cancleBtn setBackgroundImage:[UIImage imageNamed:@"dapp_cancle"] forState:UIControlStateNormal];
    
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"允许" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(popNext) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitleColor:[YCommonMethods colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"dapp_confirm"] forState:UIControlStateNormal];
    [footerView addSubview:cancleBtn];
    [footerView addSubview:confirmBtn];
    _confirmBtn = confirmBtn;
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ADAPTATIONIPHeight(130));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.left.mas_equalTo(self);
        make.top.mas_equalTo(self.headView.mas_bottom);
        make.bottom.mas_equalTo(footerView.mas_top) ;
    }];
    
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(108);
        make.top.mas_equalTo(40);
        make.right.mas_equalTo(footerView.mas_centerX).mas_offset(-6);
    }];
    
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(108);
        make.top.mas_equalTo(cancleBtn);
        make.left.mas_equalTo(footerView.mas_centerX).mas_offset(6);
    }];
    
    CGFloat height = 0.f ;
    if (self.datas.count > 0) {
        
        height = self.datas.count > 4 ? 444 : self.datas.count * 54 + ADAPTATIONIPHeight(130) + HeaderViewHeight ;
    }else{
        
        height = 54 + ADAPTATIONIPHeight(130) + HeaderViewHeight ;
    }

    self.size = CGSizeMake(KSCREEN_WIDTH, height);
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.datas.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"YRequireAddressViewCell";
    YRequireAddressViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[YRequireAddressViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = ClearBackColor;
    }
    YRequireAddressViewCellModel * mdoel = self.datas[indexPath.row] ;
    mdoel.isSecurity = _isSecurity ;
    cell.model = mdoel ;
    
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YRequireAddressViewCellModel * model = self.datas[indexPath.row];
    NSMutableArray * arrs = [NSMutableArray array];
    for (int i = 0 ; i < self.datas.count ; i ++ ) {
        
        YRequireAddressViewCellModel * model = self.datas[i];
        model.isSelect = NO ;
        if (indexPath.row == i) {
            _chooseWalletID = model.walletID ;
            [[ChannelDapp sharedInstance] updateDIDChoose:_chooseWalletID];
            model.isSelect = YES ;
        }
        [arrs addObject:model];
    }
    self.datas = arrs.mutableCopy ;
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 54.f ;
}

-(NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    
    return [[NSMutableAttributedString alloc] initWithString:@"  "];
}

-(UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    
    return [UIImage imageNamed:@"da_addwallet"] ;
}

-(void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view{
    
    [self headerViewBtnAction:nil];
}
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    
     [self headerViewBtnAction:nil];
}

-(void)updateSercurityText:(UIButton*)stateBtn{
    
    BOOL isState = stateBtn.isSelected ;
    stateBtn.selected = !isState ;
    _isSecurity = !isState ;
    [_tableView reloadData];
}

-(void)headerViewBtnAction:(UIButton*)btn{
    
    [self.zhp dismiss];
    
     if (_actionBlock) {
         
         _actionBlock(-1);
     }
}

+(YRequireAddressView *)showWithAcitonBlock:(ActionBlock)acitonBlock type:(VDATYPE)type datas:(nonnull NSArray *)datas{

    YRequireAddressView * popView = [[YRequireAddressView alloc] init];
    popView.zhp = [zhPopupController new];
    popView.zhp.allowPan = NO;
    popView.zhp.dismissOnMaskTouched = YES;
    popView.actionBlock = acitonBlock ;
    popView.daiType = type ;
    popView.datas = datas;
    WEAK(popView)
    [ popView.zhp setMaskTouched:^(zhPopupController * _Nonnull popupController) {
        
        [weakObject popDismiss];
    }];
    popView.zhp.layoutType = zhPopupLayoutTypeBottom;
    popView.zhp.maskAlpha = 0.3;//黑色背景透明度
    [ popView.zhp presentContentView: popView];
    return popView;
}

-(void)popDismiss {

    [self.zhp dismiss];
    
     if (_actionBlock) {
         
         _actionBlock(0);
     }
    
}

-(void)popNext{

    [self.zhp dismiss];
    
    BOOL state = _chooseWalletID ? 1 : 0 ;
    
    if (_actionBlock) {
        
        _actionBlock(state);
    }
}


-(UIView *)headView{
    
    if (!_headView) {
        _headView = [[UIView alloc] init];
        [self addSubview:_headView];
        
        UIImageView * dappIcon = [[UIImageView alloc] init];
        //DA_BANCOR
        dappIcon.image = [UIImage imageNamed:@""];
        _dappIcon = dappIcon ;
        [self addSubview:dappIcon];
        
        UILabel * dappName = [[UILabel alloc] init];
        dappName.text = @"";
        dappName.textColor = [YCommonMethods colorWithHexString:@"#000000"];
        dappName.font = [UIFont fontWithName:Font_Medium size:14];
        _dappName = dappName ;
        [self addSubview:dappName];
        
        UILabel * dappDesc = [[UILabel alloc] init];
        dappDesc.text = @"获取您的DID去中心化身份地址信息";
        dappDesc.textColor = [YCommonMethods colorWithHexString:@"#000000"];
        dappDesc.font = [UIFont fontWithName:Font_Medium size:16];
        dappDesc.numberOfLines = 0 ;
        [self addSubview:dappDesc];
        
        UIButton * dappSmallIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        [dappSmallIcon setImage:[UIImage imageNamed:@"menu_eye"] forState:UIControlStateNormal];
        [dappSmallIcon setImage:[UIImage imageNamed:@"menu_uneye"] forState:UIControlStateSelected];
        [dappSmallIcon addTarget:self action:@selector(updateSercurityText:) forControlEvents:UIControlEventTouchUpInside];
        dappSmallIcon.selected = _isSecurity ;
        [self addSubview:dappSmallIcon];
        
        [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(HeaderViewHeight);
        }];
        
        [dappIcon mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(22);
            make.left.mas_equalTo(33);
            make.size.mas_equalTo(30);
        }];
        [dappName mas_makeConstraints:^(MASConstraintMaker *make) {
               
            make.centerY.mas_equalTo(dappIcon.mas_centerY);
            make.left.mas_equalTo(dappIcon.mas_right).mas_offset(10);
            make.right.mas_equalTo(self.mas_right).mas_offset(-33);
        }];
        [dappDesc mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(dappIcon.mas_bottom).mas_offset(8);
            make.left.mas_equalTo(dappIcon.mas_left);
            make.right.mas_equalTo(dappSmallIcon.mas_left).mas_offset(-10);
        }];
        [dappSmallIcon mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.mas_equalTo(self.mas_right).mas_offset(-25);
            make.centerY.mas_equalTo(dappDesc.mas_centerY);
            make.size.mas_equalTo(24);
        }];
        
    }
    return _headView ;
}

//-(NSMutableArray *)datas{
//
//    if (!_datas) {
//
//        _datas = [NSMutableArray array];
//
//        NSArray * wallets = [YDataManager fetchWalletDataWithCoinType:YCoinType_VNS];
//        NSMutableArray * arrs = [NSMutableArray array];
//        _chooseWallet = [YWalletEntity fetchDidChoose];
//        for (YWalletEntity * re in wallets) {
//
//            YRequireAddressViewCellModel * model = [[YRequireAddressViewCellModel alloc] init];
//            YWalletFromType from = re.YwalletFromType ;
//            NSString * fromimg = [re fetchFromTypeImg];
//            model.fromImg = fromimg ;
//            model.balanceStr = re.balance ;
//            model.addressStr = re.Ywallettname ;
//            model.nameStr = [re fetchGroupWalletName];
//            model.et = re ;
//            if ([_chooseWallet.YpubKeyOwner isEqualToString:re.YpubKeyOwner]) {
//                model.isSelect = YES ;
//            }
//            [arrs addObject:model];
//        }
//        _datas = arrs ;
//    }
//    return  _datas ;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


