#!/usr/bin/env groovy

pipeline {
	agent any
	stages {
		stage('OCP Multus') {
			steps {
				script {
					def jobDeploy = build job: 'OVN-UPI-Install-4.4', wait: true, propagate: false
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
	}
}
