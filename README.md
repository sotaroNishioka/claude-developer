# Claude Developer 自動化ツール

プロンプトテンプレートを使って Claude Code を実行するシンプルなツールです。プロンプト内の変数を引数で縛れるため、様々な自動化タスクに活用できます。

## 概要

このツールは、テキストファイルに記述したプロンプトを Claude Code で実行します。プロンプト内の変数を引数で縛れるため、様々な自動化タスクに活用できます。

## セットアップ

```bash
chmod +x automation.sh
```

## 使い方

```bash
./automation.sh <プロンプトファイル> [引数1] [引数2] ...
```

### 例

```bash
# プロジェクト分析とISSUE作成
./automation.sh issue_creator

# カスタムプロンプトを実行
./automation.sh my_prompt.txt

# 複数の引数を渡す
./automation.sh custom.txt param1 param2
```

## プロンプトテンプレート

### デフォルトテンプレート

`prompts/` ディレクトリに以下のテンプレートが含まれています：

- `issue_creator.txt` - プロジェクト分析と ISSUE 作成
- `custom_example.txt` - カスタムプロンプトの例

### 変数の縛り方

プロンプト内で `{{ARG1}}`、`{{ARG2}}` などの変数を使用でき、実行時の引数で縛られます：

```bash
# pr_review.txt 内の {{ARG1}} が 123 に縛られる
./automation.sh pr_review 123
```

### カスタムプロンプトの作成

新しいプロンプトファイルを作成して、任意のタスクを自動化できます：

```bash
echo "プロジェクトのテストを実装してレポートを生成してください" > prompts/run_tests.txt
./automation.sh run_tests
```

## Cron での自動実行

```bash
# cron設定例を表示
./cron_examples.sh

# 例: 毎日朝9時にプロジェクト分析
0 9 * * * cd /path/to/project && ./automation.sh issue_creator >> ./claude_developer.log 2>&1

# 例: 毎時プロンプトを実行
0 * * * * cd /path/to/project && ./automation.sh my_hourly_task >> ./claude_developer.log 2>&1
```

## 環境変数設定

環境変数を使用してスクリプトの動作をカスタマイズできます。

### 設定方法

1. サンプルファイルをコピーして設定ファイルを作成：

```bash
cp .env.sample .env
```

2. `.env` ファイルを編集して値を設定

3. 環境変数を読み込んで実行：

```bash
# 環境変数を読み込んで実行
source .env && ./automation.sh issue_creator

# または一時的に設定して実行
LOG_DIR=/custom/log/path ./automation.sh issue_creator
```

### 利用可能な環境変数

- `PROJECT_PATH` - プロジェクトパス（デフォルト: カレントディレクトリ）
- `LOG_DIR` - ログ出力ディレクトリ（デフォルト: ./logs）
- `PROMPTS_DIR` - プロンプトディレクトリ（デフォルト: ./prompts）
- `ANTHROPIC_API_KEY` - Anthropic APIキー
- `ANTHROPIC_MODEL` - 使用するClaudeモデル

### ログファイル

実行ごとに以下のログファイルが生成されます：

- `{プロンプト名}_{タイムスタンプ}.log` - Claude Codeの実行ログ
- `system_{タイムスタンプ}.log` - システムメッセージログ

例：
```
logs/
├── issue_creator_20240531_143022.log
├── system_20240531_143020.log
└── system_20240531_143025.log
```

## 必要環境

- Claude Code CLI (`claude` コマンド)
- GitHub CLI (`gh` コマンド)
- jq
- git
- bash

## 📋 プロンプトワークフロー図

### 全体ワークフロー

```mermaid
graph TD
    %% 人間からの入力
    HumanRequest[👤 Human Request] --> RequestIssue[📝 Request Issue]
    NewIssue[🆕 New Issue] --> IssueTriager

    %% Issue処理フロー  
    RequestIssue --> IssueImprover[🔧 Issue Improver]
    IssueTriager[🏷️ Issue Triager] --> |status:ready| Implementer[⚡ Implementer]
    IssueImprover --> |status:ready| Implementer
    
    %% 実装・レビューサイクル
    Implementer --> |status:pr-created| PRReviewer[👀 PR Reviewer]
    PRReviewer --> |status:approved| Completed[✅ Completed]
    PRReviewer --> |status:changes-requested| PRResponder[🔄 PR Responder]
    PRResponder --> |status:re-reviewing| PRReviewer
    
    %% CI/CD監視フロー
    CICDFailure[🚨 CI/CD Failure] --> CICDMonitor[📊 CI/CD Monitor]
    CICDMonitor --> |Emergency Issue| IssueTriager
    
    %% 品質・分析支援フロー
    QAStrategist[🧪 QA Strategist] --> |Test Issues| IssueTriager
    CodebaseAnalyzer[🔍 Codebase Analyzer] --> |Improvement Issues| IssueTriager
    DocumentationManager[📚 Documentation Manager] --> |Doc Issues| IssueTriager
    
    %% スタイル設定
    classDef human fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000
    classDef primary fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000
    classDef support fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000
    classDef monitor fill:#ffebee,stroke:#b71c1c,stroke-width:2px,color:#000
    classDef status fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000
    
    class HumanRequest,RequestIssue,NewIssue human
    class IssueTriager,IssueImprover,Implementer,PRReviewer,PRResponder primary
    class QAStrategist,CodebaseAnalyzer,DocumentationManager support
    class CICDMonitor,CICDFailure monitor
    class Completed status
```

