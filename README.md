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
- Fill the next pipeline parameters (<a href="https://github.com/MartiMarch/Kubernetes/blob/main/Jenkinsfile">line 6</a>):</br><br>
<table>
  <tr>
    <td>GH_URL</td>
    <td>Git URL where pipeline are stored</td>
  </tr>
  <tr>
    <td>GH_USER</td>
    <td>Git user</td>
  </tr>
  <tr>
    <td>K_URL</td>
    <td>Master kubernetes node <a href="https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration">url</a></td>
  </tr>
  <tr>
    <td>FIRST_RANGE_PORT</td>
    <td>First range port that microservice could use</td>
  </tr>
  <tr>
    <td>FINAL_RANGE_PORT</td>
    <td>Last range port that microservice could use</td>
  </tr>
  <tr>
    <td>USED_PORTS</td>
    <td>File path with all used ports</td>
  </tr>
  <tr>
    <td>KNOWED_PORTS</td>
    <td>File path with all knowed ports</td>
  </tr>
</table>
- Add the following input parameters in jenkins pipeline configuration:<br><br>
<table>
  <tr>
    <td>NAME</td>
    <td>TYPE</td>
    <td>DESCRIPTION</td>
  </tr>
  <tr>
    <td>NOMBRE_MS</td>
    <td>Text</td>
    <td>Name that will use microservice</td>
  </tr>
  <tr>
    <td>INT</td>
    <td>Boolean</td>
    <td>Launch microservice over preproduction environment</td>
  </tr>
  <tr>
    <td>PROD</td>
    <td>Boolean</td>
    <td>Launch microservice over production environment</td>
  </tr>
  <tr>
    <td>TEMPLATE</td>
    <td>Boolean</td>
    <td>Launch microservice using a kubernetes <a href="https://github.com/MartiMarch/Kubernetes/tree/main/template">template</a></td>
  </tr>
</table>
<h3>Deploy a microservice over Preproduction/Production environments</h3>
<p align="justify">To deploy a microservice over preproduction/production environemnt mark INT or INT as true. The namespace is a reference to a github subdirectory. For example, to deploy MySQL over prepoduction environment the value NOMBRE_MS has to be <a href="https://github.com/MartiMarch/Kubernetes/tree/main/mysql">mysql</a>. Inside of subdirectory put yaml file. By now the kind of yaml files accepted are deployments, services, presistents volumes and persistents volume claims.</p>
