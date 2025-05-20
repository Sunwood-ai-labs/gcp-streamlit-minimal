<div align="center">

# ☁️ GCP Streamlit Minimal (Terraform版)

</div>

このプロジェクトは、Google Compute Engine (GCE) インスタンス上に最小構成のStreamlitアプリケーションをデプロイするためのTerraform設定を提供します。シンプルで安全、かつモジュール化された出発点となるように設計されています。

## 📋 概要

-   🖥️ **コンピューティングインスタンス:** デフォルトで`e2-micro` GCEインスタンスをデプロイします。
-   🐧 **オペレーティングシステム:** Debian 11ベースイメージを使用します。
-    streamlit **アプリケーション:** タイトルとスライダーを表示する基本的なStreamlitアプリケーションをセットアップします。
-   🌐 **ネットワーキング:**
    -   Streamlitアプリケーションをポート8501（設定可能）で公開します。
    -   StreamlitおよびSSHへのアクセスを許可するファイアウォールルールを設定します。
    -   **重要なセキュリティノート:** Streamlitファイアウォールルールは、初期状態ではプレースホルダーIPに制限されています。実際のIPアドレスに更新する**必要があります**。
-   🧱 **モジュール性:** GCEインスタンスの設定にはローカルTerraformモジュールを使用します。

## 📂 プロジェクト構成

```
.
├── main.tf                 # ルート設定: プロバイダ、モジュール呼び出し、ファイアウォールルール
├── variables.tf            # ルート変数: project_id, リージョン, インスタンス設定など
├── outputs.tf              # ルート出力: streamlit_url, instance_ip
├── README.md               # このファイル
└── modules/
    └── gce_instance/
        ├── main.tf         # モジュール: GCEインスタンスリソース定義
        ├── variables.tf    # モジュール: GCEインスタンスの入力変数
        └── outputs.tf      # モジュール: GCEインスタンスからの出力 (ID, 名前, ネットワーク詳細)
```

## 🏢 アーキテクチャ図

```mermaid
graph TD
    User["ユーザー"] --> Internet["インターネット"]

    subgraph GCP_Cloud["Google Cloud (GCP)"]
        direction LR
        Internet_GCP_Entry[/"インターネットからの入口"/]
        
        subgraph VPC["VPCネットワーク"]
            direction TB
            FW["ファイアウォールルール"]
            GCE["Compute Engineインスタンス"]
            App["Streamlitアプリケーション"]

            GCE -- "hosts" --> App
        end

        Internet_GCP_Entry -- "HTTP/S (Streamlit Port: 8501)" --> FW
        Internet_GCP_Entry -- "SSH (Port: 22)" --> FW
        FW -- "Streamlit (TCP:var.streamlit_port)" --> GCE
        FW -- "SSH (TCP:22)" --> GCE
    end

    Internet --> Internet_GCP_Entry

    classDef gcpBoundary fill:#f0f0f0,stroke:#333,stroke-width:2px;
    classDef vpcBoundary fill:#e6f7ff,stroke:#007bff,stroke-width:2px;
    class GCP_Cloud gcpBoundary;
    class VPC vpcBoundary;
    class User fill:#c9daf8,stroke:#6783b5;
    class Internet fill:#d9ead3,stroke:#8fbc8f;
    class FW fill:#fce5cd,stroke:#f5ab6f;
    class GCE fill:#fff2cc,stroke:#ffd966;
    class App fill:#d9d2e9,stroke:#8e7cc3;
```

## 🛠️ 前提条件

1.  **Google Cloud Platform (GCP) アカウント:** アクティブなプロジェクトを持つGCPアカウントが必要です。
2.  **課金の有効化:** GCPプロジェクトで課金が有効になっていることを確認してください。
3.  **APIの有効化:** GCPプロジェクトで以下のAPIが有効になっている必要があります:
    *   Compute Engine API
    *   Cloud Resource Manager API (通常はデフォルトで有効)
    GCPコンソールまたは`gcloud services enable compute.googleapis.com cloudresourcemanager.googleapis.com`で有効にできます。
