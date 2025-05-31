# Claude Code 自動ISSUE作成バッチ

Claude Code CLIを使ってプロジェクトを自動分析し、GitHub ISSUEを自動作成するバッチ処理システムです。

## 概要

このシステムは以下の機能を提供します：

- プロジェクトの自動分析
- 技術的負債やバグの特定
- GitHub ISSUEの自動作成
- 定期実行（cron）対応
- 複数プロジェクト対応

## 前提条件

### 必要なツール

1. **Claude Code CLI**
   ```bash
   # インストール（公式ドキュメントに従って）
   # https://docs.anthropic.com/ja/docs/claude-code/setup
   ```

2. **GitHub CLI**
   ```bash
   # macOS
   brew install gh
   
   # Ubuntu/Debian
   sudo apt install gh
   
   # 認証
   gh auth login
   ```

3. **jq（JSON処理用）**
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt install jq
   ```

## セットアップ

### 1. ファイルの配置

```bash
# ディレクトリ作成
mkdir -p ~/claude-issue-batch
cd ~/claude-issue-batch

# スクリプトファイルをダウンロード/配置
chmod +x auto_issue_batch.sh
chmod +x cron_setup.sh
```

### 2. 設定ファイルの作成

```bash
# 設定ファイルをコピーして編集
cp config.env.template config.env
nano config.env  # 設定を編集
```

### 3. 動作確認

```bash
# ドライランで動作確認
./auto_issue_batch.sh --dry-run --path /path/to/your/project

# システムチェック
./cron_setup.sh check
```

## 使用方法

### 基本的な使用

```bash
# 現在のディレクトリで実行
./auto_issue_batch.sh

# 特定のプロジェクトで実行
./auto_issue_batch.sh --path /path/to/project

# ドライランモード
./auto_issue_batch.sh --dry-run

# 最大ISSUE数を指定
./auto_issue_batch.sh --max-issues 3
```

### 設定ファイルを使用

```bash
# 設定ファイルを読み込んで実行
source config.env && ./auto_issue_batch.sh
```

### cron設定

```bash
# cron設定例を表示
./cron_setup.sh examples

# 対話的cron設定
./cron_setup.sh interactive

# システムチェック
./cron_setup.sh check
```

## 設定オプション

### コマンドラインオプション

| オプション | 説明 | 例 |
|-----------|------|-----|
| `-h, --help` | ヘルプ表示 | `--help` |
| `-d, --dry-run` | ドライランモード | `--dry-run` |
| `-p, --path` | プロジェクトパス | `--path /path/to/project` |
| `-m, --max-issues` | 最大ISSUE数 | `--max-issues 5` |
| `-l, --log-file` | ログファイル | `--log-file /tmp/log` |

### 環境変数

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `PROJECT_PATH` | プロジェクトパス | `$(pwd)` |
| `MAX_ISSUES` | 最大ISSUE作成数 | `5` |
| `DRY_RUN` | ドライランモード | `false` |
| `LOG_FILE` | ログファイルパス | `/tmp/claude_issue_batch.log` |

## cron設定例

### 週次実行（推奨）

```bash
# 毎週月曜日の朝9時
0 9 * * 1 /path/to/auto_issue_batch.sh --path /path/to/project
```

### 日次実行

```bash
# 毎日朝8時（少数のISSUE）
0 8 * * * /path/to/auto_issue_batch.sh --path /path/to/project --max-issues 2
```

### 複数プロジェクト

```bash
# プロジェクトA - 火曜日
0 9 * * 2 /path/to/auto_issue_batch.sh --path /path/to/projectA

# プロジェクトB - 木曜日  
0 9 * * 4 /path/to/auto_issue_batch.sh --path /path/to/projectB
```

## 出力例

### 生成されるISSUE例

**タイトル**: "セキュリティ: 入力バリデーションの強化が必要"

**内容**:
```markdown
## 概要
ユーザー入力の検証が不十分な箇所が見つかりました。

## 詳細
- ファイル: src/api/user.js
- 行: 45-50
- 問題: SQLインジェクションの可能性

## 提案解決策
1. パラメータ化クエリの使用
2. 入力サニタイゼーションの追加
3. バリデーションライブラリの導入

---
**自動生成情報:**
- 優先度: high
- タイプ: bug
- 作成日時: 2025-05-31 09:00:00
- 生成者: Claude Code Auto Batch
```

### ログ出力例

```
[2025-05-31 09:00:00] === Claude Code 自動ISSUE作成バッチ開始 ===
[2025-05-31 09:00:00] プロジェクトパス: /path/to/project
[2025-05-31 09:00:00] 前提条件チェック完了
[2025-05-31 09:00:05] Claude Code でプロジェクト分析を実行中...
[2025-05-31 09:00:15] 提案されたISSUE数: 3
[2025-05-31 09:00:16] SUCCESS: ISSUE作成完了 - セキュリティ強化
[2025-05-31 09:00:17] SUCCESS: ISSUE作成完了 - パフォーマンス改善
[2025-05-31 09:00:18] SUCCESS: ISSUE作成完了 - テストカバレッジ向上
[2025-05-31 09:00:18] === バッチ処理完了 ===
```

## トラブルシューティング

### よくある問題

1. **Claude Code CLI が見つからない**
   ```bash
   # パスの確認
   which claude
   
   # インストール確認
   claude --version
   ```

2. **GitHub認証エラー**
   ```bash
   # 認証状態確認
   gh auth status
   
   # 再認証
   gh auth login
   ```

3. **権限エラー**
   ```bash
   # 実行権限付与
   chmod +x auto_issue_batch.sh
   
   # ログファイル権限
   sudo touch /var/log/claude_issue_batch.log
   sudo chown $(whoami) /var/log/claude_issue_batch.log
   ```

### デバッグモード

```bash
# デバッグ情報付きで実行
bash -x ./auto_issue_batch.sh --dry-run
```

### ログ確認

```bash
# リアルタイムログ監視
tail -f /var/log/claude_issue_batch.log

# 最新のログ確認
tail -20 /var/log/claude_issue_batch.log
```

## カスタマイズ

### プロンプトのカスタマイズ

`analyze_and_generate_issues()` 関数内のプロンプトを編集して、プロジェクト固有の分析観点を追加できます。

### ラベルのカスタマイズ

`create_github_issue()` 関数でラベルの生成ロジックを変更できます。

### 通知の追加

Slack や メール通知機能を追加することも可能です。

## ライセンス

MIT License

## 貢献

バグ報告や機能改善のPRを歓迎します。