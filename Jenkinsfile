def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']

pipeline {
    agent {
        docker {
            image "ruby:alpine"
            args "--network=skynet"
        }
    }

    environment {
        PROJECT_NAME= "ruby_cucumber_allure"        
    }

    options {
        timeout(time: 2, unit: 'HOURS')
    }

    stages {

        stage("Build") {
            steps {
                sh "chmod +x build/alpine.sh"
                sh "./build/alpine.sh"
                sh "bundle install"
            }
        }


        stage('TESTES API') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        echo 'Executando testes em paralelo'
                        sh """
                        docker run --rm --network host \
                        -v ${env.WORKSPACE}/allure-results:/$PROJECT_NAME/allure-results \
                        -i $DOCKER_BUILD_TAG \
                        bundle execparallel_cucumber -o "-t @smoke -p hml" features
                        """
                    }
                }
            }
        }

        stage('Quality Gate - Relatório') {
            steps {
                script {
                    allure([
                        includeProperties: false,
                        jdk: '',
                        properties: [],
                        reportBuildPolicy: 'ALWAYS',
                        results: [
                            [
                                path: '/allure-results'
                                ]
                            ]
                        ]
                    )
                }
            }
        }   
    }
}
