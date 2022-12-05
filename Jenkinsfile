def SetPath(nodejsversion) {
  return sh (script: ". nvmuse " + nodejsversion,returnStdout: true).trim()
}

pipeline {
    agent {
        node {
            label 'master'
        }
    }

    environment {
        PROJECT_NAME= "ruby_cucumber_allure"
        URL_ALLURE_BUILD = null
        URL_BUILD = null

        // Docker Config
        DOCKER_USER_LOGIN = credentials('DOCKER_USER_LOGIN ')
        DOCKER_USER_PASS = credentials('DOCKER_USER_PASS ')
        DOCKER_REPOSITORY = credentials('DOCKER_REPOSITORY')

        // NODE CONFIG
        NODEJS_VERSION = 'v14.17'
        NODE_PATH = SetPath("${env.NODEJS_VERSION}")

        // Linguagem
        TYPE_COMPILE_LANG = "ruby"

        // STYLES
        INFO_COLOR = '#3498DB'
        ERROR_COLOR = 'danger'
        SUCCESS_COLOR = 'good'
        ALERT_COLOR = '#fffb1b'
        
    }

    options {
        timeout(time: 2, unit: 'HOURS')
    }

    stages {

        stage('Get env') {
            steps {
                parallel(
                'Set environment': {
                    script {
                        env.PREVIOUS = env.BUILD_NUMBER - 1
                        env.DOCKER_BUILD_TAG = "$DOCKER_REPOSITORY/$PROJECT_NAME"
                    }
                },

                'Login at docker': {
                    sh '''
                    set +x
                    docker login $DOCKER_REPOSITORY -u $DOCKER_USER_LOGIN -p $DOCKER_USER_PASS
                    set -x
                    '''
                },
                )
            }
        }

            
        stage('DOCKER Pull -> Build -> Push') {
            steps {
                sh '''
                docker pull $DOCKER_PREVIUS_BUILD_TAG || echo "Docker pull fail"
                docker build -t $DOCKER_BUILD_TAG . -f Dockerfile
                docker push $DOCKER_BUILD_TAG'
                '''
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
                        bundle exec ${tipo_exec} -t ${tag} -p ${ambiente}
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
