#!/usr/bin/env groovy

OCP_VERSIONS = ["4.3"]

// define stages (stage requires re-deployment of OCP environment)

// Topology Manager
STAGE_TM_JOBS = ["OCP-PERF-CONFIG", "OCP-SRIOV-Install", "OCP-TM-E2E"]

// Ripsaw
STAGE_RIPSAW_OVN_JOBS = ["OCP-RIPSAW-OVN"]
STAGE_RIPSAW_SRIOV_JOBS = ["OCP-RIPSAW-SRIOV"]
STAGE_SCALE_JOBS = ["OCP-SCALE"]

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
		// stage cannot contain variable
		// stage uses single quotes
		stage('TM') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_TM_JOBS.size(); i++) {
							log("", "running ${STAGE_TM_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_TM_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_TM_JOBS[i]} succeeded")
							}
							catch (err) {
                                                                log("err", "stage job ${STAGE_TM_JOBS[i]} failed")

                                                                // warning: stage doesn't complete due to previous job failure
                                                                for (int j = i+1; j < STAGE_TM_JOBS.size(); j++) {
                                                                        log("warn", "${STAGE_TM_JOBS[j]} skipped")
                                                                }

                                                                // exit won't skip following stages
                                                                // exit when any of TM task failed
                                                                exit 0
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_TM_JOBS.size(); i++) {
							log("skip", "${STAGE_TM_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('OVN RIPSAW') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_RIPSAW_OVN_JOBS.size(); i++) {
							log("", "running ${STAGE_RIPSAW_OVN_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_RIPSAW_OVN_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_RIPSAW_OVN_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err" "stage job ${STAGE_RIPSAW_OVN_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_RIPSAW_OVN_JOBS.size(); i++) {
							log("skip", "${STAGE_RIPSAW_OVN_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('SR-IOV RIPSAW') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_RIPSAW_SRIOV_JOBS.size(); i++) {
							log("", "running ${STAGE_RIPSAW_SRIOV_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_RIPSAW_SRIOV_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_RIPSAW_SRIOV_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_RIPSAW_SRIOV_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_RIPSAW_SRIOV_JOBS.size(); i++) {
							log("skip", "${STAGE_RIPSAW_SRIOV_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('OVN Scale') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_SCALE_JOBS.size(); i++) {
							log("", "running ${STAGE_SCALE_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_SCALE_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_SCALE_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_SCALE_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_SCALE_JOBS.size(); i++) {
							log("skip", "${STAGE_SCALE_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
	}
}
