import java.io.*;
import java.nio.*;

pipeline{
    agent any
    environment{
        GH_URL = "github.com/MartiMarch/Kubernetes.git"
        GH_USER = "MartiMarch"
        K_URL = "https://192.168.1.190:6443"
        FIRST_RANGE_PORT = "30000"
        FINAL_RANGE_PORT = "32767"
        USED_PORTS = "${WORKSPACE}/Kubernetes/used_ports"
        KNOWED_PORTS = "${WORKSPACE}/Kubernetes/knowed_ports"
    }
    stages{
        stage("GitHub"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                        sh "rm -rf *"
                        sh "git clone https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                    }
                }
            }
        }
        stage("Docker"){
            steps{
                script{
                    if(TEMPLATE.toBoolean() != true)
                    {
                        String ls = sh(script: "ls ./Kubernetes", returnStdout: true).trim()
                        if(ls.contains(NOMBRE_MS))
                        {
                            String dockerfile = buscarArchivo(NOMBRE_MS, "Dockerfile")
                            if(dockerfile != "")
                            {
                                sh "docker image build -f ./Kubernetes/${NOMBRE_MS}/${dockerfile} -t ${NOMBRE_MS} ."
                            }
                            else
                            {
                                currentBuild.result = "FAILURE"
                                throw new Exception("No existe ningun Dockerfile en el repositorio.")
                            }
                        }
                        else
                        {
                            currentBuild.result = "FAILURE"
                            throw new Exception("El microservicio ${NOMBRE_MS} no existe en el directorio de GitHub.")
                        }
                    }
                }
            }
        }
        stage("Kubernetes"){
            steps{
                withKubeConfig([credentialsId: 'KUBECONFIG']){
                    script{
                        String pv = ""
                        String pvc = ""
                        String deployment = ""
                        String service = ""
                        int puerto_int = 0
                        int puerto_pro = 0
                        if(INT.toBoolean() == true)
                        {
                            pv = buscarArchivo(NOMBRE_MS, "-pv.y")
                            pvc = buscarArchivo(NOMBRE_MS, "-pvc.y")
                            deployment = buscarArchivo(NOMBRE_MS, "-deployment.y")
                            service = buscarArchivo(NOMBRE_MS, "-service.y")
                            if(pv != "" && pvc != "")
                            {
                                modificarArchivo(NOMBRE_MS, pv, "int_" + pv, "    path: \"\\/home\\/${NOMBRE_MS}\"", "    path: \"\\/home\\/${NOMBRE_MS}_int\"")
                                modificarArchivo(NOMBRE_MS, pv, "int_" + pv, "  name: ${NOMBRE_MS}-pv","  name: ${NOMBRE_MS}-pv-int")
                                modificarArchivo(NOMBRE_MS, pvc, "int_" + pvc, "  name: ${NOMBRE_MS}-pvc","  name: ${NOMBRE_MS}-pvc-int")
                                modificarArchivo(NOMBRE_MS, deployment, "int_" + deployment, "          claimName: ${NOMBRE_MS}-pvc","          claimName: ${NOMBRE_MS}-pvc-int")
                            }
                            if(service != "")
                            {
                                puerto_int = getPort(FIRST_RANGE_PORT, FINAL_RANGE_PORT, USED_PORTS, NOMBRE_MS + "_int", KNOWED_PORTS)
                                if(puerto_int == -1)
                                {
                                    currentBuild.result = "FAILURE"
                                    throw new Exception("No hay puertos disponibles, rango actual: ${FIRST_RANGE_PORT}/${FINAL_RANGE_PORT}")
                                }
                                else
                                {
                                    String linea_puerto = sh(script: "cat ./Kubernetes/${NOMBRE_MS}/${service} | egrep nodePort:", returnStdout: true).trim()
                                    modificarArchivo(NOMBRE_MS, service, "int_" + service, linea_puerto, "- nodePort: " + Integer.toString(puerto_int))
                                }
                                dir('Kubernetes'){
                                    sh "git init"
                                    sh "git add used_ports"
                                    sh "git commit -m \"Updating used ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                    sh "git add knowed_ports"
                                    sh "git commit -m \"Updating knowed ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                }
                            }
                            sh "kubectl --namespace int apply -f ./Kubernetes/${NOMBRE_MS}"
                            echo "El servicio ${NOMBRE_MS} se ha desplegado en el entorno de preproduccion sobre el puerto ${Integer.toString(puerto_int)}"
                        }
                        else if(PROD.toBoolean() == true)
                        {
                            pv = buscarArchivo(NOMBRE_MS, "-pv.y")
                            pvc = buscarArchivo(NOMBRE_MS, "-pvc.y")
                            deployment = buscarArchivo(NOMBRE_MS, "-deployment.y")
                            service = buscarArchivo(NOMBRE_MS, "-service.y")
                            if(pv != "" && pvc != "")
                            {
                                modificarArchivo(NOMBRE_MS, pv, "int_" + pv, "    path: \"\\/home\\/${NOMBRE_MS}\"", "    path: \"\\/home\\/${NOMBRE_MS}_pro\"")
                                modificarArchivo(NOMBRE_MS, pv, "pro_" + pv, "  name: ${NOMBRE_MS}-pv","  name: ${NOMBRE_MS}-pv-pro")
                                modificarArchivo(NOMBRE_MS, pvc, "pro_" + pvc, "  name: ${NOMBRE_MS}-pvc","  name: ${NOMBRE_MS}-pvc-pro")
                                modificarArchivo(NOMBRE_MS, deployment, "pro_" + deployment, "          claimName: ${NOMBRE_MS}-pvc","          claimName: ${NOMBRE_MS}-pvc-pro")
                            }
                            if(service != "")
                            {
                                puerto_pro = getPort(FIRST_RANGE_PORT, FINAL_RANGE_PORT, USED_PORTS, NOMBRE_MS + "_pro", KNOWED_PORTS)
                                if(puerto_pro == -1)
                                {
                                    currentBuild.result = "FAILURE"
                                    throw new Exception("No hay puertos disponibles, rango actual: ${FIRST_RANGE_PORT}/${FINAL_RANGE_PORT}")
                                }
                                else
                                {
                                    String linea_puerto = sh(script: "cat ./Kubernetes/${NOMBRE_MS}/${service} | egrep nodePort:", returnStdout: true).trim()
                                    modificarArchivo(NOMBRE_MS, service, "pro_" + service, linea_puerto, "- nodePort: " + Integer.toString(puerto_pro))
                                }
                                dir('Kubernetes'){
                                    sh "git init"
                                    sh "git add used_ports"
                                    sh "git commit -m \"Updating used ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                    sh "git add knowed_ports"
                                    sh "git commit -m \"Updating knowed ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                }
                            }
                            sh "kubectl --namespace pro apply -f ./Kubernetes/${NOMBRE_MS}"
                            echo "El servicio ${NOMBRE_MS} se ha desplegado en el entorno de producción sobre el puerto ${Integer.toString(puerto_pro)}"
                        }
                        else if(TEMPLATE.toBoolean() == true)
                        {
                            def props = readProperties file: "${WORKSPACE}/Kubernetes/template/microservicios.properties"
                            String linea = "";
                            boolean volumeClaimExists = false;
                            boolean serviceExists = false;

                            //Deployment
                            String name = props["name"];
                            String replicas = props["replicas"];
                            String namespace = props["namespace"];
                            String imageName = props["imageName"];
                            String command = props["command"];
                            String mountPath = props["mountPath"];
                            String mountName = props["mountName"];
                            String port = props["port"];

                            //Persistent volume claim
                            String pvcStorage = props["pvcStorage"];

                            //Persistent Volume
                            String pvStorage = props["pvStorage"];
                            String pvPath = props["pvPath"];

                            //Service
                            String nodePort = props["nodePort"];
                            String servicePort = props["servicePort"];

                            //Deployment
                            if(name.length() == 0){
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deployment parameter error: \"name\" is null")
                            }
                            else if(replicas.length() == 0){
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deployment parameter error: \"replicas\" is null")
                            }
                            else if(namespace.length() == 0){
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deployment parameter error: \"namespace\" is null")
                            }
                            else if(imageName.length() == 0){
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deployment parameter error: \"imageName\" is null")
                            }
                            else{
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep name: | head -1", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "name: ${name}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep namespace:", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "namespace: ${namespace}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep replicas:", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "replicas: ${replicas}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep app: | head -1", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "app: ${name}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep app: | tail -1", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "app: ${name}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep name: | tail -1", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "- name: ${name}")
                                linea = sh(script: "cat ./Kubernetes/template/template-deployment.yaml | egrep image:", returnStdout: true).trim()
                                modificarArchivo("template", "template-deployment.yaml", "temporal_template-deployment.yaml", linea, "image: ${imageName}")
                                if(command.length() > 0)
                                {
                                    addLine("./Kubernetes/template/template-deployment.yaml", "        command: " + command)
                                }
                                if(mountPath.length() > 0 && mountName.length() > 0)
                                {
                                    addLine("./Kubernetes/template/template-deployment.yaml", "        volumeMounts:")
                                    addLine("./Kubernetes/template/template-deployment.yaml", "          - mountPath: " + mountPath)
                                    addLine("./Kubernetes/template/template-deployment.yaml", "            name: " + mountName)
                                    volumeClaimExists = true;
                                }
                                if(port.length() > 0)
                                {
                                    addLine("./Kubernetes/template/template-deployment.yaml", "        ports:")
                                    addLine("./Kubernetes/template/template-deployment.yaml", "          - containerPort: " + port)
                                }
                                if(volumeClaimExists == true)
                                {
                                    addLine("./Kubernetes/template/template-deployment.yaml", "      volumes:")
                                    addLine("./Kubernetes/template/template-deployment.yaml", "      - name: " + mountName)
                                    addLine("./Kubernetes/template/template-deployment.yaml", "        persistentVolumeClaim:")
                                    addLine("./Kubernetes/template/template-deployment.yaml", "          claimName: " + name + "-pvc")
                                }
                                sh "cat ./Kubernetes/template/template-deployment.yaml"
                            }

                            //Persistent volume claim
                            if(pvcStorage.length() > 0)
                            {
                                linea = sh(script: "cat ./Kubernetes/template/template-pvc.yaml | egrep name:", returnStdout: true).trim()
                                modificarArchivo("template", "template-pvc.yaml", "temporal_template-pvc.yaml", linea, "name: ${name}-pvc")
                                linea = sh(script: "cat ./Kubernetes/template/template-pvc.yaml | egrep namespace:", returnStdout: true).trim()
                                modificarArchivo("template", "template-pvc.yaml", "temporal_template-pvc.yaml", linea, "namespace: ${namespace}")
                                linea = sh(script: "cat ./Kubernetes/template/template-pvc.yaml | egrep storage:", returnStdout: true).trim()
                                modificarArchivo("template", "template-pvc.yaml", "temporal_template-pvc.yaml", linea, "storage: ${pvcStorage}")
                                sh "cat ./Kubernetes/template/template-pvc.yaml"
                            }
                            else if(volumeClaimExists)
                            {
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deplyoment requires a persistent volume claim, variable data are not filled")
                            }

                            //Persistent Volume
                            if(pvStorage.length() > 0 && pvPath.length() > 0)
                            {
                                linea = sh(script: "cat ./Kubernetes/template/template-pv.yaml | egrep name:" , returnStdout: true).trim()
                                modificarArchivo("template", "template-pv.yaml", "temporal_template-pv.yaml", linea, "name: ${name}-pv")
                                linea = sh(script: "cat ./Kubernetes/template/template-pv.yaml | egrep namespace:", returnStdout: true).trim()
                                modificarArchivo("template", "template-pv.yaml", "temporal_template-pv.yaml", linea, "namespace: ${namespace}")
                                linea = sh(script: "cat ./Kubernetes/template/template-pv.yaml | egrep storage:", returnStdout: true).trim()
                                modificarArchivo("template", "template-pv.yaml", "temporal_template-pv.yaml", linea, "storage: ${pvStorage}")
                                linea = sh(script: "cat ./Kubernetes/template/template-pv.yaml | egrep path:", returnStdout: true).trim()
                                pvPath = pvPath.replace("/", "\\/")
                                modificarArchivo("template", "template-pv.yaml", "temporal_template-pv.yaml", linea, "path: ${pvPath}")
                                sh "cat ./Kubernetes/template/template-pv.yaml"
                            }
                            else if(volumeClaimExists)
                            {
                                currentBuild.result = "FAILURE"
                                throw new Exception("Deplyoment requires a persistent volume claim, variable data are not filled")
                            }

                            //Service
                            if(servicePort.length() > 0 && nodePort.length() > 0)
                            {
                                linea = sh(script: "cat ./Kubernetes/template/template-service.yaml | egrep name:", returnStdout: true).trim()
                                modificarArchivo("template", "template-service.yaml", "temporal_template-service.yaml", linea, "name: ${name}")
                                inea = sh(script: "cat ./Kubernetes/template/template-service.yaml | egrep namespace:", returnStdout: true).trim()
                                modificarArchivo("template", "template-service.yaml", "temporal_template-service.yaml", linea, "namespace: ${namespace}")
                                linea = sh(script: "cat ./Kubernetes/template/template-service.yaml | egrep app: | head -1", returnStdout: true).trim()
                                modificarArchivo("template", "template-service.yaml", "temporal_template-service.yaml", linea, "app: ${name}")
                                linea = sh(script: "cat ./Kubernetes/template/template-service.yaml | egrep nodePort:", returnStdout: true).trim()
                                modificarArchivo("template", "template-service.yaml", "temporal_template-service.yaml", linea, "- nodePort: ${nodePort}")
                                linea = sh(script: "cat ./Kubernetes/template/template-service.yaml | egrep port:", returnStdout: true).trim()
                                modificarArchivo("template", "template-service.yaml", "temporal_template-service.yaml", linea, "port: ${servicePort}")
                                sh "cat ./Kubernetes/template/template-service.yaml"
                                addLine("./Kubernetes/used_ports", servicePort)
                                addLine("./Kubernetes/knowed_ports", servicePort + " - " + name)
                                dir('Kubernetes'){
                                    sh "git init"
                                    sh "git add used_ports"
                                    sh "git commit -m \"Updating used ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                    sh "git add knowed_ports"
                                    sh "git commit -m \"Updating knowed ports files\""
                                    withCredentials([string(credentialsId: 'GH_TOKEN_PER', variable: 'GH_TOKEN_PER')]){
                                        sh "git push https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                                    }
                                }
                                serviceExists = true;
                            }

                            if(!volumeClaimExists){
                                sh "rm -rf ./Kubernetes/template/template-pv.yaml"
                                sh "rm -rf ./Kubernetes/template/template-pvc.yaml"
                            }
                            if(!serviceExists){
                                sh "rm -rf ./Kubernetes/template/template-service.yaml"
                            }
                            sh "kubectl --namespace ${namespace} apply -f ./Kubernetes/template"
                        }
                    }
                }
            }
        }
    }
}

