# OpenFOAM ハイブリッド運用 ワークフローガイド (ThinkPad)

本テンプレートは、**「ThinkPadで軽量な設定・テスト計算を行い、GitHub経由でデスクトップに渡して本計算を行う」** ための標準ガイドです。

---

## 1. ケースディレクトリの推奨構成

GitHubで管理すべきファイルと、生成されるファイルの関係は以下の通りです。

```text
my_case/
├── 0.orig/              # [Git管理] 初期の境界条件・初期場（0/ ではなく 0.orig/ で保存）
│   ├── U
│   └── p
├── constant/
│   ├── transportProperties # [Git管理] 物性値
│   ├── turbulenceProperties# [Git管理] 乱流モデル
│   └── triSurface/         # [Git管理] STLなどの形状データ（軽量なもの）
├── system/
│   ├── controlDict       # [Git管理] 計算時間・ソルバー設定
│   ├── fvSchemes         # [Git管理] 離散化スキーム
│   ├── fvSolution        # [Git管理] ソルバー解法
│   └── blockMeshDict     # [Git管理] メッシュ定義
├── Allrun.test           # [Git管理] ThinkPad用テスト計算スクリプト
└── Allclean              # [Git管理] クリーンアップスクリプト
```

> **重要:** `0/` フォルダは計算を実行すると内部の数値が書き換わってしまうため、原本として `0.orig/` をGit管理し、計算開始時に `Allrun.test` が自動で `0/` にコピーする運用を行います。

---

## 2. 日常の運用手順

### ステップ 1: ThinkPadで設定作成・編集
VS Code などを使い、`system/` や `constant/`、`0.orig/` を編集します。

### ステップ 2: ThinkPadでテストラン（数分で検証）
Dockerコンテナ内に入り、テストスクリプトを実行します。

```bash
# Dockerコンテナに入る（WindowsのPowerShell等から）
docker exec -it openfoam13-container bash

# ケースディレクトリに移動
cd /home/foam/work/my_case

# テスト実行（blockMesh とソルバーの短時間実行）
./Allrun.test
```

### ステップ 3: ParaViewで初期状態・テスト結果を確認
Windows側でParaViewを開き、確認します。

```bash
# コンテナ内で .foam ファイルを作成
touch my_case.foam
```
Windows側で `C:\Users\tomar\OpenFOAM-Docker\run-openfoam.ps1` を動かしている場合は自動的にParaViewが立ち上がります。
または、WindowsのParaViewから `C:\Users\tomar\OpenFOAM-Docker\work\my_case\my_case.foam` を直接開きます。

### ステップ 4: クリーンアップ（SSD容量の防護）
テストが終わったら、ThinkPadのディスク容量（残23GB）を圧迫しないよう、計算結果を削除します。

```bash
./Allclean
```

### ステップ 5: GitHubへプッシュ
設定ファイル一式をコミットし、デスクトップへ送るためにGitHubへプッシュします。

```bash
# WindowsのGit、またはコンテナ内から
git add .
git commit -m "feat: Add new test case settings"
git push origin master
```
※厳格な `.gitignore` が設定されているため、メッシュや結果フォルダは自動的に除外されます。

### ステップ 6: デスクトップ側で本計算
デスクトップPC側で：
1. `git pull origin master`
2. `system/controlDict` の終了時間（`endTime`）やメッシュ解像度を本番用に設定
3. 並列計算（`decomposePar` -> `mpirun -np 8 ...`）を実行
4. 計算結果はデスクトップの大容量ストレージに保存
