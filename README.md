# Claude Code 統合開発自動化システム

Claude Code CLIを使ってソフトウェア開発プロセス全体を自動化する包括的なシステムです。

## 🚀 主要機能

### 📋 ISSUE管理
- **既存ISSUE改善**: 不明確なISSUEの詳細化・構造化
- **新規ISSUE作成**: プロジェクト分析による課題の自動特定
- **ISSUE分類**: 優先度・タイプ・複雑度の自動ラベリング

### 💻 自動実装
- **ISSUE自動実装**: 単純なISSUEのコード自動生成
- **ブランチ管理**: 実装用ブランチの自動作成・管理
- **プルリクエスト作成**: 実装完了時の自動PR作成

### 🔍 コードレビュー
- **PR自動レビュー**: セキュリティ・品質・パフォーマンス観点での分析
- **レビューコメント**: 具体的な改善提案の自動生成
- **承認/変更要求**: 問題の重要度に応じた自動判定

### 🔧 CI/CD監視
- **ワークフロー監視**: GitHub Actions失敗の自動検出
- **障害ISSUE作成**: CI/CD問題の自動起票・追跡

## 📦 前提条件

### 必要なツール

```bash
# Claude Code CLI
# インストール方法: https://docs.anthropic.com/claude-code/setup

# GitHub CLI
brew install gh              # macOS
sudo apt install gh          # Ubuntu/Debian
gh auth login

# jq (JSON処理)
brew install jq              # macOS  
sudo apt install jq          # Ubuntu/Debian

# Git
git --version                # 通常プリインストール済み
```

### 権限要件
- GitHub リポジトリへの書き込み権限
- GitHub Actions の実行権限
- Claude Code CLIの認証完了

## 🛠 セットアップ

### 1. リポジトリクローン

```bash
git clone https://github.com/sotaroNishioka/claude-developer.git
cd claude-developer
chmod +x *.sh
```

### 2. 設定ファイル作成

```bash
# 設定テンプレートをコピー
cp config.env.template config.env

# プロジェクト固有の設定を編集
nano config.env
```

主要な設定項目：
```bash
PROJECT_PATH="/path/to/your/project"
AUTO_IMPLEMENT=true
AUTO_REVIEW=true
AUTO_IMPROVE_ISSUES=true
MAX_ISSUES=5
MAX_IMPLEMENTATIONS=3
```

### 3. 動作確認

```bash
# ドライランで動作確認
./claude_dev_automation.sh --dry-run --path /path/to/your/project

# システム環境チェック
./cron_setup.sh check
```

## 💡 使用方法

### 基本実行

```bash
# 現在のディレクトリで全機能実行
./claude_dev_automation.sh

# 特定のプロジェクトで実行
./claude_dev_automation.sh --path /path/to/project

# フル自動化モード
./claude_dev_automation.sh --auto-implement --auto-review --improve-issues
```

### 機能別実行

```bash
# ISSUE改善とレビューのみ
./claude_dev_automation.sh --no-auto-implement --auto-review --improve-issues

# 実装のみ（レビューなし）
./claude_dev_automation.sh --auto-implement --no-auto-review --no-improve-issues

# レビューのみ（軽量モード）
./claude_dev_automation.sh --no-auto-implement --auto-review --no-improve-issues

# ISSUE分析のみ
./claude_dev_automation.sh --no-auto-implement --no-auto-review --improve-issues
```

### 設定ファイル使用

```bash
# 設定ファイル読み込み実行
source config.env && ./claude_dev_automation.sh

# 環境変数で一時的に設定変更
AUTO_IMPLEMENT=false MAX_ISSUES=10 ./claude_dev_automation.sh
```

## ⚙️ 設定オプション

### コマンドラインオプション

