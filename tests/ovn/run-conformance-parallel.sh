#!/bin/bash
set -x
set -e

pushd origin

OPENSHIFT_TESTS=$(realpath ./openshift-tests)

# run conformance parallel tests
# grep -v -f ../conformance-parallel-exclude.txt | \
$OPENSHIFT_TESTS run openshift/conformance/parallel --dry-run | \
	grep -v "Networking should provide Internet connection for containers" | \
	$OPENSHIFT_TESTS run -o ./comformance-parallel.e2e.log --junit-dir ./parallel.junit -f -

popd

#	grep -v "Networking should provide Internet connection for containers" | \
#	grep -v "OAuth server should use http1.1 only to prevent http2 connection reuse" | \
#	grep -v "expected headers returned from the authorize URL" | \
#	grep -v "expected headers returned from the grant URL" | \
#	grep -v "expected headers returned from the login URL for the allow all IDP" | \
#	grep -v "expected headers returned from the login URL for the bootstrap IDP" | \
#	grep -v "expected headers returned from the login URL for when there is only one IDP" | \
#	grep -v "expected headers returned from the logout URL" | \
#	grep -v "expected headers returned from the root URL" | \
#	grep -v "expected headers returned from the token URL" | \
#	grep -v "expected headers returned from the token request URL" | \


# 1. [Conformance][templates] templateinstance readiness test  should report failed soon after an annotated objects has failed [Suite:openshift/conformance/parallel/minimal]

# Internal Registry Hostname is not set in image config object
# Timed out waiting for internal registry hostname to be published


# 2. [Conformance][templates] templateinstance readiness test  should report ready soon after all annotated objects are ready [Suite:openshift/conformance/parallel/minimal]

# Internal Registry Hostname is not set in image config object
# Timed out waiting for internal registry hostname to be published

# 3. [Feature:Builds] Multi-stage image builds  should succeed [Conformance] [Suite:openshift/conformance/parallel/minimal]

#         Cmd: "oc --namespace=e2e-test-build-multistage-2rqks --kubeconfig=/tmp/configfile189164784 registry info"
#         StdErr: "error: the integrated registry has not been configured",

# 4. [Feature:Builds] result image should have proper labels set  Docker build from a template should create a image from "test-docker-build.json" template with proper Docker labels [Suite:openshift/conformance/parallel]

# event for test-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 5. [Feature:Builds] result image should have proper labels set  S2I build from a template should create a image from "test-s2i-build.json" template with proper Docker labels [Suite:openshift/conformance/parallel]

# event for test-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 6. [Feature:Builds][Conformance] build can reference a cluster service  with a build being created from new-build should be able to run a build that references a cluster service [Suite:openshift/conformance/parallel/minimal]

# event for centos-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 7. [Feature:Builds][Conformance] custom build with buildah  being created from new-build should complete build with custom builder image [Suite:openshift/conformance/parallel/minimal]

# event for custom-builder-image-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 8. [Feature:Builds][Conformance] oc new-app  should fail with a --name longer than 58 characters [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 9. [Feature:Builds][Conformance] oc new-app  should succeed with a --name of 58 characters [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 10. [Feature:Builds][Conformance] oc new-app  should succeed with an imagestream [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 11. [Feature:Builds][Conformance] s2i build with a root user image should create a root build and pass with a privileged SCC [Suite:openshift/conformance/parallel/minimal]

# Jan 19 17:39:18.819: INFO: At 2020-01-19 17:28:47 -0500 EST - event for nodejspass: {buildconfig-controller } BuildConfigInstantiateFailed: error instantiating Build from BuildConfig e2e-test-s2i-build-root-ffglq/nodejspass (0): Error resolving ImageStreamTag test-build-roots2i:latest in namespace e2e-test-s2i-build-root-ffglq: unable to find latest tagged image
# Jan 19 17:39:18.819: INFO: At 2020-01-19 17:28:48 -0500 EST - event for nodejspass-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 12. [Feature:Builds][Conformance][valueFrom] process valueFrom in build strategy environment variables  should fail resolving unresolvable valueFrom in docker build environment variable references [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 13. [Feature:Builds][Conformance][valueFrom] process valueFrom in build strategy environment variables  should fail resolving unresolvable valueFrom in sti build environment variable references [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 14. [Feature:Builds][Conformance][valueFrom] process valueFrom in build strategy environment variables  should successfully resolve valueFrom in docker build environment variables [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 15. [Feature:Builds][Conformance][valueFrom] process valueFrom in build strategy environment variables  should successfully resolve valueFrom in s2i build environment variables [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 16. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  [Conformance] buildconfigs should have a default history limit set when created via the group api [Suite:openshift/conformance/parallel/minimal]

