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
							echo "running ${STAGE_MULTUS_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_MULTUS_JOBS[i]}", wait: true
								echo "stage job ${STAGE_MULTUS_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_MULTUS_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_TM_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_TM_JOBS[i]}", wait: true
								echo "stage job ${STAGE_TM_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_TM_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_SRIOV_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_SRIOV_JOBS[i]}", wait: true
								echo "stage job ${STAGE_SRIOV_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_SRIOV_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_SRIOV_CONFORMANCE_JOBS[i]}", wait: true
								echo "stage job ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_SRIOV_CONFORMANCE_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_OVN_E2E_NETWORK_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_OVN_E2E_NETWORK_JOBS[i]}", wait: true
								echo "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_OVN_E2E_NETWORK_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_OVN_E2E_SERIAL_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_OVN_E2E_SERIAL_JOBS[i]}", wait: true
								echo "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_OVN_E2E_SERIAL_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_OVN_E2E_PARALLEL_JOBS[i]}", wait: true
								echo "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_OVN_E2E_PARALLEL_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_SDN_MIGRATION_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_SDN_MIGRATION_JOBS[i]}", wait: true
								echo "stage job ${STAGE_SDN_MIGRATION_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_SDN_MIGRATION_JOBS[i]} failed, exiting"

								// exit won't skip following stages
								// exit when any of migration task failed
								exit 0
							}
						}
					}
				}
			}
		}
	}
}
