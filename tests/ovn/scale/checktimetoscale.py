#!/usr/bin/env python

import argparse
import subprocess
import time


def main(scale, namespaces, deploymentname):
    print("Desired scale is {0} and namespaces is {1}".format(
        scale, namespaces))
    pod_count = 0
    replicas = scale/namespaces
    cmd = "oc get pods -o wide -A | grep {0} | grep Running | wc -l".format(
        deploymentname)
    start = time.time()
    for namespace in range(0, namespaces):
        nsname = "test-" + str(namespace+1)
        subprocess.call(["oc", "scale", "deployment", deploymentname,
                         "--replicas", str(replicas), "-n", nsname])

    while int(pod_count) != scale:
        pod_count = subprocess.check_output([cmd], shell=True)
        print("Current pod count is {0}".format(pod_count))
        time.sleep(1)
    end = time.time()
    out = """It took {0}s to scale deployment {1} to {2} pods in {3} namespaces""".format(end - start, deploymentname, scale, namespaces)
    print(out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Script to compute time taken to scale pods")
    parser.add_argument('scale', type=int,
                        help="input the desired scale to achieve")
    parser.add_argument('namespaces', type=int,
                        help="input the number of namespaces")
    parser.add_argument('deployment',
                        help="the name of deployment in each namespace")

    args = parser.parse_args()
    main(args.scale, args.namespaces, args.deployment)
