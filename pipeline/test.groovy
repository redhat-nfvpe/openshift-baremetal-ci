SERVERDIRS = [ "%SERVERLINUXDIR%" , "%SERVERLINUXARMDIR%" ]

pipeline{
    environment {
		SERVERLINUXDIR		="Linux"
		SERVERLINUXARMDIR	="Linux-ARM"
    }
    stages	{
        stage ('Debug') {
            steps	{
				script{
					for (int i = 0; i < SERVERDIRS.size(); i++) {
						bat "echo Test Var ${SERVERDIRS[i]}"
					}
			      }
            }
    }
}
