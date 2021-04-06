#!bin/sh

cd /jbrowse

wget http://zfin.org/downloads/E_antibody.gff3; bin/flatfile-to-json.pl --gff E_antibody.gff3 --type protein_coding_gene --key "ZFIN Genes with Antibody Data" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Antibody Data" --compress; bin/generate-names.pl --compress
rm E_antibody.gff3

wget http://zfin.org/downloads/E_phenotype.gff3; bin/flatfile-to-json.pl --gff E_phenotype.gff3 --type protein_coding_gene,lincRNA_gene,lncRNA_gene --key "ZFIN Genes with Phenotype" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Phenotype" --compress
rm E_phenotype.gff3

wget http://zfin.org/downloads/E_expression.gff3; bin/flatfile-to-json.pl --gff E_expression.gff3 --type lincRNA_gene,protein_coding_gene,pseudogene --key "ZFIN Genes with Expression" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Expression" --compress
rm E_expression.gff3


#the upload_to_S3.pl script is in the agr_jbrowse_config repo
#this command is run in a jbrowse/data directory
/agr_jbrowse_config/scripts/upload_to_S3.pl --bucket agrjbrowse --local data --remote MOD-jbrowses/zfin --skipseq --awsaccess $1 --awssecret $2

# s3://agrjbrowse/MOD-jbrowses/zfin/

