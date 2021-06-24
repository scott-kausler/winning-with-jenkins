# winning-with-jenkins

Demo Repo Used to Demonstrate an Idealized Jenkins Deployment building a branch from GitHub.

## Presentation
The companion presentation is[here](https://docs.google.com/presentation/d/16tdw1kBzsul6Y0bMVis7S3pFMDsvtAY6OHvGNWcZ3n8/edit?usp=sharing).


## Setup
**Step 1** Install [docker desktop](https://www.docker.com/products/docker-desktop), [terraform](https://www.terraform.io/downloads.html), and make.
**Step 2** Enable kubernetes for docker desktop and give it a sensible amount of resources (80% of your system resources should be fine).
**Step 3** Fork [this repo](https://github.com/scott-kausler/winning-with-jenkins) or ask for collaberator access.
**Step 4** Fill out the fields in .env.example and save as .env.
**Step 5** Run `make all TF_COMMAND=apply` to create the jenkins instance.
**Step 6** Browse to the outputed URL and play around.
**Step 7** USE TF_WORKSPACE=<workspace> to create another jenkins instace. Useful for development.