| オプション | 説明 | 例 |
|-----------|------|-----|
| `--help` | ヘルプ表示 | `--help` |
| `--dry-run` | 実行シミュレーション | `--dry-run` |
| `--path PATH` | プロジェクトパス指定 | `--path /home/user/project` |
| `--max-issues N` | 最大ISSUE作成数 | `--max-issues 10` |
| `--max-impl N` | 最大実装数 | `--max-impl 5` |
| `--auto-implement` | 自動実装有効化 | `--auto-implement` |
| `--auto-review` | 自動レビュー有効化 | `--auto-review` |
| `--improve-issues` | ISSUE改善有効化 | `--improve-issues` |

### 環境変数

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `PROJECT_PATH` | プロジェクトディレクトリ | `$(pwd)` |
| `AUTO_IMPLEMENT` | 自動実装フラグ | `false` |
| `AUTO_REVIEW` | 自動レビューフラグ | `true` |
| `AUTO_IMPROVE_ISSUES` | ISSUE改善フラグ | `true` |
| `MAX_ISSUES` | 最大ISSUE作成数 | `5` |
| `MAX_IMPLEMENTATIONS` | 最大実装数 | `3` |
| `BRANCH_PREFIX` | ブランチ名プレフィックス | `claude-auto` |

## 🕐 定期実行設定

### cron設定

```bash
# 対話的設定
./cron_setup.sh interactive

# 設定例表示
./cron_setup.sh examples

# 現在の設定確認
./cron_setup.sh current
```

### 推奨スケジュール

#### 小規模チーム
```bash
# 毎週月曜日 9:00 - フル自動化
0 9 * * 1 /path/to/claude_dev_automation.sh --auto-implement --auto-review --improve-issues
```

#### 大規模チーム
```bash
# 毎日 8:00 - ISSUE管理とレビュー
0 8 * * * /path/to/claude_dev_automation.sh --no-auto-implement --auto-review --improve-issues

# 平日 12:00 - 実装
0 12 * * 1-5 /path/to/claude_dev_automation.sh --auto-implement --no-auto-review --no-improve-issues
```

#### アクティブ開発
```bash
# 毎時間 - レビューのみ（開発時間中）
0 9-17 * * 1-5 /path/to/claude_dev_automation.sh --no-auto-implement --auto-review --no-improve-issues
```

## 📊 実行例と出力

### 典型的な実行フロー

```
[2025-05-31 09:00:00] === Claude Code 統合開発自動化開始 ===
[2025-05-31 09:00:01] 前提条件チェック完了
[2025-05-31 09:00:02] === 既存ISSUE改善処理開始 ===
[2025-05-31 09:00:05] ISSUE #42 の改善提案 - タイトル明確化
[2025-05-31 09:00:06] SUCCESS: ISSUE #42 を改善しました
[2025-05-31 09:00:07] === 新規ISSUE作成処理開始 ===
[2025-05-31 09:00:15] 提案されたISSUE数: 3
[2025-05-31 09:00:16] SUCCESS: ISSUE作成完了 - #123: セキュリティ強化
[2025-05-31 09:00:17] SUCCESS: ISSUE作成完了 - #124: パフォーマンス改善
[2025-05-31 09:00:18] === ISSUE自動実装処理開始 ===
[2025-05-31 09:00:20] ISSUE #125 の実装を開始します
[2025-05-31 09:00:45] SUCCESS: PR作成完了 - https://github.com/user/repo/pull/456
[2025-05-31 09:00:46] === PRレビュー処理開始 ===
[2025-05-31 09:00:50] PR #456 のレビューを開始します
[2025-05-31 09:01:20] SUCCESS: PR #456 のレビューを完了しました
[2025-05-31 09:01:21] === ワークフロー監視処理開始 ===
[2025-05-31 09:01:25] ワークフローの失敗は検出されませんでした
[2025-05-31 09:01:26] === Claude Code 統合開発自動化完了 ===
```

### 生成されるISSUE例

**タイトル**: "セキュリティ: API認証の強化が必要"

