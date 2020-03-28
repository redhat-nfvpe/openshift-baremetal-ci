#!/usr/bin/env groovy

OCP_VERSIONS = ["4.3"]

// define stages (stage requires re-deployment of OCP environment)

// Multus, SR-IOV and PTP Dev
STAGE_MULTUS_JOBS = ["OCP-Multus-E2E", "OCP-PTP-DEV"]
STAGE_SRIOV_JOBS = ["OCP-SRIOV-DEV", "OCP-SRIOV-OPERATOR-E2E"]
STAGE_SRIOV_CONFORMANCE_JOBS = ["OCP-SRIOV-CONFORMANCE"]

// Topology Manager
STAGE_TM_JOBS = ["OCP-PERF-CONFIG", "OCP-TM-E2E"]

// OVN
STAGE_OVN_E2E_NETWORK_JOBS = ["OVN-E2E-Network"]
STAGE_OVN_E2E_SERIAL_JOBS = ["OVN-E2E-Conformance-Serial"]
STAGE_OVN_E2E_PARALLEL_JOBS = ["OVN-E2E-Conformance-Parallel"]
// STAGE_SCALE_JOBS = ["OCP-SCALE"]

// Migration
STAGE_SDN_MIGRATION_JOBS = ["OCP-Networking-SDN-Migration", "OVN-E2E-Conformance-Serial", "OCP-Networking-SDN-Rollback"]

// Ripsaw
// STAGE_RIPSAW_OVN_JOBS = ["OCP-RIPSAW-OVN"]
// STAGE_RIPSAW_SRIOV_JOBS = ["OCP-RIPSAW-SRIOV"]

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
	agent any
	stages {
		// stage cannot contain variable
		// stage uses single quotes
		stage('Multus') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_MULTUS_JOBS.size(); i++) {
							log("", "running ${STAGE_MULTUS_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_MULTUS_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_MULTUS_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_MULTUS_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_MULTUS_JOBS.size(); i++) {
							log("skip", "${STAGE_MULTUS_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
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
		stage('SR-IOV') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_SRIOV_JOBS.size(); i++) {
							log("", "running ${STAGE_SRIOV_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_SRIOV_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_SRIOV_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_SRIOV_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_SRIOV_JOBS.size(); i++) {
							log("skip", "${STAGE_SRIOV_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('SR-IOV Conformance') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_SRIOV_CONFORMANCE_JOBS.size(); i++) {
							log("", "running ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_SRIOV_CONFORMANCE_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_SRIOV_CONFORMANCE_JOBS.size(); i++) {
							log("skip", "${STAGE_SRIOV_CONFORMANCE_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('OVN E2E Network') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_OVN_E2E_NETWORK_JOBS.size(); i++) {
							log("", "running ${STAGE_OVN_E2E_NETWORK_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_OVN_E2E_NETWORK_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_OVN_E2E_NETWORK_JOBS.size(); i++) {
							log("skip", "${STAGE_OVN_E2E_NETWORK_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('OVN E2E Serial') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_OVN_E2E_SERIAL_JOBS.size(); i++) {
							log("", "running ${STAGE_OVN_E2E_SERIAL_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_OVN_E2E_SERIAL_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_OVN_E2E_SERIAL_JOBS.size(); i++) {
							log("skip", "${STAGE_OVN_E2E_SERIAL_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('OVN E2E Parallel') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_OVN_E2E_PARALLEL_JOBS.size(); i++) {
							log("", "running ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_OVN_E2E_PARALLEL_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} failed")
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_OVN_E2E_PARALLEL_JOBS.size(); i++) {
							log("skip", "${STAGE_OVN_E2E_PARALLEL_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
		stage('SDN Migration') {
			steps {
				script {
					def jobDeploy = build job: 'OCP-UPI-Install-SDN-4.5', wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_SDN_MIGRATION_JOBS.size(); i++) {
							log("", "running ${STAGE_SDN_MIGRATION_JOBS[i]} on ${OCP_VERSIONS[0]}")
							try {
								build job: "${STAGE_SDN_MIGRATION_JOBS[i]}", wait: true
								log("success", "stage job ${STAGE_SDN_MIGRATION_JOBS[i]} succeeded")
							}
							catch (err) {
								log("err", "stage job ${STAGE_SDN_MIGRATION_JOBS[i]} failed, exiting")

								// warning: stage doesn't complete due to previous job failure
								for (int j = i+1; j < STAGE_SDN_MIGRATION_JOBS.size(); j++) {
									log("warn", "${STAGE_SDN_MIGRATION_JOBS[j]} skipped")
								}

								// exit won't skip following stages
								// exit when any of migration task failed
								exit 0
							}
						}
					} else {
						log("err", "OCP Installation OVN-UPI-Install-${OCP_VERSIONS[0]} failed")
						for (int i = 0; i < STAGE_SDN_MIGRATION_JOBS.size(); i++) {
							log("skip", "${STAGE_SDN_MIGRATION_JOBS[i]} skipped due to failed ocp install")
						}
					}
				}
			}
		}
	}
}
