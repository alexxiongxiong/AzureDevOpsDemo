#Used to preconfigure the Azure DevOps agent

#!/bin/bash
uname -a
echo "The image tag in this release is ${tag}!"
echo "The image tag in this release is ${BUILD_BUILDID}!" 
echo ${BUILD_SOURCEBRANCH}