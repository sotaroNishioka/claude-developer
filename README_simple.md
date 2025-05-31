# シンプルなClaude Code自動化ツール

自分のプロジェクトでClaude Codeを使った自動化処理を簡単に実行するためのシンプルなツールです。

## 機能

- **ISSUE作成**: プロジェクトを分析して改善提案をISSUEとして作成
- **PRレビュー**: オープンなPRを自動でレビュー
- **ISSUE実装**: 指定したISSUEを自動で実装してPR作成
- **カスタムプロンプト実行**: 任意のプロンプトファイルを実行

## セットアップ

1. スクリプトに実行権限を付与
```bash
chmod +x simple_automation.sh
```

2. 設定ファイルを編集（オプション）
```bash
cp simple_config.env config.env
# config.envを編集
```

## 使い方

### 基本的な使用方法

```bash
# ISSUE作成
./simple_automation.sh issues

# PRレビュー
./simple_automation.sh review

# ISSUE実装
./simple_automation.sh implement 123

# カスタムプロンプト実行
./simple_automation.sh run my_prompt.txt
```

### プロンプトのカスタマイズ

`prompts/`ディレクトリ内のテキストファイルを編集することで、プロンプトをカスタマイズできます：

- `issue_analysis.txt` - ISSUE作成時のプロンプト
- `pr_review.txt` - PRレビュー時のプロンプト
- `implementation.txt` - ISSUE実装時のプロンプト

### Cronでの自動実行

```bash
# cron設定例を表示
./simple_cron_examples.sh

# 例: 毎時15分にレビューを実行
15 * * * * cd /path/to/project && ./simple_automation.sh review >> ./claude.log 2>&1

# 例: 毎時30分に実装を実行
30 * * * * cd /path/to/project && ./simple_automation.sh implement 123 >> ./claude.log 2>&1
```

## 環境変数

- `PROJECT_PATH` - プロジェクトパス（デフォルト: カレントディレクトリ）
- `DRY_RUN` - ドライラン実行（デフォルト: false）
- `LOG_FILE` - ログファイルパス（デフォルト: ./claude_simple.log）
- `PROMPTS_DIR` - プロンプトディレクトリ（デフォルト: ./prompts）

## 必要な環境

- Claude Code CLI (`claude`コマンド)
- GitHub CLI (`gh`コマンド)
- jq
- git
- bash