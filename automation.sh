#!/bin/bash

# =============================================================================
# シンプルなClaude Code自動化スクリプト
# =============================================================================

set -e

# スクリプトディレクトリを最初に取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .envファイルを読み込み
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# 設定（.env読み込み後にデフォルト値を設定）
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
PROMPTS_DIR="${PROMPTS_DIR:-$SCRIPT_DIR/prompts}"

# Claude Codeのパス設定（Cron実行対応）
CLAUDE_CMD="${CLAUDE_CMD:-claude}"

# ログディレクトリ作成
mkdir -p "$LOG_DIR"

# ログ関数
log() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local system_log_file="${LOG_DIR}/system_${timestamp}.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$system_log_file"
}

# プロンプト実行
execute_prompt() {
    local prompt_file="$1"
    shift
    
    # ファイルが存在するか確認
    if [ ! -f "$prompt_file" ]; then
        # プロンプトディレクトリ内を探す
        if [ -f "${PROMPTS_DIR}/${prompt_file}" ]; then
            prompt_file="${PROMPTS_DIR}/${prompt_file}"
        elif [ -f "${PROMPTS_DIR}/${prompt_file}.txt" ]; then
            prompt_file="${PROMPTS_DIR}/${prompt_file}.txt"
        else
            log "ERROR: プロンプトファイルが見つかりません: ${PROMPTS_DIR}/${prompt_file}"
            exit 1
        fi
    fi
    
    # ログファイル名生成（プロンプトファイル名 + タイムスタンプ）
    local prompt_name=$(basename "$prompt_file" .txt)
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local main_log_file="${LOG_DIR}/${prompt_name}_${timestamp}.log"
    
    log "プロンプト実行: $prompt_file"
    log "ログファイル: $main_log_file"
    
    # プロンプト読み込み
    local prompt=$(cat "$prompt_file")
    
    # 引数による変数置換
    local i=1
    for arg in "$@"; do
        prompt=$(echo "$prompt" | sed "s/{{ARG${i}}}/$arg/g")
        i=$((i + 1))
    done
    
    # Claude実行（非対話的モード）
    "$CLAUDE_CMD" --output-format stream-json --print --dangerously-skip-permissions "$prompt" 2>&1 | tee "$main_log_file"
    
    log "実行完了"
}

# メイン処理
main() {
    # 前提条件チェック
    if [ ! -f "$CLAUDE_CMD" ] && ! command -v claude &> /dev/null; then
        echo "ERROR: Claude Code CLIが見つかりません: $CLAUDE_CMD"
        exit 1
    fi
    
    cd "$PROJECT_PATH"
    
    # 引数チェック
    if [ $# -eq 0 ]; then
        cat << EOF
使用方法: $0 <プロンプトファイル> [引数1] [引数2] ...

プロンプトファイルを指定してClaude Codeを実行します。

例:
  $0 issue_analysis              # issue_analysis.txtを実行
  $0 pr_review 123               # pr_review.txtを実行（{{ARG1}}を123に置換）
  $0 implementation 456          # implementation.txtを実行（{{ARG1}}を456に置換）
  $0 my_prompt.txt               # カスタムプロンプトを実行
  $0 custom.txt param1 param2    # {{ARG1}}, {{ARG2}}を置換して実行

環境変数:
  PROJECT_PATH   - プロジェクトパス (デフォルト: カレントディレクトリ)
  PROMPTS_DIR    - プロンプトディレクトリ (デフォルト: ./prompts)
  LOG_DIR        - ログ出力ディレクトリ (デフォルト: ./logs)
EOF
        exit 0
    fi
    
    execute_prompt "$@"
}

main "$@"