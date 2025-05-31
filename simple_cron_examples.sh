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
SCRIPT_PATH="$SCRIPT_DIR/simple_automation.sh"

echo "# === 基本的な設定例 ==="
echo ""

echo "# 毎時0分にPRレビューを実行"
echo "0 * * * * cd /your/project/path && $SCRIPT_PATH review >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎時15分にPRレビューを実行"
echo "15 * * * * cd /your/project/path && $SCRIPT_PATH review >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎時30分に特定ISSUEの実装を実行"
echo "30 * * * * cd /your/project/path && $SCRIPT_PATH implement 123 >> ./claude_cron.log 2>&1"
echo ""

echo "# 毎日朝9時にISSUE作成"
echo "0 9 * * * cd /your/project/path && $SCRIPT_PATH issues >> ./claude_cron.log 2>&1"
echo ""

echo "# 平日の10時と15時にレビュー"
echo "0 10,15 * * 1-5 cd /your/project/path && $SCRIPT_PATH review >> ./claude_cron.log 2>&1"
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

echo "# プロジェクトAのレビュー（毎時）"
echo "0 * * * * cd /path/to/projectA && $SCRIPT_PATH review >> ./projectA.log 2>&1"
echo ""

echo "# プロジェクトBの実装（毎時30分）"
echo "30 * * * * cd /path/to/projectB && $SCRIPT_PATH implement \$(cat ./next_issue.txt) >> ./projectB.log 2>&1"
echo ""

echo "# 環境変数を使った設定"
echo "15 * * * * PROJECT_PATH=/path/to/project DRY_RUN=false $SCRIPT_PATH review >> ./claude.log 2>&1"
echo ""

echo "=== 設定のヒント ==="
echo "1. /your/project/path を実際のプロジェクトパスに置き換えてください"
echo "2. ログファイルのパスも適切に設定してください"
echo "3. 最初はDRY_RUN=trueで動作確認することをお勧めします"
echo "4. crontab -l で現在の設定を確認できます"