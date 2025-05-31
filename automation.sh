#!/bin/bash

# =============================================================================
# シンプルなClaude Code自動化スクリプト
# =============================================================================

set -e

# 設定
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
LOG_FILE="${LOG_FILE:-./claude_simple.log}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="${PROMPTS_DIR:-$SCRIPT_DIR/prompts}"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# プロンプトテンプレート読み込み
load_prompt() {
    local template_name="$1"
    local template_file="${PROMPTS_DIR}/${template_name}.txt"
    
    if [ -f "$template_file" ]; then
        cat "$template_file"
    else
        log "WARNING: プロンプトテンプレートが見つかりません: $template_file"
        echo ""
    fi
}

# プロジェクト分析してISSUE作成
create_issues() {
    log "=== ISSUE作成開始 ==="
    
    local prompt=$(load_prompt "issue_analysis")

    local result=$(claude -p --output-format json "$prompt" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        local issues=$(echo "$result" | jq -r '.response.issues // .issues // []')
        local count=$(echo "$issues" | jq length)
        
        log "提案されたISSUE数: $count"
        
        for i in $(seq 0 $((count - 1))); do
            local issue=$(echo "$issues" | jq -r ".[$i]")
            local title=$(echo "$issue" | jq -r '.title')
            local body=$(echo "$issue" | jq -r '.body')
            local priority=$(echo "$issue" | jq -r '.priority')
            
            gh issue create --title "$title" --body "$body" --label "auto-generated,priority:$priority"
            log "ISSUE作成完了 - $title"
        done
    else
        log "ERROR: Claude分析失敗"
    fi
    
    log "=== ISSUE作成完了 ==="
}

# オープンPRをレビュー
review_prs() {
    log "=== PRレビュー開始 ==="
    
    local prs=$(gh pr list --state open --limit 5 --json number,title | jq -r '.[].number')
    
    for pr in $prs; do
        log "PR #$pr をレビュー中..."
        
        local prompt_template=$(load_prompt "pr_review")
        local prompt=$(echo "$prompt_template" | sed "s/{{PR_NUMBER}}/$pr/g")
        claude "$prompt"
        log "PR #$pr レビュー完了"
    done
    
    log "=== PRレビュー完了 ==="
}

# 単一ISSUEの実装
implement_issue() {
    local issue_number="$1"
    
    log "=== ISSUE #$issue_number 実装開始 ==="
    
    # ISSUE情報取得
    local issue_data=$(gh issue view "$issue_number" --json title,body)
    local title=$(echo "$issue_data" | jq -r '.title')
    local body=$(echo "$issue_data" | jq -r '.body // ""')
    
    # ブランチ作成
    local branch_name="fix/issue-${issue_number}"
    
    git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
    
    # プロンプト生成
    local prompt_template=$(load_prompt "implementation")
    local prompt=$(echo "$prompt_template" | \
        sed "s/{{ISSUE_NUMBER}}/$issue_number/g" | \
        sed "s/{{ISSUE_TITLE}}/$title/g" | \
        sed "s/{{ISSUE_BODY}}/$body/g")
    
    # 実装実行
    claude "$prompt"
    
    # 変更があればPR作成
    if ! git diff --quiet; then
        git push -u origin "$branch_name"
        gh pr create --title "fix: implement #$issue_number - $title" \
                    --body "Closes #$issue_number" \
                    --base main
        log "PR作成完了"
    fi
    
    git checkout main
    
    log "=== ISSUE #$issue_number 実装完了 ==="
}

# メイン処理
main() {
    log "=== シンプル自動化開始 ==="
    
    # 前提条件チェック
    if ! command -v claude &> /dev/null; then
        log "ERROR: Claude Code CLIが見つかりません"
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log "ERROR: GitHub CLIが見つかりません"
        exit 1
    fi
    
    cd "$PROJECT_PATH"
    
    # 処理実行
    case "${1:-help}" in
        issues)
            create_issues
            ;;
        review)
            review_prs
            ;;
        implement)
            if [ -n "$2" ]; then
                implement_issue "$2"
            else
                echo "ERROR: ISSUE番号を指定してください"
                exit 1
            fi
            ;;
        run)
            if [ -n "$2" ]; then
                if [ -f "$2" ]; then
                    log "プロンプトファイル実行: $2"
                    local prompt=$(cat "$2")
                    claude "$prompt"
                    log "実行完了"
                else
                    echo "ERROR: ファイルが見つかりません: $2"
                    exit 1
                fi
            else
                echo "ERROR: プロンプトファイルを指定してください"
                exit 1
            fi
            ;;
        all)
            create_issues
            review_prs
            ;;
        help|*)
            cat << EOF
使用方法: $0 [コマンド] [オプション]

コマンド:
  issues              - プロジェクト分析とISSUE作成
  review              - オープンPRのレビュー
  implement <番号>    - 指定ISSUEの実装
  run <ファイル>      - 指定したプロンプトファイルを実行
  all                 - ISSUE作成とレビューを実行

環境変数:
  PROJECT_PATH        - プロジェクトパス (デフォルト: カレントディレクトリ)
  PROMPTS_DIR        - プロンプトテンプレートのディレクトリ

例:
  $0 issues                    # ISSUE作成のみ
  $0 review                    # PRレビューのみ
  $0 implement 123             # ISSUE #123を実装
  $0 run my_prompt.txt         # カスタムプロンプトを実行
EOF
            exit 0
            ;;
    esac
    
    log "=== シンプル自動化完了 ==="
}

main "$@"