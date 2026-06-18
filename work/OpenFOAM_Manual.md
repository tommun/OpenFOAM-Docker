# OpenFOAM 13 Docker 操作マニュアル (更新版)

## 1. 環境の概要
- **OS:** Ubuntu 22.04
- **OpenFOAM:** version 13 (Foundation版)
- **保存場所:** 
  - プログラム・設定: C:\Users\tomar\OpenFOAM-Docker (ローカルCドライブ)
  - 解析データ: /home/foam/work/ (ホスト側の work フォルダと同期)

## 2. GUI (ParaView) へのアクセス
ブラウザで以下のURLを開きます。
URL: http://localhost:6080/vnc.html
パスワード: foam123

- **ParaViewの起動:** ターミナルで paraview と入力します。
- **解析データの読み込み:** 
  解析ディレクトリに移動し、touch result.foam を実行してから ParaView でそのファイルを開くとスムーズです。

## 3. Git によるバージョン管理
プロジェクト全体が Git で管理されています。変更を加えたら履歴を残すことを推奨します。
ホスト側（Windows）のターミナルで以下を実行：
```bash
cd C:\Users\tomar\OpenFOAM-Docker
git add .
git commit -m "解析ケースの追加"
```

## 4. 旧環境 (VirtualBox VM) からの移行データ
旧VM「あばばばあ」から以下のデータを移行済みです。
- **場所:** /home/foam/work/ 直下
- **内容:** Univ/ (大学関連データ), sphere_test/, constant/
※VM内では OpenFOAM-v2512 が使われていましたが、現在の環境は OpenFOAM 13 です。

## 5. Google Drive へのバックアップ (rclone)
ローカルのCドライブで計算を行い、完了した重要なデータのみを Google Drive へ同期する運用を推奨します。

### 初期設定 (未完了の場合)
1. コンテナ内で rclone config を実行。
2. 名前を gdrive、タイプを drive に設定。
3. Use auto config? で n (No) を選び、ブラウザで認証。

### 同期コマンド
```bash
# Gドライブをマウント
rclone mount gdrive: /home/foam/gdrive --daemon

# データのコピー (例: Univフォルダをバックアップ)
cp -r /home/foam/work/Univ /home/foam/gdrive/Backup/
```

## 6. 注意事項
- **日本語ファイル名:** VMから移行したファイルに日本語が含まれています。ParaView等でエラーが出る場合は、アルファベット名にリネームしてください。
- **ディスク容量:** Cドライブの空き容量にご注意ください。
