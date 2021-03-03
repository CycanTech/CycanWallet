import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coinid/public.dart';
import 'package:flutter_coinid/utils/permission.dart';
import 'package:path_provider/path_provider.dart';

enum MemoCount { MemoCount_12, MemoCount_18, MemoCount_24 }

//导入类型 私钥、keystore 、coinid助记词 、 标准助记词
enum MLeadType {
  MLeadType_Prvkey, //通过私钥
  MLeadType_KeyStore, //通过keystore
  MLeadType_Memo, //通过助记词
  MLeadType_StandardMemo //通过标准助记词
}
//来源类型
enum MOriginType {
  MOriginType_Create, //创建
  MOriginType_Restore, //恢复
  MOriginType_LeadIn, //导入
  MOriginType_Colds, //冷
  MOriginType_NFC, //nfc
  MOriginType_MultiSign, //预留多签
}

enum MCoinType {
  MCoinType_All,
  MCoinType_BTC,
  MCoinType_ETH,
  MCoinType_EOS,
  MCoinType_VNS,
  MCoinType_BTM,
  MCoinType_LTC,
  MCoinType_USDT,
  MCoinType_GPS,
  MCoinType_DOT,
}

enum MStatusCode {
  MStatusCode_Success,
  MStatusCode_Failere,
  MStatusCode_BaseFailere,
  MStatusCode_Exist,
  MStatusCode_MemoInvalid,
  MStatusCode_KeystorePwdInvalid,
  MStatusCode_PrvKeyInvalid,
}

enum MQRStatusCode {
  MQRStatusCode_Success, //解析成功
  MQRStatusCode_Type_Err, //链类型错误
  MQRStatusCode_Dispose_Err //解析失败
}

enum MWalletOptionType {
  MWalletOptionType_Update_Name, //修改钱包名字
  MWalletOptionType_Tips, //密码提示
  MWalletOptionType_Export_Prvkey, //导出私钥
  MWalletOptionType_Export_Keystore, //导出Keystore
  MWalletOptionType_SigData, //切换地址
  MWalletOptionType_Clean, //删除钱包
  MWalletOptionType_Show_PubKey, //查看公钥
}

enum MSignType {
  MSignType_Main,
  MSignType_Token,
  MSignType_BancorBuy,
  MSignType_BancorSell,
  MSignType_EosTypeReg,
  MSignType_EosTypeBuyRam,
  MSignType_EosTypeSellRam,
  MSignType_EosTypeStakeCpu,
  MSignType_EosTypeUnStakeCpu,
}

enum MTransType {
  MTransType_All,
  MTransType_Out,
  MTransType_In,
  MTransType_Err,
}

enum MTransState {
  MTransState_Failere,
  MTransState_Success,
  MTransState_Loading,
}

enum MNodeNetType {
  MNodeNetType_Main,
  MNodeNetType_Test,
}

enum MURLType { Links, Bancor, VDns, VDai }

enum MButtonState {
  ButtonState_Normal,
  ButtonState_Top,
  ButtonState_Bottom,
}

enum MCurrencyType {
  CNY,
  USD,
}
enum MLanguage {
  zh_hans,
  en,
}

class Constant {
  static const bool inProduction = kReleaseMode;
  static bool isDriverTest = false;

  static bool isAndroid = Platform.isAndroid;
  static bool isIOS = Platform.isIOS;

  static const String ASSETS_IMG = './assets/images/';
  static const int BUTTON_BACKGROUND_COLOR = 0xff46556F;
  static const int TextFileld_FillColor = 0xffffffff;
  static const int TextFileld_FocuseCOlor = 0xFFCFCFCF;

  static const String CHANNEL_PATH = 'plugins.coinidwallet';
  static const String CHANNEL_Memos = CHANNEL_PATH + ".memos";
  static const String CHANNEL_Wallets = CHANNEL_PATH + ".wallets";
  static const String CHANNEL_Natives = CHANNEL_PATH + ".natives";
  static const String CHANNEL_Scans = CHANNEL_PATH + ".scans";
  static const String CHANNEL_Dapp = CHANNEL_PATH + ".dapps";

  static const int tabbar_unselect_color = 0xff888888;
  static const int tabbar_select_color = 0xFF494949;
  static const int main_color = 0xFFFFFFFF; //主黑色调

  static String getChainSymbol(int coinType) {
    String symbol = "";
    if (MCoinType.MCoinType_EOS.index == coinType) {
      symbol = "EOS";
    } else if (MCoinType.MCoinType_ETH.index == coinType) {
      symbol = "ETH";
    } else if (MCoinType.MCoinType_BTC.index == coinType) {
      symbol = "BTC";
    } else if (MCoinType.MCoinType_BTM.index == coinType) {
      symbol = "BTM";
    } else if (MCoinType.MCoinType_VNS.index == coinType) {
      symbol = "VNS";
    } else if (MCoinType.MCoinType_LTC.index == coinType) {
      symbol = "LTC";
    } else if (MCoinType.MCoinType_GPS.index == coinType) {
      symbol = "GPS";
    } else if (MCoinType.MCoinType_USDT.index == coinType) {
      symbol = "USDT";
    } else if (MCoinType.MCoinType_DOT.index == coinType) {
      symbol = "DOT";
    }
    return symbol;
  }

