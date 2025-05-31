#!/bin/bash

# =============================================================================
# Claude Code 統合開発自動化 - cron設定スクリプト
# =============================================================================

# 設定値
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/claude_dev_automation.sh"
CRON_LOG="/var/log/claude_dev_automation.log"

# cron設定例
setup_cron_jobs() {
    echo "Claude Code 統合開発自動化のcron設定例を表示します..."
    echo ""
    echo "=== 基本的なcron設定 ==="
    echo ""
    
    echo "# 毎週月曜日の朝9時 - フル自動化（推奨）"
    echo "0 9 * * 1 $MAIN_SCRIPT --path /path/to/your/project --auto-implement --auto-review --improve-issues >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 毎日朝8時 - 軽量モード（ISSUE改善とレビューのみ）"
    echo "0 8 * * * $MAIN_SCRIPT --path /path/to/your/project --no-auto-implement --auto-review --improve-issues --max-issues 2 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 平日18時 - 実装重視モード"
    echo "0 18 * * 1-5 $MAIN_SCRIPT --path /path/to/your/project --auto-implement --no-auto-review --max-impl 2 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 毎時間 - レビューのみ（アクティブ開発時）"
    echo "0 * * * * $MAIN_SCRIPT --path /path/to/your/project --no-auto-implement --auto-review --no-improve-issues >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== チーム開発向け設定 ==="
    echo ""
    
    echo "# 大規模チーム - 段階的実行"
    echo "# 朝: ISSUE改善と作成"
    echo "0 8 * * * $MAIN_SCRIPT --path /path/to/project --no-auto-implement --no-auto-review --improve-issues --max-issues 5 >> $CRON_LOG 2>&1"
    echo "# 昼: 実装"
    echo "0 12 * * * $MAIN_SCRIPT --path /path/to/project --auto-implement --no-auto-review --no-improve-issues --max-impl 3 >> $CRON_LOG 2>&1"
    echo "# 夕方: レビュー"
    echo "0 17 * * * $MAIN_SCRIPT --path /path/to/project --no-auto-implement --auto-review --no-improve-issues >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== 複数プロジェクト管理 ==="
    echo ""
    echo "# メインプロジェクト - 毎日フル自動化"
    echo "0 9 * * * $MAIN_SCRIPT --path /path/to/main-project --auto-implement --auto-review --improve-issues >> $CRON_LOG 2>&1"
    echo ""
    echo "# サブプロジェクトA - 週2回"
    echo "0 9 * * 2,5 $MAIN_SCRIPT --path /path/to/project-a --auto-implement --auto-review --max-issues 3 --max-impl 2 >> $CRON_LOG 2>&1"
    echo ""
    echo "# レガシープロジェクト - 改善のみ"
    echo "0 9 * * 1 $MAIN_SCRIPT --path /path/to/legacy-project --no-auto-implement --no-auto-review --improve-issues --max-issues 2 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== 開発フェーズ別設定 ==="
    echo ""
    echo "# 開発初期段階 - アイデア重視"
    echo "0 9 * * * $MAIN_SCRIPT --path /path/to/new-project --no-auto-implement --no-auto-review --improve-issues --max-issues 10 >> $CRON_LOG 2>&1"
    echo ""
    echo "# アクティブ開発 - 実装重視"
    echo "0 9,14 * * * $MAIN_SCRIPT --path /path/to/active-project --auto-implement --auto-review --max-impl 5 >> $CRON_LOG 2>&1"
    echo ""
    echo "# メンテナンスフェーズ - 品質重視"
    echo "0 9 * * 1,3,5 $MAIN_SCRIPT --path /path/to/stable-project --no-auto-implement --auto-review --improve-issues --max-issues 3 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== 環境変数を使った高度な設定 ==="
    echo ""
    echo "# 設定ファイルベース"
    echo "0 9 * * * cd /path/to/project && source .env && $MAIN_SCRIPT --auto-implement --auto-review >> $CRON_LOG 2>&1"
    echo ""
    echo "# 動的設定（曜日によって動作変更）"
    echo "0 9 * * 1 WEEKDAY=monday $MAIN_SCRIPT --path /path/to/project --auto-implement --auto-review --improve-issues --max-issues 10 >> $CRON_LOG 2>&1"
    echo "0 9 * * 2-5 WEEKDAY=weekday $MAIN_SCRIPT --path /path/to/project --auto-implement --auto-review --max-issues 3 --max-impl 2 >> $CRON_LOG 2>&1"
    echo ""
}

