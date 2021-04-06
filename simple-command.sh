#!bin/sh

cd /jbrowse

wget http://zfin.org/downloads/E_antibody.gff3; bin/flatfile-to-json.pl --gff E_antibody.gff3 --type protein_coding_gene --key "ZFIN Genes with Antibody Data" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Antibody Data" --compress; bin/generate-names.pl --compress


#the upload_to_S3.pl script is in the agr_jbrowse_config repo
#this command is run in a jbrowse/data directory
/agr_jbrowse_config/scripts/upload_to_S3.pl --bucket agrjbrowse --local data --remote MOD-jbrowses/zfin --skipseq --awsaccess $1 --awssecret $2

# s3://agrjbrowse/MOD-jbrowses/zfin/

