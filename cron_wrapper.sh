#!/bin/bash

# =============================================================================
# Cron実行用ラッパースクリプト
# =============================================================================

# スクリプトディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .envファイルを読み込み
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "Error: .env file not found at $SCRIPT_DIR/.env"
    exit 1
fi

# 実行するプロンプト名を引数から取得
PROMPT_NAME="$1"

if [ -z "$PROMPT_NAME" ]; then
    echo "Usage: $0 <prompt_name>"
    echo "Example: $0 codebase_analyzer"
    exit 1
fi

# ログディレクトリが存在しない場合は作成
mkdir -p "$LOG_DIR"

# タイムスタンプ生成
TIMESTAMP=$(date +%Y%m%d_%H%M)

# ログファイル名
LOG_FILE="$LOG_DIR/${PROMPT_NAME}_${TIMESTAMP}.log"

# プロジェクトディレクトリに移動
cd "$PROJECT_PATH" || {
    echo "Error: Cannot change to PROJECT_PATH: $PROJECT_PATH"
    exit 1
}

# automation.shを実行
echo "=== Starting $PROMPT_NAME at $(date) ===" >> "$LOG_FILE"
echo "PROJECT_PATH: $PROJECT_PATH" >> "$LOG_FILE"
echo "LOG_DIR: $LOG_DIR" >> "$LOG_FILE"
echo "CLAUDE_CMD: $CLAUDE_CMD" >> "$LOG_FILE"
echo "=======================================" >> "$LOG_FILE"

"$SCRIPT_DIR/automation.sh" "$PROMPT_NAME" >> "$LOG_FILE" 2>&1

# 実行結果をログに記録
EXIT_CODE=$?
echo "=== Finished $PROMPT_NAME at $(date) with exit code: $EXIT_CODE ===" >> "$LOG_FILE"

exit $EXIT_CODE