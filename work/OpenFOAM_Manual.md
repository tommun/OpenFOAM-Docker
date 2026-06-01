# OpenFOAM 13 Docker 操作マニュアル

## 1. GUI (ParaView) へのアクセス
ブラウザで以下のURLを開きます。
URL: [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)
パスワード: \oam123
- 左下のメニュー（または右クリック）からターミナルを起動できます。
- ターミナルで \paraview\ または \paraFoam\ と入力すると可視化ツールが起動します。

## 2. Git 設定
Gitの設定（User: tommun, Email: tom.arufa@gmail.com）は完了しています。
GitHubとの連携にSSHが必要な場合は、コンテナ内で \ssh-keygen\ を実行し、公開鍵をGitHubに登録してください。

## 3. Google Drive (rclone) の初期設定
Google Driveを接続するには、以下の手順で認証を行ってください。

1. コンテナ内で設定を開始：
   \\ash
   rclone config
   \2. \ (New remote) を選択。
3. 名前を \gdrive\ にします。
4. ストレージタイプで \drive\ (Google Drive) を選択（通常は18番付近）。
5. \client_id\ / \client_secret\ は空欄のままエンター。
6. \scope\ は \1\ (Full access) を選択。
7. \service_account_file\ は空欄のままエンター。
8. \Edit advanced config\ は \ (No)。
9. \Use auto config\ は **必ず \ (No)** を選択してください（コンテナにブラウザがないため）。
10. 表示されたURLをホスト（Windows）のブラウザで開き、認証コードを取得してコンテナに貼り付けます。
11. \Configure this as a Shared Drive?\ は \ (No)。
12. 最後に \y\ (Yes this is OK) を選択して終了します。

## 4. Google Drive のマウント
設定完了後、以下のコマンドでマウントできます：
\\ash
rclone mount gdrive: /home/foam/gdrive --daemon
\これで \/home/foam/gdrive\ フォルダ経由でファイルの読み書きが可能になります。

## 5. ファイルの保存
- \/home/foam/work\ に保存したファイルは、ホスト側の \OpenFOAM-Docker/work\ フォルダと同期されます。
- \/home/foam/gdrive\ に保存したファイルは、Google Driveと同期されます。
