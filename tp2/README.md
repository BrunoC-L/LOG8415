# LOG8415 TP3
Aicha, Bruno, Mirado, Quentin

## Scripts that we use
__run.sh__: Main file. Sets up everything to launch an instance. This is the file you run on your computer after having correctly configured the aws credentials (to be able to launch instances)<br>

__setupInstance.sh__: This script runs on the instance at initialization. We pass it through the --user-data when launching the instance. It installs docker, builds our custom docker image and launches a docker container with the image. After the container is done running, it recovers the result files from it. <br>

__Dockerfile__: File that we use to build our custom docker image. It builds an ubuntu focal image with pyspark and hadoop installed. When the container using this image is run, docker-run.sh is launched on the container.<br>

__docker-run.sh__: Executes the hadoop vs Linux, hadoop Vs Spark and the solution to the social network problem. <br>

To automatically launch everything run ./run.sh on your PC<br>
Be sur to have your aws credentials set up<br>
The results will be available on the running instance inside /var/log