def buscarArchivo(String nombre_ms, String expresion)
{
    ls = sh(script: "ls ./Kubernetes/${nombre_ms}", returnStdout: true).trim()
    String[] archivos =  ls.split("\\s+");
    String out = "";
    for(int i = 0; i < archivos.length; ++i)
    {
        if(archivos[i].contains(expresion))
        {
            out = archivos[i];
        }
    }
    return out;
}

def modificarArchivo(nombre_ms, archivo, temp_archivo, lineaOriginal, lineaCambiada)
{
    sh "cat ./Kubernetes/${nombre_ms}/${archivo} | sed -e \'s/${lineaOriginal}/${lineaCambiada}/\' > ./Kubernetes/${nombre_ms}/${temp_archivo}"
    sh "mv ./Kubernetes/${nombre_ms}/${temp_archivo} ./Kubernetes/${nombre_ms}/${archivo}"
}

def getPort(first_rp, final_rp, path, nombre_ms, path2)
{
    try{
        int port = -1;
        ArrayList<String> ports = new ArrayList();
        def archivo = readFile(file: path)
        String[] contenidoArchivo = archivo.split('\n');
        for(int i = 0; i < contenidoArchivo.length; ++i)
        {
            if(contenidoArchivo[i].length() > 0)
            {
                ports.add(contenidoArchivo[i]);
            }
        }
        boolean puerto_libre = false;
        for(int i = Integer.parseInt(first_rp); i < Integer.parseInt(final_rp) && puerto_libre == false; ++i)
        {
            if(!ports.contains(Integer.toString(i)))
            {
                puerto_libre = true;
                port = i;
                linea = Integer.toString(port) + "\n";
                archivo = new File(path)
                archivo.append(linea)
                archivo = new File(path2)
                linea = Integer.toString(port) + " - " + nombre_ms + "\n";
                archivo.append(linea)
            }
        }
    }
    catch(IOException e){
        e.printStackTrace();
    }
    return port;
}

def addLine(String path, String line)
{
    sh "echo \"${line}\" >> ${path}"
}