# 対話的cron設定
interactive_cron_setup() {
    echo "統合開発自動化の対話的cron設定を開始します..."
    echo ""
    
    # プロジェクトパスの入力
    read -p "プロジェクトのパスを入力してください: " project_path
    if [ ! -d "$project_path" ]; then
        echo "ERROR: 指定されたパスが存在しません: $project_path"
        return 1
    fi
    
    # 自動化レベルの選択
    echo ""
    echo "自動化レベルを選択してください:"
    echo "1) 基本 - ISSUE改善とレビューのみ"
    echo "2) 標準 - ISSUE作成・改善・レビュー"
    echo "3) フル - 全自動化（実装含む）"
    echo "4) カスタム - 個別設定"
    
    read -p "選択してください (1-4): " automation_level
    
    # 実行頻度の選択
    echo ""
    echo "実行頻度を選択してください:"
    echo "1) 毎日"
    echo "2) 毎週（月曜日）"
    echo "3) 平日のみ"
    echo "4) 週2回（火・金）"
    echo "5) カスタム"
    
    read -p "選択してください (1-5): " frequency_choice
    
    # 実行時刻の入力
    read -p "実行時刻を入力してください (例: 9 = 9時): " hour
    if ! [[ "$hour" =~ ^[0-9]+$ ]] || [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        echo "ERROR: 有効な時刻を入力してください (0-23)"
        return 1
    fi
    
    # 自動化オプションの構築
    local automation_args=""
    case $automation_level in
        1)
            automation_args="--no-auto-implement --auto-review --improve-issues --max-issues 3"
            ;;
        2)
            automation_args="--no-auto-implement --auto-review --improve-issues --max-issues 5"
            ;;
        3)
            automation_args="--auto-implement --auto-review --improve-issues --max-issues 5 --max-impl 3"
            ;;
        4)
            echo ""
            read -p "自動実装を有効にしますか？ (y/N): " enable_implement
            read -p "自動レビューを有効にしますか？ (y/N): " enable_review
            read -p "ISSUE改善を有効にしますか？ (y/N): " enable_improve
            read -p "最大ISSUE作成数 (デフォルト: 5): " max_issues
            read -p "最大実装数 (デフォルト: 3): " max_impl
            
            max_issues=${max_issues:-5}
            max_impl=${max_impl:-3}
            
            automation_args="--max-issues $max_issues --max-impl $max_impl"
            
            if [[ $enable_implement =~ ^[Yy]$ ]]; then
                automation_args="$automation_args --auto-implement"
            else
                automation_args="$automation_args --no-auto-implement"
            fi
            
            if [[ $enable_review =~ ^[Yy]$ ]]; then
                automation_args="$automation_args --auto-review"
            else
                automation_args="$automation_args --no-auto-review"
            fi
            
            if [[ $enable_improve =~ ^[Yy]$ ]]; then
                automation_args="$automation_args --improve-issues"
            else
                automation_args="$automation_args --no-improve-issues"
            fi
            ;;
        *)
            echo "ERROR: 無効な選択です"
            return 1
            ;;
    esac
    
    # cron式の生成
    local cron_expression
    case $frequency_choice in
        1)
            cron_expression="0 $hour * * *"
            ;;
        2)
            cron_expression="0 $hour * * 1"
            ;;
        3)
            cron_expression="0 $hour * * 1-5"
            ;;
        4)
            cron_expression="0 $hour * * 2,5"
            ;;
        5)
            read -p "cron式を入力してください (例: 0 9 * * 1): " cron_expression
            ;;
        *)
            echo "ERROR: 無効な選択です"
            return 1
            ;;
    esac
    
    # 最終的なcronエントリの生成
    local cron_entry="$cron_expression $MAIN_SCRIPT --path $project_path $automation_args >> $CRON_LOG 2>&1"
    
    echo ""
    echo "生成されたcronエントリ:"
    echo "$cron_entry"
    echo ""
    
    read -p "このcronエントリを追加しますか？ (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # 現在のcrontabを取得
        local current_crontab
        current_crontab=$(crontab -l 2>/dev/null || echo "")
        
        # 新しいエントリを追加
        {
            echo "$current_crontab"
            echo "# Claude Code 統合開発自動化 - $(date)"
            echo "$cron_entry"
        } | crontab -
        
        echo "cronエントリが追加されました。"
        echo "ログファイル: $CRON_LOG"
    else
        echo "cronエントリの追加をキャンセルしました。"
    fi
}

# ログローテーション設定
setup_log_rotation() {
    echo "ログローテーション設定を作成します..."
    
    local logrotate_config="/etc/logrotate.d/claude-dev-automation"
    
    cat << EOF
以下の内容でログローテーション設定ファイルを作成してください:
ファイル: $logrotate_config

$CRON_LOG {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $(whoami) $(whoami)
    copytruncate
}

# 一時ファイルもクリーンアップ
/tmp/claude_*.txt {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 $(whoami) $(whoami)
}

作成コマンド例:
sudo tee $logrotate_config << 'EOL'
$CRON_LOG {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $(whoami) $(whoami)
    copytruncate
}

/tmp/claude_*.txt {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 $(whoami) $(whoami)
}
EOL
EOF
}