# s: "Timed out waiting for internal registry hostname to be published",

# 17. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  should prune builds after a buildConfig change [Suite:openshift/conformance/parallel]
# 18. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  should prune canceled builds based on the failedBuildsHistoryLimit setting [Suite:openshift/conformance/parallel]
# 19. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  should prune completed builds based on the successfulBuildsHistoryLimit setting [Suite:openshift/conformance/parallel]
# 20. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  should prune errored builds based on the failedBuildsHistoryLimit setting [Suite:openshift/conformance/parallel]
# 21. [Feature:Builds][pruning] prune builds based on settings in the buildconfig  should prune failed builds based on the failedBuildsHistoryLimit setting [Suite:openshift/conformance/parallel]

# s: "Timed out waiting for internal registry hostname to be published",

# 22. event for docker-build-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured
 
# event for docker-build-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 23. [Feature:Builds][timing] capture build stages and durations  should record build stages and durations for docker [Suite:openshift/conformance/parallel]

# event for test-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 24. [Feature:Builds][timing] capture build stages and durations  should record build stages and durations for s2i [Suite:openshift/conformance/parallel]

# event for test-1: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 26. [Feature:DeploymentConfig] deploymentconfigs should respect image stream tag reference policy [Conformance] resolve the image pull spec [Suite:openshift/conformance/parallel/minimal]
# 27. [Feature:DeploymentConfig] deploymentconfigs with minimum ready seconds set [Conformance] should not transition the deployment to Complete before satisfied [Suite:openshift/conformance/parallel/minimal]

# image related

# 28. [Feature:ImageAppend] Image append should create images by appending them [Suite:openshift/conformance/parallel]

# fail [github.com/openshift/origin/test/extended/images/append.go:86]: registry not yet configured?

# 29. [Feature:ImageExtract] Image extract should extract content from an image [Suite:openshift/conformance/parallel]

# fail [github.com/openshift/origin/test/extended/images/extract.go:35]: registry not yet configured?

# 30. [Feature:ImageLayers][registry] Image layer subresource should return layers from tagged images [Suite:openshift/conformance/parallel]

# event for output: {build-controller } InvalidOutput: Error starting build: an image stream cannot be used as build output because the integrated container image registry is not configured

# 31. [Feature:ImageLookup][registry][Conformance] Image policy should perform lookup when the pod has the resolve-names annotation [Suite:openshift/conformance/parallel/minimal]

# image related

# 32. [Feature:ImageLookup][registry][Conformance] Image policy should update standard Kube object image fields when local names are on [Suite:openshift/conformance/parallel/minimal]

# 33. [Feature:Image] oc tag should change image reference for internal images [Suite:openshift/conformance/parallel]

# StdErr: "error: the integrated registry has not been configured",

# 34. [Feature:OAuthServer] OAuth server should use http1.1 only to prevent http2 connection reuse [Suite:openshift/conformance/parallel]

# <string>: x509: certificate signed by unknown authority

# 35. [Feature:OAuthServer] [Headers] expected headers returned from the authorize URL [Suite:openshift/conformance/parallel]

# Jan 19 17:27:35.418: INFO: Waiting for the OAuth server route to be ready: x509: certificate signed by unknown authority
# Jan 19 17:27:36.411: INFO: Waiting for the OAuth server route to be ready

# 36. [Feature:OAuthServer] [Headers] expected headers returned from the grant URL [Suite:openshift/conformance/parallel]
# 37。 [Feature:OAuthServer] [Headers] expected headers returned from the login URL for the allow all IDP [Suite:openshift/conformance/parallel]
# 38. [Feature:OAuthServer] [Headers] expected headers returned from the login URL for the bootstrap IDP [Suite:openshift/conformance/parallel]
# 39. [Feature:OAuthServer] [Headers] expected headers returned from the login URL for when there is only one IDP [Suite:openshift/conformance/parallel]
# 40. [Feature:OAuthServer] [Headers] expected headers returned from the logout URL [Suite:openshift/conformance/parallel]
# 41. [Feature:OAuthServer] [Headers] expected headers returned from the root URL [Suite:openshift/conformance/parallel]
# 42. [Feature:OAuthServer] [Headers] expected headers returned from the token URL [Suite:openshift/conformance/parallel]
# 43. [Feature:OAuthServer] [Headers] expected headers returned from the token request URL [Suite:openshift/conformance/parallel]

# Jan 19 17:27:35.418: INFO: Waiting for the OAuth server route to be ready: x509: certificate signed by unknown authority
# Jan 19 17:27:36.411: INFO: Waiting for the OAuth server route to be ready

