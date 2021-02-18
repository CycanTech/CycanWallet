#include "DataTypeDefine.h"
#include <string>
using std::string;
u8 CoinID_generateMnemonicIndex(u8 *entropyBuffer, u8 byteCounter, u8 *mnemonicIndexBuffer);
u8 CoinID_SetMaster(u8 *mnemonicBuffer, u16 mnemonicLen);
u8 CoinID_DeriveEOSKeyRoot();
u8 CoinID_DeriveEOSKeyAccount(u32 index);
u8 *CoinID_DeriveEOSKey(u32 index);
s32  CoinID_ECDSA_sign(u8 *msg, u32 length, u8 *key, u8 *sigData);
u8 *CoinID_ExportEOSPubKey(u8 *pubKey);
u8 *CoinID_ExportEOSPrvKey(u8 *prvKey);
u8 CoinID_ImportEOSPrvKeyCheck(u8 *prvKey, u8 length);
u8 *CoinID_ImportEOSPrvKey(u8 *prvKey, u8 length);
u8 *CoinID_GetTranSigJson(u8 *jsonTran, u16 length, u8 *prvKey);
u8 CoinID_EncKeyByAES128CBC(u8 *input, u16 inputLen, u8 *inputPIN, u8 pinLen, u8 *output, u8 *uuid, u8 len);
u8 CoinID_DecKeyByAES128CBC(u8 *input, u16 inputLen, u8 *inputPIN, u8 pinLen, u8 *output, u8 *uuid, u8 len);
u8 *CoinID_ParseEOSPubKey(u8 *pubKey, u8 length);
u8 CoinID_DeriveETHKeyRoot();
u8 *CoinID_DeriveETHKey(u32 index);
u8 CoinID_DeriveETHKeyAccount(u32 index);
u8 *CoinID_ExportETHPubKey(u8 *pubKey);
u8 *CoinID_sigtEthTransaction(u8 *p_nonce, u16 nonce_len, u8 *p_gasprice, u16 gasprice_len, u8 *p_startgas, u16 startgas_len, u8 *to, u8 *p_value, u16 value_len, u8 *p_data, u16 data_len, u8 *p_chainId, u16 chainId_len, u8 *prvKey);
s32  CoinID_ECDSA_signWithNotHash(u8 *hashData, u8 *key, u8 *sigData);
u8 *CoinID_getMasterPubKey();
u8 *CoinID_serializeTranJSON(u8 *jsonTran, u16 length, u8 *hash, u8 *msgLength);
u8 *CoinID_packTranJson(u8 *sigData, u8 *packData, int recid, u16 msgLen);
u8 *CoinID_genBTCAddress(u8 prefix, u8 *pubKey, u8 length, u8 type);
u8 *CoinID_sigtBTCTransaction(u8 *jsonTran, u16 length, u8 *prvKey);
u8 *CoinID_ImportETHPrvKey(u8 *prvKey);
u8 CoinID_DeriveBTCKeyRoot();
u8 CoinID_DeriveBTCKeyAccount(u32 index);
u8 *CoinID_DeriveBTCKey(u32 index);
u8 *CoinID_ImportBTCPrvKeyByWIF(u8 *prvKey, u16 length);
u8 *CoinID_ExportBTCPrvKeyByWIF(u8 *prvKey);
u8 *CoinID_genScriptHash(u8 *address, u16 length);
u8 *CoinID_serializeETHTranJSON(u8 *p_nonce, u16 nonce_len, u8 *p_gasprice, u16 gasprice_len, u8 *p_startgas, u16 startgas_len, u8 *to, u8 *p_value, u16 value_len, u8 *p_data, u16 data_len, u8 *p_chainId, u16 chainId_len, u8 *sigHash, u8 *outLength);
u8 *CoinID_packETHTranJson(u8 *sigOut, u8 *sigData, int recid, u8 *p_chainId, u16 chainId_len, u8* serLen);
u8 *CoinID_serializeBTCTranJSON(u8 *jsonTran, u16 length, u8 *pubKey, u8 *outLen);
u8 *CoinID_packBTCTranJson(u8 isSegwit, u8 *sigData, u32 length, u8 *pubKey);
u8 CoinID_checkMemoValid(u16 *memoIndexBuf, u8 count);
u8 CoinID_EncByAES128CBC(u8 *input, u16 inputLen, u8 *inputKEY, u8 *output);
u16 CoinID_DecByAES128CBC(u8 *input, u16 inputLen, u8 *inputKEY, u8 *output);
u8 CoinID_genKeyPair(u8 *random, u8 *prvKey, u8 *pubKey);
u8 CoinID_keyAgreement(u8 *prvKey, u8 *pubKey, u8 *output_ecdh);
u8 CoinID_ECDSA_verify(u8 *msg, u32 length, u8 *sigData, u8 *pubKey);
u8 CoinID_DeriveKeyRoot(u32 coinType);
u8 CoinID_DeriveKeyAccount(u32 index);
u8 *CoinID_DeriveKey(u32 index);
u8 *CoinID_getBYTOMAddress(u8 *pubkey);
u8 *CoinID_sigtBYTOMTransaction(u8 *jsonTran, u8 *prvKey);
u8 *CoinID_serializeBYTOMTranJSON(u8 *jsonTran, u8 *outLen);
u8 *CoinID_packBYTOMTranJson(u8 *sigOut, u16 length);
u8 *CoinID_importKeyStore(u8 *json, u8 *passwd, u8 passLen, u8 *outLen);
u8 *CoinID_exportKeyStore(u8 * prvKey, u8 keyLen, u8 type, u8 *passwd, u8 passLen, u8 *salt, u8 *iv, u8 *uuid);
u8 *CoinID_getBYTOMCode(u8 *address);
u8 *CoinID_ImportBYTOMPrvKey(u8 *prvKey);
u8 *CoinID_serializeTranJSONOnly(u8 *jsonTran, u8 *msgLength);
u8 *CoinID_packTranJsonOnly(u8 *sigData, int recid);
u8 *CoinID_serializeBTCTranJSONOnly(u8 *jsonTran, u8 *pubKey, u8 *outLen);
u8 *CoinID_packBTCTranJsonOnly(u8 *sigData, u32 length, u8 *pubKey);
u8 *CoinID_serializeBYTOMTranJSONOnly(u8 *jsonTran, u8 *outLen);
u8 *CoinID_packBYTOMTranJsonOnly(u8 *sigOut, u16 length);
u8 *CoinID_ImportPrvKeyByWIF(u8 *prvKey, u16 length);
u8 *CoinID_ExportPrvKeyByWIF(u8 prefix, u8 *prvKey);
u8 *CoinID_getBCHAddress(u8 *pubkey);
string CoinID_sigETH_TX_by_str(string p_nonce, string p_gasprice, string p_startgas, string to, string p_value, string p_data, string p_chainId, string prvKey);
string CoinID_serETH_TX_by_str(string p_nonce, string p_gasprice, string p_startgas, string to, string p_value, string p_data, string p_chainId, u8 *sigHash);
string CoinID_packETH_TX_by_str(string sigOut, string sigData, int recid, string p_chainId);
bool CoinID_checkETHpushValid(string pushStr, string to, string value, int decimal, bool isContract, string contractAddr);
bool CoinID_SetMasterStandard(string mnemonicBuffer);
string CoinID_deriveKeyByPath(string path);
string CoinID_GetVersion();
bool CoinID_checkEOSpushValid(string pushStr, string to, string value, string unit);
bool CoinID_checkBTCpushValid(string pushStr, string to, string toValue, string from, string fromValue, string usdtValue, string coinType, bool isSegwit);
bool CoinID_checkBYTOMpushValid(string pushStr, string to, string toValue, string from, string fromValue);
string CoinID_SHA256(string input);
bool CoinID_checkAddressValid(string chainType, string address);
bool CoinID_checkCrossChain(string coinType, string pushStr, string contractAddr, string chainName, string tokenid, string account, string amout, int decimal, string unit);
string CoinID_EncPhoneNum(string number);
string CoinID_DecPhoneNum(string number);
string CoinID_ExportEOSPubByPre(string prefix, string pubKey);
string CoinID_cvtAddrByEIP55(string address);


