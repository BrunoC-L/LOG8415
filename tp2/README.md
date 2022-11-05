# LOG8415 TP3
Aicha, Bruno, Mirado, Quentin

## files to use and how
__run.sh__: Main file. Sets up everything to launch an instance. This is the file you run on your computer after having correctly configured the aws credentials (to be able to launch instances)<br>

__setupInstance.sh__: This script runs on the instance at initialization. We pass it through the --user-data when launching the instance. It installs docker, builds our custom docker image and launches a docker container with the image. After the container is done running, it recovers the result files from it. <br>

__Dockerfile__: File that we use to build our custom docker image. It builds an ubuntu focal image with pyspark and hadoop installed. When the container using this image is run, docker-run.sh is launched on the container.<br>

__docker-run.sh__: Executes the hadoop vs Linux, hadoop Vs Spark and the solution to the social network problem. <br>

__run.sh__: Main file. Sets up everything to launch an instance. This is the file you run on your computer after having correctly configured the aws credentials (to be able to launch instances)<br>

__run.sh__: Main file. Sets up everything to launch an instance. This is the file you run on your computer after having correctly configured the aws credentials (to be able to launch instances)<br>