# システムチェック
system_check() {
    echo "システム環境をチェックしています..."
    echo ""
    
    # cron サービスの確認
    if systemctl is-active --quiet cron 2>/dev/null || systemctl is-active --quiet crond 2>/dev/null; then
        echo "✓ cronサービスが動作中です"
    else
        echo "✗ cronサービスが動作していません"
        echo "  systemctl start cron (または crond) で開始してください"
    fi
    
    # メインスクリプトの確認
    if [ -f "$MAIN_SCRIPT" ] && [ -x "$MAIN_SCRIPT" ]; then
        echo "✓ メインスクリプトが実行可能です: $MAIN_SCRIPT"
    else
        echo "✗ メインスクリプトが見つからないか実行可能ではありません: $MAIN_SCRIPT"
        echo "  chmod +x $MAIN_SCRIPT で実行権限を付与してください"
    fi
    
    # 必要なツールの確認
    local tools=("claude" "gh" "git" "jq")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "✓ $tool が利用可能です"
        else
            echo "✗ $tool が見つかりません"
        fi
    done
    
    # ログディレクトリの確認
    local log_dir=$(dirname "$CRON_LOG")
    if [ -w "$log_dir" ]; then
        echo "✓ ログディレクトリに書き込み権限があります: $log_dir"
    else
        echo "✗ ログディレクトリに書き込み権限がありません: $log_dir"
        echo "  sudo touch $CRON_LOG && sudo chown $(whoami) $CRON_LOG で権限を設定してください"
    fi
    
    # GitHub認証の確認
    if gh auth status &> /dev/null; then
        echo "✓ GitHub認証が完了しています"
    else
        echo "✗ GitHub認証が必要です"
        echo "  gh auth login で認証してください"
    fi
    
    # 一時ディレクトリの確認
    if [ -w "/tmp" ]; then
        echo "✓ 一時ディレクトリが利用可能です"
    else
        echo "✗ 一時ディレクトリに書き込み権限がありません"
    fi
    
    echo ""
}

# 現在のcron設定表示
show_current_cron() {
    echo "現在のcron設定:"
    echo ""
    
    local current_crontab
    current_crontab=$(crontab -l 2>/dev/null)
    
    if [ -n "$current_crontab" ]; then
        echo "$current_crontab" | grep -E "(claude|Claude)" || echo "Claude関連のcronエントリはありません"
    else
        echo "cronエントリが設定されていません"
    fi
    
    echo ""
}

# パフォーマンス監視設定
setup_monitoring() {
    echo "パフォーマンス監視設定..."
    echo ""
    
    cat << EOF
以下の監視設定を推奨します:

1. ログ監視アラート:
   tail -f $CRON_LOG | grep -E "(ERROR|FAILED)" --line-buffered | while read line; do
       echo "ALERT: \$line" | mail -s "Claude Automation Error" admin@example.com
   done

2. ディスク容量監視:
   df -h \$(dirname $CRON_LOG) | awk 'NR==2 {if(\$5+0 > 80) print "WARNING: Log directory is " \$5 " full"}'

3. プロセス監視:
   ps aux | grep -E "(claude|gh)" | grep -v grep

4. 実行統計:
   grep "SUCCESS" $CRON_LOG | tail -100 | wc -l  # 成功回数
   grep "ERROR" $CRON_LOG | tail -100 | wc -l    # エラー回数
EOF
}

# メイン処理
main() {
    echo "=== Claude Code 統合開発自動化 - cron設定 ==="
    echo ""
    
    case "${1:-menu}" in
        "examples")
            setup_cron_jobs
            ;;
        "interactive")
            interactive_cron_setup
            ;;
        "logrotate")
            setup_log_rotation
            ;;
        "check")
            system_check
            ;;
        "current")
            show_current_cron
            ;;
        "monitoring")
            setup_monitoring
            ;;
        "menu"|*)
            echo "利用可能なコマンド:"
            echo "  examples     - cron設定例を表示"
            echo "  interactive  - 対話的cron設定"
            echo "  logrotate    - ログローテーション設定"
            echo "  check        - システム環境チェック"
            echo "  current      - 現在のcron設定表示"
            echo "  monitoring   - 監視設定のヘルプ"
            echo ""
            echo "使用例:"
            echo "  $0 examples"
            echo "  $0 interactive"
            echo "  $0 check"
            echo "  $0 current"
            ;;
    esac
}

main "$@"