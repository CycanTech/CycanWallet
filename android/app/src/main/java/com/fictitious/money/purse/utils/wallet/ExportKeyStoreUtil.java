package com.fictitious.money.purse.utils.wallet;

import com.fictitious.money.purse.Constants;
import com.fictitious.money.purse.utils.CommonUtil;
import com.fictitious.money.purse.utils.DigitalTrans;
import com.fictitious.money.purse.utils.HexUtil;
import com.fictitious.money.purse.utils.XMHCoinUtitls;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class ExportKeyStoreUtil {
    public static Map exportKeyStore(String content, String pin, int coinType){
        Map map = new HashMap();
        String keyStore = getWalletKeystore(content, pin, coinType);
        map.put("coinType", coinType);
        map.put("keyStore", keyStore);
        return map;
    }

    static String getWalletKeystore(String content, String pwd, int coinType){
        byte[] prvKey = DigitalTrans.decKeyByAES128CBC(HexUtil.hexStringToBytes(content), pwd, coinType);
        if (coinType == Constants.COIN_TYPE.TYPE_POLKADOT) {
            String pubKey = XMHCoinUtitls.CoinID_getPolkaPubByPriv(CommonUtil.byteArrayToStr(prvKey));
            String keystore =  XMHCoinUtitls.CoinID_polkadot_ept_keystore(pwd, CommonUtil.byteArrayToStr(prvKey), (byte) 0, pubKey);
            return keystore;
        } else {
            byte[] keyStoreByte = null;
            byte[] salt = new byte[64];
            byte[] iv = new byte[32];
            byte[] uuid = new byte[32];
            Random random = new Random();
            String saltStr = "";
            String ivStr = "";
            String uuidStr = "";
            for(int i = 0; i < salt.length; i ++){
                saltStr += random.nextInt(10);
            }
            salt = CommonUtil.strToByteArray(saltStr);
            for(int i = 0; i < iv.length; i ++){
                ivStr += random.nextInt(10);
            }
            iv = CommonUtil.strToByteArray(ivStr);
            for(int i = 0; i < uuid.length; i ++){
                uuidStr += random.nextInt(10);
            }
            uuid = CommonUtil.strToByteArray(uuidStr);
            if(coinType == Constants.COIN_TYPE.TYPE_ETH || coinType == Constants.COIN_TYPE.TYPE_VNS) {
                keyStoreByte = prvKey;
            } else if(coinType == Constants.COIN_TYPE.TYPE_BTC || coinType == Constants.COIN_TYPE.TYPE_USDT) {
                keyStoreByte = new byte[32];
                byte[] keyByte = XMHCoinUtitls.CoinID_ImportBTCPrvKeyByWIF(prvKey, (short)prvKey.length);
                System.arraycopy(keyByte, 0, keyStoreByte, 0 , keyStoreByte.length);//私钥
            } else if(coinType == Constants.COIN_TYPE.TYPE_LTC || coinType == Constants.COIN_TYPE.TYPE_BCH || coinType == Constants.COIN_TYPE.TYPE_DASH){
                keyStoreByte = new byte[32];
                byte[] keyByte = XMHCoinUtitls.CoinID_ImportPrvKeyByWIF(prvKey, (short)prvKey.length);
                System.arraycopy(keyByte, 0, keyStoreByte, 0 , keyStoreByte.length);//私钥
            } else if(coinType == Constants.COIN_TYPE.TYPE_EOS || coinType == Constants.COIN_TYPE.TYPE_GPS) {
                byte[] owner_byte = XMHCoinUtitls.CoinID_ImportEOSPrvKey(prvKey, (byte) prvKey.length);
                keyStoreByte = new byte[32];
                System.arraycopy(owner_byte, 0, keyStoreByte, 0, keyStoreByte.length);
            }
            if(keyStoreByte != null){
                try {
//                Log.d("keystore", "===pwd==" + HexUtil.formatHexString(CommonUtil.strToByteArray(pwd)));
//                Log.d("keystore", "===pwd.length==" + (byte) CommonUtil.strToByteArray(pwd).length);
//                Log.d("keystore", "===privateKey==" + HexUtil.formatHexString(keyStoreByte));
//                Log.d("keystore", "===privateKey.length==" + (byte) keyStoreByte.length);
//                Log.d("keystore", "===salt==" + HexUtil.formatHexString(salt));
//                Log.d("keystore", "===iv==" + HexUtil.formatHexString(iv));
//                Log.d("keystore", "===uuid==" + HexUtil.formatHexString(uuid));
                    byte[] jsonByte = XMHCoinUtitls.CoinID_exportKeyStore(keyStoreByte, (byte) keyStoreByte.length, (byte) 0, CommonUtil.strToByteArray(pwd), (byte) CommonUtil.strToByteArray(pwd).length, salt, iv, uuid);
                    String json = new String(jsonByte);
                    return json;
                }catch (Exception e){
                    e.printStackTrace();
                }
            }
        }
        return "";
    }
}
