# シンプルな Claude Code 自動化ツール

プロンプトテンプレートを使って Claude Code を実行するシンプルなツールです。

## 概要

このツールは、テキストファイルに記述したプロンプトを Claude Code で実行します。プロンプト内の変数を引数で置換できるため、様々な自動化タスクに活用できます。

## セットアップ

```bash
chmod +x automation.sh
```

## 使い方

```bash
./automation.sh <プロンプトファイル> [引数1] [引数2] ...
```

### 例

```bash
# プロジェクト分析とISSUE作成
./automation.sh issue_creater

# カスタムプロンプトを実行
./automation.sh my_prompt.txt

# 複数の引数を渡す
./automation.sh custom.txt param1 param2
```

## プロンプトテンプレート

### デフォルトテンプレート

`prompts/`ディレクトリに以下のテンプレートが含まれています：

- `issue_creater.txt` - プロジェクト分析と ISSUE 作成
- `custom_example.txt` - カスタムプロンプトの例

### 変数の置換

プロンプト内で `{{ARG1}}`, `{{ARG2}}` などの変数を使用でき、実行時の引数で置換されます：

```bash
# pr_review.txt 内の {{ARG1}} が 123 に置換される
./automation.sh pr_review 123
```

### カスタムプロンプトの作成

新しいプロンプトファイルを作成して、任意のタスクを自動化できます：

```bash
echo "プロジェクトのテストを実行してレポートを生成してください" > prompts/run_tests.txt
./automation.sh run_tests
```

## Cron での自動実行

```bash
# cron設定例を表示
./cron_examples.sh

# 例: 毎日朝9時にプロジェクト分析
0 9 * * * cd /path/to/project && ./automation.sh issue_creater >> ./claude_developer.log 2>&1

# 例: 毎時プロンプトを実行
0 * * * * cd /path/to/project && ./automation.sh my_hourly_task >> ./claude_developer.log 2>&1
```

## 環境変数

- `PROJECT_PATH` - プロジェクトパス（デフォルト: カレントディレクトリ）
- `LOG_FILE` - ログファイルパス（デフォルト: ./claude_developer.log）
- `PROMPTS_DIR` - プロンプトディレクトリ（デフォルト: ./prompts）

## 必要な環境

- Claude Code CLI (`claude`コマンド)
- GitHub CLI (`gh`コマンド)
- jq
- git
- bash
