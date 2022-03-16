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
        stage("Kubernetes"){
            steps{
                withKubeConfig([credentialsId: 'KUBECONFIG']){
                    script{
                        String pv = buscarArchivo(NOMBRE_MS, "-pv.y")
                        String pvc = buscarArchivo(NOMBRE_MS, "-pvc.y")
                        String deployment = buscarArchivo(NOMBRE_MS, "-deployment.y")
                        String service = buscarArchivo(NOMBRE_MS, "-service.y")
                        int puerto_int = 0
                        int puerto_pro = 0
                        if(INT.toBoolean() == true)
                        {
                            if(pv != "" && pvc != "")
                            {
                                String ruta_pv = sh(script: "cat ./Kubernetes/${NOMBRE_MS}/${pv} | egrep path:", returnStdout: true).trim()
                                ruta_pv = ruta_pv.replaceAll("/", "\\/");
                                modificarArchivo(NOMBRE_MS, pv, "int_" + pv, ruta_pv, ruta_pv.substring(0, ruta_pv.length()-1) + "_int\"")
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
                            }
                            sh "kubectl --namespace int apply -f ./Kubernetes/${NOMBRE_MS}"
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
                        if(PROD.toBoolean() == true)
                        {
                            if(INT.toBoolean() == true)
                            {
                                sh "rm -rf *"
                                sh "git clone https://${GH_USER}:${GH_TOKEN_PER}@${GH_URL}"
                            }
                            if(pv != "" && pvc != "")
                            {
                                String ruta_pv = sh(script: "cat ./Kubernetes/${NOMBRE_MS}/${pv} | egrep path:", returnStdout: true).trim()
                                modificarArchivo(NOMBRE_MS, pv, "pro_" + pv, ruta_pv, ruta_pv.substring(0, ruta_pv.length()-1) + "_pro\"")
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
                            }
                            sh "kubectl --namespace pro apply -f ./Kubernetes/${NOMBRE_MS}"
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
                        if(INT.toBoolean())
                        {
                            echo "El servicio ${NOMBRE_MS} se ha desplegado en el entorno de integración sobre el puerto ${Integer.toString(puerto_int)}"
                        }
                        if(PROD.toBoolean() == true)
                        {
                            echo "El servicio ${NOMBRE_MS} se ha desplegado en el entorno de producción sobre el puerto ${Integer.toString(puerto_pro)}"
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
    int port = -1;
    ArrayList<String> ports = new ArrayList();
    try{
        def archivo = readFile(file: path)
        String[] contenidoArchivo = archivo.split('\n');
        for(int i = 0; i < contenidoArchivo.length; ++i)
        {
            if(contenidoArchivo[i].length() > 0)
            {
                ports.add(contenidoArchivo[i]);
            }
        }
    }
    catch(IOException e){
        e.printStackTrace();
    }
    boolean puerto_libre = false;
    for(int i = Integer.parseInt(first_rp); i < Integer.parseInt(final_rp) && puerto_libre == false; ++i)
    {
        if(!ports.contains(Integer.toString(i)))
        {
            puerto_libre = true;
            port = i;
            linea = Integer.toString(port) + "\n";
            def archivo = new File(path)
            archivo.append(linea)
            archivo = new File(path2)
            linea = Integer.toString(port) + " - " + nombre_ms + "\n";
            archivo.append(linea)
        }
    }
    return port;
}