string CoinID_DeriveEOSKeyStr(u32 index);
string CoinID_DeriveETHKeyStr(u32 index);
string CoinID_ExportEOSPubKeyStr(string pubKey);
string CoinID_ExportEOSPrvKeyStr(string prvKey);
string CoinID_ParseEOSPubKeyStr(string pubKey);
u8 CoinID_ImportEOSPrvKeyCheckStr(string prvKey);
string CoinID_ImportEOSPrvKeyStr(string prvKey);
string CoinID_GetTranSigJsonStr(string jsonTran, string prvKey);
string CoinID_ExportETHPubKeyStr(string pubKey);
string CoinID_getMasterPubKeyStr();
string CoinID_serializeTranJSONStr(string jsonTran);
string CoinID_packTranJsonStr(string sigData, int recid);
string CoinID_genBTCAddressStr(u8 prefix, string pubKey, u8 type);
string CoinID_sigtBTCTransactionStr(string jsonTran, string prvKey);
string CoinID_ImportETHPrvKeyStr(string prvKey);
string CoinID_DeriveBTCKeyStr(u32 index);
string CoinID_ImportBTCPrvKeyByWIFStr(string prvKey);
string CoinID_ExportBTCPrvKeyByWIFStr(string prvKey);
string CoinID_genScriptHashStr(string address);
string CoinID_serializeBTCTranJSONStr(string jsonTran, string pubKey);
string CoinID_packBTCTranJsonStr(u8 isSegwit, string sigData, string pubKey);
string CoinID_DeriveKeyStr(u32 index);
string CoinID_getBYTOMAddressStr(string pubkey);
string CoinID_sigtBYTOMTransactionStr(string jsonTran, string prvKey);
string CoinID_serializeBYTOMTranJSONStr(string jsonTran);
string CoinID_packBYTOMTranJsonStr(string sigOut);
string CoinID_importKeyStoreStr(string json, string passwd);
string CoinID_exportKeyStoreStr(string prvKey, u8 type, string passwd, string salt, string iv, string uuid);
string CoinID_getBYTOMCodeStr(string address);
string CoinID_ImportBYTOMPrvKeyStr(string prvKey);
string CoinID_serializeTranJSONOnlyStr(string jsonTran);
string CoinID_packTranJsonOnlyStr(string sigData, int recid);
string CoinID_serializeBTCTranJSONOnlyStr(string jsonTran, string pubKey);
string CoinID_packBTCTranJsonOnlyStr(string sigData, string pubKey);
string CoinID_serializeBYTOMTranJSONOnlyStr(string jsonTran);
string CoinID_packBYTOMTranJsonOnlyStr(string sigOut);
string CoinID_ImportPrvKeyByWIFStr(string prvKey);
string CoinID_ExportPrvKeyByWIFStr(u8 prefix, string prvKey);
string CoinID_getBCHAddressStr(string pubkey);

