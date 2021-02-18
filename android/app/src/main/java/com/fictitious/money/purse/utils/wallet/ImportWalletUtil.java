package com.fictitious.money.purse.utils.wallet;

import android.text.TextUtils;

import com.fictitious.money.purse.Constants;
import com.fictitious.money.purse.model.MemorizingWordInfo;
import com.fictitious.money.purse.utils.CommonUtil;
import com.fictitious.money.purse.utils.DigitalTrans;
import com.fictitious.money.purse.utils.HexUtil;
import com.fictitious.money.purse.utils.XMHCoinUtitls;
import com.google.gson.Gson;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ImportWalletUtil {

    //EOS
    private static String temp_public, temp_private;
    private static String owner_public, owner_private;
    private static String active_public, active_private;
    private static byte[] owner_byte, active_byte;
    private static byte[] owner_public_result, active_public_result;
    private static byte[] owner_private_result, active_private_result;

    //GPS
    private static String owner_gps_public, owner_gps_private;
    private static String active_gps_public, active_gps_private;
    private static byte[] owner_gps_byte, active_gps_byte;
    private static byte[] owner_gps_public_result, active_gps_public_result;
    private static byte[] owner_gps_private_result, active_gps_private_result;

    //vns
    private static String vns_public, vns_private;
    private static byte[] vns_byte;
    private static byte[] vns_public_result, vns_private_result;

    //eth
    private static String eth_public, eth_private;
    private static byte[] eth_byte;
    private static byte[] eth_public_result, eth_private_result;

    //btc
    private static String btc_public, btc_private;
    private static byte[] btc_byte;
    private static byte[] btc_public_result, btc_private_result;

    //btm
    private static String btm_public, btm_private;
    private static byte[] btm_byte;
    private static byte[] btm_public_result, btm_private_result;

    //ltc
    private static String ltc_public, ltc_private;
    private static byte[] ltc_byte;
    private static byte[] ltc_public_result, ltc_private_result;

    //bch
    private static String bch_public, bch_private;
    private static byte[] bch_byte;
    private static byte[] bch_public_result, bch_private_result;

    //dash
    private static String dash_public, dash_private;
    private static byte[] dash_byte;
    private static byte[] dash_public_result, dash_private_result;

    //polkadot
    private static String pk_public, pk_private;
    private static byte[] pk_byte;
    private static byte[] pk_public_result, pk_private_result;

    public static List importPurse(int leadType, int mCoin_type, String pin, String content)
    {
        boolean isChinese = false;
        List<MemorizingWordInfo> wordslist = new ArrayList<>();
        List wallets = new ArrayList();
        if(leadType == Constants.LEAD_TYPE.MEMO || leadType == Constants.LEAD_TYPE.STANDARMEMO)
        {
            String chinese = CommonUtil.readAssetsTxt("chinese_simplified").replace("\r\n",",").replace("\n",",").replace("\r",",").replace("\t",",");
            String englise = CommonUtil.readAssetsTxt("english").replace("\r\n",",").replace("\n",",").replace("\r",",").replace("\t",",");
            String[] chineses = chinese.split(",");
            String[] englishs = englise.split(",");
            List<String> arr_chinese = new ArrayList<>();
            List<String> arr_english = new ArrayList<>();

            if(chineses != null)
            {
                arr_chinese = Arrays.asList(chinese.split(","));
            }

            if(englishs != null)
            {
                arr_english = Arrays.asList(englise.split(","));
            }

            String wordList = content.replaceAll(",", " ").replaceAll("，", " ").trim();
            String[] words = wordList.split(" ");
            List<String> arr_words = Arrays.asList(words);
            if(words.length != 12 && words.length != 18 && words.length != 24)
            {
                return wallets;
            }
            else
            {
                boolean isError = false;
                for (String s : arr_words)
                {
                    if(!arr_chinese.contains(s))
                    {
                        isError = false;
                        break;
                    }
                    else
                    {
                        isError = true;
                        isChinese = true;
                    }
                }

                if(!isError)
                {
                    for (String s : arr_words)
                    {
                        if(!arr_english.contains(s))
                        {
                            isError = false;
                            break;
                        }
                        else
                        {
                            isError = true;
                            isChinese = false;
                        }
                    }
                }

                if(isError)
                {
                    for (String s : arr_words)
                    {
                        if(isChinese){
                            for (int i = 0; i < arr_chinese.size(); i ++)
                            {
                                if(s.equals(arr_chinese.get(i)))
                                {
                                    MemorizingWordInfo memorizingWordInfo = new MemorizingWordInfo();
                                    memorizingWordInfo.setIndex(i);
                                    memorizingWordInfo.setWord(s);
                                    wordslist.add(memorizingWordInfo);
                                }
                            }
                        } else {
                            for (int i = 0; i < arr_english.size(); i ++)
                            {
                                if(s.equals(arr_english.get(i)))
                                {
                                    MemorizingWordInfo memorizingWordInfo = new MemorizingWordInfo();
                                    memorizingWordInfo.setIndex(i);
                                    memorizingWordInfo.setWord(s);
                                    wordslist.add(memorizingWordInfo);
                                }
                            }
                        }
                    }

                    String[] words_arr = content.replaceAll(",", " ").replaceAll("，", " ").trim().split(" ");
                    short[] index_arr = new short[wordslist.size()];
                    String hex_str = "";
                    boolean result;
                    if(wordslist !=  null && wordslist.size() > 0){
                        for (int i = 0; i < wordslist.size(); i ++) {
                            index_arr[i] = (short) wordslist.get(i).getIndex();
                        }
                    }
                    boolean checkMemo = XMHCoinUtitls.CoinID_checkMemoValid(index_arr, (byte) (index_arr.length));
                    if(!checkMemo){
                        wordslist.clear();
                        return wallets;
                    }

                    if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                        result =  XMHCoinUtitls.CoinID_SetMasterStandard(content.replaceAll(",", " ").replaceAll("，", " ").trim());
                    } else {
                        if (isChinese) {
                            for (int i = 0; i < words_arr.length; i ++) {
                                try {
                                    byte[] hex = new byte[2];
                                    byte[] bytes = words_arr[i].getBytes("gb2312");
                                    hex[0] = bytes[0];
                                    hex[1] = bytes[1];
                                    hex_str += DigitalTrans.byte2hex(hex);
                                } catch (UnsupportedEncodingException e) {
                                    e.printStackTrace();
                                }
                            }

                            byte[] mnemonicBuffer = HexUtil.hexStringToBytes(hex_str);
                            result =  XMHCoinUtitls.CoinID_SetMaster(mnemonicBuffer, (short) mnemonicBuffer.length);//先验证助记词
                        } else {
                            byte[] mnemonicBuffer = CommonUtil.strToByteArray(wordList.replace(" ", ""));
                            result =  XMHCoinUtitls.CoinID_SetMaster(mnemonicBuffer, (short) mnemonicBuffer.length);//先验证助记词
                        }
                    }

                    if(result){
                        if(mCoin_type == Constants.COIN_TYPE.TYPE_EOS) {
                            //EOS
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String ownerStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/194'/0'/0/0");
                                String activeStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/194'/0'/0/0");
                                owner_byte = HexUtil.hexStringToBytes(ownerStr);
                                active_byte = HexUtil.hexStringToBytes(activeStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveEOSKeyRoot();//生成EOS主私钥
                                XMHCoinUtitls.CoinID_DeriveEOSKeyAccount(0);
                                owner_byte = XMHCoinUtitls.CoinID_DeriveEOSKey(0);
                                active_byte = XMHCoinUtitls.CoinID_DeriveEOSKey(1);
                            }

                            if(owner_byte == null || active_byte == null || owner_byte.length <= 32 || active_byte.length <= 32){
                                return wallets;
                            }

                            //私钥
                            owner_private_result = new byte[32];
                            active_private_result = new byte[32];
                            System.arraycopy(owner_byte, 0, owner_private_result, 0 , owner_private_result.length);
                            System.arraycopy(active_byte, 0, active_private_result, 0 , active_private_result.length);
                            owner_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_private_result), pin));
                            active_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(active_private_result), pin));

                            //公钥的
                            owner_public_result = new byte[owner_byte.length - 32];
                            active_public_result = new byte[active_byte.length - 32];
                            System.arraycopy(owner_byte, 32, owner_public_result, 0 , owner_public_result.length);
                            System.arraycopy(active_byte, 32, active_public_result, 0 , active_public_result.length);
                            owner_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportEOSPubKey(owner_public_result));
                            active_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportEOSPubKey(active_public_result));

                            if(TextUtils.isEmpty(owner_public) || TextUtils.isEmpty(owner_private) || TextUtils.isEmpty(active_public) || TextUtils.isEmpty(active_private))
                            {
                                return wallets;
                            }
                            else
                            {
                                Map map = new HashMap();
                                map.put("prvKey", owner_private);
                                map.put("subPrvKey", active_private);
                                map.put("pubKey", owner_public);
                                map.put("subPubKey", active_public);
                                map.put("coinType", Constants.COIN_TYPE.TYPE_EOS);
                                map.put("address", "");
                                map.put("masterPubKey", "");
                                wallets.add(map);
                                return wallets;
                            }
                        }
                        else if(mCoin_type == Constants.COIN_TYPE.TYPE_GPS)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String ownerStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/194'/0'/0/0");
                                String activeStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/194'/0'/0/0");
                                owner_gps_byte = HexUtil.hexStringToBytes(ownerStr);
                                active_gps_byte = HexUtil.hexStringToBytes(activeStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveEOSKeyRoot();//生成GPS主私钥
                                XMHCoinUtitls.CoinID_DeriveEOSKeyAccount(1);
                                owner_gps_byte = XMHCoinUtitls.CoinID_DeriveEOSKey(0);
                                active_gps_byte = XMHCoinUtitls.CoinID_DeriveEOSKey(1);
                            }

                            if(owner_gps_byte == null || active_gps_byte == null || owner_gps_byte.length <= 32 || active_gps_byte.length <= 32){
                                return wallets;
                            }

                            //私钥
                            owner_gps_private_result = new byte[32];
                            active_gps_private_result = new byte[32];
                            System.arraycopy(owner_gps_byte, 0, owner_gps_private_result, 0 , owner_gps_private_result.length);
                            System.arraycopy(active_gps_byte, 0, active_gps_private_result, 0 , active_gps_private_result.length);
                            owner_gps_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_gps_private_result), pin));
                            active_gps_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(active_gps_private_result), pin));

                            //公钥的
                            owner_gps_public_result = new byte[33];
                            active_gps_public_result = new byte[33];
                            System.arraycopy(owner_gps_byte, 32, owner_gps_public_result, 0 , owner_gps_public_result.length);
                            System.arraycopy(active_gps_byte, 32, active_gps_public_result, 0 , active_gps_public_result.length);
                            owner_gps_public = XMHCoinUtitls.CoinID_ExportEOSPubByPre("GPS", HexUtil.encodeHexStr(owner_gps_public_result));
                            active_gps_public = XMHCoinUtitls.CoinID_ExportEOSPubByPre("GPS", HexUtil.encodeHexStr(active_gps_public_result));

                            if(TextUtils.isEmpty(owner_gps_public) || TextUtils.isEmpty(owner_gps_private) || TextUtils.isEmpty(active_gps_public) || TextUtils.isEmpty(active_gps_private))
                            {
                                return wallets;
                            }
                            else
                            {
                                Map map = new HashMap();
                                map.put("prvKey", owner_gps_private);
                                map.put("subPrvKey", active_gps_private);
                                map.put("pubKey", owner_gps_public);
                                map.put("subPubKey", active_gps_public);
                                map.put("coinType", Constants.COIN_TYPE.TYPE_GPS);
                                map.put("address", "");
                                map.put("masterPubKey", "");
                                wallets.add(map);
                                return wallets;
                            }
                        }
                        else if(mCoin_type == Constants.COIN_TYPE.TYPE_ETH)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String ethStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/60'/0'/0/0");
                                eth_byte = HexUtil.hexStringToBytes(ethStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveETHKeyRoot();
                                XMHCoinUtitls.CoinID_DeriveETHKeyAccount(0);
                                eth_byte = XMHCoinUtitls.CoinID_DeriveETHKey(0);
                            }
                            return getEthPurse(eth_byte,  pin);
                        }
                        else if(mCoin_type == Constants.COIN_TYPE.TYPE_VNS)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String vnsStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/316'/0'/0/0");
                                vns_byte = HexUtil.hexStringToBytes(vnsStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveKeyRoot(0x13c);
                                XMHCoinUtitls.CoinID_DeriveKeyAccount(0);
                                vns_byte = XMHCoinUtitls.CoinID_DeriveKey(0);
                            }
                            return getVnsPurse(vns_byte,  pin);
                        }
                        else  if(mCoin_type == Constants.COIN_TYPE.TYPE_BTC)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String btcStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/0'/0'/0/0");
                                btc_byte = HexUtil.hexStringToBytes(btcStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveBTCKeyRoot();
                                XMHCoinUtitls.CoinID_DeriveBTCKeyAccount(0);
                                btc_byte = XMHCoinUtitls.CoinID_DeriveBTCKey(0);
                            }
                            return getBtcPurse(btc_byte,  pin);
                        }
                        else  if(mCoin_type == Constants.COIN_TYPE.TYPE_BTM)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String btmStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44/153/1/0/1");
                                btm_byte = HexUtil.hexStringToBytes(btmStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveKeyRoot(0x99);
                                XMHCoinUtitls.CoinID_DeriveKeyAccount(0);
                                btm_byte = XMHCoinUtitls.CoinID_DeriveKey(0);
                            }
                            return getBtmPurse(btm_byte, pin);
                        }
                        else  if(mCoin_type == Constants.COIN_TYPE.TYPE_LTC)
                        {
                            if(leadType == Constants.LEAD_TYPE.STANDARMEMO){
                                String ltcStr = XMHCoinUtitls.CoinID_deriveKeyByPath("44'/2'/0'/0/0");
                                ltc_byte = HexUtil.hexStringToBytes(ltcStr);
                            } else {
                                XMHCoinUtitls.CoinID_DeriveKeyRoot(2);
                                XMHCoinUtitls.CoinID_DeriveKeyAccount(0);
                                ltc_byte = XMHCoinUtitls.CoinID_DeriveKey(0);
                            }
                            return getLtcPurse(ltc_byte, pin);
                        }
                        else if(mCoin_type == Constants.COIN_TYPE.TYPE_BCH){
                            boolean bch_result = XMHCoinUtitls.CoinID_DeriveKeyRoot(0x91);
                            if(bch_result) {
                                XMHCoinUtitls.CoinID_DeriveKeyAccount(0);
                                bch_byte = XMHCoinUtitls.CoinID_DeriveKey(0);
                                return getBchPurse(bch_byte, pin);
                            }
                        }
                        else if(mCoin_type == Constants.COIN_TYPE.TYPE_DASH){
                            boolean dash_result = XMHCoinUtitls.CoinID_DeriveKeyRoot(5);
                            if(dash_result) {
                                XMHCoinUtitls.CoinID_DeriveKeyAccount(0);
                                dash_byte = XMHCoinUtitls.CoinID_DeriveKey(0);
                                return getDashPurse(dash_byte, pin);
                            }
                        }
                        else  if(mCoin_type == Constants.COIN_TYPE.TYPE_USDT)
                        {
                            boolean btc_result = XMHCoinUtitls.CoinID_DeriveBTCKeyRoot();
                            if(btc_result)
                            {
                                XMHCoinUtitls.CoinID_DeriveBTCKeyAccount(0);
                                btc_byte = XMHCoinUtitls.CoinID_DeriveBTCKey(0);
                                return getBtcPurse(btc_byte, pin);
                            }
                        }
                        else if (mCoin_type == Constants.COIN_TYPE.TYPE_POLKADOT)
                        {
                            short[] mnemonicIndexBuffer = new short[words_arr.length];
                            if(isChinese){
                                for(int i = 0; i < words_arr.length; i ++){
                                    mnemonicIndexBuffer[i] = (short) arr_chinese.indexOf(words_arr[i]);
                                }
                            } else {
                                for(int i = 0; i < words_arr.length; i ++){
                                    mnemonicIndexBuffer[i] = (short) arr_english.indexOf(words_arr[i]);
                                }
                            }

                            String pkStr = XMHCoinUtitls.CoinID_genPolkaDotKeyPairByPath(mnemonicIndexBuffer, words_arr.length, "");
                            pk_byte = HexUtil.hexStringToBytes(pkStr);
                            return getPolkadotPurse(pk_byte, pin);
                        }
                    }
                    else
                    {
                        return wallets;
                    }
                }
                else
                {
                    return wallets;
                }
            }
        }
        else if(leadType == Constants.LEAD_TYPE.KEYSTORE)
        {
            byte[] jsonByte = CommonUtil.strToByteArray(content);
            byte[] passWordByte = CommonUtil.strToByteArray(pin);
            byte[] outLen = new byte[2];
            if(mCoin_type == Constants.COIN_TYPE.TYPE_EOS) {
                owner_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getEosPurse(owner_byte, pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_GPS) {
                owner_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getGpsPurse(owner_byte, pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_ETH){
                eth_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getEthPurse(eth_byte, pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_VNS){
                vns_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getVnsPurse(vns_byte,pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_BTC){
                btc_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getBtcPurse(btc_byte, pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_LTC){
                ltc_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getLtcPurse(ltc_byte, pin);
            } else if(mCoin_type == Constants.COIN_TYPE.TYPE_BCH){
                bch_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getBchPurse(bch_byte, pin);
            } else if(mCoin_type == Constants.COIN_TYPE.TYPE_DASH){
                dash_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getDashPurse(dash_byte, pin);
            }else if(mCoin_type == Constants.COIN_TYPE.TYPE_USDT){
                btc_byte = XMHCoinUtitls.CoinID_importKeyStore(jsonByte, passWordByte, (byte) passWordByte.length, outLen);
                return getBtcPurse(btc_byte, pin);
            } else if (mCoin_type == Constants.COIN_TYPE.TYPE_POLKADOT) {
                String pk_byte_str = XMHCoinUtitls.CoinID_polkadot_ipt_keystore(pin, content);
                return getPolkadotPurse(HexUtil.hexStringToBytes(pk_byte_str), pin);
            }
        }
        else if(leadType == Constants.LEAD_TYPE.PRVKEY)
        {
            String prvStr = content.replace("\r\n","").replace("\n","").replace("\r","").replace("\t","").replace(" ", "").replace(" ", "").trim();
            if(mCoin_type == Constants.COIN_TYPE.TYPE_EOS)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                boolean check = XMHCoinUtitls.CoinID_ImportEOSPrvKeyCheck(prvKey, (byte) prvKey.length);
                if(check)
                {
                    owner_byte = XMHCoinUtitls.CoinID_ImportEOSPrvKey(prvKey, (byte) prvKey.length);
                    return getEosPurse(owner_byte, pin);
                }
                else
                {
                    return wallets;
                }
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_GPS)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                boolean check = XMHCoinUtitls.CoinID_ImportEOSPrvKeyCheck(prvKey, (byte) prvKey.length);
                if(check)
                {
                    owner_byte = XMHCoinUtitls.CoinID_ImportEOSPrvKey(prvKey, (byte) prvKey.length);
                    return getGpsPurse(owner_byte, pin);
                }
                else
                {
                    return wallets;
                }
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_ETH)
            {
                byte[] prvKey;
                try {
                    prvKey = DigitalTrans.hex2byte(prvStr);
                } catch (Exception e) {
                    return wallets;
                }

                if(prvKey == null || prvKey.length != 32){
                    return wallets;
                }

                eth_byte = XMHCoinUtitls.CoinID_ImportETHPrvKey(prvKey);
                return getEthPurse(eth_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_VNS)
            {
                byte[] prvKey;
                try {
                    prvKey = DigitalTrans.hex2byte(prvStr);
                } catch (Exception e) {
                    return wallets;
                }

                if(prvKey == null || prvKey.length != 32){
                    return wallets;
                }

                vns_byte = XMHCoinUtitls.CoinID_ImportETHPrvKey(prvKey);
                return getVnsPurse(vns_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_BTC)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                btc_byte = XMHCoinUtitls.CoinID_ImportBTCPrvKeyByWIF(prvKey, (short) prvKey.length);
                return getBtcPurse(btc_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_BTM)
            {
                byte[] prvKey;
                try {
                    prvKey = DigitalTrans.hex2byte(prvStr);
                } catch (Exception e) {
                    return wallets;
                }

                if(prvKey == null || prvKey.length != 64){
                    return wallets;
                }

                btm_byte = XMHCoinUtitls.CoinID_ImportBYTOMPrvKey(prvKey);
                return getBtmPurse(btm_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_LTC)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                ltc_byte = XMHCoinUtitls.CoinID_ImportPrvKeyByWIF(prvKey, (short) prvKey.length);
                return getLtcPurse(ltc_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_BCH)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                bch_byte = XMHCoinUtitls.CoinID_ImportPrvKeyByWIF(prvKey, (short) prvKey.length);
                return getBchPurse(bch_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_DASH)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                dash_byte = XMHCoinUtitls.CoinID_ImportPrvKeyByWIF(prvKey, (short) prvKey.length);
                return getDashPurse(dash_byte, pin);
            }
            else if(mCoin_type == Constants.COIN_TYPE.TYPE_USDT)
            {
                byte[] prvKey = CommonUtil.strToByteArray(prvStr);
                btc_byte = XMHCoinUtitls.CoinID_ImportBTCPrvKeyByWIF(prvKey, (short) prvKey.length);
                return getBtcPurse(btc_byte, pin);
            } else if (mCoin_type == Constants.COIN_TYPE.TYPE_POLKADOT) {
                String pubKey = XMHCoinUtitls.CoinID_getPolkaPubByPriv(prvStr);
                return getPolkadotPurse(pubKey, prvStr, pin);
            }
        }
        return wallets;
    }

    static List getEosPurse(byte[] owner_byte, String pin){
        List wallet = new ArrayList();
        if(owner_byte != null && owner_byte.length > 32)
        {
            //私钥
            owner_private_result = new byte[32];
            System.arraycopy(owner_byte, 0, owner_private_result, 0 , owner_private_result.length);
//            temp_private = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_private_result));
            temp_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_private_result), pin));

            //公钥
            owner_public_result = new byte[owner_byte.length - 32];
            System.arraycopy(owner_byte, 32, owner_public_result, 0 , owner_public_result.length);
            temp_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportEOSPubKey(owner_public_result));

            Map map = new HashMap();
            map.put("pubKey", temp_public);
            map.put("prvKey", temp_private);
            map.put("coinType", Constants.COIN_TYPE.TYPE_EOS);
            map.put("address", "");
            map.put("masterPubKey", "");
            wallet.add(map);
        }
        return wallet;
    }

    static List getGpsPurse(byte[] owner_byte, String pin){
        List wallet = new ArrayList();
        if(owner_byte != null && owner_byte.length > 32)
        {
            //私钥
            owner_gps_private_result = new byte[32];
            System.arraycopy(owner_byte, 0, owner_gps_private_result, 0 , owner_gps_private_result.length);
//            temp_private = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_gps_private_result));
            temp_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportEOSPrvKey(owner_gps_private_result), pin));

            //公钥
            owner_gps_public_result = new byte[33];
            System.arraycopy(owner_byte, 32, owner_gps_public_result, 0 , owner_gps_public_result.length);
            temp_public = XMHCoinUtitls.CoinID_ExportEOSPubByPre("GPS", HexUtil.encodeHexStr(owner_gps_public_result));

            Map map = new HashMap();
            map.put("pubKey", temp_public);
            map.put("prvKey", temp_private);
            map.put("coinType", Constants.COIN_TYPE.TYPE_GPS);
            map.put("address", "");
            map.put("masterPubKey", "");
            wallet.add(map);
        }
        return wallet;
    }

    static List getEthPurse(byte[] eth_byte, String pin){
        List wallet = new ArrayList();
        if(eth_byte == null || eth_byte.length <= 33){
            return wallet;
        }

        //私钥
        eth_private_result = new byte[32];
        System.arraycopy(eth_byte, 0, eth_private_result, 0 , eth_private_result.length);

        //公钥
        eth_public_result = new byte[eth_byte.length - 33];
        System.arraycopy(eth_byte, 33, eth_public_result, 0 , eth_public_result.length);

        eth_public = "0x"+ CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportETHPubKey(eth_public_result));