  static MCoinType getCoinType(String symbol) {
    MCoinType coinType;
    if (symbol.toLowerCase() == "eos") {
      coinType = MCoinType.MCoinType_EOS;
    } else if (symbol.toLowerCase() == "eth") {
      coinType = MCoinType.MCoinType_ETH;
    } else if (symbol.toLowerCase() == "btc") {
      coinType = MCoinType.MCoinType_BTC;
    } else if (symbol.toLowerCase() == "btm") {
      coinType = MCoinType.MCoinType_BTM;
    } else if (symbol.toLowerCase() == "vns") {
      coinType = MCoinType.MCoinType_VNS;
    } else if (symbol.toLowerCase() == "ltc") {
      coinType = MCoinType.MCoinType_LTC;
    } else if (symbol.toLowerCase() == "gps") {
      coinType = MCoinType.MCoinType_GPS;
    } else if (symbol.toLowerCase() == "usdt") {
      coinType = MCoinType.MCoinType_USDT;
    } else if (symbol.toLowerCase() == "dot") {
      coinType = MCoinType.MCoinType_DOT;
    }
    return coinType;
  }

  static String getChainFullName(int coinType) {
    String fullName = "";
    if (MCoinType.MCoinType_EOS.index == coinType) {
      fullName = "Enterprise Operation System";
    } else if (MCoinType.MCoinType_ETH.index == coinType) {
      fullName = "Ethereum";
    } else if (MCoinType.MCoinType_BTC.index == coinType) {
      fullName = "Bitcoin";
    } else if (MCoinType.MCoinType_BTM.index == coinType) {
      fullName = "Bytom";
    } else if (MCoinType.MCoinType_VNS.index == coinType) {
      fullName = "Venus";
    } else if (MCoinType.MCoinType_LTC.index == coinType) {
      fullName = "Litecoin";
    } else if (MCoinType.MCoinType_GPS.index == coinType) {
      fullName = "GPS";
    } else if (MCoinType.MCoinType_USDT.index == coinType) {
      fullName = "USDT";
    } else if (MCoinType.MCoinType_DOT.index == coinType) {
      fullName = "DOT";
    }
    return fullName;
  }

  static int getChainDecimals(int coinType) {
    int decimals;
    if (MCoinType.MCoinType_EOS.index == coinType) {
      decimals = 4;
    } else if (MCoinType.MCoinType_ETH.index == coinType) {
      decimals = 18;
    } else if (MCoinType.MCoinType_BTC.index == coinType) {
      decimals = 8;
    } else if (MCoinType.MCoinType_BTM.index == coinType) {
      decimals = 8;
    } else if (MCoinType.MCoinType_VNS.index == coinType) {
      decimals = 18;
    } else if (MCoinType.MCoinType_LTC.index == coinType) {
      decimals = 8;
    } else if (MCoinType.MCoinType_GPS.index == coinType) {
      decimals = 4;
    } else if (MCoinType.MCoinType_USDT.index == coinType) {
      decimals = 8;
    } else if (MCoinType.MCoinType_DOT.index == coinType) {
      decimals = 10;
    } else {
      assert(false, "getChainDecimals");
    }
    return decimals;
  }

  static Future<File> getAppFile() async {
    Directory documentsDir;
    if (Constant.isAndroid) {
      documentsDir = await getExternalStorageDirectory();
    } else {
      documentsDir = await getApplicationDocumentsDirectory();
    }
    String documentsPath = documentsDir.absolute.path;
    File file = File('$documentsPath');
    return file;
  }

  static Future<String> getAgreementPath() async {
    try {
      if (await PermissionUtils.checkStoragePermissions() == false) {
        HWToast.showText(text: "权限未开启");
        return null;
      }
      final filename = "agreementinfo.pdf";
      var filebd = await rootBundle.load("assets/data/agreementinfo.pdf");
      File documentsDir = await getAppFile();
      String documentsPath = documentsDir.absolute.path;
      File file = File('$documentsPath/$filename');
      final buffer = filebd.buffer;
      file.writeAsBytes(
          buffer.asUint8List(filebd.offsetInBytes, filebd.lengthInBytes));
      return file.path;
    } catch (e) {
      LogUtil.v(e);
      return null;
    }
  }

  static String getChainLogo(int chainType) {
    String logofile = Constant.ASSETS_IMG + "wallet/logo_";
    logofile = logofile + getChainSymbol(chainType) + ".png";
    return logofile;
  }
}
