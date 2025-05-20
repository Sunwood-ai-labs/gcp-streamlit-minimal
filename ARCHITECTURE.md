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
