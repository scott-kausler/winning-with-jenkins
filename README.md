# winning-with-jenkins
Demo Repo Used to Demonstrate an Idealized Jenkins Deployment building a branch from GitHub.

## Setup
**Step 1** Install [docker desktop](https://www.docker.com/products/docker-desktop), [terraform](https://www.terraform.io/downloads.html), and make
**Step 2** Enable kubernetes for docker desktop and give it a sensible amount of resources (80% of your system resources should be fine).
**Step 3** Fork [this repo](https://github.com/scott-kausler/winning-with-jenkins) or ask for collaberator access
**Step 4** Fill out the fields in .env.example and save as .env
**Step 5** Run `make all TF_COMMAND=apply` to create the jenkins instance
**Step 6** Browse to http://localhost:32592/ and play around