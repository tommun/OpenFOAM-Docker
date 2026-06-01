# OpenFOAM 13 Docker Environment

OpenFOAM 13 (Foundation版) を Ubuntu 22.04 上で実行し、GUI (ParaView) や Google Drive/GitHub 連携を可能にする環境です。

## セットアップと起動

1. **イメージのビルドと起動**
   ```bash
   docker-compose up -d --build
   ```

2. **GUIへのアクセス**
   ブラウザで以下のURLを開きます：
   [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)
   - **VNC Password:** `foam123`

3. **コンソールへの入る場合**
   ```bash
   docker exec -it openfoam13-container bash
   ```

## Google Drive 連携 (rclone)

Google Drive を `gdrive` フォルダにマウントするには以下の手順を推奨します：

1. **ホスト側（Windows）で rclone 設定を作成**
   Windowsに `rclone` をインストールし、`rclone config` で `gdrive` という名前のリモートを作成します。
2. **設定ファイルをコピー**
   作成された `rclone.conf` をこのディレクトリの `config/rclone/rclone.conf` にコピーします。
   （通常は `%APPDATA%/rclone/rclone.conf` にあります）
3. **コンテナ内でマウント**
   コンテナ内のターミナルで以下を実行します：
   ```bash
   rclone mount gdrive: /home/foam/gdrive --daemon
   ```

## GitHub 連携

- `git` は既にインストールされています。
- ホストのSSHキーを使用したい場合は、`docker-compose.yml` の `volumes` セクションのコメントアウトを外してください。

## OpenFOAM の使用

GUI上のターミナルで以下のようにコマンドを実行できます：
- OpenFOAM環境の有効化（自動で行われます）
- `paraFoam` または `paraview` で可視化ツールを起動

## 注意事項
- `work` ディレクトリはホストと同期されているため、計算結果などはここに保存することを推奨します。
