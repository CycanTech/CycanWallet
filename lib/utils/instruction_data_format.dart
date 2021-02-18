//指令数据格式转换
import 'dart:convert';
import 'package:flutter_coinid/utils/log_util.dart';

import 'package:crypto/crypto.dart';

class InstructionDataFormat {
  //10进制转换成16进制数组
  static Future<List<int>> intToHex(String value) async {
    List<int> list = [];
    for (int i = 0; i < value.length / 2; i++) {
      String instruction = value.substring(i * 2, i * 2 + 2);
      list.add(int.parse(instruction, radix: 16));
    }
    return Future.value(list);
  }

  ///10进制数据转16进制数据
  static List<String> intParseHex(String value) {
    List<String> list = [];
    String hexNum = int.tryParse(value).toRadixString(16);
    for (int i = 0; i < hexNum.length; i += 2) {
      String instruction;
      try {
        instruction = hexNum.substring(i, i + 2);
      } catch (e) {
        instruction = hexNum.substring(i, i + 1);
      }
      LogUtil.v("instruction $instruction hexNum $hexNum");
      list.add(instruction);
    }
    return list;
  }

  static List<String> hexParseList(String value) {
    List<String> list = [];
    for (int i = 0; i < value.length / 2; i++) {
      String instruction = value.substring(i * 2, i * 2 + 2);
      list.add(instruction);
    }
    return list;
  }

 
  //10进制数组转换成字符串
  static String intToString(List<int> value) {
    String result = "";
    try {
      while (value.length > 0 && value.last == 0) {
        value.removeLast();
      }
      result = utf8.decode(value);
    } catch (e) {}
    return result;
  }

  static int crc16(List<int> bytes, int len) {
    int crc = 0xFFFF;
    for (int j = 0; j < len; j++) {
      crc = (((crc >> 8) | (crc << 8)) & 0xffff);
      crc ^= (bytes[j] & 0xff);
      crc ^= ((crc & 0xff) >> 4);
      crc ^= (crc << 12) & 0xffff;
      crc ^= ((crc & 0xFF) << 5) & 0xffff;
    }
    crc &= 0xffff;
    return crc;
  }

  static bool verifyCrc16(List<int> bytes) {
    if (bytes == null || bytes.length < 6) {
      return false;
    }
    List<int> datas = bytes.sublist(0, bytes.length - 2);
    int ownCrc = crc16(datas, datas.length);
    List<int> crcs = bytes.sublist(bytes.length - 2, bytes.length);
    int receiveCrc = ((crcs[0]) << 8) + crcs[1];
    return ownCrc == receiveCrc;
  }

  static String convertHex(List<int> datas) {
    String values = "";
    for (var item in datas) {
      String aa = item.toRadixString(16).toString();
      if (aa.length == 1) {
        aa = "0" + aa;
      }
      values += aa;
    }
    return values;
  }

  static String SHA1(String content) {
    if (content == null || content.length == 0) {
      return "";
    }
    try {
      return sha256.convert(utf8.encode(content)).toString();
    } catch (e) {
      LogUtil.v("SHA1 err" + e);
    }
    return "";
  }
}
