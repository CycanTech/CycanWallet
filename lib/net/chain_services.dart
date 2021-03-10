import 'dart:convert';
import 'dart:math';
import 'package:flutter_coinid/channel/channel_native.dart';
import 'package:flutter_coinid/models/transrecord/trans_record.dart';
import 'package:flutter_coinid/net/request_method.dart';
import 'package:flutter_coinid/net/wallet_services.dart';
import 'package:flutter_coinid/utils/instruction_data_format.dart';
import 'package:flutter_coinid/utils/json_util.dart';
import '../public.dart';

class ChainServices {
  static const bool isTestNode = true;

  static const String _ethTestChain = "http://103.46.128.21:26082";
  static String ethMainChain = "https://mainnet-eth.coinid.pro";
  static String _ethurl = isTestNode ? _ethTestChain : ethMainChain;

  static const String _btcTestChain = "http://c181e88770.51vip.biz";
  // static String btcMainChain = "https://api.bitcore.io";
  static String btcMainChain = "https://btc-api.coinid.pro";
  static String _btcurl = isTestNode ? _btcTestChain : btcMainChain;

  static const String regtestBtcSend = "/api/BTC/regtest/tx/send";
  static const String regtestBtcList = "/api/BTC/regtest";
  static const String mainnetBtcList = "/api/BTC/mainnet";

  static void requestChainInfo(
      {String chainType,
      String from,
      String amount,
      int m,
      int n,
      String contract,
      complationBlock block}) {
    assert(chainType != null, "requestChainInfo");
    assert(from != null, "requestChainInfo");
    assert(amount != null, "requestChainInfo");
    assert(block != null, "requestChainInfo");

    if (chainType.toLowerCase() == "eth") {
      return _requestETHAddresssInfo(
          from: from, contract: contract, block: block);
    } else if (chainType.toLowerCase() == "dot") {
      return _requestDotChainInfo(from: from, contract: contract, block: block);
    } else {
      return _requesUnSpendList(chainType, from, amount, (result, code) async {
        if (code == 200) {
          String utxojson = JsonUtil.encodeObj(result);
          LogUtil.v("utxojson  $utxojson  amount $amount m $m  n $n ");
          if (block != null) {
            block(result, 200);
          }
        } else {
          if (block != null) {
            block([], 500);
          }
        }
      });
    }
  }

  static void requestTransRecord(int chainType, MTransType transType,
      String from, String contract, int page, complationBlock block) {
    assert(chainType != null, "requestTransRecord");
    assert(from != null, "requestTransRecord");
    assert(block != null, "requestTransRecord");

    if (chainType == MCoinType.MCoinType_ETH.index) {
      return _requestETHTransRecord(from, contract, page, block);
    } else if (chainType == MCoinType.MCoinType_BTC.index) {
      return _requestBTCTransRecord(transType, from, page, block);
    } else if (chainType == MCoinType.MCoinType_DOT.index) {
    } else {}
  }

  static void pushData(
      String chainType, String packByteString, complationBlock block) {
    if (chainType == null) {
      LogUtil.v("链类型为空");
      return;
    }
    if (packByteString == null || packByteString.length == 0) {
      LogUtil.v("签名数据为空");
      return;
    }

    if (chainType.toLowerCase() == "eth") {
      packByteString = "0x" + packByteString;
      return _pushETHData(packByteString, block);
    }
    if (chainType.toLowerCase() == "btc") {
      return _pushBTCData(packByteString, block);
    }
    if (chainType.toLowerCase() == "dot") {
      return _pushDOTData(packByteString, block);
    }
  }

  static Future<dynamic> requestAssets(
      {@required String chainType,
      @required String from,
      @required String contract,
      @required String token,
      int tokenDecimal = 18,
      bool neePrice = true,
      complationBlock block}) {
    assert(chainType != null);
    assert(from != null);

    if (chainType.toLowerCase() == "eth") {
      return _requestETHAssets(
          from: from,
          contract: contract,
          neePrice: neePrice,
          tokenDecimal: tokenDecimal,
          token: token,
          block: block);
    }
    if (chainType.toLowerCase() == "btc") {
      return _requestBTCAssets(from, neePrice, block);
    } else if (chainType.toLowerCase() == "dot") {
      return _requestDotAssets(from, neePrice, block);
    } else {
      return null;
    }
  }

