#!/usr/bin/env groovy

OCP_VERSIONS = ["master"]
// OVN
STAGE_OVN_E2E_NETWORK_JOBS = ["OVN-E2E-Network"]
STAGE_OVN_E2E_SERIAL_JOBS = ["OVN-E2E-Conformance-Serial"]
STAGE_OVN_E2E_PARALLEL_JOBS = ["OVN-E2E-Conformance-Parallel"]
// STAGE_SCALE_JOBS = ["OCP-SCALE"]

def log(String level, String str) {
    switch (level) {
        case 'err': echo "\033[31m [ERROR]: $str \033[0m"; break
        case 'warn': echo "\033[33m [WARNING]: $str \033[0m"; break
        case 'skip': echo "\033[34m [SKIPPED]: $str \033[0m"; break
        case 'success': echo "\033[32m [SUCCESS]: $str \033[0m"; break
        default: echo "$str"
    }
}

pipeline {
    options {
        ansiColor('xterm')
    }
    agent any
    stages {
        stage ('Build Cluster') {
            steps {
                build job: 'OCP_Baremetal_IPI_OVN_master'
            }
        }

        stage ('Enable Hardware Offloading') {
            steps {
                build job: 'OCP_Baremetal_IPI_OVN_master'
            }
        }

        stage('OVN E2E') {
            steps {
                catchError(stageResult: 'FAILURE') {
                    script {
                        def result = 0 
                        for (int i = 0; i < STAGE_OVN_E2E_NETWORK_JOBS.size(); i++) {
                            log("", "running ${STAGE_OVN_E2E_NETWORK_JOBS[i]} on ${OCP_VERSIONS[0]}")
                            try {
                                build job: "${STAGE_OVN_E2E_NETWORK_JOBS[i]}", wait: true
                                log("success", "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} succeeded")
                            }
                            catch (err) {
                                log("err", "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} failed")
                                result = 1
                            }
                        }
                        sh "exit $result"
                    }
                }
            }
        }
        
        stage('OVN Conformance Serial') {
            steps {
                catchError(stageResult: 'FAILURE') {
                    script {
                        def result = 0 
                        for (int i = 0; i < STAGE_OVN_E2E_SERIAL_JOBS.size(); i++) {
                            log("", "running ${STAGE_OVN_E2E_SERIAL_JOBS[i]} on ${OCP_VERSIONS[0]}")
                            try {
                                build job: "${STAGE_OVN_E2E_SERIAL_JOBS[i]}", wait: true
                                log("success", "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} succeeded")
                            }
                            catch (err) {
                                log("err", "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} failed")
                                result = 1
                            }
                        }
                        sh "exit $result"
                    }
                }
            }
        }

        stage('OVN Conformance Parallel') {
            steps {
                catchError(stageResult: 'FAILURE') {
                    script {
                        def result = 0 
                        for (int i = 0; i < STAGE_OVN_E2E_PARALLEL_JOBS.size(); i++) {
                            log("", "running ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} on ${OCP_VERSIONS[0]}")
                            try {
                                build job: "${STAGE_OVN_E2E_PARALLEL_JOBS[i]}", wait: true
                                log("success", "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} succeeded")
                            }
                            catch (err) {
                                log("err", "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} failed")
                                result = 1
                            }
                        }
                        sh "exit $result"
                    }
                }
            }
        }
    }
}
