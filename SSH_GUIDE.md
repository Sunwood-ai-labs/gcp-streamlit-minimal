## 💻 SSHアクセス

メンテナンスやデバッグのためにCompute EngineインスタンスにSSH接続できます。

1.  **インスタンス詳細の取得:**
    Terraformの出力からインスタンスの外部IPを取得できます:
    ```bash
    terraform output instance_ip
    ```
    インスタンス名とゾーンも必要になります。これらは`variables.tf`（または`.tfvars`ファイル）で定義されています。

2.  **`gcloud`を使用した接続 (推奨):**
    SSH接続する最も簡単な方法は、`gcloud`コマンドラインツールを使用することです。これはSSHキー管理を自動的に処理します:
    ```bash
    gcloud compute ssh <YOUR_INSTANCE_NAME> --project <YOUR_PROJECT_ID> --zone <YOUR_INSTANCE_ZONE>
    ```
    `<YOUR_INSTANCE_NAME>`、`<YOUR_PROJECT_ID>`、`<YOUR_INSTANCE_ZONE>`を実際の値に置き換えてください。例:
    ```bash
    gcloud compute ssh streamlit --project your-project-id --zone asia-northeast1-a
    ```

3.  **標準SSHクライアントを使用した接続:**
    必要であれば、標準のSSHクライアントを使用できます。SSH公開鍵がインスタンスに追加されていることを確認する必要があります（gcloudはこれを自動的に行いますが、インスタンスメタデータ経由でSSHキーを管理することもできます）。
    ```bash
    ssh -i /path/to/your/private_key your_gcp_user@<INSTANCE_EXTERNAL_IP>
    ```
    `/path/to/your/private_key`をSSH秘密鍵へのパスに、`your_gcp_user`をインスタンス上のLinuxユーザー名（多くの場合、`@domain.com`なしのGoogleアカウントユーザー名）に、`<INSTANCE_EXTERNAL_IP>`をIPアドレスに置き換えます。

### 詳細なSSHキー管理 (Manually Managing SSH Keys)

`gcloud compute ssh`コマンドはSSHキーの管理を自動的に行い非常に便利ですが、手動でSSHキーペアを管理し、標準のSSHクライアントで使用することも可能です。以下にその手順を示します。

1.  **SSHキーペアの生成 (Generating SSH Key Pairs):**
    まず、ローカルマシンでSSHキーペア（秘密鍵と公開鍵）を生成します。ターミナルで以下のコマンドを実行します。
    ```bash
    ssh-keygen -t rsa -f ~/.ssh/google_cloud_key -C YOUR_USERNAME
    ```
    *   `-t rsa`: RSAタイプのキーを生成します。`ed25519`なども使用可能です (`ssh-keygen -t ed25519 ...`)。
    *   `-f ~/.ssh/google_cloud_key`: キーファイルのパスと名前を指定します (`~/.ssh/`ディレクトリに`google_cloud_key`という名前で秘密鍵が、`google_cloud_key.pub`という名前で公開鍵が作成されます)。
    *   `-C YOUR_USERNAME`: キーのコメントです。通常はユーザー名やメールアドレスを使用します (例: `user@example.com`)。
    コマンド実行中にパスフレーズの入力を求められます。セキュリティ向上のため設定を推奨しますが、省略することも可能です。

2.  **公開鍵のGCPへの追加 (Adding Public Key to GCP):**
    生成した公開鍵 (`~/.ssh/google_cloud_key.pub`など) の内容をGCPに追加する必要があります。GCPでは、プロジェクト全体または特定のインスタンスに対してSSHキーを登録できます。

    *   **プロジェクト全体のメタデータに追加:**
        GCPコンソールの「Compute Engine」>「メタデータ」>「SSH認証鍵」タブに公開鍵を追加します。ここに追加された公開鍵は、プロジェクト内のすべてのインスタンス（OS Loginが有効になっていない場合、またはOS Loginでプロジェクト全体の鍵が許可されている場合）で利用可能になります。
        *   **推奨ケース:** 複数のインスタンスに同じキーでアクセスしたい場合や、新しいインスタンスにも自動的に適用したい場合。
    *   **特定のインスタンスのメタデータに追加:**
        特定のGCEインスタンスの詳細ページを開き、「編集」をクリックして「セキュリティとアクセス」セクション内の「SSH認証鍵」に公開鍵を追加します。
        *   **推奨ケース:** 特定のインスタンスのみにアクセスを制限したい場合。

    公開鍵ファイルの内容全体（例: `ssh-rsa AAAA... YOUR_USERNAME`）をコピーし、GCPコンソールの適切なフィールドに貼り付けます。

3.  **`gcloud compute ssh`コマンドについて (About `gcloud compute ssh` command):**
    前述の通り、`gcloud compute ssh`コマンドは、多くの場合、ローカルにSSHキーが存在しない場合にキーペアを自動生成し、その公開鍵をGCPプロジェクトのメタデータ（またはOS Loginプロファイル）に登録し、SSH接続までをシームレスに行います。このため、通常は手動でのキー管理は不要です。手動でのキー管理は、この自動処理を理解したい場合、特定の既存キーペアを使用したい場合、または`gcloud`ツールが利用できない環境で作業する場合に役立ちます。

4.  **標準SSHクライアントの使用 (Using a Standard SSH Client):**
    公開鍵をGCPに登録し、インスタンスが起動したら、指定した秘密鍵を使って標準のSSHクライアントで接続できます。
    ```bash
    ssh -i ~/.ssh/google_cloud_key YOUR_USERNAME@INSTANCE_EXTERNAL_IP
    ```
    *   `~/.ssh/google_cloud_key`: 手順1で生成した秘密鍵のパス。
    *   `YOUR_USERNAME`: インスタンスにログインするユーザー名。これは通常、公開鍵のコメント部分 (`-C`で指定したユーザー名) と一致しますが、OS Loginを使用している場合はGCPアカウントに基づいたユーザー名 (例: `firstname_lastname_example_com`) になることがあります。
    *   `INSTANCE_EXTERNAL_IP`: 接続するインスタンスの外部IPアドレス。

この手動でのキー管理方法は、`gcloud`コマンドが利用できない環境や、特定のセキュリティポリシーに従う必要がある場合に特に有効です。