//        eth_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(eth_private_result, pin));
        eth_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(CommonUtil.strToByteArrayNotAddEnd(DigitalTrans.byte2hex(eth_private_result)), pin));

        Map map = new HashMap();
        map.put("prvKey", eth_private);
        map.put("pubKey", DigitalTrans.byte2hex(eth_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_ETH);
        map.put("address", eth_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getVnsPurse(byte[] vns_byte, String pin){
        List wallet = new ArrayList();
        if(vns_byte == null || vns_byte.length <= 33){
            return wallet;
        }

        //私钥
        vns_private_result = new byte[32];
        System.arraycopy(vns_byte, 0, vns_private_result, 0 , vns_private_result.length);

        //公钥
        vns_public_result = new byte[vns_byte.length - 33];
        System.arraycopy(vns_byte, 33, vns_public_result, 0 , vns_public_result.length);

        vns_public = "0x"+ CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_ExportETHPubKey(vns_public_result));
//        vns_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(vns_private_result, pin));
        vns_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(CommonUtil.strToByteArrayNotAddEnd(DigitalTrans.byte2hex(vns_private_result)), pin));

        Map map = new HashMap();
        map.put("prvKey", vns_private);
        map.put("pubKey", DigitalTrans.byte2hex(vns_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_VNS);
        map.put("address", vns_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getBtcPurse(byte[] btc_byte, String pin){
        List wallet = new ArrayList();
        if(btc_byte == null || btc_byte.length < 97){
            return wallet;
        }

        //私钥
        btc_private_result = new byte[32];
        System.arraycopy(btc_byte, 0, btc_private_result, 0 , btc_private_result.length);

        //公钥
        btc_public_result = new byte[btc_byte.length - 32];
        System.arraycopy(btc_byte, 32, btc_public_result, 0 , btc_public_result.length);

        btc_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_genBTCAddress((byte) 0, btc_public_result, (byte) 33, (byte) 0));
        btc_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportBTCPrvKeyByWIF(btc_private_result), pin));

        Map map = new HashMap();
        map.put("prvKey", btc_private);
        map.put("pubKey", DigitalTrans.byte2hex(btc_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_BTC);
        map.put("address", btc_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getDashPurse(byte[] dash_byte, String pin){
        List wallet = new ArrayList();
        if(dash_byte == null || dash_byte.length < 97){
            return wallet;
        }

        //私钥
        dash_private_result = new byte[32];
        System.arraycopy(dash_byte, 0, dash_private_result, 0 , dash_private_result.length);

        //公钥
        dash_public_result = new byte[dash_byte.length - 32];
        System.arraycopy(dash_byte, 32, dash_public_result, 0 , dash_public_result.length);

        dash_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_genBTCAddress((byte) 76, dash_public_result, (byte) 33, (byte) 0));
        dash_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportPrvKeyByWIF((byte) 204, dash_private_result), pin));

        Map map = new HashMap();
        map.put("prvKey", dash_private);
        map.put("pubKey", DigitalTrans.byte2hex(dash_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_DASH);
        map.put("address", dash_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getBchPurse(byte[] bch_byte, String pin){
        List wallet = new ArrayList();
        if(bch_byte == null || bch_byte.length < 97){
            return wallet;
        }

        //私钥
        bch_private_result = new byte[32];
        System.arraycopy(bch_byte, 0, bch_private_result, 0 , bch_private_result.length);

        //公钥
        bch_public_result = new byte[bch_byte.length - 32];
        System.arraycopy(bch_byte, 32, bch_public_result, 0 , bch_public_result.length);

        bch_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_getBCHAddress(bch_public_result));
        bch_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportPrvKeyByWIF((byte) 128, bch_private_result), pin));

        Map map = new HashMap();
        map.put("prvKey", bch_private);
        map.put("pubKey", DigitalTrans.byte2hex(bch_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_BCH);
        map.put("address", bch_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getLtcPurse(byte[] ltc_byte, String pin){
        List wallet = new ArrayList();
        if(ltc_byte == null || ltc_byte.length < 97){
            return wallet;
        }

        //私钥
        ltc_private_result = new byte[32];
        System.arraycopy(ltc_byte, 0, ltc_private_result, 0 , ltc_private_result.length);

        //公钥
        ltc_public_result = new byte[ltc_byte.length - 32];
        System.arraycopy(ltc_byte, 32, ltc_public_result, 0 , ltc_public_result.length);

        ltc_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_genBTCAddress((byte) 48, ltc_public_result, (byte) 33, (byte) 0));
        ltc_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(XMHCoinUtitls.CoinID_ExportPrvKeyByWIF((byte) 176, ltc_private_result), pin));

        Map map = new HashMap();
        map.put("prvKey", ltc_private);
        map.put("pubKey", DigitalTrans.byte2hex(ltc_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_LTC);
        map.put("address", ltc_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getBtmPurse(byte[] btm_byte, String pin){
        List wallet = new ArrayList();
        if(btm_byte == null || btm_byte.length < 128){
            return wallet;
        }

        //私钥
        btm_private_result = new byte[64];
        System.arraycopy(btm_byte, 0, btm_private_result, 0 , btm_private_result.length);

        //公钥
        btm_public_result = new byte[64];
        System.arraycopy(btm_byte, 64, btm_public_result, 0 , btm_public_result.length);

        btm_public = CommonUtil.byteArrayToStr(XMHCoinUtitls.CoinID_getBYTOMAddress(btm_public_result));
//        btm_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(btm_private_result, pin));
        btm_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(CommonUtil.strToByteArrayNotAddEnd(DigitalTrans.byte2hex(btm_private_result)), pin));

        Map map = new HashMap();
        map.put("prvKey", btm_private);
        map.put("pubKey", DigitalTrans.byte2hex(btm_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_BTM);
        map.put("address", btm_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getPolkadotPurse(byte[] pk_byte, String pin){
        List wallet = new ArrayList();
        if(pk_byte == null || pk_byte.length < 96){
            return wallet;
        }

        //私钥
        pk_private_result = new byte[64];
        System.arraycopy(pk_byte, 0, pk_private_result, 0, pk_private_result.length);

        //公钥
        pk_public_result = new byte[pk_byte.length - 64];
        System.arraycopy(pk_byte, 64, pk_public_result, 0, pk_public_result.length);

        pk_public = XMHCoinUtitls.CoinID_getPolkaDotAddress((byte) 0, HexUtil.encodeHexStr(pk_public_result));
        pk_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(CommonUtil.strToByteArrayNotAddEnd(DigitalTrans.byte2hex(pk_private_result)), pin));

        Map map = new HashMap();
        map.put("prvKey", pk_private);
        map.put("pubKey", DigitalTrans.byte2hex(pk_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_POLKADOT);
        map.put("address", pk_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }

    static List getPolkadotPurse(String pubKey, String priKey, String pin){
        List wallet = new ArrayList();
        if(TextUtils.isEmpty(pubKey) || TextUtils.isEmpty(priKey)){
            return wallet;
        }

        pk_public = XMHCoinUtitls.CoinID_getPolkaDotAddress((byte) 0, pubKey);
        pk_private = DigitalTrans.byte2hex(DigitalTrans.encKeyByAES128CBC(CommonUtil.strToByteArrayNotAddEnd(priKey), pin));

        Map map = new HashMap();
        map.put("prvKey", pk_private);
        map.put("pubKey", DigitalTrans.byte2hex(pk_public_result));
        map.put("coinType", Constants.COIN_TYPE.TYPE_POLKADOT);
        map.put("address", pk_public);
        map.put("masterPubKey", "");
        wallet.add(map);
        return wallet;
    }
}
