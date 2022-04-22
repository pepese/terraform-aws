# eks-sample

[terraform](https://www.terraform.io/) で [Amazon EKS](https://aws.amazon.com/jp/eks/) を構築してみる。  
また、オプションで Terraform で VPC とかを作成し、後は [eksctl](https://eksctl.io/) で EKS を構築する方法も記載する。

## 環境構築

### Terraform

```bash
$ brew install tfenv
$ tfenv install 0.12.9
$ tfenv use 0.12.9
$ terraform -v
Terraform v0.12.9
```

### eksctl

```bash
$ brew tap weaveworks/tap
$ brew install weaveworks/tap/eksctl
$ eksctl version
[ℹ]  version.Info{BuiltAt:"", GitCommit:"", GitTag:"0.5.3"}
```

## 全体像

```bash
.
├── README.md
├── modules
│   ├── eks
│   │   ├── aws.tf      # provider 設定
│   │   ├── eks.tf      # eksctl の時は使用しない
│   │   ├── iam.tf      # eksctl の時は使用しない
│   │   ├── outputs.tf  # Terraform で EKS 構築した際の config 出力
│   │   │               # eksctl 用に新規作成 必要な ID とか ARN 出力
│   │   ├── variables.tf
│   │   ├── vpc.tf
│   │   └── template
│   │       └── eks_cluster.tpl # eksctl マニフェスト用の Terraform template
│   └── <その他モジュール>
└── services
    ├── eks
    │   ├── dev
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── eks_cluster.yaml # terraform apply 後に template から作成される eksctl マニフェスト
    │   ├── tst
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── eks_cluster.yaml
    │   ├── stg
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── eks_cluster.yaml
    │   └── prd
    │       ├── main.tf
    │       ├── terraform.tfvars
    │       └── eks_cluster.yaml
    └── <その他サービス>
```

ディレクトリ構成の考え方は以下。

- `modules/` 配下に分割したい単位で Terraform のモジュールを整理する
- `services/` 配下に構築するサービス毎にディレクトリ分割し、さらにその配下を環境（ dev/stg/prd ）毎に分割する
- `services/<サービス名>/<環境名>/main.tf` にてモジュール呼出・変数値代入などを行い、このディレクトリで `terraform` コマンドを実行する
- `services/<サービス名>/<環境名>/terraform.tfvars` にクレデンシャル情報を記載し、 git 管理対象外とする
- `modules/<モジュール名>/variables.tf` にそのモジュールで利用する variable/locals を定義し、 `services/<サービス名>/<環境名>/main.tf` にて値を代入して利用する
- `modules/<モジュール名>/template/eks_cluster.tpl` に eksctl のマニフェスト雛形を作成して、 Terraform template 出力

## 構築から削除まで

### 構築

```bash
$ pwd
/path/to/project/services/eks/dev
$ terraform plan
$ terraform apply
$ eksctl create cluster -f eks_cluster.yaml # eksctl を利用する場合
```

### kubectl context 設定

eksctl 利用時は勝手に設定されている。

```bash
$ kubectl config current-context     # 現在の context を確認
$ kubectl config get-contexts        # 利用可能な context の一覧を取得
$ kubectl config delete-context xxxx # 不要な context の削除
```

上記で context を確認して、作成が必要であれば以下を実施。

```bash
# EKS を構築した AWS へのアクセス権がある場合
$ aws eks update-kubeconfig --region ap-northeast-1 --name pepese-dev-cluster
# AWS へのアクセス権が無い場合は、 Terraform が出力する context の設定を kubeconfig に追記
$ terraform output kubeconfig >> ~/.kube/config
```

> ここでは、 `aws eks update-kubeconfig` コマンドを使用して、クラスター API サーバー通信に必要なクライアントセキュリティトークンを作成している。  
> AWS CLI バージョン 1.16.156 以上がない場合は「 aws-iam-authenticator 」を利用する。

設定後は以下で確認。

```bash
$ kubectl config current-context
# xxxxxx@pepese-dev-cluster.ap-northeast-1.eksctl.io               # eksctl の自動設定の場合
# aws                                                              # terraform output の場合
# arn:aws:eks:ap-northeast-1:xxxxxxxxxx:cluster/pepese-dev-cluster # aws eks update-kubeconfig で設定した場合
```

なお、 eksctl を利用せずに構築した場合、 EKS 内の node の権限が不足するため `kubectl get nodes` でリソース情報が取得できない。  
以下で権限を付与する。

```bash
$ terraform output configmap > config_map.yaml
$ kubectl apply -f config_map.yaml
```

### eks 構築確認

```bash
$ kubectl get nodes # node が表示され、 Ready であることを確認
NAME                                             STATUS   ROLES    AGE   VERSION
ip-10-0-65-159.ap-northeast-1.compute.internal   Ready    <none>   13m   v1.14.6-eks-5047ed
ip-10-0-66-185.ap-northeast-1.compute.internal   Ready    <none>   13m   v1.14.6-eks-5047ed
$ kubectl get svc  # service が表示されることを確認
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   35m
$ kubectl get all --namespace=kube-system -o wide # 表示される全てのリソースが Ready / Running であることを確認
NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE                                             NOMINATED NODE   READINESS GATES
pod/aws-node-96vl5             1/1     Running   0          14m   10.0.65.159   ip-10-0-65-159.ap-northeast-1.compute.internal   <none>           <none>
pod/aws-node-lw76p             1/1     Running   0          14m   10.0.66.185   ip-10-0-66-185.ap-northeast-1.compute.internal   <none>           <none>
pod/coredns-5bbb5994c5-csvd2   1/1     Running   0          35m   10.0.66.232   ip-10-0-66-185.ap-northeast-1.compute.internal   <none>           <none>
pod/coredns-5bbb5994c5-fhbx8   1/1     Running   0          35m   10.0.66.117   ip-10-0-66-185.ap-northeast-1.compute.internal   <none>           <none>
pod/kube-proxy-5tvsp           1/1     Running   0          14m   10.0.66.185   ip-10-0-66-185.ap-northeast-1.compute.internal   <none>           <none>
pod/kube-proxy-kn2ds           1/1     Running   0          14m   10.0.65.159   ip-10-0-65-159.ap-northeast-1.compute.internal   <none>           <none>

NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE   SELECTOR
service/kube-dns   ClusterIP   172.20.0.10   <none>        53/UDP,53/TCP   35m   k8s-app=kube-dns

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS   IMAGES                                                                     SELECTOR
daemonset.apps/aws-node     2         2         2       2            2           <none>          35m   aws-node     xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/amazon-k8s-cni:v1.5.3    k8s-app=aws-node
daemonset.apps/kube-proxy   2         2         2       2            2           <none>          35m   kube-proxy   xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks/kube-proxy:v1.14.6   k8s-app=kube-proxy

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                                                 SELECTOR
deployment.apps/coredns   2/2     2            2           35m   coredns      xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks/coredns:v1.3.1   eks.amazonaws.com/component=coredns,k8s-app=kube-dns

NAME                                 DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                                                                 SELECTOR
replicaset.apps/coredns-5bbb5994c5   2         2         2       35m   coredns      xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/eks/coredns:v1.3.1   eks.amazonaws.com/component=coredns,k8s-app=kube-dns,pod-template-hash=5bbb5994c5
```

### 削除

```bash
$ eksctl delete cluster --name pepese-dev-cluster # eksctl 利用時はこちらも
$ terraform destroy
$ kubectl config delete-context xxxx              # 不要な context の削除
```

## モジュール設定概要

命名はリソース系はアンスコ区切り、名前系はハイフン区切りの小文字で。  
（ CloudFormation の名前系はアンスコ区切り NG のため）

### vpc.tf

EKS クラスタを構築する VPC の設定。（まだ完成してない）

- Public Subnet 、 Cluster Subnet 、 Private Subnet をそれぞれ 3 つ構築（ Multi-AZ / 3AZ ）
  - Public Subnet  : LB 置き場。 リクエスト を Cluster Subnet の Nord Port へ流す。
  - Cluster Subnet : eks cluster （ worker ）を構築。 Public Subnet からのリクエストを Nord Port で受ける。
  - Private Subnet : DB 置き場。 Cluster Subnet からのリクエストのみ受け付ける。
- 各 Public Subnet に NAT ゲートウェイを設置し、 Cluster Subnet からの egress をルーティング
- Bastion が必要な場合は一時的に Public Subnet へ配置

### eks.tf（要修正）

EKS クラスタの設定。

- `aws_eks_cluster` リソースの設定があんまわかってない
  - `vpc_config.security_group_ids` の設定に Master Node の SG を適用している、これでいいのか、、、
  - `vpc_config.subnet_ids` に Worker Node が起動する Private Subnet を設定している、これでいいのか、、、

## 構築できているか検証（要修正）

`nginx.deployment.yaml` を作ってデプロイする。

```yaml:nginx.deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.5
        ports:
        - containerPort: 80
```

```bash
$ kubectl apply -f nginx.deployment.yaml
deployment.extensions/nginx created
$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP            NODE                                             NOMINATED NODE   READINESS GATES
nginx-954765466-cgrrc   1/1     Running   0          3m12s   10.0.65.103   ip-10-0-65-159.ap-northeast-1.compute.internal   <none>           <none>
```

## 参考

- [Modular and Scalable Amazon EKS Architecture](https://s3.amazonaws.com/aws-quickstart/quickstart-amazon-eks/doc/amazon-eks-architecture.pdf)
  - 構築手順
- [aws-quickstart/quickstart-amazon-eks](https://github.com/aws-quickstart/quickstart-amazon-eks/tree/master/templates)
  - EKS CloudFormation Templates
- [eksctlでEKSを構築・運用する際のTips](https://blog.3-shake.com/n/n224cce562fe2)
- [eksctl で VPC を作るのをやめて Terraform で作るようにしました](https://blog.hatappi.me/entry/2019/02/17/123111)
- [Example with custom IAM and VPC config](https://eksctl.io/examples/reusing-iam-and-vpc/)