**内容**:
```markdown
## 概要
現在のAPI認証システムに脆弱性が発見されました。

## 詳細分析
- ファイル: `src/api/auth.js`
- 問題: JWT トークンの検証が不十分
- 影響度: 高（不正アクセスのリスク）

## 推奨解決策
1. JWT署名検証の強化
2. トークン有効期限の適切な設定
3. レート制限の実装
4. 監査ログの追加

## 受入条件
- [ ] JWT検証の単体テスト追加
- [ ] セキュリティスキャン通過
- [ ] ドキュメント更新

---
**自動生成情報:**
- 優先度: high
- タイプ: bug
- 実装複雑度: medium
- 作成日時: 2025-05-31 09:00:16
- 生成者: Claude Code Auto Batch
```

### 自動実装例

**ブランチ**: `claude-auto/issue-125`

**コミットメッセージ**:
```
fix: implement #125 - API入力バリデーション強化

- パラメータサニタイゼーション追加
- スキーマバリデーション実装
- エラーハンドリング改善
- 単体テスト追加

Implemented by Claude Code Auto Batch
- ISSUE: #125
- Branch: claude-auto/issue-125
- Date: 2025-05-31 09:00:45
```

### レビューコメント例

**PR #456 レビュー**:
```markdown
## 全体評価: 承認（軽微な改善提案あり）

### ✅ 良い点
- セキュリティ対策が適切に実装されています
- テストカバレッジが十分です
- コードの可読性が高いです

### 💡 改善提案

**src/api/auth.js:45**
```suggestion
// より明確なエラーメッセージを推奨
throw new Error('Invalid token format');
```

**src/tests/auth.test.js:23**
```suggestion
// エッジケースのテストを追加することを推奨
test('should handle malformed JWT tokens', () => {
  // テストケース実装
});
```

### 📊 分析結果
- セキュリティリスク: なし
- パフォーマンス影響: 軽微
- 後方互換性: 維持
```

## 🔧 トラブルシューティング

### よくある問題

#### 1. Claude Code CLI認証エラー
```bash
# 状態確認
claude --version

# 設定確認
claude config

# 再認証（必要に応じて）
# ブラウザで claude.ai にアクセスして認証
```

#### 2. GitHub CLI認証エラー
```bash
# 認証状態確認
gh auth status

# 再認証
gh auth login --web

# トークンの権限確認
gh api user
```

#### 3. 権限エラー
```bash
# スクリプト実行権限
chmod +x claude_dev_automation.sh cron_setup.sh

# ログファイル権限
sudo touch /var/log/claude_dev_automation.log
sudo chown $(whoami) /var/log/claude_dev_automation.log

# 一時ファイル権限
sudo chmod 755 /tmp
```

#### 4. Git操作エラー
```bash
# Git設定確認
git config --global user.name
git config --global user.email

# リモートリポジトリ確認
git remote -v

# ブランチ権限確認
git push --dry-run
```

#### 5. JSON解析エラー
```bash
# jqインストール確認
jq --version

# macOS
brew install jq

# Ubuntu/Debian
sudo apt update && sudo apt install jq
```

### デバッグ手順

#### 1. 詳細ログ有効化
```bash
# デバッグモードで実行
DEBUG_MODE=true VERBOSE_LOGGING=true ./claude_dev_automation.sh --dry-run
```

#### 2. 段階的実行
```bash
# 個別機能テスト
./claude_dev_automation.sh --no-auto-implement --no-auto-review --improve-issues --dry-run
./claude_dev_automation.sh --no-auto-implement --auto-review --no-improve-issues --dry-run
./claude_dev_automation.sh --auto-implement --no-auto-review --no-improve-issues --dry-run
```

#### 3. ログ分析
```bash
# エラーログ確認
grep "ERROR" /var/log/claude_dev_automation.log | tail -20

# 実行統計
grep "SUCCESS" /var/log/claude_dev_automation.log | wc -l
grep "FAILED\|ERROR" /var/log/claude_dev_automation.log | wc -l

# 最新実行ログ
tail -50 /var/log/claude_dev_automation.log
```

## 🎯 カスタマイズ

### プロンプトカスタマイズ