  static void _requestETHTransRecord(
      String from, String contract, int page, complationBlock block) {
    String url = "http://192.168.1.190:9090/api/accountTxs?addr=$from";
    RequestMethod().requestNetwork(Method.GET, url, (result, code) {
      List<MHTransRecordModel> results = [];
      if (code == 200 && result as Map != null) {
        if (result != null && result.keys.contains("data")) {
          List datas = result["data"] as List;
          datas.forEach((element) {
            Map data = element as Map;
            BigInt value = BigInt.from(data["value"]);
            String expiration = data["time"] as String;
            String trxId = data["tx_hash"] as String;
            String to = data["to"] as String;
            String time = DateUtil.formatDateStr(expiration,
                isUtc: false, format: DateFormats.full);
            Map<String, dynamic> dic = Map();
            MHTransRecordModel model = MHTransRecordModel();
            model.from = from;
            model.date = time;
            model.amount = value.toString();
            model.txid = trxId;
            model.token = "ETH";
            model.coinType = "ETH";
            // model.blocknumber = block_number;
            // model.fee = fee;
            model.to = to;
            model.transStatus = MTransState.MTransState_Success.index;
            // model.confirmations = confirmations;
            // model.gasPrice = gas_price;
            // model.gasLimit = gas_limit;
            model.isOut =
                (from.toLowerCase() == to.toLowerCase()) == true ? false : true;
            results.add(model);
          });
          if (block != null) {
            block(results, 200);
          }
        }
      } else {
        if (block != null) {
          block([], 500);
        }
      }
    });
  }

  static void _requestBTCTransRecord(
      MTransType transType, String from, int page, complationBlock block) {
    String baseurl;
    String recordURL;
    String coinsurl;
    if (isTestNode == true) {
      baseurl = _btcurl + regtestBtcList;
    } else {
      baseurl = _btcurl + mainnetBtcList;
    }
    const int limit = 15;
    page = max(1, page);
    int start = (page - 1) * limit;
    int to = limit * page;
    if (transType == MTransType.MTransType_Err) {
      if (block != null) {
        block([], 500);
      }
      return;
    }
    recordURL = baseurl + "/address/$from/txs?limit=$to";
    RequestMethod().requestNetwork(Method.GET, recordURL, (result, code) {
      if (code == 200 && result is List) {
        List datas = result;
        List<MHTransRecordModel> results = [];
        int requestCount = 0;
        for (var element in datas) {
          Map data = element as Map;
          String trxId = data["mintTxid"] as String;
          coinsurl = baseurl + "/tx/$trxId/coins";
          RequestMethod().requestNetwork(Method.GET, coinsurl,
              (coinsresult, code) {
            requestCount++;
            if (code == 200 && coinsresult is Map) {
              List outputs = coinsresult["outputs"] as List;
              List inputs = coinsresult["inputs"] as List;
              String lcoalTime = "";
              String blockTime = coinsresult["timestap"] as String;
              if (blockTime != null) {
                lcoalTime = DateUtil.formatDateStr(blockTime, isUtc: false);
              }
              String blockheight = data["mintHeight"].toString();
              String confirmations = data["confirmations"].toString();
              Map state = _checkTransType("btc", from, inputs, outputs);
              String trx_amount = state["a"] as String;
              String value = (num.tryParse(trx_amount) / pow(10, 8)).toString();
              bool isOut = state["o"] as int == 0 ? false : true;
              MHTransRecordModel model = MHTransRecordModel();
              model.isOut = isOut;
              model.from = isOut == true ? from : state["d"];
              model.date = lcoalTime;
              model.amount = value;
              model.txid = trxId;
              model.token = "BTC";
              model.coinType = "BTC";
              model.blocknumber = blockheight.toString();
              model.to = isOut == false ? from : state["d"];
              model.transStatus = MTransState.MTransState_Success.index;
              model.confirmations = confirmations.toString();
              if (transType == MTransType.MTransType_All) {
                results.add(model);
              } else if (transType == MTransType.MTransType_Out &&
                  isOut == true) {
                results.add(model);
              } else if (transType == MTransType.MTransType_In &&
                  isOut == false) {
                results.add(model);
              }
            }
            if (requestCount == datas.length) {
              results.sort((a, b) => b.date.compareTo(a.date));
              if (block != null) {
                block(results, 200);
              }
            }
          });
        }
      } else {
        if (block != null) {
          block([], 500);
        }
      }
    });
  }

