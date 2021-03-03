import '../public.dart';

class WalletServices {
  static const String host = "https://api.coinid.pro/coinidplus/v1";
  // static const String host = "https://api.coinid.pro/alltoken/v1";
  static const String findTokensData = "/api/mobile/findTokensData";
  static const String collectionToken = "/api/mobile/collectionToken";
  static const String myCollectionTokens = "/api/mobile/myCollectionTokens";
  static const String getCurrencyTokenPriceAndTokenCount =
      "/api/mobile/getCurrencyTokenPriceAndTokenCount";
  static const String getSystemMessage = "/api/mobile/getSystemMessage";
  static const String getTransferNotice = "/api/mobile/getTransferNotice";
  static const String clickSystemMessage = "/api/mobile/clickSystemMessage";
  static const String clickTransferNotice = "/api/mobile/clickTransferNotice";
  static const String clickTransferAllRead = "/api/mobile/clickTransferAllRead";
  static const String getCurrencyInfo = "/api/mobile/market/getCurrencyInfo";
  static const String myCollection = "/api/mobile/myCollection";
  static const String getOtherLinkImage =
      "/api/mobile/market/getOtherLinkImageResult/";
  static const String getPopularCurrency = "/api/mobile/getPopularCurrency";
  static const String currencySearch = "/api/mobile/currencySearch";
  static const String updateInfo = "/api/mobile/update";
  static const String versionLog = "/api/mobile/versionInfo";
  static const String getCurrencyPrice = "/api/mobile/getCurrencyPrice";

