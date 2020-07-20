#!/bin/bash
APPSURL=apps.ns-cluster.cp.fyre.ibm.com

# oc new-project nsaini-common
# 
# oc process --parameters -f todoapp.yaml
# oc new-app --dry-run -f todoapp.yaml -p PASSWORD=x -p HOSTNAME=y -p BACKEND=z
# create template
# oc create -f todoapp.yaml
# oc process --parameters todoapp # list parameters
#
# podman login -u nsaini quay.io
# oc create secret generic quayio --from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json \
#	--type kubernetes.io/dockerconfigjson
#
# oc import-image todo-frontend --confirm --reference-policy local --from quay.io/nsaini/todo-frontend
# 
# oc tag docker.io/centos/nodejs-8-centos7 -n openshift nodejs:8
# 
# The backend is a s2i (nodejs app) therefore we need to tag the nodejs image as by default there was no nodejs:8
#
# oc new-project nsaini-multicontainers
# oc policy add-role-to-group -n nsaini-common system:image-puller system:serviceaccounts:nsaini-multicontainers
#
oc new-app nsaini-common/todoapp -p PASSWORD=redhat -p CLEAN_DATABASE=false \
	-p HOSTNAME=todoui.${APPSURL} -p BACKEND=todoapi.${APPSURL}
#
# this deploys 3 containers. 
# 1. Frontend = NGINX image
#	this image is stored in quay.io and is imported into a "nsaini-common" project for other projects to reuse
# 2. Backend = nodejs s2i image with API hitting the DB
#	nodejs s2i image which implements the API
# 3. DB data that backend uses to expose an API
#	mysql image
# 
# oc logs -f bc/backend
# 
# if frontend is not deploying...you will have to change the FRONTEND Image namespace by editing the dc
# oc edit dc/frontend
# change image project to nsaini-common
#
# Backend will go into a crashbackoff loop as "Readiness/Liveness" probes are failing.
# this is because there is no data in the db
#
# populate db
# oc rsh tododb-pod  /opt/rh/rh-mysql57/root/usr/bin/mysql -utodoapp -predhat todo < todo.sql
#
# check the logs
# get the route
# oc get route
# curl -siw "\n" todoapi.${APPSURL}/todo/api/items-count
#
