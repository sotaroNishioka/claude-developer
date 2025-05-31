# 使用例とサンプル

## 基本的な使用例

### 1. 基本実行

```bash
# 現在のディレクトリで実行
./auto_issue_batch.sh

# 特定のプロジェクトで実行
./auto_issue_batch.sh --path /path/to/your/project

# ドライランで動作確認
./auto_issue_batch.sh --dry-run
```

### 2. 設定ファイルを使用

```bash
# 設定ファイルを作成
cp config.env.template config.env
# config.envを編集

# 設定を読み込んで実行
source config.env && ./auto_issue_batch.sh
```

### 3. cron設定

```bash
# 対話的設定
./cron_setup.sh interactive

# 設定例を表示
./cron_setup.sh examples

# システムチェック
./cron_setup.sh check
```

## 実際のプロジェクトでの活用例

### Web開発プロジェクト

```bash
# React/Node.jsプロジェクトの場合
PROJECT_PATH="/home/user/my-webapp" \
MAX_ISSUES=3 \
./auto_issue_batch.sh --dry-run
```

期待される出力例：
- セキュリティ: 依存関係の脆弱性チェック
- パフォーマンス: バンドルサイズの最適化
- 品質: TypeScript型定義の改善

### API開発プロジェクト

```bash
# REST API プロジェクトの場合
PROJECT_PATH="/home/user/api-server" \
MAX_ISSUES=5 \
./auto_issue_batch.sh
```

期待される出力例：
- セキュリティ: 認証処理の強化
- ドキュメント: OpenAPI仕様の更新
- テスト: エンドポイントのテストカバレッジ向上
- パフォーマンス: データベースクエリの最適化
- 監視: ログ出力の改善

### マイクロサービスプロジェクト

```bash
# 複数サービスを順次処理
for service in auth user payment notification; do
    echo "Processing $service service..."
    ./auto_issue_batch.sh \
        --path "/home/user/microservices/$service" \
        --max-issues 2
    sleep 10  # API rate limit対策
done
```

## cron設定の実例

### 開発チーム向け設定

```bash
# 毎週月曜日の朝9時 - 週次レビュー
0 9 * * 1 /home/user/claude-issue-batch/auto_issue_batch.sh --path /home/user/main-project --max-issues 5 >> /var/log/claude_issue_batch.log 2>&1

# 毎日朝8時 - 日次チェック（軽量）
0 8 * * * /home/user/claude-issue-batch/auto_issue_batch.sh --path /home/user/main-project --max-issues 2 >> /var/log/claude_issue_batch.log 2>&1
```

### 複数プロジェクト管理

```bash
# プロジェクトA（本番環境）- 週2回
0 9 * * 2,5 /home/user/claude-issue-batch/auto_issue_batch.sh --path /home/user/project-a --max-issues 3 >> /var/log/claude_issue_batch.log 2>&1

# プロジェクトB（開発中）- 毎日
0 8 * * * /home/user/claude-issue-batch/auto_issue_batch.sh --path /home/user/project-b --max-issues 2 >> /var/log/claude_issue_batch.log 2>&1

# プロジェクトC（メンテナンス）- 月1回
0 9 1 * * /home/user/claude-issue-batch/auto_issue_batch.sh --path /home/user/project-c --max-issues 10 >> /var/log/claude_issue_batch.log 2>&1
```

## トラブルシューティング例

### Claude Code CLI認証エラー

```bash
# Claude認証状態確認
claude --version

# 再認証が必要な場合
claude config  # 設定画面で認証
```

### GitHub CLI認証エラー

```bash
# GitHub認証状態確認
gh auth status

# 再認証
gh auth login --web
```

### 権限エラー

```bash
# スクリプト実行権限
chmod +x auto_issue_batch.sh cron_setup.sh

# ログファイル権限
sudo touch /var/log/claude_issue_batch.log
sudo chown $(whoami) /var/log/claude_issue_batch.log
```

### JSON解析エラー

```bash
# jqのインストール確認
jq --version

# macOS
brew install jq

# Ubuntu/Debian
sudo apt update && sudo apt install jq
```

## カスタマイズ例

### プロジェクト固有のプロンプト

`auto_issue_batch.sh`の`analyze_and_generate_issues()`関数を編集：

```bash
# 例：セキュリティ重視のプロンプト
local prompt="このプロジェクトはFinTechアプリケーションです。
特にセキュリティと規制遵守の観点で分析し、以下の形式で..."
```

### 独自ラベルシステム

`create_github_issue()`関数で独自ラベルを追加：

```bash
# 例：重要度とカテゴリの組み合わせ
label_args="$label_args --label \"severity:$priority\" --label \"category:$type\" --label \"auto-generated\""
```

### Slack通知の追加

スクリプトに通知機能を追加：

```bash
# Slack通知関数
send_slack_notification() {
    local message="$1"
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK_URL"
    fi
}
```

これらの例を参考に、プロジェクトの要件に合わせてカスタマイズしてください。