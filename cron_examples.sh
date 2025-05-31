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

echo "# :00 - プロジェクト分析でISSUE作成"
echo "0 * * * * cd /your/project/path && $SCRIPT_PATH codebase_analyzer >> ./logs/codebase_analyzer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :05 - 新規ISSUEを分類・優先度設定"
echo "5 * * * * cd /your/project/path && $SCRIPT_PATH issue_triager >> ./logs/issue_triager_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :10 - requestタグISSUEの詳細化"
echo "10 * * * * cd /your/project/path && $SCRIPT_PATH issue_improver >> ./logs/issue_improver_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :15 - 1回目の実装処理（メイン）"
echo "15 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :20 - 2回目の実装処理（追加）"
echo "20 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_extra_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :30 - PRレビュー実行"
echo "30 * * * * cd /your/project/path && $SCRIPT_PATH pr_reviewer >> ./logs/pr_reviewer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :30 - CI/CD監視（30分ごと）"
echo "*/30 * * * * cd /your/project/path && $SCRIPT_PATH cicd_monitor >> ./logs/cicd_monitor_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :35 - レビューフィードバック対応"
echo "35 * * * * cd /your/project/path && $SCRIPT_PATH pr_responder >> ./logs/pr_responder_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :45 - 3回目の実装処理（メイン）"
echo "45 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# :50 - 4回目の実装処理（追加）"
echo "50 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_extra_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# 品質監査: 6時間ごと - テスト戦略分析"
echo "0 */6 * * * cd /your/project/path && $SCRIPT_PATH qa_strategist >> ./logs/qa_strategist_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ドキュメント: 毎日深夜2時 - ドキュメント同期確認"
echo "0 2 * * * cd /your/project/path && $SCRIPT_PATH documentation_manager >> ./logs/documentation_manager_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ログ管理: 毎日深夜3時 - 古いログファイルの圧縮"
echo "0 3 * * * cd /your/project/path && find ./logs -name \"*.log\" -mtime +7 -exec gzip {} \;"
echo ""

echo "# ログクリーンアップ: 毎週日曜日深夜4時 - 30日以上古いログ削除"
echo "0 4 * * 0 cd /your/project/path && find ./logs -name \"*.gz\" -mtime +30 -delete"
echo ""

echo "=== 設定方法 ==="
echo "1. /your/project/path を実際のプロジェクトパスに置き換え"
echo "2. crontab -e で上記をコピー&ペースト"
echo "3. crontab -l で設定確認"
echo ""
echo "=== 実行スケジュール ==="
echo "毎時間: 00→05→10→15→20→30→35→45→50分の順で自動実行"
echo "implementer: 1時間に4回実行で複数ISSUE並行処理"
echo "CI/CD監視: 30分間隔で適度な頻度"