  static void _requestETHAddresssInfo(
      {String from, String contract, complationBlock block}) {
    Map gasPrice = {
      "jsonrpc": "2.0",
      "method": "eth_gasPrice",
      "params": [],
      "id": "p"
    };
    Map nonce = {
      "jsonrpc": "2.0",
      "id": "n",
      "method": "eth_getTransactionCount",
      "params": [from, "latest"]
    };
    Map version = {
      "jsonrpc": "2.0",
      "method": "net_version",
      "params": [],
      "id": "v"
    };

    RequestMethod().requestNetwork(Method.POST, _ethurl, (response, code) {
      if (code == 200) {
        if (response as List != null) {
          Map<String, dynamic> values = Map();
          values["g"] = "23788";
          if (contract.isValid()) {
            values["g"] = "60000";
          }
          List datas = response as List;
          datas.forEach(
            (element) {
              if (element as Map != null) {
                Map params = element as Map;
                if (params.keys.contains("result")) {
                  String result = params["result"] as String;
                  String id = params["id"] as String;
                  result = result.replaceFirst("0x", '');
                  BigInt bigValue = BigInt.parse(result, radix: 16);
                  values[id] = bigValue.toString();
                }
              }
            },
          );
          if (block != null) {
            block(values, 200);
          }
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: [gasPrice, nonce, version]);
  }

  static void _requestDotChainInfo(
      {String from, String contract, complationBlock block}) async {
    String nonceKey = await ChannelNative.polkadotgetNonceKey(from);
    nonceKey = "0x" + nonceKey;
    Map spec_trans_version = {
      "jsonrpc": "2.0",
      "method": "state_getRuntimeVersion",
      "params": [],
      "id": "state_getRuntimeVersion"
    };
    Map blockNumber = {
      "jsonrpc": "2.0",
      "id": "chain_getBlock",
      "method": "chain_getBlock",
      "params": []
    };
    Map getBlockHash = {
      "jsonrpc": "2.0",
      "method": "chain_getBlockHash",
      "params": [],
      "id": "chain_getBlockHash"
    };
    Map getNonce = {
      "jsonrpc": "2.0",
      "method": "state_getStorage",
      "params": [nonceKey],
      "id": "getNonce"
    };
    String url = "http://192.168.1.224:9933";
    Map<String, dynamic> objects = Map();
    RequestMethod().requestNetwork(Method.POST, url, (result, code) {
      if (code == 200 && result is List) {
        for (Map item in result) {
          if (item.containsKey("result") == true) {
            if (item["id"] == "state_getRuntimeVersion") {
              int specVersion = item["result"]["specVersion"] as int;
              int transactionVersion =
                  item["result"]["transactionVersion"] as int;
              objects["specVersion"] = specVersion;
              objects["txVersion"] = transactionVersion;
            } else if (item["id"] == "chain_getBlock") {
              String number = item["result"]["block"]["header"]["number"];
              number = number.replaceAll("0x", "");
              int blocknum = int.tryParse(number, radix: 16);
              objects["blockNumber"] = blocknum;
              // getBlockHash["params"] = [blocknum, 0];
              Map genParams = Map.from(getBlockHash);
              getBlockHash["params"] = [blocknum];
              genParams["params"] = [0];
              RequestMethod().requestNetwork(Method.POST, url,
                  (hashresult, hashcode) {
                if (hashcode == 200 && hashresult is List) {
                  String value = hashresult[0]["result"];
                  objects["blockHash"] = value;
                  String genesisHash = hashresult[1]["result"];
                  objects["genesisHash"] = genesisHash;
                  if (block != null) {
                    block(objects, 200);
                  }
                } else {
                  if (block != null) {
                    block(null, 500);
                  }
                }
              }, data: [getBlockHash, genParams]);
            } else if (item["id"] == "getNonce") {
              String value = item["result"] as String;
              value ??= "0000000000000000";
              String nonceStr = value.replaceAll("0x", "").substring(0, 16);
              int nonce =
                  InstructionDataFormat.littleConvertBigEndian(nonceStr);
              LogUtil.v("nonce $nonce");
              objects["nonce"] = nonce;
            }
          } else {
            if (block != null) {
              block(null, 500);
            }
            break;
          }
        }
      } else {
        if (block != null) {
          block(null, 500);
        }
      }
    }, data: [spec_trans_version, blockNumber, getNonce]);
  }

  static void _requesUnSpendList(
      String chainType, String from, String amount, complationBlock block) {
    if (chainType.toLowerCase() == "btc" || chainType.toLowerCase() == "usdt") {
      return _requesBTCUnSpendList(from, amount, block);
    }
  }

  static void _requesBTCUnSpendList(
      String from, String amount, complationBlock block) async {
    String baseurl;
    String url;
    if (isTestNode == true) {
      baseurl = _btcurl + regtestBtcList;
    } else {
      baseurl = _btcurl + mainnetBtcList;
    }
    url = baseurl + "/address/$from/?unspent=true&limit=1000";
    RequestMethod().requestNetwork(Method.GET, url, (result, code) {
      if (code == 200) {
        List<Map<String, dynamic>> datas = [];
        for (var item in result) {
          Map<String, dynamic> params = Map();
          params["tx_hash"] = item["mintTxid"] as String;
          params["tx_pos"] = item["mintIndex"];
          params["value"] = item["value"];
          params["height"] = item["mintHeight"];
          datas.add(params);
        }
        if (block != null) {
          block(datas, 200);
        }
      } else {
        if (block != null) {
          block([], 500);
        }
      }
    });
  }

  static void _pushETHData(String packByteString, complationBlock block) {
    final Map<String, dynamic> params = {
      "id": "1",
      "jsonrpc": "2.0",
      "method": "eth_sendRawTransaction",
      "params": [packByteString]
    };

    RequestMethod().requestNetwork(Method.POST, _ethurl, (response, code) {
      if (code == 200 && response as Map != null) {
        if (response.keys.contains("error")) {
          Map<String, dynamic> err = response["error"] as Map;
          if (err != null) {
            String message = err["message"] as String;
            int code = err["code"] as int;
            if (block != null) {
              //失败 texid 为空
              block(message, code);
            }
          }
        } else if (response.keys.contains("result")) {
          String result = response["result"] as String;
          if (block != null) {
            block(result, 200);
          }
        }
      } else {
        if (block != null) {
          block([], 500);
        }
      }
    }, data: params);
  }

  static void _pushBTCData(String packByteString, complationBlock block) {
    if (isTestNode) {
      String url = _btcurl + regtestBtcSend;
      Map<String, dynamic> params = {"rawTx": packByteString};
      RequestMethod().requestNetwork(Method.POST, url, (response, code) {
        if (code == 200 && response as Map != null) {
          if (response.keys.contains("txid")) {
            String result = response["txid"] as String;
            if (block != null) {
              block(result, 200);
            } else {
              block(response.toString(), 500);
            }
          }
        } else {
          block(response.toString(), 500);
        }
      }, data: params);
    } else {
      final Map<String, dynamic> params = {
        "id": "3",
        "jsonrpc": "2.0",
        "method": "blockchain.transaction.broadcast",
        "params": [packByteString]
      };
      RequestMethod().requestNetwork(Method.POST, _btcurl, (response, code) {
        if (code == 200 && response as Map != null) {
          if (response.keys.contains("error")) {
            Map<String, dynamic> err = response["error"] as Map;
            if (err != null) {
              String message = err["message"] as String;
              int code = err["code"] as int;
              if (block != null) {
                block(message, code);
              }
            }
          } else if (response.keys.contains("result")) {
            String result = response["result"] as String;
            if (block != null) {
              block(result, 200);
            }
          }
        } else {
          if (block != null) {
            block("", 500);
          }
        }
      }, data: params);
    }
  }

  static void _pushDOTData(String packByteString, complationBlock block) {
    final Map<String, dynamic> params = {
      "id": "3",
      "jsonrpc": "2.0",
      "method": "author_submitExtrinsic",
      "params": [packByteString]
    };
    RequestMethod().requestNetwork(Method.POST, "http://192.168.1.224:9933",
        (response, code) {
      if (code == 200 && response as Map != null) {
        if (response.keys.contains("error")) {
          Map<String, dynamic> err = response["error"] as Map;
          if (err != null) {
            String message = err["message"] as String;
            int code = err["code"] as int;
            if (block != null) {
              block(message, code);
            }
          }
        } else if (response.keys.contains("result")) {
          String result = response["result"] as String;
          if (block != null) {
            block(result, 200);
          }
        }
      } else {
        if (block != null) {
          block("", 500);
        }
      }
    }, data: params);
  }

  static Future<dynamic> _requestETHAssets(
      {String from,
      String contract,
      String token,
      int tokenDecimal = 18,
      bool neePrice = true,
      complationBlock block}) async {
    Map<String, dynamic> balanceParams = Map();
    if (contract.isValid() == true) {
      String data =
          "0x70a08231000000000000000000000000" + from.replaceAll("0x", "");

      balanceParams["jsonrpc"] = "2.0";
      balanceParams["method"] = "eth_call";
      balanceParams["params"] = [
        {"to": contract, "data": data},
        "latest"
      ];
      balanceParams["id"] = 1;
    } else {
      balanceParams["jsonrpc"] = "2.0";
      balanceParams["method"] = "eth_getBalance";
      balanceParams["params"] = [from, "latest"];
      balanceParams["id"] = 1;
    }
    Map<String, dynamic> assetResult = {"c": "0", "p": "0", "up": "0"};
    dynamic balresult = await RequestMethod()
        .futureRequestData(Method.POST, _ethurl, null, data: balanceParams);
    if (balresult != null && tokenDecimal != 0) {
      String bal = balresult["result"] as String;
      bal = bal?.replaceFirst("0x", "");
      bal ??= "";
      bal = bal.length == 0 ? "0" : bal;
      bal = (BigInt.tryParse(bal, radix: 16)).toString();
      if (contract.isValid() == false) {
        bal = (double.tryParse(bal) / pow(10, 18)).toString();
      } else {
        bal = (double.tryParse(bal) / pow(10, tokenDecimal)).toString();
      }
      assetResult["c"] = bal ??= "0";
    }
    if (neePrice == true) {
      Map<String, dynamic> priceResule = await WalletServices.requestTokenPrice(
          token == null ? "ETH" : token, null);
      priceResule.forEach((key, value) {
        assetResult[key] = value;
      });
    }
    if (block != null) {
      block(assetResult, 200);
    }
    return assetResult;
  }

  static Future<dynamic> _requestDotAssets(
      String from, bool neePrice, complationBlock block) async {
    Map<String, dynamic> assetResult = {"c": "1000", "p": "100", "up": "1"};
    String url = "https://polkadot.subscan.io/api/scan/search";
    Map<String, dynamic> balanceParams = Map();
    // from = "13GkDCmf2pxLW1mDCTkSezQF541Ksy6MsZfAEhw5vfTdPsxE";
    balanceParams["key"] = from;
    balanceParams["row"] = 1;
    balanceParams["page"] = 0;
    dynamic balresult = await RequestMethod()
        .futureRequestData(Method.POST, url, null, data: balanceParams);
    if (balresult != null) {
      Map balMap = balresult as Map;
      if (balMap != null) {
        Map dataMap = balresult["data"] as Map;
        if (dataMap != null) {
          Map accountMap = dataMap["account"] as Map;
          assetResult["c"] = accountMap["balance"];
          // assetResult["c"] = "1000";
          if (neePrice) {
            Map<String, dynamic> priceResule = await requestDotPrice(null);
            priceResule.forEach((key, value) {
              assetResult[key] = value;
            });
          }
        }
      }
    }
    if (block != null) {
      block(assetResult, 200);
    }
    return assetResult;
  }

  static Future<dynamic> _requestBTCAssets(
      String from, bool neePrice, complationBlock block) async {
    Map<String, dynamic> assetResult = {"c": "0", "p": "0", "up": "0"};
    String url = "";
    if (isTestNode) {
      url = _btcurl + "$regtestBtcList/address/$from/balance";
    } else {
      url = _btcurl + "$mainnetBtcList/address/$from/balance";
    }
    dynamic balresult = await RequestMethod()
        .futureRequestData(Method.GET, url, (balresult, balcode) {});
    if (balresult != null) {
      Map balMap = balresult as Map;
      if (balMap != null) {
        BigInt confirmed = BigInt.from(balMap["confirmed"]);
        String bal = (confirmed / BigInt.from(pow(10, 8))).toString();
        assetResult["c"] = bal;
      }
    }
    // dynamic usdtresult = _requestUSDTAssets(from, neePrice, null);

    if (neePrice == true) {
      Map<String, dynamic> priceResule =
          await WalletServices.requestTokenPrice("BTC", null);
      priceResule.forEach((key, value) {
        assetResult[key] = value;
      });
    }
    if (block != null) {
      block(assetResult, 200);
    }
    return assetResult;
  }

  static Future<dynamic> _requestUSDTAssets(
      String from, bool neePrice, complationBlock block) async {
    Map<String, dynamic> assetResult = {"c": "0", "p": "0", "up": "0"};

    Map<String, dynamic> info = Map();
    info["addr"] = from;
    String url = "https://api.omniexplorer.info/v1/address/addr/";
    dynamic balresult = await RequestMethod().futureRequestData(
        Method.POST, url, (balresult, balcode) {},
        data: info);
    if (balresult != null) {
      Map balMap = balresult as Map;
      if (balMap != null && balMap.containsKey("balance") == true) {
        for (var balance in balMap["balance"]) {
          Map propertyinfo = balance["propertyinfo"];
          if (propertyinfo != null && propertyinfo["name"] == "TetherUS") {
            String usdtValue = balance["value"];
            String bal = (double.tryParse(usdtValue) / (pow(10, 8))).toString();
            assetResult["c"] = bal;
          }
        }
      }
    }
    if (neePrice == true) {
      Map<String, dynamic> priceResule =
          await WalletServices.requestTokenPrice("USDT", null);
      priceResule.forEach((key, value) {
        assetResult[key] = value;
      });
    }
    if (block != null) {
      block(assetResult, 200);
    }
    return assetResult;
  }

  static Future<Map<String, dynamic>> requestDotPrice(
      complationBlock block) async {
    Map<String, dynamic> datas = Map();
    datas["p"] = "0";
    datas["up"] = "0";
    dynamic usdresult = await RequestMethod().futureRequestData(
        Method.POST, "https://polkadot.subscan.io/api/scan/token", null);
    if (usdresult != null) {
      Map pMap = usdresult as Map;
      if (pMap != null) {
        Map dataMap = pMap["data"] as Map;
        if (dataMap != null) {
          Map detailMap = dataMap["detail"] as Map;
          if (detailMap != null) {
            Map dotMap = detailMap["DOT"] as Map;
            if (dotMap != null) {
              datas["up"] = dotMap["price"];
              dynamic rateresult = await RequestMethod().futureRequestData(
                  Method.GET,
                  "https://api.it120.cc/gooking/forex/rate?fromCode=CNY&toCode=USD",
                  null);
              if (rateresult != null) {
                Map rateMap = rateresult as Map;
                if (rateMap != null) {
                  Map dataMap = rateMap["data"] as Map;
                  if (dataMap != null) {
                    datas["p"] =
                        (double.parse(dotMap["price"]) * dataMap["rate"])
                            .toString();
                  }
                }
              }
            }
          }
        }
      }
    }
    if (block != null) {
      block(datas, 200);
    }
    return Future.value(datas);
  }

  /// d = toAddress; a  o 0in 1 出
  static Map _checkTransType(
      String chainType, String from, List inputs, List outputs) {
    //根据input里数组有没有自己判断转入转出
    //转入时在input取转入的地址，在out取自己地址对应的金额,
    //转出时在out里去转出的地址，过滤找零金额取显示的地址金额
    Map params = Map();
    int out = 0; //默认转入
    String toAddress = "coinbase";
    BigInt value = BigInt.zero;
    if (chainType.toLowerCase() == "btc" || chainType.toLowerCase() == "bch") {
      //判断转入转出
      if (inputs.length > 0) {
        for (var input in inputs) {
          String address = input["address"] as String;
          if (address != null && from.toLowerCase() == address.toLowerCase()) {
            out = 1; //转出
            break;
          }
        }
      }
      //找出地址金额
      if (out == 0) {
        if (inputs.length > 0) {
          for (var input in inputs) {
            String address = input["address"] as String;
            if (address != null && address.length > 0) {
              toAddress = address;
              break;
            }
          }
        }
        for (var output in outputs) {
          String address = output["address"];
          if (address == "false") {
            continue;
          }
          if (address.toLowerCase() == from.toLowerCase()) {
            value = BigInt.from(output["value"]);
            break;
          }
        }
      } else {
        for (var output in outputs) {
          String address = output["address"];
          if (address == "false") {
            continue;
          }
          toAddress = address;
          if (toAddress.toLowerCase() == from.toLowerCase()) {
            //剔除找零
            continue;
          }
          value = BigInt.from(output["value"]);
          break;
        }
      }
    } else if (chainType.toLowerCase() == "ltc") {
      if (inputs.length > 0) {
        for (var input in inputs) {
          String addr = input["addr"] as String;
          if (addr != null && from.toLowerCase() == addr.toLowerCase()) {
            out = 1; //转出
            break;
          }
        }
      }
      if (out == 0) {
        for (var input in inputs) {
          String addr = input["addr"] as String;
          if (addr != null) {
            toAddress = addr;
            break;
          }
        }
        for (var output in outputs) {
          Map scriptPubKey = output["scriptPubKey"] as Map;
          if (scriptPubKey != null) {
            List addresses = scriptPubKey["addresses"] as List;
            if (addresses != null && addresses.length > 0) {
              for (String ads in addresses) {
                if (ads.toLowerCase() == from.toLowerCase()) {
                  double amount = double.parse(output["value"] as String);
                  value = BigInt.from(amount * pow(10, 8));
                  break;
                }
              }
            }
          }
        }
      } else {
        for (var output in outputs) {
          Map scriptPubKey = output["scriptPubKey"] as Map;
          if (scriptPubKey != null) {
            List addresses = scriptPubKey["addresses"] as List;
            if (addresses != null && addresses.length > 0) {
              for (String add in addresses) {
                if (add.toLowerCase() == from.toLowerCase()) {
                  continue;
                }
                toAddress = add;
                double amount = double.parse(output["value"] as String);
                value = BigInt.from(amount * pow(10, 8));
                break;
              }
            }
          }
        }
      }
    } else if (chainType.toLowerCase() == "btm") {
      if (inputs.length > 0) {
        for (var input in inputs) {
          if (input["address"].toLowerCase() == from.toLowerCase()) {
            out = 1;
            break;
          }
        }
      }
      //找出地址金额
      if (out == 0) {
        if (inputs.length > 0) {
          for (var input in inputs) {
            String address = input["address"] as String;
            if (address != null && address.length > 0) {
              toAddress = address;
              break;
            }
          }
        }
      } else {
        for (var output in outputs) {
          String address = output["address"];
          if (address != null && address.length > 0) {
            toAddress = address;
            break;
          }
          break;
        }
      }
    }
    params["d"] = toAddress;
    params["a"] = value.toString();
    params["o"] = out;
    return params;
  }
}
