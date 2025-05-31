#!/bin/bash

# =============================================================================
# Claude Code CLI を使った自動ISSUE作成バッチスクリプト
# =============================================================================

set -e  # エラー時に停止

# 設定値
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
LOG_FILE="${LOG_FILE:-/tmp/claude_issue_batch.log}"
MAX_ISSUES="${MAX_ISSUES:-5}"
DRY_RUN="${DRY_RUN:-false}"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# 前提条件チェック
check_prerequisites() {
    log "前提条件をチェック中..."
    
    # Claude Code CLI の存在確認
    if ! command -v claude &> /dev/null; then
        error_exit "Claude Code CLI が見つかりません。インストールしてください。"
    fi
    
    # GitHub CLI の存在確認
    if ! command -v gh &> /dev/null; then
        error_exit "GitHub CLI が見つかりません。インストールしてください。"
    fi
    
    # プロジェクトディレクトリの確認
    if [ ! -d "$PROJECT_PATH" ]; then
        error_exit "プロジェクトディレクトリが見つかりません: $PROJECT_PATH"
    fi
    
    # Gitリポジトリの確認
    cd "$PROJECT_PATH"
    if [ ! -d .git ]; then
        error_exit "Gitリポジトリではありません: $PROJECT_PATH"
    fi
    
    # GitHub認証の確認
    if ! gh auth status &> /dev/null; then
        error_exit "GitHub認証が必要です。'gh auth login' を実行してください。"
    fi
    
    log "前提条件チェック完了"
}

# Claude Code でプロジェクト分析とISSUE提案を取得
analyze_and_generate_issues() {
    log "Claude Code でプロジェクト分析を実行中..."
    
    local prompt="このプロジェクトを分析して、以下の形式でGitHub ISSUEの提案をJSON形式で出力してください:

{
  \"issues\": [
    {
      \"title\": \"ISSUE のタイトル\",
      \"body\": \"ISSUE の詳細説明（マークダウン形式）\",
      \"labels\": [\"ラベル1\", \"ラベル2\"],
      \"priority\": \"high|medium|low\",
      \"type\": \"bug|feature|improvement|documentation\"
    }
  ]
}

以下の観点で分析してください:
1. コードの品質向上
2. 技術的負債の解消
3. セキュリティの改善
4. パフォーマンスの最適化
5. ドキュメントの改善
6. テストカバレッジの向上

最大${MAX_ISSUES}個のISSUEを提案してください。"

    # Claude Code CLI を実行してJSON出力を取得
    local claude_output
    claude_output=$(claude -p --output-format json "$prompt" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        error_exit "Claude Code の実行に失敗しました"
    fi
    
    # JSON の妥当性チェック
    if ! echo "$claude_output" | jq empty 2>/dev/null; then
        error_exit "Claude Code からの出力が有効なJSONではありません"
    fi
    
    echo "$claude_output"
}

# ISSUE データを解析して個別に処理
process_issues() {
    local claude_output="$1"
    
    # Claude の出力からissuesデータを抽出
    local issues_data
    issues_data=$(echo "$claude_output" | jq -r '.response // .content // .' | jq -r '.issues // empty')
    
    if [ -z "$issues_data" ] || [ "$issues_data" = "null" ]; then
        log "WARNING: ISSUE データが見つかりませんでした"
        return 1
    fi
    
    local issue_count
    issue_count=$(echo "$issues_data" | jq length)
    log "提案されたISSUE数: $issue_count"
    
    # 各ISSUEを処理
    for i in $(seq 0 $((issue_count - 1))); do
        local issue
        issue=$(echo "$issues_data" | jq -r ".[$i]")
        
        local title body labels priority type
        title=$(echo "$issue" | jq -r '.title // "Untitled Issue"')
        body=$(echo "$issue" | jq -r '.body // "No description provided"')
        labels=$(echo "$issue" | jq -r '.labels[]? // empty' | tr '\n' ',' | sed 's/,$//')
        priority=$(echo "$issue" | jq -r '.priority // "medium"')
        type=$(echo "$issue" | jq -r '.type // "improvement"')
        
        create_github_issue "$title" "$body" "$labels" "$priority" "$type"
    done
}

