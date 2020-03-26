OCP_VERSIONS = [ "OCP" ]
pipeline {
    agent any
    stages {
        stage('-1') {
            steps {
		        script {
		            echo "running ${OCP_VERSIONS[0]}"
		            JOBS = ["OCP-TEST-PASSWORD-PARAMETER", "${OCP_VERSIONS[0]}-PTP-DEV", "OCP-TEST-PASSWORD-PARAMETER"]
		            for (int i = 0; i < JOBS.size(); i++) {
		                try {
                            echo "${JOBS[i]}"
                            build job: "${JOBS[i]}", wait: true
		                }
		                catch (err) {
		                    echo "stage -1 - step ${JOBS[i]} failed"
		                }
		            }
		        }
            }
        }
        stage('0') {
            steps {
		        script {
		            def jobDeploy = build job: 'OCP-PTP-DEV', wait: true, propagate: false
		            def jobDeployResult = jobDeploy.getResult()
		            if (jobDeployResult == 'SUCCESS') {
		                build job: 'OCP-TEST-PASSWORD-PARAMETER', wait: true
		            }
		        }
            }
        }
        stage('1') {
            steps {
		        script {
		            try {
                            build job: 'OCP-TEST-PASSWORD-PARAMETER', wait: true
                            build job: 'OCP-PTP-DEV', wait: true
		            }
		            catch (err) {
		                echo "stage 1 failed"
		            }
		        }
            }
        }
        stage('2') {
            steps {
		        script {
			        try {
                        build job: 'OCP-TEST-PASSWORD-PARAMETER', wait: true
                        build job: 'OCP-PTP-DEV', wait: true
			        }
			        catch (err) {
				        echo 'stage 2 failed'
			        }
		        }
            }
		}
        stage('3') {
		    steps {
		        script {
			        sh 'exit 0'
		        }
		    }
		}
    }
}
