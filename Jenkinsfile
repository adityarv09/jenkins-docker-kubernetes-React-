pipeline {
    agent { label 'slave-node' }
    
    environment {
        GITHUB_REPO_URL = "https://github.com/M95kandan/end-to-end-CI-CD"
        DOCKERHUB_USERNAME = "m95kandan"
        DOCKERHUB_PASSWORD = "Enter_docker_pass"
        DOCKERHUB_REPOSITORY = "m95kandan/website"
        BUILD_NUMBER_TAG = "${BUILD_NUMBER}"
        RETRY_COUNT = 3
        RETRY_INTERVAL = 60  // seconds
    }
    
    // stages {
    //     stage('Clone Repository') {
    //         steps {
    //             script {
    //                 // Clone the repository
    //                 git branch: 'main', url: 'https://github.com/M95kandan/end-to-end-CI-CD'
    //             }
    //         }
    //     }

        stage('Build Docker Image') {
            steps {
                script {
                    retry(RETRY_COUNT) {
                        ansiblePlaybook(
                            playbook: 'docker-build.yml',
                            inventory: 'inventory',
                            extraVars: [
                                github_repo_url: GITHUB_REPO_URL,
                                dockerhub_username: DOCKERHUB_USERNAME,
                                dockerhub_password: DOCKERHUB_PASSWORD,
                                dockerhub_repository: DOCKERHUB_REPOSITORY,
                                build_number_tag: BUILD_NUMBER_TAG
                            ]
                        )
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    retry(RETRY_COUNT) {
                        ansiblePlaybook(
                            playbook: 'docker-push.yml',
                            inventory: 'inventory',
                            extraVars: [
                                dockerhub_username: DOCKERHUB_USERNAME,
                                dockerhub_password: DOCKERHUB_PASSWORD,
                                dockerhub_repository: DOCKERHUB_REPOSITORY,
                                build_number_tag: BUILD_NUMBER_TAG
                            ]
                        )
                    }
                }
            }
        }

        stage('Notify Approval') {
            steps {
                script {
                    mail to: 'manikandanprakash.p@gmail.com', subject: 'Pipeline waiting for Approval?', body: '''Hi,

This is the mail for getting approved to deploy into production'''
                }
            }
        }

        stage('Approved') {
            steps {
                script {
                    Boolean userInput = input(id: 'Proceed1', message: 'Promote build?', parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm you agree with this']])
                    echo 'userInput: ' + userInput

                    if(userInput == true) {
                        // do action
                    } else {
                        // not do action
                        echo "Action was aborted."
                    }
                }
            }
        }

        stage('Run K8sMasterSlave playbook') {
            steps {
                script {
                    retry(RETRY_COUNT) {
                        ansiblePlaybook(
                            playbook: 'K8sMasterSlave.yml',
                            inventory: 'inventory'
                        )
                    }
                }
            }
        }

        stage('Deploy Application on Kubernetes') {
            steps {
                script {
                    retry(RETRY_COUNT) {
                        ansiblePlaybook(
                            playbook: 'k8sAppDeploy.yml',
                            inventory: 'inventory'
                        )
                    }
                }
            }
        }
          stage('Creating scrvice on Kubernetes') {
            steps {
                script {
                    retry(RETRY_COUNT) {
                        ansiblePlaybook(
                            playbook: 'service-playbook.yml',
                            inventory: 'inventory'
                        )
                    }
                }
            }
        }
    
    }
    



 post {
        success {
            emailext body: '''Hi Manikandan,

Our latest version has launched successfully!

Best regards,
Jenkins''', 
            subject: 'Pipeline of CI/CD has run successfully!',
            to: 'manikandanprakash.p@gmail.com'
        }
        
        failure {
            emailext body: '''Hi Manikandan,

Unfortunately, the pipeline of CI/CD has failed.

Best regards,
Jenkins''', 
            subject: 'Pipeline of CI/CD has failed!',
            to: 'manikandanprakash.p@gmail.com'
        }
    }
}