# 44. [Feature:OAuthServer] [Token Expiration] Using a OAuth client with a non-default token max age to generate tokens that do not expire works as expected when using a code authorization flow [Suite:openshift/conformance/parallel]
# 45. [Feature:OAuthServer] [Token Expiration] Using a OAuth client with a non-default token max age to generate tokens that do not expire works as expected when using a token authorization flow [Suite:openshift/conformance/parallel]
# 46. [Feature:OAuthServer] [Token Expiration] Using a OAuth client with a non-default token max age to generate tokens that expire shortly works as expected when using a code authorization flow [Suite:openshift/conformance/parallel]
# 47. [Feature:OAuthServer] [Token Expiration] Using a OAuth client with a non-default token max age to generate tokens that expire shortly works as expected when using a token authorization flow [Suite:openshift/conformance/parallel]

# Jan 19 17:27:35.418: INFO: Waiting for the OAuth server route to be ready: x509: certificate signed by unknown authority
# Jan 19 17:27:36.411: INFO: Waiting for the OAuth server route to be ready

# 48. [Feature:OAuthServer] well-known endpoint should be reachable [Suite:openshift/conformance/parallel]

# x509: certificate signed by unknown authority

# 49. [Feature:OpenShiftControllerManager] TestAutomaticCreationOfPullSecrets [Suite:openshift/conformance/parallel]
# 50. [Feature:OpenShiftControllerManager] TestDockercfgTokenDeletedController [Suite:openshift/conformance/parallel]

# fail [github.com/onsi/ginkgo/internal/leafnodes/runner.go:64]: pull secret was not created
# fail [github.com/onsi/ginkgo/internal/leafnodes/runner.go:64]: pull secret was not created

# 51. [Feature:Platform] Managed cluster should ensure control plane pods do not run in best-effort QoS [Suite:openshift/conformance/parallel]

# 1 pods found in best-effort QoS:
# openshift-infra/autoapprover-0 is running in best-effort QoS


# 52. [Feature:Platform] Managed cluster should ensure pods use downstream images from our release image with proper ImagePullPolicy [Suite:openshift/conformance/parallel]

# Jan 19 17:31:23.277: INFO: Pods with invalid dowstream images: 
# Jan 19 17:31:23.278: FAIL: Pods found with invalid container images not present in release payload: openshift-infra/autoapprover-0/signer image=registry.svc.ci.openshift.org/origin/4.2:cli

# 53. [Feature:Prometheus][Conformance] Prometheus when installed on the cluster should have important platform topology metrics [Suite:openshift/conformance/parallel/minimal]

# 54. [Feature:Prometheus][Conformance] Prometheus when installed on the cluster should have important platform topology metrics [Suite:openshift/conformance/parallel/minimal]
# 55. [Feature:Prometheus][Conformance] Prometheus when installed on the cluster shouldn't report any alerts in firing state apart from Watchdog and AlertmanagerReceiversNotConfigured [Suite:openshift/conformance/parallel/minimal]

# unknown

# 56. [Suite:openshift/oauth/htpasswd] HTPasswd IDP should successfully configure htpasswd and be responsive [Suite:openshift/conformance/parallel]

# Jan 19 17:11:09.066: INFO: Waiting for the OAuth server route to be ready: x509: certificate signed by unknown authority
# Jan 19 17:11:10.058: INFO: Waiting for the OAuth server route to be ready


# TLS: can't accept: error:14094412:SSL routines:ssl3_read_bytes:sslv3 alert bad certificate.
# 5e24d718 conn=1000 fd=14 closed (TLS negotiation failure)

# 57. [Suite:openshift/oauth] LDAP IDP should authenticate against an ldap server [Suite:openshift/conformance/parallel]
# 58. [Suite:openshift/oauth] LDAP should start an OpenLDAP test server [Suite:openshift/conformance/parallel]

# Jan 19 17:24:55.268: INFO: runonce-ldapsearch-pod[e2e-test-oauth-ldap-idp-z5srq].container[runonce-ldapsearch-pod].log
# ldap_start_tls: Connect error (-11)
# 	additional info: error:1416F086:SSL routines:tls_process_server_certificate:certificate verify failed (certificate is not yet valid)
# ldap_result: Can't contact LDAP server (-1)

# 59. [sig-network] Networking should provide Internet connection for containers [Feature:Networking-IPv4] [Suite:openshift/conformance/parallel] [Suite:k8s]

# nc: connect to 8.8.8.8 port 53 (tcp) failed: Connection refused