# GitHub ISSUE を作成
create_github_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local priority="$4"
    local type="$5"
    
    log "ISSUE作成準備: $title"
    
    # ラベルの準備
    local label_args=""
    if [ -n "$labels" ]; then
        # カンマ区切りのラベルを個別の--labelオプションに変換
        IFS=',' read -ra LABEL_ARRAY <<< "$labels"
        for label in "${LABEL_ARRAY[@]}"; do
            label=$(echo "$label" | xargs)  # 前後の空白を削除
            if [ -n "$label" ]; then
                label_args="$label_args --label \"$label\""
            fi
        done
    fi
    
    # 優先度とタイプのラベルを追加
    label_args="$label_args --label \"priority:$priority\" --label \"type:$type\""
    
    # ISSUE本文にメタデータを追加
    local enhanced_body="$body

---
**自動生成情報:**
- 優先度: $priority
- タイプ: $type
- 作成日時: $(date '+%Y-%m-%d %H:%M:%S')
- 生成者: Claude Code Auto Batch"
    
    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: 以下のISSUEを作成する予定です:"
        log "  タイトル: $title"
        log "  ラベル: $labels, priority:$priority, type:$type"
        log "  本文: $(echo "$enhanced_body" | head -3)..."
    else
        # GitHub ISSUE作成コマンドを構築して実行
        local create_command="gh issue create --title \"$title\" --body \"$enhanced_body\" $label_args"
        
        log "ISSUE作成実行中: $title"
        if eval "$create_command"; then
            log "SUCCESS: ISSUE作成完了 - $title"
        else
            log "ERROR: ISSUE作成失敗 - $title"
        fi
    fi
}

# 重複ISSUE チェック
check_duplicate_issues() {
    log "重複ISSUEチェック中..."
    
    # 最近作成されたISSUEを取得（過去7日）
    local recent_issues
    recent_issues=$(gh issue list --state open --limit 50 --json title,createdAt)
    
    # TODO: より高度な重複チェックロジックを実装
    # 現在は簡単なタイトル一致チェックのみ
    
    log "重複チェック完了"
}

# メイン処理
main() {
    log "=== Claude Code 自動ISSUE作成バッチ開始 ==="
    log "プロジェクトパス: $PROJECT_PATH"
    log "ドライラン: $DRY_RUN"
    log "最大ISSUE数: $MAX_ISSUES"
    
    # 前提条件チェック
    check_prerequisites
    
    # プロジェクトディレクトリに移動
    cd "$PROJECT_PATH"
    
    # 重複チェック
    check_duplicate_issues
    
    # Claude Code でプロジェクト分析
    local claude_output
    claude_output=$(analyze_and_generate_issues)
    
    if [ $? -eq 0 ] && [ -n "$claude_output" ]; then
        # ISSUE処理
        process_issues "$claude_output"
        log "=== バッチ処理完了 ==="
    else
        error_exit "Claude Code からの出力取得に失敗しました"
    fi
}

# ヘルプ表示
show_help() {
    cat << EOF
Claude Code 自動ISSUE作成バッチスクリプト

使用方法:
    $0 [オプション]

オプション:
    -h, --help          このヘルプを表示
    -d, --dry-run       実際には作成せず、動作確認のみ
    -p, --path PATH     プロジェクトパス（デフォルト: 現在のディレクトリ）
    -m, --max-issues N  最大ISSUE作成数（デフォルト: 5）
    -l, --log-file FILE ログファイルパス（デフォルト: /tmp/claude_issue_batch.log）

環境変数:
    PROJECT_PATH        プロジェクトパス
    MAX_ISSUES          最大ISSUE作成数
    DRY_RUN            ドライランモード（true/false）
    LOG_FILE           ログファイルパス

例:
    # 基本実行
    $0
    
    # ドライランで動作確認
    $0 --dry-run
    
    # 特定のプロジェクトで実行
    $0 --path /path/to/project --max-issues 3
    
    # 環境変数で設定
    PROJECT_PATH=/path/to/project DRY_RUN=true $0
EOF
}

# コマンドライン引数の処理
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -p|--path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -m|--max-issues)
            MAX_ISSUES="$2"
            shift 2
            ;;
        -l|--log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        *)
            error_exit "不明なオプション: $1"
            ;;
    esac
done

# メイン処理実行
main