#!/bin/bash

# =============================================================================
# シンプルなClaude Code自動化スクリプト
# =============================================================================

set -e

# 設定
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
LOG_FILE="${LOG_FILE:-./claude_developer.log}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${PROMPTS_DIR:-$SCRIPT_DIR/prompts}"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
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
            log "ERROR: プロンプトファイルが見つかりません: $prompt_file"
            exit 1
        fi
    fi
    
    log "プロンプト実行: $prompt_file"
    
    # プロンプト読み込み
    local prompt=$(cat "$prompt_file")
    
    # 引数による変数置換
    local i=1
    for arg in "$@"; do
        prompt=$(echo "$prompt" | sed "s/{{ARG${i}}}/$arg/g")
        i=$((i + 1))
    done
    
    # Claude実行
    claude "$prompt"
    
    log "実行完了"
}

# メイン処理
main() {
    # 前提条件チェック
    if ! command -v claude &> /dev/null; then
        echo "ERROR: Claude Code CLIが見つかりません"
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
EOF
        exit 0
    fi
    
    execute_prompt "$@"
}

main "$@"