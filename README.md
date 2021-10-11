zfin-jbrowse
JBrowse configs to replicate GBrowse functionality

This repo contains two Dockerfiles: one that generates a JBrowse
server container that serves up JBrowse with the ZFIN zebrafish
genome feature data, and one that processes the ZFIN GFF3 into
JBrowse NCList json data.

The jbrowse instances that are driven by the Dockerfile here are at
http://jbrowse_zfin_dev.alliancegenome.org/jbrowse/ (server-dev branch) and 
http://jbrowse_zfin_prod.alliancegenome.org/jbrowse/ (main branch)

JBrowse server container (Dockerfile)
=====================================

This docker file uses multistage builds, where the first stage (named 'build')
gets lots of prereqs, checks out git repos and runs the setup script. The
resulting image is over 2GB and can be deleted after building. The second
stage (called 'production') then copies files from the first stage and
results in a image that is just over 100MB.

Also, note the change to the initial parent image: there is now a jbrowse-buildenv
image at docker hub.

Finally, a short note about how this JBrowse instance is configured to work:
This instance is served up by nginx and only the configuration files and
javascript files are served from here.  All of the data are stored in an AWS
S3 bucket.  This separation makes development and production issues easier
(in my opinion)

GFF3 Processor container (Dockerfile.processgff)
================================================

Note that for the upload command to work, the AWS access key and the AWS
secret key must supplied as environment variables called AWS_ACCESS_KEY and
AWS_SECRET_KEY.

Example invocation:

    docker build --no-cache -f Dockerfile.processgff -t test-gff .
    docker run --rm -e "AWS_ACCESS_KEY=<AWSACCESS>" -e "AWS_SECRET_KEY=<AWSSECRET>" test-gff

The script "simple-command.sh" also allows specifying what S3 bucket to use
via an environment variable called AWS_S3_BUCKET but the default is agrjbrowse, the
Alliance bucket for jbrowse data.  It also assumes the path is /mod-jbrowses/zfin,
which is what the trackList.json (JBrowse's track config file) assumes as well.
So, if you want to use a different bucket or path, it needs to be changed both in the
simple-command.sh script as well as in /jbrowse/data/trackList.json file (basically,
all of the urlTemplate entries for NCList tracks).

Obviously the simple-command.sh processing script could and probably should be
generalized to use a config file to control what gets processed, but since
the zfin JBrowse instance is currently pretty simple, there isn't much need to do that.

Also note that this image only processes GFF files into NCList json and does
not deal with processing FASTA data (since it changes relatively infrequently,
that is the sort of thing that ought to be done "by hand").  It also doesn't deal
with any other file types like BigWig or VCF.

