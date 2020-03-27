#!/usr/bin/env groovy

OCP_VERSIONS = ["4.3"]

// define stages (stage requires re-deployment of OCP environment)

// Topology Manager
STAGE_TM_JOBS = ["OCP-PERF-CONFIG", "OCP-TM-E2E"]

// Ripsaw
STAGE_RIPSAW_OVN_JOBS = ["OCP-RIPSAW-OVN"]
STAGE_RIPSAW_SRIOV_JOBS = ["OCP-RIPSAW-SRIOV"]
STAGE_SCALE_JOBS = ["OCP-SCALE"]

pipeline {
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
		stage('OVN RIPSAW') {
			steps {
				script {
					def jobDeploy = build job: "OVN-UPI-Install-${OCP_VERSIONS[0]}", wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						for (int i = 0; i < STAGE_RIPSAW_OVN_JOBS.size(); i++) {
							echo "running ${STAGE_RIPSAW_OVN_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_RIPSAW_OVN_JOBS[i]}", wait: true
								echo "stage job ${STAGE_RIPSAW_OVN_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_RIPSAW_OVN_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_RIPSAW_SRIOV_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_RIPSAW_SRIOV_JOBS[i]}", wait: true
								echo "stage job ${STAGE_RIPSAW_SRIOV_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_RIPSAW_SRIOV_JOBS[i]} failed"
							}
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
							echo "running ${STAGE_SCALE_JOBS[i]} on ${OCP_VERSIONS[0]}"
							try {
								build job: "${STAGE_SCALE_JOBS[i]}", wait: true
								echo "stage job ${STAGE_SCALE_JOBS[i]} succeeded"
							}
							catch (err) {
								echo "stage job ${STAGE_SCALE_JOBS[i]} failed"
							}
						}
					}
				}
			}
		}
	}
}
