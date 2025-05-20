<div align="center">

# ☁️ GCP Streamlit Minimal

</div>

GCP Compute EngineでStreamlitアプリケーションを最小構成で実行するためのTerraform設定

## 📋 概要

- 🖥️ GCP e2-microインスタンスを使用
- 🐧 Debian 11ベースイメージ
- 📱 Streamlit最小構成アプリケーション
- 🌐 標準ポート(8501)でのデプロイ

## 🛠️ 前提条件

- 🔑 Google Cloud Platformアカウント
- 💰 プロジェクトの作成と課金の有効化
- ✅ 必要なAPIの有効化:
  - Compute Engine API
  - Cloud Resource Manager API

## 🚀 セットアップ

1. terraformの初期化
```bash
terraform init
```

2. プロジェクトIDの設定
```bash
# main.tfのproject値を変更
provider "google" {
  project = "your-project-id"  # あなたのプロジェクトIDに変更
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}
```

3. インフラストラクチャのデプロイ
```bash
terraform apply
```

## 📝 使用方法

デプロイ完了後、出力されるURLにアクセス:
```
streamlit_url = http://<external-ip>:8501
```

## 🗑️ リソースの削除

```bash
terraform destroy
```

## 📜 ライセンス

MITライセンス

## 📚 詳細情報

詳細な説明やチュートリアルは `/docs/learning/` ディレクトリを参照してください:

- 📖 `LEARNING.md`: 実装の詳細な解説
- 🎓 `CONCEPTS.md`: 使用技術の概念説明
- ✏️ `EXERCISES.md`: 練習課題
- 📌 `NOTES.md`: 実装時の注意点
