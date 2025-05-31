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

echo "=== 設定のヒント ==="
echo "1. /your/project/path を実際のプロジェクトパスに置き換えてください"
echo "2. ログファイルのパスも適切に設定してください"
echo "3. プロンプトファイル名は prompts/ ディレクトリ内のファイルを指定できます"
echo "4. crontab -l で現在の設定を確認できます"