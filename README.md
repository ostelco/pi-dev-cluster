# infra
Terraform and other nice things...

## To install Tiller

    kubectl create serviceaccount -n kube-system tiller
    kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller
    helm init --service-account tiller
    kubectl get pods -n kube-system