string CoinID_createBTMMultAddr(string prefix, string pubkeys, int quorum);
string CoinID_getBTMMultSigInfo(string jsonTran);
string CoinID_getBTMMultSigSignature(string msgs, string key, bool needSig);
string CoinID_packBTMMultSigInfo(string jsonTran, string jsonWitness);
string CoinID_BTMMSSignature(string msg, string key);
bool CoinID_BTMMSVerify(string msg, string key, string signature);

string CoinID_getBTCMultSigInfo(string jsonTran, string pubKeys, int quorum);
string CoinID_createBTCMultAddr(u8 prefix, string pubkeys, int quorum);
string CoinID_packBTCMultSigInfo(string jsonTran, string jsonWitness, string pubkeys, int quorum);
string CoinID_getBTCMultSigSignature(string msgs, string key, bool needSig);
string CoinID_BTCMSSignature(string msg, string key);
bool CoinID_BTCMSVerify(string msg, string key, string signature);

string CoinID_serBTMMS(string jsonTran);
string CoinID_serBTCMS(string jsonTran, string pubKeys, int quorum);
string CoinID_filterUTXO(string utxoJson, string amount, string fee, int quorum, int num,string type);
string CoinID_getXMRAddress(string nettype, string pubSpendKey, string pubViewKey, string short_pid);
string CoinID_getXMRViewBySpend(string prvSpendKey);
string CoinID_getXMRPubByPrv(string prvKey);
string CoinID_sigtMoneroTransaction(string unspent_outsStr, string mix_outsStr, string prvSpendKey, string prvViewKey);
string CoinID_searchXMRTX(string spdPrv, string viewPrv, string txData);
string CoinID_CRC16_CCITT_FALSE(string input);

string CoinID_genPolkaDotKeyPairByPath(u16 * mnemonicIndexBuffer, int indexLen, std::string path);
string CoinID_getPolkaDotAddress(u8 prefix, string pubkeyStr);
string CoinID_sigPolkadotTransaction(string jsonTran, string prvKeyStr, string pubKeyStr);
string CoinID_polkadot_ept_keystore(string password, string prvKeyStr, u8 prefix, string pubKeyStr);
string CoinID_polkadot_ipt_keystore(string password, string keystore);
string CoinID_getPolkaPubByPriv(string prvKeyStr);
string CoinID_polkadot_getNonceKey(string address);