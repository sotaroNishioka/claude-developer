#!/bin/bash

# =============================================================================
# 1時間ごとISSUE作成・実装フロー - Cron設定
# =============================================================================

echo "=== 1時間サイクル自動化 - Crontab設定 ==="
echo ""
echo "以下をcrontabに追加してください (crontab -e で編集):"
echo ""

# スクリプトのパスを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/automation.sh"

echo "# === 1時間タイムライン（常時実行） ==="
echo ""

echo "# :00 - プロジェクト監視"
echo "0 * * * * $SCRIPT_DIR/index.sh monitor"
echo ""

echo "# :05 - 新規ISSUEを分析・準備"
echo "5 * * * * $SCRIPT_DIR/index.sh issue_processor"
echo ""

echo "# :10 - requestタグISSUEの詳細化"
echo "10 * * * * $SCRIPT_DIR/index.sh issue_processor"
echo ""

echo "# :15 - 1回目の実装処理（メイン）"
echo "15 * * * * $SCRIPT_DIR/index.sh implementer"
echo ""

echo "# :20 - 2回目の実装処理（追加）"
echo "20 * * * * $SCRIPT_DIR/index.sh implementer"
echo ""

echo "# :30 - PRレビュー実行"
echo "30 * * * * $SCRIPT_DIR/index.sh pr_reviewer"
echo ""

echo "# :30 - CI/CD監視（30分ごと）"
echo "*/30 * * * * $SCRIPT_DIR/index.sh monitor"
echo ""

echo "# :35 - PR修正対応"
echo "35 * * * * $SCRIPT_DIR/index.sh pr_fixer"
echo ""

echo "# :45 - 3回目の実装処理（メイン）"
echo "45 * * * * $SCRIPT_DIR/index.sh implementer"
echo ""

echo "# :50 - 4回目の実装処理（追加）"
echo "50 * * * * $SCRIPT_DIR/index.sh implementer"
echo ""

echo "# 品質監査: 6時間ごと - プロジェクト全体監視"
echo "0 */6 * * * $SCRIPT_DIR/index.sh monitor"
echo ""

echo "# ドキュメント: 毎日深夜2時 - ドキュメント監視"
echo "0 2 * * * $SCRIPT_DIR/index.sh monitor"
echo ""

echo "# ログ管理: 毎日深夜3時 - 古いログファイルの圧縮"
echo "0 3 * * * source $SCRIPT_DIR/.env && find \\\$LOG_DIR -name \"*.log\" -mtime +7 -exec gzip {} \\;"
echo ""

echo "# ログクリーンアップ: 毎週日曜日深夜4時 - 30日以上古いログ削除"
echo "0 4 * * 0 source $SCRIPT_DIR/.env && find \\\$LOG_DIR -name \"*.gz\" -mtime +30 -delete"
echo ""

echo "=== 設定方法 ==="
echo "1. .env.sample を .env にコピーして環境変数を設定"
echo "2. PROJECT_PATH, LOG_DIR などを実際のパスに変更"
echo "3. crontab -e で上記をコピー&ペースト"
echo "4. crontab -l で設定確認"
echo ""
echo "=== .env設定例 ==="
echo "PROJECT_PATH=/path/to/your/project"
echo "LOG_DIR=/path/to/your/project/logs"
echo "PROMPTS_DIR=/path/to/claude-developer/prompts"
echo "ANTHROPIC_API_KEY=your_api_key_here"
echo "ANTHROPIC_MODEL=claude-3-sonnet-20240229"
echo ""
echo "=== 実行スケジュール ==="
echo "毎時間: 00→05→10→15→20→30→35→45→50分の順で自動実行"
echo "implementer: 1時間に4回実行で複数ISSUE並行処理"
echo "CI/CD監視: 30分間隔で適度な頻度"