### ステータス遷移図

```mermaid
stateDiagram-v2
    [*] --> request : 人間のリクエスト
    request --> analyzing : Issue Improver開始
    analyzing --> ready : 分析完了
    ready --> implementing : Implementer開始
    implementing --> pr_created : PR作成完了
    pr_created --> reviewing : PR Reviewer開始
    reviewing --> approved : レビュー承認
    reviewing --> changes_requested : 修正要求
    changes_requested --> fixing : PR Responder開始
    fixing --> fix_completed : 修正完了
    fix_completed --> re_reviewing : 再レビュー待ち
    re_reviewing --> reviewing : 再レビュー開始
    approved --> completed : マージ完了
    completed --> [*]
    
    note right of changes_requested : [MUST FIX]<br/>[SHOULD FIX]<br/>[CONSIDER]
    note right of re_reviewing : 無限ループ防止<br/>明確な状態分離
```

### Worker排他制御とラベル管理

```mermaid
graph LR
    subgraph "Priority Labels"
        P1[priority:critical]
        P2[priority:high]
        P3[priority:medium]
        P4[priority:low]
    end
    
    subgraph "Type Labels"
        T1[type:bug]
        T2[type:feature]
        T3[type:enhancement]
        T4[type:documentation]
    end
    
    subgraph "Worker Labels"
        W1[worker:issue-triager]
        W2[worker:issue-improver]
        W3[worker:implementer]
        W4[worker:pr-reviewer]
        W5[worker:pr-responder]
        W6[worker:cicd-monitor]
    end
    
    subgraph "Status Labels"
        S1[status:request]
        S2[status:analyzing]
        S3[status:ready]
        S4[status:implementing]
        S5[status:pr-created]
        S6[status:reviewing]
        S7[status:approved]
        S8[status:changes-requested]
        S9[status:fixing]
        S10[status:re-reviewing]
        S11[status:completed]
    end
    
    classDef priority fill:#ffcdd2
    classDef type fill:#c8e6c9
    classDef worker fill:#fff9c4
    classDef status fill:#e1f5fe
    
    class P1,P2,P3,P4 priority
    class T1,T2,T3,T4 type
    class W1,W2,W3,W4,W5,W6 worker
    class S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11 status
```

## 🔧 ワークフロー整合性改善

### プロンプトファイル詳細

| プロンプト | 役割 | 入力条件 | 出力ステータス |
|-----------|-----|----------|---------------|
| **Issue Triager** | 新規ISSUE分析・分類 | ラベル未設定ISSUE | `status:ready` |
| **Issue Improver** | リクエストの詳細化 | `status:request` | `status:ready` |
| **Implementer** | 実装とPR作成 | `status:ready` | `status:pr-created` |
| **PR Reviewer** | PRレビュー実行 | `status:pr-created`<br/>`status:re-reviewing` | `status:approved`<br/>`status:changes-requested` |
| **PR Responder** | レビュー修正対応 | `status:changes-requested` | `status:re-reviewing` |
| **CI/CD Monitor** | CI/CD失敗監視 | ワークフロー失敗検出 | 緊急ISSUE作成 |
| **QA Strategist** | テスト戦略分析 | 独立実行 | テスト改善ISSUE |
| **Codebase Analyzer** | コード品質分析 | 独立実行 | 改善ISSUE作成 |
| **Documentation Manager** | ドキュメント管理 | 独立実行 | ドキュメントISSUE |

### 主要改善点

#### 1. ステータス遷移の明確化
- **新ステータス追加**: `status:re-reviewing` を新設
- **無限ループ防止**: `fix-completed` → `re-reviewing` → `approved/changes-requested`
- **状態分離**: 初回レビューと修正後レビューの明確な区別

#### 2. Worker排他制御の強化
- **並行処理制御**: 同一Issue/PRでの複数Worker同時実行を防止
- **処理中表示**: `worker:*` ラベルによる実行状況の明示
- **適切な解放**: 処理完了時のworkerラベル自動除去

#### 3. CI/CD統合の改善
- **統合フロー**: CI/CD Monitor によるISSUE作成を既存ワークフローに統合
- **統一ラベル**: `priority:critical` + `worker:cicd-monitor` の組み合わせ
- **緊急度統一**: 全プロンプト間での緊急度判定基準統一

### エラーハンドリング強化
- **デッドロック防止**: 異常状態の自動検出と復旧
- **メトリクス収集**: 各ステータスでの滞留時間測定
- **品質保証**: Worker別処理時間とエラー率の監視

これらの改善により、より堅牢で信頼性の高い自動化システムが実現されました。