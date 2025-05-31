#!/bin/bash

# =============================================================================
# Claude Code 自動ISSUE作成 - cron設定スクリプト
# =============================================================================

# 設定値
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/auto_issue_batch.sh"
CRON_LOG="/var/log/claude_issue_batch_cron.log"

# cron設定例
setup_cron_jobs() {
    echo "cron設定例を表示します..."
    echo ""
    echo "=== 推奨cron設定 ==="
    echo ""
    
    echo "# 毎週月曜日の朝9時に実行（週次レビュー）"
    echo "0 9 * * 1 $MAIN_SCRIPT --path /path/to/your/project >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 毎日朝8時に実行（日次チェック、最大2つのISSUE）"
    echo "0 8 * * * $MAIN_SCRIPT --path /path/to/your/project --max-issues 2 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 毎月1日に実行（月次レビュー）"
    echo "0 9 1 * * $MAIN_SCRIPT --path /path/to/your/project --max-issues 10 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "# 平日の業務時間後（18時）に実行"
    echo "0 18 * * 1-5 $MAIN_SCRIPT --path /path/to/your/project --max-issues 3 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== 複数プロジェクト対応例 ==="
    echo ""
    echo "# プロジェクトA - 毎週火曜日"
    echo "0 9 * * 2 $MAIN_SCRIPT --path /path/to/projectA --max-issues 5 >> $CRON_LOG 2>&1"
    echo ""
    echo "# プロジェクトB - 毎週木曜日"
    echo "0 9 * * 4 $MAIN_SCRIPT --path /path/to/projectB --max-issues 3 >> $CRON_LOG 2>&1"
    echo ""
    
    echo "=== 環境変数を使った設定例 ==="
    echo ""
    echo "# 環境変数ファイルを読み込み"
    echo "0 9 * * 1 cd /path/to/project && source .env && $MAIN_SCRIPT >> $CRON_LOG 2>&1"
    echo ""
}

# 対話的cron設定
interactive_cron_setup() {
    echo "対話的cron設定を開始します..."
    echo ""
    
    # プロジェクトパスの入力
    read -p "プロジェクトのパスを入力してください: " project_path
    if [ ! -d "$project_path" ]; then
        echo "ERROR: 指定されたパスが存在しません: $project_path"
        return 1
    fi
    
    # 実行頻度の選択
    echo ""
    echo "実行頻度を選択してください:"
    echo "1) 毎日"
    echo "2) 毎週（月曜日）"
    echo "3) 毎月（1日）"
    echo "4) 平日のみ"
    echo "5) カスタム"
    
    read -p "選択してください (1-5): " frequency_choice
    
    # 実行時刻の入力
    read -p "実行時刻を入力してください (例: 9 = 9時): " hour
    if ! [[ "$hour" =~ ^[0-9]+$ ]] || [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        echo "ERROR: 有効な時刻を入力してください (0-23)"
        return 1
    fi
    
    # 最大ISSUE数の入力
    read -p "最大ISSUE作成数を入力してください (デフォルト: 5): " max_issues
    max_issues=${max_issues:-5}
    
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
            cron_expression="0 $hour 1 * *"
            ;;
        4)
            cron_expression="0 $hour * * 1-5"
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
    local cron_entry="$cron_expression $MAIN_SCRIPT --path $project_path --max-issues $max_issues >> $CRON_LOG 2>&1"
    
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
            echo "# Claude Code 自動ISSUE作成 - $(date)"
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
    
    local logrotate_config="/etc/logrotate.d/claude-issue-batch"
    
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
    
    # ログディレクトリの確認
    local log_dir=$(dirname "$CRON_LOG")
    if [ -w "$log_dir" ]; then
        echo "✓ ログディレクトリに書き込み権限があります: $log_dir"
    else
        echo "✗ ログディレクトリに書き込み権限がありません: $log_dir"
        echo "  sudo touch $CRON_LOG && sudo chown $(whoami) $CRON_LOG で権限を設定してください"
    fi
    
    echo ""
}

# メイン処理
main() {
    echo "=== Claude Code 自動ISSUE作成 - cron設定 ==="
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
        "menu"|*)
            echo "利用可能なコマンド:"
            echo "  examples     - cron設定例を表示"
            echo "  interactive  - 対話的cron設定"
            echo "  logrotate    - ログローテーション設定"
            echo "  check        - システム環境チェック"
            echo ""
            echo "使用例:"
            echo "  $0 examples"
            echo "  $0 interactive"
            echo "  $0 check"
            ;;
    esac
}

main "$@"