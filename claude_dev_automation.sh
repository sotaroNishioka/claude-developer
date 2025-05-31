#!/bin/bash

# =============================================================================
# Claude Code 統合開発自動化スクリプト
# ISSUE作成・実装・PRレビュー・ISSUE改善を自動化
# =============================================================================

set -e  # エラー時に停止

# 設定値
PROJECT_PATH="${PROJECT_PATH:-$(pwd)}"
LOG_FILE="${LOG_FILE:-/tmp/claude_dev_automation.log}"
MAX_ISSUES="${MAX_ISSUES:-5}"
MAX_IMPLEMENTATIONS="${MAX_IMPLEMENTATIONS:-3}"
DRY_RUN="${DRY_RUN:-false}"
AUTO_IMPLEMENT="${AUTO_IMPLEMENT:-false}"
AUTO_REVIEW="${AUTO_REVIEW:-true}"
AUTO_IMPROVE_ISSUES="${AUTO_IMPROVE_ISSUES:-true}"
BRANCH_PREFIX="${BRANCH_PREFIX:-claude-auto}"

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
    
    # jq の存在確認
    if ! command -v jq &> /dev/null; then
        error_exit "jq が見つかりません。インストールしてください。"
    fi
    
    # Git の存在確認
    if ! command -v git &> /dev/null; then
        error_exit "Git が見つかりません。インストールしてください。"
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

# 1. 既存ISSUEの改善
improve_existing_issues() {
    log "=== 既存ISSUE改善処理開始 ==="
    
    if [ "$AUTO_IMPROVE_ISSUES" != "true" ]; then
        log "ISSUE改善がスキップされました（AUTO_IMPROVE_ISSUES=false）"
        return 0
    fi
    
    # 最近のオープンISSUEを取得
    local issues_json
    issues_json=$(gh issue list --state open --limit 20 --json number,title,body,labels)
    
    local issue_count
    issue_count=$(echo "$issues_json" | jq length)
    
    if [ "$issue_count" -eq 0 ]; then
        log "改善対象のISSUEが見つかりませんでした"
        return 0
    fi
    
    log "改善対象ISSUE数: $issue_count"
    
    # 各ISSUEを分析・改善
    for i in $(seq 0 $((issue_count - 1))); do
        local issue
        issue=$(echo "$issues_json" | jq -r ".[$i]")
        
        local number title body
        number=$(echo "$issue" | jq -r '.number')
        title=$(echo "$issue" | jq -r '.title')
        body=$(echo "$issue" | jq -r '.body // ""')
        
        improve_single_issue "$number" "$title" "$body"
    done
    
    log "=== 既存ISSUE改善処理完了 ==="
}

