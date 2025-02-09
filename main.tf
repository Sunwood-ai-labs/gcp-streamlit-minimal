# プロバイダーの設定
provider "google" {
  project = "your-project-id"  # あなたのプロジェクトIDに変更してください
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

# Compute Engineインスタンスの作成
resource "google_compute_instance" "streamlit" {
  name         = "streamlit"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10  # GBサイズ
    }
  }

  network_interface {
    network = "default"
    access_config {
      # 外部IPを自動割り当て
    }
  }

  # メタデータ（スタートアップスクリプト）
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # システムの更新とPython環境のセットアップ
    apt-get update
    apt-get install -y python3-pip

    # Streamlitのインストール
    pip3 install streamlit

    # アプリケーションの作成
    cat <<EOT > /home/app.py
    import streamlit as st

    st.title('GCP Streamlit Minimal')
    st.write('Welcome to the minimal Streamlit application on GCP!')
    
    # サンプル機能
    number = st.slider('Select a number', 0, 100, 50)
    st.write(f'Selected number: {number}')
    EOT

    # Streamlitの起動
    # バックグラウンドで実行し、ログをファイルに出力
    nohup streamlit run /home/app.py \
      --server.port=8501 \
      --server.address=0.0.0.0 \
      > /var/log/streamlit.log 2>&1 &
  EOF

  # 必要に応じてサービスアカウントを設定
  service_account {
    scopes = ["cloud-platform"]
  }

  # タグの設定（ファイアウォールルールで使用）
  tags = ["streamlit-server"]
}

# ファイアウォール設定
resource "google_compute_firewall" "streamlit" {
  name    = "allow-streamlit"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8501"]
  }

  # Streamlitサーバーを持つインスタンスにのみ適用
  target_tags = ["streamlit-server"]
  
  # 任意のIPからのアクセスを許可
  source_ranges = ["0.0.0.0/0"]
}

# 出力の設定
output "streamlit_url" {
  value = "http://${google_compute_instance.streamlit.network_interface[0].access_config[0].nat_ip}:8501"
}
