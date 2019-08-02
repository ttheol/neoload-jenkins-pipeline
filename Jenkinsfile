pipeline {
  agent none
  stages {
    stage('Start NeoLoad infrastructure') {
      agent { label 'master' }
      steps {
        sh 'docker network create neoload'
        sh 'docker-compose -f neoload/load-generators/docker-compose.yml up -d'
        stash includes: 'neoload/load-generators/lg.yaml', name: 'LG'
        stash includes: 'neoload/load-generators/docker-compose.yml', name: 'infra'
        stash includes: 'Jenkinsfile', name: 'Jenkinsfile'
      }
    }
    stage('API Tests') {
      agent {
        dockerfile {
          args '--user root -v /tmp:/tmp --network=neoload --name=docker-controller'
          dir 'neoload/controller'
        }
      }
      steps {
        git(branch: "master",
            url: 'https://github.com/ttheol/neoload-as-code-demo.git')
        unstash 'LG'
        withCredentials([string(credentialsId: 'neoloadToken', variable: 'neoloadToken')]) {
          sh script: "NeoLoad -project '$WORKSPACE/default.yaml' -testResultName 'Petstore API (build ${BUILD_NUMBER})' -description 'Testing Load as Code' -launch 'Petstore API' -loadGenerators '$WORKSPACE/neoload/load-generators/lg.yaml' -nlweb -nlwebAPIURL http://dockerps1.neotys.com:8080 -nlwebToken ${neoloadToken} -leaseServer nlweb -leaseLicense 10:1"
        }
      }
    }
  }
  post {
    always{
      node('master'){
        unstash 'infra'
        unstash 'Jenkinsfile'
        sh 'docker-compose -f neoload/load-generators/docker-compose.yml down'
        sh 'docker network rm neoload'
        script {
          NEOLOAD_PROJECT_FILES = sh (
            script: "ls | grep -vE  'common|default.yaml|neoload|Jenkinsfile|v1|*.bak' | tr '\n' ',' ; echo",
            returnStdout: true
          ).trim().replace(' ',',')
          zip archive: true, dir: '', glob: "${NEOLOAD_PROJECT_FILES}", zipFile: 'neoload_as_code_demo.zip'
        }
        //sh 'zip api_as_code_demo.zip $(ls | grep -vE  "common|default.yaml|neoload|Jenkinsfile|v1|*.bak")'
        //fileOperations([folderCreateOperation('api_as_code_demo'), fileCopyOperation(flattenFiles: false, includes: '*.nlp,config.zip,custom-resources/**,', targetLocation: 'api_as_code_demo'), fileZipOperation('api_as_code_demo')])
        archiveArtifacts allowEmptyArchive: true, artifacts: 'results/**,Jenkinsfile,neoload/**'
        sh 'docker volume prune -f'
        cleanWs()
    }
    }
  }
}
