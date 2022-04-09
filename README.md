<h1> Kubernetes</h1>
<p align="justify">All the kubernetes yaml files created.</p>

<h2>Jenkins pipeline</h2>
<p align="justify">This repositoriy contains a pipeline that allow to launch microservices into a kubernetes cluster.</p>

<h3>Requeriments</h3>
- Jenkins<br>
- Git<br>
- <a href="https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/">Kubernetes token</a> as jenkins secret text<br>
- <a href="https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/">Kubeconfig file</a> as jenkins secret file<br>
- Git user if repositoriy is private as jenkins secret text</br>
- Git token if repository is private as jenkins secret text</br>
- Fill the next pipeline parameters (<a href="https://github.com/MartiMarch/Kubernetes/blob/main/Jenkinsfile">line 6</a>):</br>