  static void requestUpdateInfo(String imei, String version, String packageName,
      String appType, String productId, complationBlock block) {
    Map<String, dynamic> params = {
      "imei": imei,
      "version": version,
      "packageName": packageName,
      "appType": appType,
    };
    if (productId != null) {
      params["productId"] = productId;
    }
    RequestMethod().requestNetwork(Method.POST, host + updateInfo,
        (response, code) {
      if (code == 200 && response is Map) {
        if (block != null) {
          block(response, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestVersionLog(String appType, complationBlock block) {
    if (appType == null || appType.length == 0) {
      LogUtil.v("平台类型为空");
      return;
    }

    Map<String, dynamic> params = {
      "appType": appType,
    };

    RequestMethod().requestNetwork(Method.POST, host + versionLog,
        (response, code) {
      if (code == 200 && response as List != null) {
        List datas = response as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              String version = data["version"] as String;
              String description = data["description"] as String;
              String createTime = data["createTime"] as String;

              Map<String, dynamic> dic = Map();
              dic["version"] = version;
              dic["description"] = description;
              dic["createTime"] = createTime;
              results.add(dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static Future<Map<String, dynamic>> requestTokenPrice(
      String token, complationBlock block) async {
    String url = host + getCurrencyPrice;
    Map<String, dynamic> datas = Map();
    datas["p"] = "0";
    datas["up"] = "0";
    Map<String, dynamic> cnyPara = Map();
    cnyPara["currency"] = token;
    cnyPara["convert"] = "CNY";
    Map<String, dynamic> usdtPara = Map();
    usdtPara["currency"] = token;
    usdtPara["convert"] = "USD";
    dynamic cnyresult = await RequestMethod()
        .futureRequestData(Method.GET, url, null, queryParameters: cnyPara);
    dynamic usdresult = await RequestMethod()
        .futureRequestData(Method.GET, url, null, queryParameters: usdtPara);
    if (cnyresult != null) {
      datas["p"] = cnyresult["data"];
    }
    if (usdresult != null) {
      datas["up"] = usdresult["data"];
    }
    if (block != null) {
      block(datas, 200);
    }
    return Future.value(datas);
  }

  static void requestGetCurrencyTokenPriceAndTokenCount(
      String account, String convert, String coinType, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "type": coinType,
      "convert": convert,
    };
    RequestMethod()
        .requestNetwork(Method.POST, host + getCurrencyTokenPriceAndTokenCount,
            (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["data"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              String symbol = data["symbol"] as String;
              String code = data["code"] as String;
              String balance = data["balance"] as String;
              String price = data["price"] as String;

              Map<String, dynamic> dic = Map();
              dic["symbol"] = symbol;
              dic["code"] = code;
              dic["price"] = price;
              dic["balance"] = balance;
              results.insert(0, dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestMyCollectionTokens(
      String account, String convert, String coinType, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "coinType": coinType,
      "convert": convert,
    };

    RequestMethod().requestNetwork(Method.POST, host + myCollectionTokens,
        (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["data"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              int id = data["id"];
              String contract = data["contract"] as String;
              String token = data["token"] as String;
              String coinType = data["coinType"] as String;
              String iconPath = data["iconPath"] as String;
              int state = data["state"];
              int decimals = 0;
              double price = 0;
              String balance = "0";
              if (data["decimals"] != null) {
                decimals = data["decimals"];
              }
              if (data["price"] != null) {
                price = double.parse(data["price"].toString());
              }
              if (data["balance"] != null) {
                balance = data["balance"] as String;
              }

              Map<String, dynamic> dic = Map();
              dic["id"] = id;
              dic["contract"] = contract;
              dic["token"] = token;
              dic["coinType"] = coinType;
              dic["iconPath"] = iconPath;
              dic["state"] = state;
              dic["decimals"] = decimals;
              dic["price"] = price;
              dic["balance"] = balance;
              results.insert(0, dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestFindTokensData(
      String account, String token, String coinType, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "token": StringUtil.isNotEmpty(token) ? token : "",
      "currencyType": "",
      "coinType": coinType,
    };

    RequestMethod().requestNetwork(Method.POST, host + findTokensData,
        (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["data"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              int id = data["id"];
              String contract = data["contract"] as String;
              String token = data["token"] as String;
              String coinType = data["coinType"] as String;
              String iconPath = data["iconPath"] as String;
              int state = data["state"];

              Map<String, dynamic> dic = Map();
              dic["id"] = id;
              dic["contract"] = contract;
              dic["token"] = token;
              dic["coinType"] = coinType;
              dic["iconPath"] = iconPath;
              dic["state"] = state;
              results.add(dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestCollectionToken(
      String account, int tokenId, String coinType, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "tokenId": tokenId,
      "coinType": coinType,
    };

    RequestMethod().requestNetwork(Method.POST, host + collectionToken,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(null, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestGetSystemMessage(
      String account, int page, int pageSize, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "page": page,
      "pageSize": pageSize,
    };

    RequestMethod().requestNetwork(Method.POST, host + getSystemMessage,
        (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["data"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              int id = data["id"];
              String title = data["title"] as String;
              String message = data["message"] as String;
              String author = data["author"] as String;
              int datatime = data["dataTime"];
              int state = data["state"];

              Map<String, dynamic> dic = Map();
              dic["id"] = id;
              dic["title"] = title;
              dic["message"] = message;
              dic["author"] = author;
              dic["dataTime"] = datatime;
              dic["state"] = state;
              results.add(dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestClickSystemMessage(
      String account, int messageId, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "messageId": messageId,
    };

    RequestMethod().requestNetwork(Method.POST, host + clickSystemMessage,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(null, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestClickSystemMessageAllRead(
      String account, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
    };

    RequestMethod().requestNetwork(Method.POST, host + clickSystemMessage,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(null, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestGetTransferNotice(
      List<String> account, int page, int pageSize, complationBlock block) {
    Map<String, dynamic> params = {
      "account": account,
      "start": page,
      "limit": pageSize,
    };

    RequestMethod().requestNetwork(Method.POST, host + getTransferNotice,
        (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["DataBean"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              String trxId = data["trxId"] as String;
              String from = data["from"] as String;
              String to = data["to"] as String;
              String trxState = data["trxState"] as String;
              String gasPrice = data["gasPrice"] as String;
              String gasLimit = data["gasLimit"] as String;
              String blHeight = data["blHeight"] as String;
              String value = data["value"] as String;
              String createTime = data["createTime"] as String;
              String timeStamp = data["timeStamp"] as String;
              String txFee = data["txFee"] as String;
              String mome = data["mome"] as String;
              String title = data["title"] as String;
              String message = data["message"] as String;
              String type = data["type"] as String;
              String token = data["token"] as String;
              int state = data["state"];

              Map<String, dynamic> dic = Map();
              dic["trxId"] = trxId;
              dic["from"] = from;
              dic["to"] = to;
              dic["trxState"] = trxState;
              dic["gasPrice"] = gasPrice;
              dic["gasLimit"] = gasLimit;
              dic["blHeight"] = blHeight;
              dic["value"] = value;
              dic["createTime"] = createTime;
              dic["timeStamp"] = timeStamp;
              dic["txFee"] = txFee;
              dic["mome"] = mome;
              dic["title"] = title;
              dic["message"] = message;
              dic["type"] = type;
              dic["token"] = token;
              dic["state"] = state;
              results.add(dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestClickTransferNotice(
      String account, String trxId, complationBlock block) {
    Map<String, dynamic> params = {
      "addr": account,
      "trxId": trxId,
    };

    RequestMethod().requestNetwork(Method.POST, host + clickTransferNotice,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(null, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void requestClickTransferNoticeAllRead(
      List<String> account, complationBlock block) {
    RequestMethod().requestNetwork(Method.POST, host + clickTransferAllRead,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(null, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: account);
  }

  static void requestGetCurrencyInfo(Map params, complationBlock block) {
    RequestMethod().requestNetwork(Method.POST, host + getCurrencyInfo,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(response, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void updateMyCollection(Map params, complationBlock block) {
    RequestMethod().requestNetwork(Method.POST, host + myCollection,
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (block != null) {
          block(response, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: params);
  }

  static void getOtherLinkImageDatas(String coinType, complationBlock block) {
    RequestMethod().requestNetwork(
        Method.GET, host + getOtherLinkImage + coinType, (response, code) {
      if (code == 200 && response as Map != null) {
        List datas = response["data"] as List;
        List<Map<String, dynamic>> results = [];
        datas.forEach(
          (element) {
            if (element as Map != null) {
              Map data = element as Map;
              String linkImage = data["linkImage"] as String;
              String linkUrl = data["linkUrl"] as String;

              Map<String, dynamic> dic = Map();
              dic["linkImage"] = linkImage;
              dic["linkUrl"] = linkUrl;
              results.add(dic);
            }
          },
        );
        if (block != null) {
          block(results, 200);
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    });
  }

  static void requestPopularCurrency(complationBlock block) {
    RequestMethod().requestNetwork(
      Method.GET,
      host + getPopularCurrency,
      (response, code) {
        if (code == 200 && response as Map != null) {
          if (block != null) {
            block(response, 200);
          }
        } else {
          if (block != null) {
            block(null, 500);
          }
        }
      },
    );
  }

  static void requestCurrencySearch(
      Map<String, dynamic> params, complationBlock block) {
    RequestMethod().requestNetwork(
      Method.GET,
      host + currencySearch,
      (response, code) {
        if (code == 200 && response as Map != null) {
          if (block != null) {
            block(response, 200);
          }
        } else {
          if (block != null) {
            block(null, 500);
          }
        }
      },
      queryParameters: params,
    );
  }
}
