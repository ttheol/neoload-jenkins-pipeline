pipeline {
  agent none
  stages {
    stage('Start NeoLoad infrastructure') {
      agent { label 'master' }
      steps {
        sh 'docker network create neoload'
        sh 'docker-compose -f neoload/load-generators/docker-compose.yml up -d'
        sh 'docker network join neoload $(docker ps -f name=docker-lg*)'
        stash includes: 'neoload/load-generators/lg.yaml', name: 'LG'
      }
    }
    stage('API Tests') {
      agent {
        dockerfile {
          args '--user root -v /tmp:/tmp --network=neoload'
          dir 'neoload/controller'
        }
      }
      steps {
        git(branch: "master",
            url: 'https://github.com/ttheol/neoload-as-code-demo.git')
        unstash 'LG'
        sh script: "NeoLoadCmd -project '$WORKSPACE/default.yaml' -testResultName 'Petstore API (build ${BUILD_NUMBER})' -description 'Testing Load as Code' -launch 'Petstore API' -loadGenerators '$WORKSPACE/neoload/load-generators/lg.yaml' -nlweb -nlwebAPIURL http://dockerps1.neotys.com:8080 -nlwebToken t2w9wTIWQmaEe60U1IvEQwIs -leaseServer nlweb -leaseLicense 10:1"
      }
    }
    stage('Stop NeoLoad infrastructure') {
      agent { label 'master' }
      steps {
        sh 'docker-compose -f neoload/load-generators/docker-compose.yml down'
      }
    }
    stage('Cleanup') {
      agent{ label 'master' }
      steps {
        archiveArtifacts 'results/**'
        archiveArtifacts 'Jenkinsfile'
        archiveArtifacts 'neoload/**'
        sh 'docker volume prune -f'
        sh 'docker network rm neoload'
        cleanWs()
      }
    }
  }
}
