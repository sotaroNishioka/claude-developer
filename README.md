# シンプルな Claude Code 自動化ツール

自分のプロジェクトで Claude Code を使った自動化処理を簡単に実行するためのシンプルなツールです。

## 機能

- **ISSUE 作成**: プロジェクトを分析して改善提案を ISSUE として作成
- **PR レビュー**: オープンな PR を自動でレビュー
- **ISSUE 実装**: 指定した ISSUE を自動で実装して PR 作成
- **カスタムプロンプト実行**: 任意のプロンプトファイルを実行

## セットアップ

1. スクリプトに実行権限を付与

```bash
chmod +x automation.sh
```

2. 設定ファイルを編集（オプション）

```bash
cp config.env config.env
# config.envを編集
```

## 使い方

### 基本的な使用方法

```bash
# ISSUE作成
./automation.sh issues

# PRレビュー
./automation.sh review

# ISSUE実装
./automation.sh implement 123

# カスタムプロンプト実行
./automation.sh run my_prompt.txt
```

### プロンプトのカスタマイズ

`prompts/`ディレクトリ内のテキストファイルを編集することで、プロンプトをカスタマイズできます：

- `issue_analysis.txt` - ISSUE 作成時のプロンプト
- `pr_review.txt` - PR レビュー時のプロンプト
- `implementation.txt` - ISSUE 実装時のプロンプト

### Cron での自動実行

```bash
# cron設定例を表示
./cron_examples.sh

# 例: 毎時15分にレビューを実行
15 * * * * cd /path/to/project && ./automation.sh review >> ./claude.log 2>&1

# 例: 毎時30分に実装を実行
30 * * * * cd /path/to/project && ./automation.sh implement 123 >> ./claude.log 2>&1
```

## 環境変数

- `PROJECT_PATH` - プロジェクトパス（デフォルト: カレントディレクトリ）
- `LOG_FILE` - ログファイルパス（デフォルト: ./claude_simple.log）
- `PROMPTS_DIR` - プロンプトディレクトリ（デフォルト: ./prompts）

## 必要な環境

- Claude Code CLI (`claude`コマンド)
- GitHub CLI (`gh`コマンド)
- jq
- git
- bash
