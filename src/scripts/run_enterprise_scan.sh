#!/bin/bash
set +e
docker run --rm --pull=always \
-u "$(id -u)" -v "$(pwd)":"$(pwd)" -w "$(pwd)" \
-e BURP_ENTERPRISE_SERVER_URL="$(circleci env subst "${PARAM_ENTERPRISE_SERVER_URL}")" \
-e BURP_ENTERPRISE_API_KEY="$(circleci env subst "${PARAM_ENTERPRISE_API_KEY}")" \
-e BURP_START_URL="$(circleci env subst "${PARAM_START_URL}")" \
-e BURP_REPORT_FILE_PATH="$(circleci env subst "${PARAM_REPORT_FILE_PATH}")" \
-e BURP_CONFIG_FILE_PATH="$(circleci env subst "${PARAM_CONFIG_FILE_PATH}")" \
public.ecr.aws/portswigger/enterprise-scan-container:latest
exitCode=$?
if [ "$exitCode" -eq 1 ] && [ "${PARAM_FAIL_ON_FAILURE}" -eq 0 ]
then
    exit 0
else
    exit "$exitCode"
fi