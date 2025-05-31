#!/bin/bash

# =============================================================================
# シンプルなcron設定例
# =============================================================================

echo "=== Claude Code自動化のcron設定例 ==="
echo ""
echo "以下をcrontabに追加してください (crontab -e で編集):"
echo ""

# スクリプトのパスを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/automation.sh"

echo "# === 基本的な設定例 ==="
echo ""

echo "# 毎日朝9時にプロジェクト分析とISSUE作成"
echo "0 9 * * * cd /your/project/path && $SCRIPT_PATH issue_analysis >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎時15分にカスタムプロンプトを実行"
echo "15 * * * * cd /your/project/path && $SCRIPT_PATH hourly_check >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎時30分に特定のタスクを実行"
echo "30 * * * * cd /your/project/path && $SCRIPT_PATH my_task.txt >> ./claude_cron.log 2>&1"
echo ""

echo "# 平日の10時にPR #123をレビュー"
echo "0 10 * * 1-5 cd /your/project/path && $SCRIPT_PATH pr_review 123 >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎週月曜日の朝にISSUE #456を実装"
echo "0 9 * * 1 cd /your/project/path && $SCRIPT_PATH implementation 456 >> ./claude_cron.log 2>&1"
echo ""

echo "# === 時間指定のパターン ==="
echo ""

echo "# 毎時実行（0分）"
echo "0 * * * *    # 毎時0分"
echo ""

echo "# 毎時実行（15分）"
echo "15 * * * *   # 毎時15分"
echo ""

echo "# 毎時実行（30分）"
echo "30 * * * *   # 毎時30分"
echo ""

echo "# 毎時実行（45分）"
echo "45 * * * *   # 毎時45分"
echo ""

echo "# 30分ごと"
echo "*/30 * * * * # 0分と30分"
echo ""

echo "# 15分ごと"
echo "*/15 * * * * # 0,15,30,45分"
echo ""

echo "# === 実際の使用例 ==="
echo ""

echo "# プロジェクトAの分析（毎日）"
echo "0 9 * * * cd /path/to/projectA && $SCRIPT_PATH issue_analysis >> ./projectA.log 2>&1"
echo ""

echo "# プロジェクトBのカスタムタスク（毎時30分）"
echo "30 * * * * cd /path/to/projectB && $SCRIPT_PATH custom_task.txt param1 >> ./projectB.log 2>&1"
echo ""

echo "# 環境変数を使った設定"
echo "15 * * * * PROJECT_PATH=/path/to/project $SCRIPT_PATH daily_report >> ./claude.log 2>&1"
echo ""

echo "# === 1時間ごとISSUE作成・実装フロー [推奨設定] ==="
echo ""
echo "# 完全自動化: ISSUE作成から実装まで1時間サイクル"
echo ""

echo "# ステップ1: 毎時00分 - プロジェクト分析とISSUE作成"
echo "0 * * * * cd /your/project/path && $SCRIPT_PATH codebase_analyzer >> ./logs/codebase_analyzer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ2: 毎時05分 - 新規ISSUEの分類・優先度設定"
echo "5 * * * * cd /your/project/path && $SCRIPT_PATH issue_triager >> ./logs/issue_triager_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ3: 毎時10分 - requestタグISSUEの詳細化"
echo "10 * * * * cd /your/project/path && $SCRIPT_PATH issue_improver >> ./logs/issue_improver_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ4: 毎時15分・45分 - ready状態ISSUEの実装開始（複数ISSUE対応）"
echo "15,45 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ5: 毎時20分・50分 - 追加実装処理（高負荷時対応）"
echo "20,50 * * * * cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_extra_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ6: 毎時30分 - PRレビューの実行"
echo "30 * * * * cd /your/project/path && $SCRIPT_PATH pr_reviewer >> ./logs/pr_reviewer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# ステップ7: 毎時35分 - レビューフィードバックへの対応"
echo "35 * * * * cd /your/project/path && $SCRIPT_PATH pr_responder >> ./logs/pr_responder_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# CI/CD監視: 30分ごと - CI/CD失敗監視（適度な頻度）"
echo "*/30 * * * * cd /your/project/path && $SCRIPT_PATH cicd_monitor >> ./logs/cicd_monitor_\$(date +%Y%m%d_%H%M).log 2>&1"
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

echo "# === 営業時間限定版（平日9-18時） ==="
echo ""
echo "# 営業時間のみの実行（リソース節約）"
echo "0 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH codebase_analyzer >> ./logs/codebase_analyzer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "5 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH issue_triager >> ./logs/issue_triager_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "10 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH issue_improver >> ./logs/issue_improver_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "15,45 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "20,50 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH implementer >> ./logs/implementer_extra_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "30 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH pr_reviewer >> ./logs/pr_reviewer_\$(date +%Y%m%d_%H%M).log 2>&1"
echo "35 9-18 * * 1-5 cd /your/project/path && $SCRIPT_PATH pr_responder >> ./logs/pr_responder_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# CI/CD監視は30分ごと（24時間継続）"
echo "*/30 * * * * cd /your/project/path && $SCRIPT_PATH cicd_monitor >> ./logs/cicd_monitor_\$(date +%Y%m%d_%H%M).log 2>&1"
echo ""

echo "# === 環境別設定例 ==="
echo ""
echo "# 開発環境（高頻度）"
echo "*/30 * * * * LOG_DIR=/dev/logs ANTHROPIC_MODEL=claude-3-haiku cd /your/project/path && $SCRIPT_PATH issue_triager"
echo ""

echo "# 本番環境（低頻度・高品質）"
echo "0 */2 * * * LOG_DIR=/prod/logs ANTHROPIC_MODEL=claude-3-opus cd /your/project/path && $SCRIPT_PATH implementer"
echo ""

echo "# === 実行タイムライン（1時間の流れ） ==="
echo ""
echo "# :00 - プロジェクト分析でISSUE作成"
echo "# :05 - 新規ISSUEを分類・優先度設定"
echo "# :10 - requestタグISSUEの詳細化"
echo "# :15 - 1回目の実装処理（メイン）"
echo "# :20 - 2回目の実装処理（追加）"
echo "# :30 - PRレビュー実行 + CI/CD監視"
echo "# :35 - レビューフィードバック対応"
echo "# :45 - 3回目の実装処理（メイン）"
echo "# :50 - 4回目の実装処理（追加）"
echo ""

echo "=== 設定のヒント ==="
echo "1. /your/project/path を実際のプロジェクトパスに置き換えてください"
echo "2. ログファイルのパスも適切に設定してください"
echo "3. プロンプトファイル名は prompts/ ディレクトリ内のファイルを指定できます"
echo "4. crontab -l で現在の設定を確認できます"
echo "5. implementerは1時間に4回実行されるため、複数ISSUEの並行処理が可能"
echo "6. CI/CD監視は30分間隔で適度な監視頻度を維持"
echo "7. ログファイルに _extra_ が付くものは追加実装処理用"