pipeline {
  agent none
  stages {
    stage('Launch Infrastructure') {
        stage('Start NeoLoad infrastructure') {
          agent { label 'master' }
          steps {
            sh 'docker-compose -f neoload/lg/docker-compose.yml up -d'
            stash includes: 'neoload/load-generators/lg.yaml', name: 'LG'
          }
        }
    }
    stage('API Tests') {
      agent {
        dockerfile {
          args '--user root -v /tmp:/tmp'
          dir 'neoload/controller'
        }
      }
      steps {
        git(branch: "master",
            url: 'https://github.com/ttheol/neoload-as-code-demo.git')
        unstash 'LG'
        script {
          neoloadRun executable: '/home/neoload/neoload/bin/NeoLoadCmd',
            project: "$WORKSPACE/default.yaml",
            testName: 'Petstore API (build ${BUILD_NUMBER})',
            testDescription: 'Testing Load as Code',
            commandLineOption: "-loadGenerators $WORKSPACE/neoload/load-generators/lg.yaml -nlweb -nlwebAPIURL http://dockerps1.neotys.com:8080 -nlwebToken t2w9wTIWQmaEe60U1IvEQwIs -leaseServer nlweb -leaseLicense 10:1",
            scenario: 'Petstore API', sharedLicense: [server: 'NeoLoad Demo License', duration: 2, vuCount: 5]
        }
      }
    }
    stage('Stop Infrastructure') {
        stage('Stop NeoLoad infrastructure') {
          agent { label 'master' }
          steps {
            sh 'docker-compose -f neoload/load-generators/docker-compose.yml down'
          }
        }
    }
    stage('Cleanup') {
      agent{ label 'master' }
      steps {
        archiveArtifacts 'results/**'
        archiveArtifacts 'Jenkinsfile'
        archiveArtifacts 'neoload/**'
        sh 'docker volume prune -f'
        cleanWs()
      }
    }
  }
}
