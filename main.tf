provider "aws" {
  region = "us-east-1"  # Ajuste para a região que preferir
}

# Criação do Cluster EKS
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "soat7grupo5-cluster"
  cluster_version = "1.24"  # Versão do Kubernetes

  # Configurações para o cluster
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "your-key-pair"  # Substitua com seu par de chaves
    }
  }
}

# Criando VPC (Virtual Private Cloud)
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "soat7grupo5-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Provisão de IAM Roles para o EKS
module "eks_iam" {
  source = "terraform-aws-modules/iam/aws//modules/eks"

  cluster_name = module.eks.cluster_name
}

# Configuração dos ConfigMaps e Secrets para o Kubernetes
resource "kubernetes_config_map" "api" {
  metadata {
    name      = "api-configmap"
    namespace = "default"
  }

  data = {
    SPRING_DATASOURCE_URL      = "jdbc:mysql://mysql-svc:3306/soat7grupo5"
    SPRING_DATASOURCE_USERNAME = "soat7grupo5"
    SPRING_DATASOURCE_PASSWORD = "soat7grupo5"
  }
}

resource "kubernetes_secret" "mysql_secrets" {
  metadata {
    name      = "mysql-secrets"
    namespace = "default"
  }

  data = {
    MYSQL_ROOT_PASSWORD = base64encode("root")
    MYSQL_INIT_DB       = base64encode("soat7grupo5")
    MYSQL_INIT_USER     = base64encode("soat7grupo5")
    MYSQL_INIT_PASSWORD = base64encode("soat7grupo5")
  }
  
  type = "Opaque"
}

# Incluindo o resto do seu Deployment e Serviços para o Kubernetes aqui

resource "kubernetes_deployment" "api" {
  # Código do deployment para sua aplicação
}

resource "kubernetes_service" "api" {
  # Código do service para sua aplicação
}

# Persistência para o MySQL
resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  # Código do PVC
}

