# ESP32 BLE通信テストプロジェクト for Swift

## 本プロジェクトファイルについて

[ESP32 BLE for Arduino](https://github.com/nkolban/ESP32_BLE_Arduino) のサンプルファイル BLE_uartの対向デバイスを作成する上でテストしたプロジェクトファイルです。  
Swift4.0向けに作成されています。

## 本プロジェクトファイル

スキャン開始し、ローカルネーム `UART Service` を発見すると  
接続→サービス探査→Notify開始  
XcodeのデバックエリアにNotify通知された文字列表示とSENDボタン押下時に特定文字列をESP32に送信します。

## 参考サイト
* [Core Bluetooth with Swift （ObjCのおまけ付き）](https://qiita.com/shu223/items/78614325ce25bf7f4379)