# 単一ISSUEの改善
improve_single_issue() {
    local number="$1"
    local title="$2"
    local body="$3"
    
    log "ISSUE #$number の改善を分析中: $title"
    
    local prompt="GitHub ISSUEの改善を行ってください。

現在のISSUE:
タイトル: $title
内容: $body

以下の観点で改善提案をJSON形式で出力してください:
{
  \"should_improve\": true/false,
  \"improved_title\": \"改善されたタイトル\",
  \"improved_body\": \"改善された詳細説明（マークダウン形式）\",
  \"added_labels\": [\"追加すべきラベル\"],
  \"improvements\": [\"改善点の説明\"]
}

改善観点:
1. タイトルの明確化
2. 説明の詳細化
3. 再現手順の追加
4. 受入条件の明確化
5. 技術的詳細の補強
6. 適切なラベルの提案

軽微な修正のみの場合はshould_improve: falseにしてください。"

    local claude_output
    claude_output=$(claude -p --output-format json "$prompt" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        log "ERROR: Claude分析失敗 - ISSUE #$number"
        return 1
    fi
    
    # JSON解析
    local should_improve
    should_improve=$(echo "$claude_output" | jq -r '.response.should_improve // .should_improve // false')
    
    if [ "$should_improve" = "true" ]; then
        local improved_title improved_body added_labels
        improved_title=$(echo "$claude_output" | jq -r '.response.improved_title // .improved_title // ""')
        improved_body=$(echo "$claude_output" | jq -r '.response.improved_body // .improved_body // ""')
        added_labels=$(echo "$claude_output" | jq -r '.response.added_labels // .added_labels // []' | jq -r '.[]' | tr '\n' ',' | sed 's/,$//')
        
        if [ "$DRY_RUN" = "true" ]; then
            log "DRY RUN: ISSUE #$number の改善提案"
            log "  新タイトル: $improved_title"
            log "  ラベル追加: $added_labels"
        else
            # ISSUE更新
            local update_args=""
            if [ -n "$improved_title" ]; then
                update_args="$update_args --title \"$improved_title\""
            fi
            if [ -n "$improved_body" ]; then
                update_args="$update_args --body \"$improved_body\""
            fi
            
            if [ -n "$update_args" ]; then
                eval "gh issue edit $number $update_args"
                log "SUCCESS: ISSUE #$number を改善しました"
            fi
            
            # ラベル追加
            if [ -n "$added_labels" ]; then
                IFS=',' read -ra LABEL_ARRAY <<< "$added_labels"
                for label in "${LABEL_ARRAY[@]}"; do
                    label=$(echo "$label" | xargs)
                    if [ -n "$label" ]; then
                        gh issue edit "$number" --add-label "$label" 2>/dev/null || true
                    fi
                done
            fi
        fi
    else
        log "ISSUE #$number は改善不要と判定されました"
    fi
}

# 2. 新規ISSUE作成
create_new_issues() {
    log "=== 新規ISSUE作成処理開始 ==="
    
    local prompt="このプロジェクトを分析して、以下の形式でGitHub ISSUEの提案をJSON形式で出力してください:

{
  \"issues\": [
    {
      \"title\": \"ISSUE のタイトル\",
      \"body\": \"ISSUE の詳細説明（マークダウン形式）\",
      \"labels\": [\"ラベル1\", \"ラベル2\"],
      \"priority\": \"high|medium|low\",
      \"type\": \"bug|feature|improvement|documentation\",
      \"implementation_complexity\": \"simple|medium|complex\",
      \"auto_implementable\": true/false
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
7. 新機能の提案
8. バグの特定と修正

最大${MAX_ISSUES}個のISSUEを提案してください。
auto_implementableはClaude Codeで自動実装可能かどうかを判定してください。"

    local claude_output
    claude_output=$(claude -p --output-format json "$prompt" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        error_exit "Claude Code の実行に失敗しました"
    fi
    
    # ISSUE処理
    process_new_issues "$claude_output"
    
    log "=== 新規ISSUE作成処理完了 ==="
}

# 新規ISSUE処理
process_new_issues() {
    local claude_output="$1"
    
    local issues_data
    issues_data=$(echo "$claude_output" | jq -r '.response.issues // .issues // empty')
    
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
        
        local title body labels priority type complexity auto_implementable
        title=$(echo "$issue" | jq -r '.title // "Untitled Issue"')
        body=$(echo "$issue" | jq -r '.body // "No description provided"')
        labels=$(echo "$issue" | jq -r '.labels[]? // empty' | tr '\n' ',' | sed 's/,$//')
        priority=$(echo "$issue" | jq -r '.priority // "medium"')
        type=$(echo "$issue" | jq -r '.type // "improvement"')
        complexity=$(echo "$issue" | jq -r '.implementation_complexity // "medium"')
        auto_implementable=$(echo "$issue" | jq -r '.auto_implementable // false')
        
        local issue_number
        issue_number=$(create_github_issue "$title" "$body" "$labels" "$priority" "$type" "$complexity")
        
        # 自動実装対象の場合はキューに追加
        if [ "$auto_implementable" = "true" ] && [ "$AUTO_IMPLEMENT" = "true" ] && [ -n "$issue_number" ]; then
            echo "$issue_number" >> "/tmp/claude_implement_queue.txt"
        fi
    done
}

# GitHub ISSUE作成
create_github_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local priority="$4"
    local type="$5"
    local complexity="$6"
    
    log "ISSUE作成準備: $title"
    
    # ラベルの準備
    local label_args=""
    if [ -n "$labels" ]; then
        IFS=',' read -ra LABEL_ARRAY <<< "$labels"
        for label in "${LABEL_ARRAY[@]}"; do
            label=$(echo "$label" | xargs)
            if [ -n "$label" ]; then
                label_args="$label_args --label \"$label\""
            fi
        done
    fi
    
    # メタデータラベルを追加
    label_args="$label_args --label \"priority:$priority\" --label \"type:$type\" --label \"complexity:$complexity\""
    
    # ISSUE本文にメタデータを追加
    local enhanced_body="$body

---
**自動生成情報:**
- 優先度: $priority
- タイプ: $type  
- 実装複雑度: $complexity
- 作成日時: $(date '+%Y-%m-%d %H:%M:%S')
- 生成者: Claude Code Auto Batch"

    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: 以下のISSUEを作成する予定です:"
        log "  タイトル: $title"
        log "  ラベル: $labels, priority:$priority, type:$type"
        echo "mock_issue_123"  # モック番号を返す
    else
        # GitHub ISSUE作成
        local create_command="gh issue create --title \"$title\" --body \"$enhanced_body\" $label_args"
        
        log "ISSUE作成実行中: $title"
        local issue_url
        issue_url=$(eval "$create_command")
        
        if [ $? -eq 0 ]; then
            local issue_number
            issue_number=$(echo "$issue_url" | grep -o '[0-9]*$')
            log "SUCCESS: ISSUE作成完了 - #$issue_number: $title"
            echo "$issue_number"
        else
            log "ERROR: ISSUE作成失敗 - $title"
            echo ""
        fi
    fi
}

# 3. ISSUE自動実装
implement_issues() {
    log "=== ISSUE自動実装処理開始 ==="
    
    if [ "$AUTO_IMPLEMENT" != "true" ]; then
        log "自動実装がスキップされました（AUTO_IMPLEMENT=false）"
        return 0
    fi
    
    # 実装キューファイルの確認
    local queue_file="/tmp/claude_implement_queue.txt"
    if [ ! -f "$queue_file" ]; then
        log "実装対象のISSUEがありません"
        return 0
    fi
    
    local implemented_count=0
    while IFS= read -r issue_number && [ "$implemented_count" -lt "$MAX_IMPLEMENTATIONS" ]; do
        if [ -n "$issue_number" ]; then
            implement_single_issue "$issue_number"
            implemented_count=$((implemented_count + 1))
        fi
    done < "$queue_file"
    
    # 処理済みキューをクリア
    rm -f "$queue_file"
    
    log "=== ISSUE自動実装処理完了 ==="
}

# 単一ISSUE実装
implement_single_issue() {
    local issue_number="$1"
    
    log "ISSUE #$issue_number の実装を開始します"
    
    # ISSUE詳細取得
    local issue_data
    issue_data=$(gh issue view "$issue_number" --json title,body,labels)
    
    local title body
    title=$(echo "$issue_data" | jq -r '.title')
    body=$(echo "$issue_data" | jq -r '.body // ""')
    
    # ブランチ作成
    local branch_name="${BRANCH_PREFIX}/issue-${issue_number}"
    
    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: ブランチ $branch_name を作成してISSUE実装を開始予定"
        return 0
    fi
    
    # メインブランチの最新を取得
    git fetch origin
    git checkout main 2>/dev/null || git checkout master 2>/dev/null
    git pull origin $(git branch --show-current)
    
    # 新ブランチ作成・切り替え
    if git checkout -b "$branch_name" 2>/dev/null; then
        log "ブランチ作成成功: $branch_name"
    else
        log "ERROR: ブランチ作成失敗: $branch_name"
        return 1
    fi
    
    # Claude Codeで実装
    local implement_prompt="ISSUE #${issue_number}を実装してください。

タイトル: $title
詳細: $body

以下の手順で進めてください:
1. 実装内容を分析
2. 必要なファイルを特定
3. コードを実装
4. テストを追加（可能な場合）
5. ドキュメントを更新（必要な場合）

実装が完了したら、変更内容をコミットしてください。
コミットメッセージは「fix: implement #${issue_number} - ${title}」の形式にしてください。"

    # Claude Codeで実装実行
    claude "$implement_prompt"
    
    # 変更があるかチェック
    if git diff --quiet && git diff --cached --quiet; then
        log "WARNING: ISSUE #$issue_number - 実装による変更が検出されませんでした"
        git checkout main
        git branch -D "$branch_name" 2>/dev/null || true
        return 1
    fi
    
    # 変更をコミット（Claude Codeがコミットしていない場合）
    if git diff --quiet --cached; then
        git add .
        git commit -m "fix: implement #${issue_number} - ${title}

Implemented by Claude Code Auto Batch
- ISSUE: #${issue_number}
- Branch: ${branch_name}
- Date: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # ブランチをプッシュ
    git push -u origin "$branch_name"
    
    # プルリクエスト作成
    local pr_body="## 概要
ISSUE #${issue_number} の自動実装です。

## 変更内容
$body

## 実装詳細
Claude Code により自動実装されました。

Closes #${issue_number}"

    local pr_url
    pr_url=$(gh pr create \
        --title "fix: implement #${issue_number} - ${title}" \
        --body "$pr_body" \
        --base main \
        --head "$branch_name" \
        --label "auto-implementation" \
        --label "needs-review")
    
    if [ $? -eq 0 ]; then
        log "SUCCESS: PR作成完了 - $pr_url"
        
        # PR番号を取得してレビューキューに追加
        local pr_number
        pr_number=$(echo "$pr_url" | grep -o '[0-9]*$')
        echo "$pr_number" >> "/tmp/claude_review_queue.txt"
    else
        log "ERROR: PR作成失敗 - ISSUE #$issue_number"
    fi
    
    # メインブランチに戻る
    git checkout main
}

# 4. プルリクエストレビュー
review_pull_requests() {
    log "=== PRレビュー処理開始 ==="
    
    if [ "$AUTO_REVIEW" != "true" ]; then
        log "自動レビューがスキップされました（AUTO_REVIEW=false）"
        return 0
    fi
    
    # レビュー対象PRの取得（新規作成PRも含む）
    local review_queue="/tmp/claude_review_queue.txt"
    local prs_to_review=()
    
    # キューからPR取得
    if [ -f "$review_queue" ]; then
        while IFS= read -r pr_number; do
            if [ -n "$pr_number" ]; then
                prs_to_review+=("$pr_number")
            fi
        done < "$review_queue"
        rm -f "$review_queue"
    fi
    
    # 最近のオープンPRも追加
    local recent_prs
    recent_prs=$(gh pr list --state open --limit 10 --json number | jq -r '.[].number')
    
    for pr in $recent_prs; do
        if [[ ! " ${prs_to_review[@]} " =~ " ${pr} " ]]; then
            prs_to_review+=("$pr")
        fi
    done
    
    # 各PRをレビュー
    for pr_number in "${prs_to_review[@]}"; do
        review_single_pr "$pr_number"
    done
    
    log "=== PRレビュー処理完了 ==="
}

# 単一PRレビュー
review_single_pr() {
    local pr_number="$1"
    
    log "PR #$pr_number のレビューを開始します"
    
    # PR詳細取得
    local pr_data
    pr_data=$(gh pr view "$pr_number" --json title,body,files,additions,deletions)
    
    local title body
    title=$(echo "$pr_data" | jq -r '.title')
    body=$(echo "$pr_data" | jq -r '.body // ""')
    
    # 変更ファイル一覧取得
    local changed_files
    changed_files=$(gh pr diff "$pr_number" --name-only)
    
    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: PR #$pr_number のレビューを実行予定"
        log "  対象ファイル: $(echo "$changed_files" | wc -l)件"
        return 0
    fi
    
    # Claude Codeでレビュー実行
    local review_prompt="PR #${pr_number}をレビューしてください。

タイトル: $title
説明: $body

変更ファイル:
$changed_files

以下の観点でレビューしてください:
1. コードの品質
2. セキュリティの問題
3. パフォーマンスの影響
4. テストの妥当性
5. ドキュメントの更新
6. 命名規則の遵守
7. 設計パターンの適用

レビューコメントがある場合は、具体的な行やファイルに対してコメントしてください。
重大な問題がない場合はApproveし、問題がある場合はRequest Changesしてください。"

    # レビュー実行
    claude "$review_prompt"
    
    log "SUCCESS: PR #$pr_number のレビューを完了しました"
}

# 5. GitHub Actionsワークフロー監視
monitor_workflows() {
    log "=== ワークフロー監視処理開始 ==="
    
    # 最近のワークフロー実行状況を確認
    local failed_runs
    failed_runs=$(gh run list --status failure --limit 5 --json databaseId,status,conclusion,workflowName)
    
    local failed_count
    failed_count=$(echo "$failed_runs" | jq length)
    
    if [ "$failed_count" -gt 0 ]; then
        log "WARNING: 失敗したワークフローが${failed_count}件見つかりました"
        
        # 失敗したワークフローに対してISSUE作成
        for i in $(seq 0 $((failed_count - 1))); do
            local run
            run=$(echo "$failed_runs" | jq -r ".[$i]")
            
            local workflow_name run_id
            workflow_name=$(echo "$run" | jq -r '.workflowName')
            run_id=$(echo "$run" | jq -r '.databaseId')
            
            create_workflow_failure_issue "$workflow_name" "$run_id"
        done
    else
        log "ワークフローの失敗は検出されませんでした"
    fi
    
    log "=== ワークフロー監視処理完了 ==="
}

# ワークフロー失敗ISSUE作成
create_workflow_failure_issue() {
    local workflow_name="$1"
    local run_id="$2"
    
    local title="CI/CD: ${workflow_name} ワークフローが失敗しています"
    local body="## 概要
GitHub Actions ワークフロー「${workflow_name}」が失敗しています。

## 詳細
- ワークフロー: ${workflow_name}
- 実行ID: ${run_id}
- 検出日時: $(date '+%Y-%m-%d %H:%M:%S')

## 対応が必要な事項
1. ワークフロー実行ログの確認
2. 失敗原因の特定
3. 問題の修正
4. 再実行の確認

## 参考リンク
[ワークフロー実行詳細](https://github.com/$(gh repo view --json owner,name | jq -r '.owner.login + \"/\" + .name')/actions/runs/${run_id})"

    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: ワークフロー失敗ISSUE作成予定 - $title"
    else
        gh issue create \
            --title "$title" \
            --body "$body" \
            --label "ci/cd" \
            --label "priority:high" \
            --label "type:bug" \
            --label "auto-generated"
        
        log "SUCCESS: ワークフロー失敗ISSUE作成完了 - $title"
    fi
}

# メイン処理
main() {
    log "=== Claude Code 統合開発自動化開始 ==="
    log "プロジェクトパス: $PROJECT_PATH"
    log "ドライラン: $DRY_RUN"
    log "自動実装: $AUTO_IMPLEMENT"
    log "自動レビュー: $AUTO_REVIEW"
    log "ISSUE改善: $AUTO_IMPROVE_ISSUES"
    
    # 前提条件チェック
    check_prerequisites
    
    # プロジェクトディレクトリに移動
    cd "$PROJECT_PATH"
    
    # 処理実行
    improve_existing_issues
    create_new_issues
    implement_issues
    review_pull_requests
    monitor_workflows
    
    log "=== Claude Code 統合開発自動化完了 ==="
}

# ヘルプ表示
show_help() {
    cat << EOF
Claude Code 統合開発自動化スクリプト

機能:
  - 既存ISSUEの改善
  - 新規ISSUE作成
  - ISSUE自動実装
  - プルリクエストレビュー
  - ワークフロー監視

使用方法:
    $0 [オプション]

オプション:
    -h, --help              このヘルプを表示
    -d, --dry-run           実際には実行せず、動作確認のみ
    -p, --path PATH         プロジェクトパス（デフォルト: 現在のディレクトリ）
    -m, --max-issues N      最大ISSUE作成数（デフォルト: 5）
    -i, --max-impl N        最大実装数（デフォルト: 3）
    -l, --log-file FILE     ログファイルパス
    --auto-implement        ISSUE自動実装を有効化
    --no-auto-implement     ISSUE自動実装を無効化
    --auto-review          PR自動レビューを有効化
    --no-auto-review       PR自動レビューを無効化
    --improve-issues       ISSUE改善を有効化
    --no-improve-issues    ISSUE改善を無効化

環境変数:
    PROJECT_PATH           プロジェクトパス
    MAX_ISSUES            最大ISSUE作成数
    MAX_IMPLEMENTATIONS    最大実装数
    DRY_RUN               ドライランモード（true/false）
    AUTO_IMPLEMENT        自動実装（true/false）
    AUTO_REVIEW           自動レビュー（true/false）
    AUTO_IMPROVE_ISSUES   ISSUE改善（true/false）
    BRANCH_PREFIX         実装用ブランチのプレフィックス

例:
    # 基本実行
    $0
    
    # フル自動化
    $0 --auto-implement --auto-review --improve-issues
    
    # レビューのみ
    $0 --no-auto-implement --auto-review --no-improve-issues
    
    # ドライランで動作確認
    $0 --dry-run --auto-implement
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
        -i|--max-impl)
            MAX_IMPLEMENTATIONS="$2"
            shift 2
            ;;
        -l|--log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        --auto-implement)
            AUTO_IMPLEMENT=true
            shift
            ;;
        --no-auto-implement)
            AUTO_IMPLEMENT=false
            shift
            ;;
        --auto-review)
            AUTO_REVIEW=true
            shift
            ;;
        --no-auto-review)
            AUTO_REVIEW=false
            shift
            ;;
        --improve-issues)
            AUTO_IMPROVE_ISSUES=true
            shift
            ;;
        --no-improve-issues)
            AUTO_IMPROVE_ISSUES=false
            shift
            ;;
        *)
            error_exit "不明なオプション: $1"
            ;;
    esac
done

# メイン処理実行
main