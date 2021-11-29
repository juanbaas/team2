
#We create our Datas to be able to use kubernetes provider
/*data "azurerm_resource_group" "rg" {
  name = "ProjectDOU"
}
data "azurerm_kubernetes_cluster" "example" {
  name                = "kubercluster"
  resource_group_name = data.azurerm_resource_group.rg.name
}


provider "helm" {
  kubernetes {
    host                   = "${data.azurerm_kubernetes_cluster.example.kube_config.0.host}"
    client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)}"
  }
}*/
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

/*provider "kubernetes" {
  host                   = "${data.azurerm_kubernetes_cluster.example.kube_config.0.host}"
  client_certificate     = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)}"
}*/

terraform {
  backend "azurerm" {
    resource_group_name  = "juan-baas"
    storage_account_name = "storagejuanbaas"
    container_name       = "juanbaas"
    key                  = "tfstate"
  }
}

#Here starts all the modules of the script, if you have problems seeing how modules work, just copy and replace everything of
#the module here

#Inside some module directories, there is an "output.tf" file, these are used to get data and create variables after the 
#creation of that module, so instead of having an echo of a varibale and then typing it on terminal it does everything
#auto

#Azure cluster service
module "acr" {
  source              = "./modules/acr"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = "juan-baas"
}

#Azure Kubernetes Cluster Service
module "aks" {
  source              = "./modules/aks"
  prefix              = var.prefix
  location            = var.location
  client_id           = var.client_id
  client_secret       = var.client_secret
  node_count          = var.node_count
  vm_size             = var.vm_size
  os_disk_size_gb     = var.os_disk_size_gb
  resource_group_name = "juan-baas"
}

#Helm
/*module "helm" {
  source                 = "./modules/helm"
  prefix                 = var.prefix
  location               = var.location
  client_id              = var.client_id
  client_secret          = var.client_secret
  node_count             = var.node_count
  resource_group_name    = data.azurerm_resource_group.rg.name
}*/

#Creation of load balancer to add a little extra
module "load_balancer" {
  source               = "./modules/load_balancer"
  public_ip_address_id = module.public_ip.id
  location             = var.location
  prefix               = var.prefix
  resource_group_name  = "juan-baas"
}

#We need a public IP to access our server
module "public_ip" {
  source              = "./modules/public_ip"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = "juan-baas"
}