4.  **Terraformのインストール:** [terraform.io](https://www.terraform.io/downloads.html) からTerraformをダウンロードしてインストールします。
5.  **Google Cloud SDK (`gcloud`) の設定:** `gcloud` CLIをインストールして設定します。以下を実行してGCPで認証します:
    ```bash
    gcloud auth application-default login
    ```
    これにより、TerraformがGCPアカウントに対して認証できるようになります。

## ⚙️ 設定

1.  **リポジトリのクローン (該当する場合):**
    ```bash
    # git clone <repository_url>
    # cd <repository_directory>
    ```

2.  **プロジェクトID:**
    `variables.tf`を開き、`project_id`のデフォルト値を更新します:
    ```terraform
    variable "project_id" {
      description = "The ID of the GCP project."
      type        = string
      default     = "your-project-id" # <-- ここを変更
    }
    ```
    または、`terraform.tfvars`ファイルを作成し（`.gitignore`に`*.tfvars`を追加すればデフォルトでgit管理外になります）、そこにプロジェクトIDを設定します:
    ```terraform
    # terraform.tfvars
    project_id = "your-actual-project-id"
    ```
    あるいは、適用時に指定します (機密性の高い値には非推奨):
    ```bash
    terraform apply -var="project_id=your-actual-project-id"
    ```

3.  **重要なセキュリティ: Streamlit用ファイアウォールルールの更新:**
    `main.tf`を開きます。`allow-streamlit`という名前の`google_compute_firewall`リソースを見つけます。Streamlitアプリケーションにアクセスできるのが自分だけになるように、`source_ranges`をプレースホルダーから実際のIPアドレス/範囲に変更する**必要があります**。
    ```terraform
    resource "google_compute_firewall" "streamlit" {
      # ... 他の設定 ...
      
      # 重要: セキュリティのため、これをあなたのIPアドレスに制限してください。
      # TODO: YOUR_IP_ADDRESS/32 を実際のIPアドレスまたは特定の範囲に置き換えてください。
      source_ranges = ["YOUR_IP_ADDRESS/32"] # <-- ここを変更 (例: ["1.2.3.4/32"])
    }
    ```
    自分のパブリックIPアドレスを見つけるには、Googleで「what is my IP」と検索してください。

4.  **その他の変数:**
    `variables.tf`を確認し、カスタマイズしたい可能性のある他の設定を確認します:
    *   `region`, `zone`
    *   `instance_name`, `machine_type`
    *   `image`, `disk_size`
    *   `streamlit_port`, `ssh_port`

5.  **カスタムサービスアカウント (オプション、セキュリティ強化のため推奨):**
    GCEインスタンスモジュールは、カスタムサービスアカウントを使用する準備ができています。
    *   GCPで最小限の必要な権限を持つ専用のサービスアカウントを作成します。
    *   `main.tf`の`module "gce_instance"`ブロック内で、`service_account_email`パラメータのコメントを解除して設定します:
        ```terraform
        module "gce_instance" {
          source = "./modules/gce_instance"
          # ... 他のパラメータ ...
          # セキュリティ強化のため、最小限の権限を持つ専用のサービスアカウントを作成し、
          # このモジュールブロックの 'service_account_email' 変数経由でそのメールアドレスを提供することを検討してください。
          # 例: service_account_email = "your-custom-sa@your-project-id.iam.gserviceaccount.com"
          # service_account_email = "your-custom-sa@your-project-id.iam.gserviceaccount.com"
        }
        ```
    `service_account_email`が提供されないか`null`に設定されている場合、インスタンスは`cloud-platform`スコープを持つデフォルトのCompute Engineサービスアカウントを使用します。

## 🚀 デプロイ

1.  **Terraformの初期化:**
    ターミナルでプロジェクトのルートディレクトリに移動し、以下を実行します:
    ```bash
    terraform init
    ```
    このコマンドは作業ディレクトリを初期化し、必要なプロバイダプラグインをダウンロードします。

2.  **デプロイ計画の作成:**
    (オプションですが推奨) Terraformが作成/変更するリソースを確認します:
    ```bash
    terraform plan
    ```

3.  **設定の適用:**
    リソースをデプロイします:
    ```bash
    terraform apply
    ```
    デプロイを確認するプロンプトが表示されたら`yes`と入力します。

## 🌐 アプリケーションへのアクセス

`terraform apply`が完了すると、TerraformはStreamlitアプリケーションのURLを出力します:

1.  **Streamlit URLの取得:**
    ```bash
    terraform output streamlit_url
    ```
    `http://<EXTERNAL_IP_ADDRESS>:8501` のような形式になります。

2.  **ブラウザで開く:**
    このURLをコピーしてウェブブラウザに貼り付けます。アクセスは設定したファイアウォールルールによって制限されていることを忘れないでください。

## 💻 SSHアクセス

GCEインスタンスへのSSHアクセスが可能です。詳細な手順（SSHキーの生成、GCPへの公開鍵の追加、各種SSHクライアントの利用方法を含む）については、[SSH接続ガイド (SSH_GUIDE.md)](./SSH_GUIDE.md) を参照してください。

## 🧹 クリーンアップ

このTerraform設定によって作成されたすべてのリソースを削除するには:

1.  **リソースの破棄:**
    ```bash
    terraform destroy
    ```
    削除を確認するプロンプトが表示されたら`yes`と入力します。

## 🧱 モジュール

### `gce_instance`

このローカルモジュール (`./modules/gce_instance`) は、Google Compute Engineインスタンスの作成と設定を担当します。様々な入力（インスタンス名、マシンタイプ、イメージ、起動スクリプトなど）を受け取り、作成されたインスタンスに関する詳細を出力します。このモジュラーアプローチはコードの整理に役立ち、必要に応じてGCEインスタンス設定を再利用可能にします。

## 📜 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。`LICENSE`ファイル（存在する場合）を参照するか、存在しない場合はMITとみなしてください。
```
