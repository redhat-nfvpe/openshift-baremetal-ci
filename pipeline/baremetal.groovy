#!/usr/bin/env groovy

pipeline {
	agent {
		node {
			label 'nfvpe-multus-05'
		}
	}
	stages {
		stage('OCP Multus') {
			steps {
				script {
					def jobDeploy = build job: 'OVN-UPI-Install', wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						build job: 'OCP-Multus-E2E', wait: true
						build job: 'OCP-PTP-DEV', wait: true
						build job: 'OCP-SRIOV-DEV', wait: true
						build job: 'OCP-SRIOV-CONFORMANCE', wait: true
						build job: 'OCP-SRIOV-OPERATOR-E2E', wait: true
					}
				}
			}
		}
		stage('OCP RIPSAW OVN') {
			steps {
				script {
					def jobDeploy = build job: 'OVN-UPI-Install', wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						build job: 'OCP-RIPSAW-OVN', wait: true
					}
				}
			}
		}
		stage('OCP RIPSAW SRIOV') {
			steps {
				script {
					def jobDeploy = build job: 'OVN-UPI-Install', wait: true, propagate: false
					def jobDeployResult = jobDeploy.getResult()

					if (jobDeployResult == 'SUCCESS') {
						build job: 'OCP-RIPSAW-SRIOV', wait: true
					}
				}
			}
		}
	}
}