スクリプト内の分析プロンプトを編集してプロジェクト固有の要件に対応：

```bash
# config.env で設定
export CUSTOM_PROMPT_PREFIX="このプロジェクトはFinTechアプリケーションです。特に金融規制とセキュリティを重視してください。"
export FOCUS_AREAS="security,compliance,performance,audit"
```

### 独自ワークフロー追加

```bash
# カスタム関数をconfig.envに追加
custom_pre_process() {
    # 独自の前処理ロジック
    echo "カスタム前処理実行中..."
    # Slack通知、データベース更新など
}

custom_post_process() {
    # 独自の後処理ロジック
    echo "カスタム後処理実行中..."
    # レポート生成、メール送信など
}
```

### 通知システム統合

#### Slack通知
```bash
# config.envに設定
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# 通知関数（スクリプトに追加）
send_slack_notification() {
    local message="$1"
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK_URL"
    fi
}
```

#### Discord通知
```bash
# config.envに設定
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR/WEBHOOK"

# 通知関数
send_discord_notification() {
    local message="$1"
    if [ -n "$DISCORD_WEBHOOK_URL" ]; then
        curl -H "Content-Type: application/json" \
            -d "{\"content\":\"$message\"}" \
            "$DISCORD_WEBHOOK_URL"
    fi
}
```

## 📈 メトリクス・分析

### 実行統計の取得

```bash
# 今日の実行回数
grep "$(date '+%Y-%m-%d')" /var/log/claude_dev_automation.log | grep "開始" | wc -l

# 成功率計算
total=$(grep "開始" /var/log/claude_dev_automation.log | wc -l)
success=$(grep "完了" /var/log/claude_dev_automation.log | wc -l)
echo "成功率: $(($success * 100 / $total))%"

# 機能別統計
grep "ISSUE作成完了" /var/log/claude_dev_automation.log | wc -l  # 作成されたISSUE数
grep "PR作成完了" /var/log/claude_dev_automation.log | wc -l    # 作成されたPR数
grep "レビュー完了" /var/log/claude_dev_automation.log | wc -l   # レビュー数
```

### パフォーマンス監視

```bash
# 実行時間分析
grep -E "(開始|完了)" /var/log/claude_dev_automation.log | tail -20

# リソース使用量監視（実行中）
ps aux | grep claude_dev_automation
top -p $(pgrep -f claude_dev_automation)
```

## 🛡️ セキュリティ考慮事項

### 推奨設定

```bash
# 本番環境用設定
export REQUIRE_MANUAL_APPROVAL=true
export SECURITY_SCAN_BEFORE_MERGE=true
export AUTO_APPROVE_SIMPLE=false
export IMPLEMENTATION_STRATEGY="conservative"
export REVIEW_CRITERIA="strict"
```

### アクセス制御

- GitHub リポジトリのブランチ保護ルール設定
- PR必須レビュー設定
- 自動マージの無効化（重要なブランチ）
- 署名付きコミットの強制（オプション）

### 監査ログ

```bash
# 全操作ログの保存
export VERBOSE_LOGGING=true

# セキュリティイベントの記録
grep -E "(ERROR|SECURITY|FAILED)" /var/log/claude_dev_automation.log > security_audit.log
```

## 📚 追加リソース

### 公式ドキュメント
- [Claude Code CLI Documentation](https://docs.anthropic.com/claude-code/)
- [GitHub CLI Manual](https://cli.github.com/manual/)

### コミュニティ
- [Issues](https://github.com/sotaroNishioka/claude-developer/issues) - バグ報告・機能要求
- [Discussions](https://github.com/sotaroNishioka/claude-developer/discussions) - 質問・アイデア共有

### 関連プロジェクト
- GitHub Actions workflows
- Pre-commit hooks
- Code quality tools

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

## 🤝 貢献

プルリクエスト・イシュー・フィードバックを歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

---

**注意**: このツールは強力な自動化機能を提供しますが、重要なプロダクションコードでは慎重に使用し、適切なレビュープロセスを維持してください。