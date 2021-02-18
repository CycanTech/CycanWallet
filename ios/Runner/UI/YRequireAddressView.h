//
//  YRequireAddressView.h
//  CoinID
//
//  Created by MWTECH on 2019/10/30.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ActionBlock)(NSInteger btnState);
typedef void(^AddressActionBlock)(id param ,NSInteger code);
#define kLeftText @"kLeftText"
#define kContent @"kContent"

typedef NS_ENUM(NSInteger, VDATYPE) {
  
    VDATYPE_Bancor,
    VDATYPE_Vdns,
    VDATYPE_Vuds,
    VDATYPE_Trans,
};

@interface YRequireAddressViewCellModel : NSObject

@property (nonatomic,copy) NSString * fromImg ;
@property (nonatomic,copy) NSString * nameStr ;
@property (nonatomic,copy) NSString * addressStr ;
@property (nonatomic,copy) NSString * balanceStr ;
@property (nonatomic,assign) BOOL  isSelect ;
@property (nonatomic,assign) BOOL  isSecurity ;
@property (nonatomic,copy) NSString* walletID ;

@end


@interface YRequireSignView: UIView

@property (nonatomic,strong) NSMutableArray * datas ;

+(instancetype)showWithAcitonBlock:(ActionBlock)acitonBlock type:(VDATYPE)type  ;


@end

@interface YRequireAddressViewCell : UITableViewCell

@property (strong, nonatomic)  UIImageView  * image; //from
@property (strong, nonatomic)  UILabel      * name; //wallet name
@property (strong, nonatomic)  UILabel      * address; //address name
@property (strong, nonatomic)  UIImageView  * backImage;
@property (strong , nonatomic)  UILabel * balanceLabel; //余额
@property (strong , nonatomic)  UIButton * checkBtn ;
@property (nonatomic,strong)   YRequireAddressViewCellModel * model ;

@end

@interface YRequireAddressView : UIView

@property (nonatomic,copy) NSString *  defaultChooseWalletID ;
@property (nonatomic,strong)NSArray *  datas ;


+(YRequireAddressView *)showWithAcitonBlock:(ActionBlock)acitonBlock type:(VDATYPE)type datas:(NSArray * )datas;


@end



NS_ASSUME_NONNULL_END
