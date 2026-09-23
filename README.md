# OpenFOAM 13 ハイブリッド運用ガイド (ThinkPad E14 Gen 6)

本環境は、**「ThinkPad（ラップトップ）で設定作成・粗メッシュテスト・ParaView可視化を行い、本計算は大容量デスクトップに任せる」** というハイブリッド運用のための OpenFOAM 13 Docker ワークスペースです。

---

## 1. マシンの役割分担

| 項目 | ThinkPad (ラップトップ) | デスクトップPC |
| :--- | :--- | :--- |
| **主な役割** | 条件設定・辞書編集、テストラン、結果可視化 | メッシュ本格生成、並列本計算、大容量保存 |
| **強み** | **メモリ 32GB**（ParaViewでの軽快な可視化）、持ち運び | 高冷却、大容量SSD/HDD、多コアCPU並列 |
| **注意点** | **SSD 256GB（残容量制限）** $\rightarrow$ 結果を溜め込まない | リモート操作（SSH / RDP / VS Code） |

---

## 2. 毎日の基本ワークフロー

```
[ThinkPad]
 1. VS Codeで辞書編集 (system, constant, 0.orig)
 2. ./Allrun.test で短時間テスト計算
 3. touch case.foam で Windows側 ParaView (32GB) で初期状態確認
 4. ./Allclean でSSD容量を即時解放！
 5. git push で GitHub へ設定のみ同期
       │
       ▼ (GitHub 経由)
[デスクトップ]
 6. git pull で設定取得
 7. 本格メッシュ作成 & 並列本計算実行
 8. （必要に応じて）軽量化VTKやサンプリングデータのみThinkPadへ転送し可視化
```

---

## 3. クイックスタート (ThinkPad側)

### ① コンテナの起動と接続
PowerShellから以下のスクリプトを実行すると、コンテナ起動・ParaView監視・コンテナログインがワンストップで行われます。

```powershell
.\run-openfoam.ps1
```

※手動で入る場合：
```powershell
docker exec -it -u foam openfoam13-container bash
```

### ② 新しいケースの作成とテスト
`work/templates` 内のスクリプトを利用します。

```bash
# コンテナ内で
cd /home/foam/work/my_new_case

# テンプレートからスクリプトをコピー
cp ../templates/Allrun.test .
cp ../templates/Allclean .

# テスト実行（blockMesh と短時間ソルバー計算）
./Allrun.test

# Windows側 ParaView 6.1.0 で可視化（自動検知）
touch my_new_case.foam

# 確認が終わったら、SSD容量節約のため必ずクリーンアップ！
./Allclean
```

---

## 4. GitHub同期（大容量ファイルの厳格な防護）

本リポジトリ直下の `.gitignore` により、以下の大容量ファイルは自動的に除外されます：
- タイムディレクトリ（`[1-9]*`, `0.*` 等）
- メッシュデータ（`constant/polyMesh/`）
- 並列分割データ（`processor*/`）
- ログファイル（`log.*`）
- VTK・ポスト処理データ（`VTK/`, `postProcessing/`）

### GitHub への Push（設定ファイルのみ送信）
```bash
git add .
git commit -m "feat: Add new simulation case setup"
git push origin master
```

---

## 5. デスクトップとの連携（リモート接続・データ転送）

### デスクトップへの接続（ThinkPadから）
Windows標準の OpenSSH、または VS Code の `Remote - SSH` 拡張機能を利用できます。

```powershell
ssh <ユーザー名>@<デスクトップのIPアドレス>
```

### 計算結果の軽量転送（デスクトップ $\rightarrow$ ThinkPad）
デスクトップ側で `foamToVTK` などで軽量化したVTKファイルや特定ステップのみをThinkPadへ転送し、ThinkPadのネイティブParaView（メモリ32GB）で描画します。

```powershell
# ThinkPadのPowerShellからデスクトップの特定結果を取得する例
scp -r <ユーザー名>@<デスクトップIP>:/path/to/desktop/case/VTK ./work/my_case/
```

---

## 6. GUI（Webブラウザ経由）でのアクセス
WebブラウザからLinuxデスクトップを操作したい場合：
- **URL:** [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)
- **Password:** `foam123`
