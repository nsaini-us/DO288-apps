#!/bin/bash
#NPM_REGISTRY=http://${RHT_OCP4_NEXUS_SERVER}/repository/nodejs
#

# deploy a database
# oc new-app --name tododb --docker-image registry.access.redhat.com/rhscl/mysql-57-rhel7 \
#	-e MYSQL_USER=todoapp -e MYSQL_PASSWORD=mypass -e MYSQL_DATABASE=todo
#
# oc port-forward 3306:3306
# in another terminal initilize the db
# mysql -h127.0.0.1 -utodoapp -pmypass todo < todo-multicontainer/todo.sql
# this loads some test data

# if nodejs:8 is not found use-
# oc tag docker.io/centos/nodejs-8-centos7 -n openshift nodejs:8
# this tags nodejs-8-centos7 to nodejs:8 and makes it avaialable to s2i

oc new-app --name backend \
	--build-env npm_config_registry=${NPM_REGISTRY} \
	-e DATABASE_NAME=todo -e DATABASE_USER=todoapp -e DATABASE_PASSWORD=mypass -e DATABASE_SVC=tododb \
	--context-dir todo-backend nodejs:8~https://github.com/nsaini-us/DO288-apps#review-service

# expose svc
oc expose svc/backend
#
# now test the endpoint
# curl -siw "\n" $ROUTE/todo/api/items-counts
#
# {"count":6}
# 
# you can now create secrets and configMaps for the parameters above
#
# oc set triggers dc/tododb --from-config --remove
# oc create secret generic tododb --from-literal user=todoapp --from-literal password=mypass
# oc set env dc/tododb --from secret/tododb --prefix=MYSQL_
# 
# oc set env dc/tododb --list
#
# all done -- rollout the deploymentConfig as triggers were removed...will not automatically rollout
# oc rollout latest dc/tododb
# now backend
#
# oc set triggers dc/backend --from-config --remove
# oc set env dc/backend --from secret/tododb --prefix DATABASE_
# oc create cm todoapp --from-literal init=true
# oc set env dc/backend --from cm/todoapp --prefix DATABASE_
#
# oc set env dc/backend --list
#
# all done -- rollout the deploymentConfig as triggers were removed...will not automatically rollout
# oc rollout latest dc/backend
#
#
# to load up the db
# oc rsh tododb-2-dr7wc /opt/rh/rh-mysql57/root/usr/bin/mysql -utodoapp -pmypass todo < todo.sql
#
