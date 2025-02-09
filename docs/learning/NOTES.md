<div align="center">

# 📝 実装時の注意点と解説

</div>

## 🔧 1. 環境構築時の注意点

### 🌐 1.1 GCPプロジェクト設定
- 🆔 プロジェクトIDは一意である必要があり、後から変更不可
- 👥 適切なIAM権限が必要
  ```bash
  # 必要な権限
  - Compute Admin
  - Security Admin
  - Service Account User
  ```

### ⚙️ 1.2 Terraform実行環境
- 🔄 バージョン互換性に注意
  ```hcl
  # 推奨バージョン設定
  terraform {
    required_version = ">= 1.0.0"
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = "~> 4.0"
      }
    }
  }
  ```

### 🌐 1.3 ネットワーク設定
- 🛡️ ファイアウォールルールは最小権限の原則に従う
- 🚫 不要なポートは開放しない
- 🔒 送信元IPの制限を検討

## 🚀 2. デプロイメント時のベストプラクティス

### 💻 2.1 インスタンス設定
- 📋 メタデータの活用
  ```hcl
  metadata = {
    startup-script = file("startup.sh")
    shutdown-script = file("shutdown.sh")
  }
  ```

### ⚡ 2.2 スタートアップスクリプト
- ⚠️ エラーハンドリングの実装
  ```bash
  set -e  # エラー時に即座に終了
  set -x  # デバッグ用にコマンドを表示
  ```

- 📝 ログ出力の追加
  ```bash
  exec 1> >(logger -s -t $(basename $0)) 2>&1
  ```

### 📦 2.3 アプリケーションデプロイ
- 📋 依存関係の明確な指定
  ```bash
  pip3 install streamlit==1.24.0  # バージョン固定
  ```

- 🔑 実行権限の確認
  ```bash
  chmod +x /path/to/script.sh
  ```

## 🔍 3. 運用時の注意点

### 📊 3.1 モニタリング
- 📈 重要なメトリクス
  - CPU使用率
  - メモリ使用率
  - ディスク使用率
  - ネットワークトラフィック

### 💾 3.2 バックアップ
- 📸 定期的なスナップショット作成
  ```hcl
  resource "google_compute_snapshot" "snapshot" {
    name        = "snapshot-${formatdate("YYYY-MM-DD", timestamp())}"
    source_disk = google_compute_instance.streamlit.boot_disk[0].source
  }
  ```

### 🔒 3.3 セキュリティ
- 🔄 定期的なセキュリティアップデート
  ```bash
  apt-get update && apt-get upgrade -y
  ```

- 🔑 SSHアクセス制限
  ```hcl
  metadata = {
    ssh-keys = "username:${file("~/.ssh/id_rsa.pub")}"
  }
  ```

## ⚠️ 4. トラブルシューティング

### 🔧 4.1 一般的な問題と解決策
1. 🚫 インスタンス起動失敗
   - 📝 スタートアップスクリプトのログを確認
   - 🔑 IAM権限の確認
   - 📊 クォータ制限の確認

2. ❌ アプリケーションアクセス不可
   - 🛡️ ファイアウォールルールの確認
   - 🔌 ポート開放状況の確認
   - 📝 アプリケーションログの確認

### 🔍 4.2 デバッグ方法
- 📟 シリアルポートの出力確認
  ```bash
  gcloud compute instances get-serial-port-output INSTANCE_NAME
  ```

- 🔑 SSHでのログイン確認
  ```bash
  gcloud compute ssh INSTANCE_NAME
  ```

### 📝 4.3 ログ確認
- 📋 Streamlitログ
  ```bash
  journalctl -u streamlit.service
  ```

- 📊 システムログ
  ```bash
  tail -f /var/log/syslog
  ```

## ⚡ 5. パフォーマンスチューニング

### 💻 5.1 インスタンス最適化
- 💾 ディスクタイプの選択
  ```hcl
  boot_disk {
    initialize_params {
      type = "pd-ssd"  # 高パフォーマンスが必要な場合
    }
  }
  ```

### 🚀 5.2 アプリケーション最適化
- 📦 キャッシュの活用
  ```python
  @st.cache_data
  def load_data():
      return pd.read_csv("data.csv")
  ```

- 📊 メモリ使用量の監視
  ```python
  import psutil
  st.write(f"Memory usage: {psutil.Process().memory_info().rss / 1024 / 1024:.2f} MB")
  ```

## 📈 6. スケーリング考慮事項

### 🔝 6.1 垂直スケーリング
- 💻 インスタンスタイプの変更
  ```hcl
  machine_type = "e2-medium"  # より大きなインスタンスへの変更
  ```

### 🔄 6.2 水平スケーリング
- 📦 インスタンスグループの利用
  ```hcl
  resource "google_compute_instance_group_manager" "streamlit" {
    name = "streamlit-group"
    base_instance_name = "streamlit"
    zone = "asia-northeast1-a"
    target_size = 2
  }
